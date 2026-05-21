// lib/business/usecases/pedido_pendiente_usecase.dart

import '../../models/models.dart';

import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../usecases/qr_usecase.dart';

/// Caso de uso que gestiona el ciclo de vida de los pedidos en estado pendiente.
/// Cubre la consulta, el registro de unidades físicas por QR,
/// la validación de completitud y la conversión del pedido a venta al completarse.
class PedidoPendienteUseCase {
  final PedidoRepository _pedidoRepository;

  final UnidadRepository _unidadRepository;

  final VentaRepository _ventaRepository;

  final QrUseCase _qrUseCase;

  PedidoPendienteUseCase({
    required PedidoRepository pedidoRepository,

    required UnidadRepository unidadRepository,

    required VentaRepository ventaRepository,

    required QrUseCase qrUseCase,
  }) : _pedidoRepository = pedidoRepository,
       _unidadRepository = unidadRepository,
       _ventaRepository = ventaRepository,
       _qrUseCase = qrUseCase;

  /// Retorna todos los pedidos cuyo estado sea [EstadoPedido.pendiente].
  Future<List<Pedido>> obtenerPedidosPendientes() async {
    final pedidos = await _pedidoRepository.obtenerTodos();

    return pedidos.where((p) => p.estado == EstadoPedido.pendiente).toList();
  }

  /// Retorna los detalles del pedido enriquecidos con información
  /// de inventario, prenda, escuela y talla para su presentación en pantalla.
  Future<List<Map<String, dynamic>>> obtenerDetallesConInfo(
    int idPedido,
  ) async {
    return await _pedidoRepository.obtenerDetallesConInfo(idPedido);
  }

  /// Retorna los detalles del pedido como modelos [DetallePedido].
  Future<List<DetallePedido>> obtenerDetalles(int idPedido) async {
    return await _pedidoRepository.obtenerDetalles(idPedido);
  }

  /// Asocia una unidad física a un detalle de pedido específico.
  Future<void> registrarUnidad({
    required int idDetallePedido,
    required int idUnidad,
  }) async {
    await _pedidoRepository.registrarUnidad(
      idDetallePedido: idDetallePedido,

      idUnidad: idUnidad,
    );
  }

  /// Registra una unidad física en un detalle de pedido mediante escaneo QR.
  /// Valida que la unidad exista, esté activa y corresponda al inventario esperado.
  /// Si la unidad ya está asignada a otro detalle del mismo u otro pedido,
  /// retorna un mapa con los datos del conflicto para que la capa de presentación
  /// solicite confirmación al usuario antes de forzar el movimiento.
  /// Si [forzarMovimiento] es true, desregistra la asignación anterior y
  /// registra la unidad en el detalle indicado sin solicitar confirmación adicional.
  /// Retorna null si la operación se completó sin conflictos.
  Future<Map<String, dynamic>?> registrarQrPedido({
    required int idPedido,

    required int idDetallePedido,

    required int idInventarioEsperado,

    required String qr,

    bool forzarMovimiento = false,
  }) async {
    final unidad = await _qrUseCase.obtenerUnidad(qr.trim());

    if (unidad == null) {
      throw StateError('El QR no existe.');
    }

    if (!unidad.activo) {
      throw StateError('La unidad ya fue utilizada.');
    }

    /// Regla de negocio: la unidad escaneada debe pertenecer al mismo
    /// inventario que el detalle del pedido que se intenta registrar.
    if (unidad.idInventario != idInventarioEsperado) {
      throw StateError('El QR escaneado no corresponde a esta prenda.');
    }

    final registroExistente = await _pedidoRepository
        .obtenerRegistroActivoPorUnidad(unidad.id!);

    if (registroExistente != null) {
      final mismoDetalle = registroExistente['id'] == idDetallePedido;

      /// Si la unidad ya está asignada al mismo detalle, no se realiza ninguna acción.
      if (mismoDetalle) {
        return null;
      }

      /// Si la unidad está asignada a un detalle diferente y no se fuerza el movimiento,
      /// se retorna la información del conflicto para que el usuario decida.
      if (!forzarMovimiento) {
        return {
          'conflicto': true,

          'detalle_anterior': registroExistente['id'],

          'pedido_anterior': registroExistente['id_pedido'],

          'cliente': registroExistente['nombre_cliente'],
        };
      }

      await _pedidoRepository.desregistrarUnidad(registroExistente['id']);
    }

    await _pedidoRepository.registrarUnidad(
      idDetallePedido: idDetallePedido,

      idUnidad: unidad.id!,
    );

    return null;
  }

  /// Elimina la asociación de una unidad física a un detalle de pedido,
  /// dejando el detalle sin unidad registrada.
  Future<void> desregistrarUnidad(int idDetallePedido) async {
    await _pedidoRepository.desregistrarUnidad(idDetallePedido);
  }

  /// Retorna true si todos los detalles del pedido tienen una unidad física registrada.
  Future<bool> pedidoCompleto(int idPedido) async {
    return await _pedidoRepository.pedidoCompleto(idPedido);
  }

  /// Completa un pedido pendiente convirtiéndolo en venta.
  /// Verifica que el pedido exista y que todos sus detalles tengan unidad registrada.
  /// Desactiva cada unidad entregada para retirarla del stock disponible.
  /// Si el pedido proviene de una orden con venta existente, agrega los detalles
  /// a esa venta. Si no tiene venta de origen, crea una nueva venta completada.
  /// Finalmente actualiza el estado del pedido a [EstadoPedido.completado].
  Future<void> completarPedido(int idPedido) async {
    final pedido = await _pedidoRepository.obtenerPorId(idPedido);

    if (pedido == null) {
      throw StateError('Pedido no encontrado.');
    }

    final completo = await _pedidoRepository.pedidoCompleto(idPedido);

    if (!completo) {
      throw StateError('Faltan prendas por registrar.');
    }

    final detalles = await _pedidoRepository.obtenerDetalles(idPedido);

    final detallesVenta = <DetalleVenta>[];

    for (final detalle in detalles) {
      if (detalle.idUnidadRegistrada == null) {
        continue;
      }

      detallesVenta.add(
        DetalleVenta(
          idVenta: pedido.idVentaOrigen ?? 0,

          idUnidad: detalle.idUnidadRegistrada!,

          cantidad: 1,

          precioUnitario: detalle.precioUnitario,
        ),
      );

      await _unidadRepository.desactivar(detalle.idUnidadRegistrada!);
    }

    /// Si el pedido no tiene una venta de origen, se genera una nueva venta
    /// completada con los detalles de las unidades entregadas.
    if (pedido.idVentaOrigen == null) {
      final venta = Venta(
        idUsuario: pedido.idUsuario,

        idOrdenOrigen: pedido.idOrdenOrigen,

        nombreCliente: pedido.nombreCliente,

        fecha: DateTime.now(),

        total: pedido.total,

        estado: EstadoVenta.completada,
      );

      await _ventaRepository.insertarVentaYDetalles(
        venta: venta,

        detalles: detallesVenta,
      );
    } else {
      /// Si ya existe una venta de origen, los detalles se agregan a ella
      /// para mantener la trazabilidad de la orden completa.
      await _ventaRepository.insertarDetallesVenta(
        idVenta: pedido.idVentaOrigen!,

        detalles: detallesVenta,
      );
    }

    await _pedidoRepository.actualizarEstado(
      idPedido: idPedido,

      estado: EstadoPedido.completado,
    );
  }

  /// Elimina un detalle del pedido y, si era el último detalle restante,
  /// elimina también el pedido completo.
  /// Retorna true si el pedido fue eliminado por quedar sin detalles, false en caso contrario.
  Future<bool> eliminarDetallePedido({
    required int idPedido,
    required int idDetallePedido,
  }) async {
    await _pedidoRepository.eliminarDetallePedido(idDetallePedido);

    final restantes = await _pedidoRepository.contarDetalles(idPedido);

    /// Regla de negocio: un pedido sin detalles no tiene razón de existir
    /// y se elimina automáticamente.
    if (restantes <= 0) {
      await _pedidoRepository.eliminarPedidoCompleto(idPedido);

      return true;
    }

    return false;
  }
}
