// lib/domain/usecases/nueva_orden_usecase.dart

import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';
import '../../models/models.dart';
import 'qr_usecase.dart';

// ── Modelo temporal de un ítem en la orden ─────────────────────────────────

/// Representa una prenda agregada a la orden antes de confirmar.
/// Puede venir de un QR (idUnidad conocido) o de selección manual
/// (idUnidad null, se resuelve al confirmar).
class ItemOrden {
  final int idInventario;
  final double precioUnitario;

  /// Conocido si fue agregado por QR. Null si fue por '+Agregar'.
  final int? idUnidad;

  const ItemOrden({
    required this.idInventario,
    required this.precioUnitario,
    this.idUnidad,
  });

  bool get tieneUnidadResuelta => idUnidad != null;
}

// ── Resultados ─────────────────────────────────────────────────────────────

enum TipoConfirmacion { venta, pedido }

class NuevaOrdenResult {
  /// ID de la venta creada (si fue confirmada como venta).
  final int? idVenta;

  /// ID del pedido creado (si fue confirmado como pedido).
  final int? idPedido;

  /// Tipo de confirmación que se aplicó.
  final TipoConfirmacion tipo;

  /// Total calculado de la orden.
  final double total;

  /// Cantidad de prendas confirmadas.
  final int totalPrendas;

  const NuevaOrdenResult({
    this.idVenta,
    this.idPedido,
    required this.tipo,
    required this.total,
    required this.totalPrendas,
  });
}

// ── UseCase ────────────────────────────────────────────────────────────────

class NuevaOrdenUseCase {
  final InventarioRepository _inventarioRepository;
  final UnidadRepository _unidadRepository;
  final VentaRepository _ventaRepository;
  final PedidoRepository _pedidoRepository;
  final QrUseCase _qrUseCase;

  NuevaOrdenUseCase({
    required InventarioRepository inventarioRepository,
    required UnidadRepository unidadRepository,
    required VentaRepository ventaRepository,
    required PedidoRepository pedidoRepository,
    required QrUseCase qrUseCase,
  })  : _inventarioRepository = inventarioRepository,
        _unidadRepository = unidadRepository,
        _ventaRepository = ventaRepository,
        _pedidoRepository = pedidoRepository,
        _qrUseCase = qrUseCase;

  // ── Agregar ítem por QR ──────────────────────────────────────────────────

  /// Escanea un QR, valida que la unidad exista y esté activa,
  /// y devuelve un [ItemOrden] listo para agregar a la lista temporal.
  /// Lanza [StateError] si el QR es inválido o la unidad no está disponible.
  Future<ItemOrden> agregarPorQr({
    required String qr,
    required List<ItemOrden> itemsActuales,
  }) async {
    final unidad = await _qrUseCase.obtenerUnidad(qr);

    if (unidad == null) {
      throw StateError('El QR escaneado no corresponde a ninguna unidad.');
    }

    if (!unidad.activo) {
      throw StateError('Esta unidad ya fue vendida o no está disponible.');
    }

    // Evitar duplicados en la lista temporal
    final yaAgregado = itemsActuales.any((i) => i.idUnidad == unidad.id);
    if (yaAgregado) {
      throw StateError('Esta unidad ya fue agregada a la orden.');
    }

    final inventario =
        await _inventarioRepository.obtenerPorId(unidad.idInventario);
    if (inventario == null) {
      throw StateError('No se encontró el inventario de esta unidad.');
    }

    return ItemOrden(
      idInventario: inventario.id!,
      precioUnitario: inventario.precio,
      idUnidad: unidad.id,
    );
  }

  // ── Agregar ítem manual (+Agregar) ───────────────────────────────────────

  /// Agrega una prenda por selección manual (sin QR).
  /// La unidad se resolverá automáticamente al confirmar la orden.
  /// Lanza [StateError] si no hay stock disponible.
  Future<ItemOrden> agregarManual({
    required int idInventario,
    required List<ItemOrden> itemsActuales,
  }) async {
    final inventario = await _inventarioRepository.obtenerPorId(idInventario);
    if (inventario == null) {
      throw StateError('El inventario seleccionado no existe.');
    }

    // Contar cuántas unidades de este inventario ya están en la lista temporal
    final unidadesReservadas = itemsActuales
        .where((i) => i.idInventario == idInventario)
        .length;

    // Verificar stock real disponible
    final stockReal =
        await _inventarioRepository.contarStock(idInventario);

    if (unidadesReservadas >= stockReal) {
      throw StateError('No hay suficiente stock disponible para esta prenda.');
    }

    return ItemOrden(
      idInventario: idInventario,
      precioUnitario: inventario.precio,
      // idUnidad null: se resuelve al confirmar
    );
  }

  // ── Confirmar orden ──────────────────────────────────────────────────────

  /// Punto de entrada principal. Delega a [confirmarVenta] o [confirmarPedido]
  /// según el [tipo] indicado.
  /// El stock solo se modifica aquí, nunca durante la selección.
  Future<NuevaOrdenResult> confirmar({
    required List<ItemOrden> items,
    required int idUsuario,
    required String? nombreCliente,
    required TipoConfirmacion tipo,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('La orden no tiene prendas agregadas.');
    }

    if (tipo == TipoConfirmacion.venta) {
      return await _confirmarVenta(
        items: items,
        idUsuario: idUsuario,
        nombreCliente: nombreCliente,
      );
    } else {
      return await _confirmarPedido(
        items: items,
        idUsuario: idUsuario,
        nombreCliente: nombreCliente,
      );
    }
  }

  // ── Confirmar como Venta ─────────────────────────────────────────────────

  /// Resuelve unidades, descuenta stock e inserta la venta con sus detalles.
  Future<NuevaOrdenResult> _confirmarVenta({
    required List<ItemOrden> items,
    required int idUsuario,
    required String? nombreCliente,
  }) async {
    final itemsResueltos = await _resolverUnidades(items);

    // Validar que todas las unidades siguen activas
    for (final item in itemsResueltos) {
      final unidad = await _unidadRepository.obtenerPorId(item.idUnidad!);
      if (unidad == null || !unidad.activo) {
        throw StateError(
          'Una de las unidades ya no está disponible. '
          'Por favor revisa la orden.',
        );
      }
    }

    final total = _calcularTotal(itemsResueltos);

    final venta = Venta(
      idUsuario: idUsuario,
      nombreCliente: nombreCliente,
      fecha: DateTime.now(),
      total: total,
      estado: EstadoVenta.completada,
    );

    final detalles = itemsResueltos
        .map((item) => DetalleVenta(
              idVenta: 0,
              idUnidad: item.idUnidad!,
              cantidad: 1,
              precioUnitario: item.precioUnitario,
            ))
        .toList();

    final idVenta = await _ventaRepository.insertarVentaYDetalles(
      venta: venta,
      detalles: detalles,
    );

    // Desactivar unidades — descuento de stock SOLO aquí
    for (final item in itemsResueltos) {
      await _unidadRepository.desactivar(item.idUnidad!);
    }

    return NuevaOrdenResult(
      idVenta: idVenta,
      tipo: TipoConfirmacion.venta,
      total: total,
      totalPrendas: itemsResueltos.length,
    );
  }

  // ── Confirmar como Pedido ────────────────────────────────────────────────

  /// Registra el pedido como pendiente usando id_inventario.
  /// NO resuelve unidades ni descuenta stock — eso ocurre al completar
  /// el pedido desde la pantalla de Pedidos Pendientes.
  Future<NuevaOrdenResult> _confirmarPedido({
    required List<ItemOrden> items,
    required int idUsuario,
    required String? nombreCliente,
  }) async {
    final total = _calcularTotal(items);

    final pedido = Pedido(
      idUsuario: idUsuario,
      nombreCliente: nombreCliente,
      fecha: DateTime.now(),
      total: total,
      estado: EstadoPedido.pendiente,
    );

    // DetallePedido usa id_inventario, NO id_unidad
    final detalles = items
        .map((item) => DetallePedido(
              idPedido: 0,
              idInventario: item.idInventario,
              cantidad: 1,
              precioUnitario: item.precioUnitario,
            ))
        .toList();

    final idPedido = await _pedidoRepository.insertarPedidoYDetalles(
      pedido: pedido,
      detalles: detalles,
    );

    return NuevaOrdenResult(
      idPedido: idPedido,
      tipo: TipoConfirmacion.pedido,
      total: total,
      totalPrendas: items.length,
    );
  }

  // ── Helpers privados ─────────────────────────────────────────────────────

  /// Resuelve las unidades de los ítems agregados manualmente (idUnidad null).
  Future<List<ItemOrden>> _resolverUnidades(List<ItemOrden> items) async {
    final List<ItemOrden> resueltos = [];
    final Set<int> unidadesUsadas = items
        .where((i) => i.tieneUnidadResuelta)
        .map((i) => i.idUnidad!)
        .toSet();

    for (final item in items) {
      if (item.tieneUnidadResuelta) {
        resueltos.add(item);
        continue;
      }

      final unidadesDisponibles =
          await _unidadRepository.obtenerPorInventario(item.idInventario);

      final unidad = unidadesDisponibles.firstWhere(
        (u) => !unidadesUsadas.contains(u.id),
        orElse: () => throw StateError(
          'No hay unidades disponibles para una de las prendas. '
          'El stock puede haber cambiado.',
        ),
      );

      unidadesUsadas.add(unidad.id!);
      resueltos.add(ItemOrden(
        idInventario: item.idInventario,
        precioUnitario: item.precioUnitario,
        idUnidad: unidad.id,
      ));
    }

    return resueltos;
  }

  double _calcularTotal(List<ItemOrden> items) =>
      items.fold(0, (sum, i) => sum + i.precioUnitario);
}
