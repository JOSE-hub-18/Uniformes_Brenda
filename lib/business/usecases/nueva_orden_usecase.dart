// lib/domain/usecases/nueva_orden_usecase.dart

import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/orden_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../../models/models.dart';

import 'qr_usecase.dart';

enum TipoItemOrden {
  venta,
  pedido,
}

class ItemOrden {

  final int idInventario;

  final double precioUnitario;

  final int? idUnidad;

  final TipoItemOrden tipo;

  const ItemOrden({
    required this.idInventario,
    required this.precioUnitario,
    required this.tipo,
    this.idUnidad,
  });

  bool get tieneUnidadResuelta =>
      idUnidad != null;
}

enum TipoConfirmacion {
  venta,
  pedido,
}

class NuevaOrdenResult {

  final int? idVenta;

  final int? idPedido;

  final TipoConfirmacion tipo;

  final double total;

  final int totalPrendas;

  const NuevaOrdenResult({
    this.idVenta,
    this.idPedido,
    required this.tipo,
    required this.total,
    required this.totalPrendas,
  });
}

class NuevaOrdenUseCase {

  final InventarioRepository
      _inventarioRepository;

  final UnidadRepository
      _unidadRepository;

  final VentaRepository
      _ventaRepository;

  final PedidoRepository
      _pedidoRepository;

  final OrdenRepository
      _ordenRepository;

  final QrUseCase
      _qrUseCase;

  NuevaOrdenUseCase({
    required InventarioRepository
        inventarioRepository,

    required UnidadRepository
        unidadRepository,

    required VentaRepository
        ventaRepository,

    required PedidoRepository
        pedidoRepository,

    required OrdenRepository
        ordenRepository,

    required QrUseCase
        qrUseCase,
  })  : _inventarioRepository =
            inventarioRepository,
        _unidadRepository =
            unidadRepository,
        _ventaRepository =
            ventaRepository,
        _pedidoRepository =
            pedidoRepository,
        _ordenRepository =
            ordenRepository,
        _qrUseCase =
            qrUseCase;

  Future<ItemOrden> agregarPorQr({
    required String qr,
    required List<ItemOrden>
        itemsActuales,
  }) async {

    final unidad =
        await _qrUseCase
            .obtenerUnidad(
      qr.trim(),
    );

    if (unidad == null) {

      throw StateError(
        'El QR escaneado no corresponde a ninguna unidad.',
      );
    }

    if (!unidad.activo) {

      throw StateError(
        'Esta unidad ya fue vendida o no está disponible.',
      );
    }

    final yaAgregado =
        itemsActuales.any(
      (i) =>
          i.idUnidad ==
          unidad.id,
    );

    if (yaAgregado) {

      throw StateError(
        'Esta unidad ya fue agregada a la orden.',
      );
    }

    final inventario =
        await _inventarioRepository
            .obtenerPorId(
      unidad.idInventario,
    );

    if (inventario == null) {

      throw StateError(
        'No se encontró el inventario de esta unidad.',
      );
    }

    return ItemOrden(

      idInventario:
          inventario.id!,

      precioUnitario:
          inventario.precio,

      idUnidad:
          unidad.id,

      tipo:
          TipoItemOrden.venta,
    );
  }

  Future<ItemOrden> agregarManual({
    required int idInventario,
    required List<ItemOrden>
        itemsActuales,
  }) async {

    final inventario =
        await _inventarioRepository
            .obtenerPorId(
      idInventario,
    );

    if (inventario == null) {

      throw StateError(
        'El inventario seleccionado no existe.',
      );
    }

    return ItemOrden(

      idInventario:
          idInventario,

      precioUnitario:
          inventario.precio,

      tipo:
          TipoItemOrden.pedido,
    );
  }

  Future<void> confirmarMixto({
    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,
  }) async {

    if (items.isEmpty) {

      throw StateError(
        'La orden no tiene prendas agregadas.',
      );
    }

    final orden = Orden(

      idUsuario:
          idUsuario,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),
    );

    final idOrden =
        await _ordenRepository
            .insertar(
      orden,
    );

    final ventas = items
        .where(
          (i) =>
              i.tipo ==
              TipoItemOrden
                  .venta,
        )
        .toList();

    final pedidos = items
        .where(
          (i) =>
              i.tipo ==
              TipoItemOrden
                  .pedido,
        )
        .toList();

    int? idVentaOrigen;

    if (ventas.isNotEmpty) {

      final resultadoVenta =
          await _confirmarVenta(

        items: ventas,

        idUsuario:
            idUsuario,

        nombreCliente:
            nombreCliente,

        idOrdenOrigen:
            idOrden,
      );

      idVentaOrigen =
          resultadoVenta.idVenta;
    }

    if (pedidos.isNotEmpty) {

      await _confirmarPedido(

        items: pedidos,

        idUsuario:
            idUsuario,

        nombreCliente:
            nombreCliente,

        idOrdenOrigen:
            idOrden,

        idVentaOrigen:
            idVentaOrigen,
      );
    }
  }

  Future<NuevaOrdenResult>
      _confirmarVenta({
    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,

    required int
        idOrdenOrigen,
  }) async {

    final itemsResueltos =
        await _resolverUnidades(
      items,
    );

    for (final item
        in itemsResueltos) {

      final unidad =
          await _unidadRepository
              .obtenerPorId(
        item.idUnidad!,
      );

      if (unidad == null ||
          !unidad.activo) {

        throw StateError(
          'Una unidad ya no está disponible.',
        );
      }
    }

    final total =
        _calcularTotal(
      itemsResueltos,
    );

    final venta = Venta(

      idUsuario:
          idUsuario,

      idOrdenOrigen:
          idOrdenOrigen,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),

      total:
          total,

      estado:
          EstadoVenta
              .completada,
    );

    final detalles =
        itemsResueltos
            .map(
              (item) =>
                  DetalleVenta(

                idVenta: 0,

                idUnidad:
                    item.idUnidad!,

                cantidad: 1,

                precioUnitario:
                    item
                        .precioUnitario,
              ),
            )
            .toList();

    final idVenta =
        await _ventaRepository
            .insertarVentaYDetalles(

      venta: venta,

      detalles:
          detalles,
    );

    for (final item
        in itemsResueltos) {

      await _unidadRepository
          .desactivar(
        item.idUnidad!,
      );
    }

    return NuevaOrdenResult(

      idVenta:
          idVenta,

      tipo:
          TipoConfirmacion
              .venta,

      total:
          total,

      totalPrendas:
          itemsResueltos.length,
    );
  }

  Future<NuevaOrdenResult>
      _confirmarPedido({

    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,

    required int
        idOrdenOrigen,

    required int?
        idVentaOrigen,
  }) async {

    final total =
        _calcularTotal(
      items,
    );

    final pedido = Pedido(

      idUsuario:
          idUsuario,

      idOrdenOrigen:
          idOrdenOrigen,

      idVentaOrigen:
          idVentaOrigen,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),

      total:
          total,

      estado:
          EstadoPedido
              .pendiente,
    );

    final detalles = items
        .map(
          (item) =>
              DetallePedido(

            idPedido: 0,

            idInventario:
                item.idInventario,

            idUnidadRegistrada:
                null,

            registrado:
                false,

            precioUnitario:
                item.precioUnitario,
          ),
        )
        .toList();

    final idPedido =
        await _pedidoRepository
            .insertarPedidoYDetalles(

      pedido: pedido,

      detalles:
          detalles,
    );

    return NuevaOrdenResult(

      idPedido:
          idPedido,

      tipo:
          TipoConfirmacion
              .pedido,

      total:
          total,

      totalPrendas:
          items.length,
    );
  }

  Future<List<ItemOrden>>
      _resolverUnidades(
    List<ItemOrden> items,
  ) async {

    final List<ItemOrden>
        resueltos = [];

    final Set<int>
        unidadesUsadas = items
            .where(
              (i) =>
                  i.tieneUnidadResuelta,
            )
            .map(
              (i) =>
                  i.idUnidad!,
            )
            .toSet();

    for (final item
        in items) {

      if (item
          .tieneUnidadResuelta) {

        resueltos.add(item);

        continue;
      }

      final unidadesDisponibles =
          await _unidadRepository
              .obtenerPorInventario(
        item.idInventario,
      );

      final unidad =
          unidadesDisponibles
              .firstWhere(

        (u) =>
            !unidadesUsadas
                .contains(
          u.id,
        ),

        orElse: () =>
            throw StateError(
          'No hay unidades disponibles.',
        ),
      );

      unidadesUsadas
          .add(unidad.id!);

      resueltos.add(

        ItemOrden(

          idInventario:
              item.idInventario,

          precioUnitario:
              item.precioUnitario,

          idUnidad:
              unidad.id,

          tipo:
              item.tipo,
        ),
      );
    }

    return resueltos;
  }

  double _calcularTotal(
    List<ItemOrden> items,
  ) {

    return items.fold(

      0,

      (sum, i) =>
          sum +
          i.precioUnitario,
    );
  }
}