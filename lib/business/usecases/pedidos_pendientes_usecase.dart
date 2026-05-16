// lib/business/usecases/pedido_pendiente_usecase.dart

import '../../models/models.dart';

import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../usecases/qr_usecase.dart';

class PedidoPendienteUseCase {

  final PedidoRepository
      _pedidoRepository;

  final UnidadRepository
      _unidadRepository;

  final VentaRepository
      _ventaRepository;

  final QrUseCase
      _qrUseCase;

  PedidoPendienteUseCase({
    required PedidoRepository
        pedidoRepository,

    required UnidadRepository
        unidadRepository,

    required VentaRepository
        ventaRepository,

    required QrUseCase
        qrUseCase,
  })  : _pedidoRepository =
            pedidoRepository,
        _unidadRepository =
            unidadRepository,
        _ventaRepository =
            ventaRepository,
        _qrUseCase =
            qrUseCase;

  Future<List<Pedido>>
      obtenerPedidosPendientes()
      async {

    final pedidos =
        await _pedidoRepository
            .obtenerTodos();

    return pedidos
        .where(
          (p) =>
              p.estado ==
              EstadoPedido
                  .pendiente,
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>>
      obtenerDetallesConInfo(
    int idPedido,
  ) async {

    return await _pedidoRepository
        .obtenerDetallesConInfo(
      idPedido,
    );
  }

  Future<List<DetallePedido>>
      obtenerDetalles(
    int idPedido,
  ) async {

    return await _pedidoRepository
        .obtenerDetalles(
      idPedido,
    );
  }

  Future<void> registrarUnidad({
    required int idDetallePedido,
    required int idUnidad,
  }) async {

    await _pedidoRepository
        .registrarUnidad(
      idDetallePedido:
          idDetallePedido,

      idUnidad: idUnidad,
    );
  }

  Future<Map<String, dynamic>?>
      registrarQrPedido({

    required int idPedido,

    required int idDetallePedido,

    required int idInventarioEsperado,

    required String qr,

    bool forzarMovimiento =
        false,
  }) async {

    final unidad =
        await _qrUseCase
            .obtenerUnidad(
      qr.trim(),
    );

    if (unidad == null) {

      throw StateError(
        'El QR no existe.',
      );
    }

    if (!unidad.activo) {

      throw StateError(
        'La unidad ya fue utilizada.',
      );
    }

    if (unidad.idInventario !=
        idInventarioEsperado) {

      throw StateError(
        'El QR escaneado no corresponde a esta prenda.',
      );
    }

    final registroExistente =
        await _pedidoRepository
            .obtenerRegistroActivoPorUnidad(
      unidad.id!,
    );

    if (registroExistente != null) {

      final mismoDetalle =
          registroExistente['id'] ==
              idDetallePedido;

      if (mismoDetalle) {
        return null;
      }

      if (!forzarMovimiento) {

        return {
          'conflicto': true,

          'detalle_anterior':
              registroExistente['id'],

          'pedido_anterior':
              registroExistente[
                  'id_pedido'],

          'cliente':
              registroExistente[
                  'nombre_cliente'],
        };
      }

      await _pedidoRepository
          .desregistrarUnidad(
        registroExistente['id'],
      );
    }

    await _pedidoRepository
        .registrarUnidad(

      idDetallePedido:
          idDetallePedido,

      idUnidad:
          unidad.id!,
    );

    return null;
  }

  Future<void> desregistrarUnidad(
    int idDetallePedido,
  ) async {

    await _pedidoRepository
        .desregistrarUnidad(
      idDetallePedido,
    );
  }

  Future<bool> pedidoCompleto(
    int idPedido,
  ) async {

    return await _pedidoRepository
        .pedidoCompleto(
      idPedido,
    );
  }

  Future<void> completarPedido(
    int idPedido,
  ) async {

    final pedido =
        await _pedidoRepository
            .obtenerPorId(
      idPedido,
    );

    if (pedido == null) {

      throw StateError(
        'Pedido no encontrado.',
      );
    }

    final completo =
        await _pedidoRepository
            .pedidoCompleto(
      idPedido,
    );

    if (!completo) {

      throw StateError(
        'Faltan prendas por registrar.',
      );
    }

    final detalles =
        await _pedidoRepository
            .obtenerDetalles(
      idPedido,
    );

    final detallesVenta =
        <DetalleVenta>[];

    for (final detalle
        in detalles) {

      if (detalle
              .idUnidadRegistrada ==
          null) {
        continue;
      }

      detallesVenta.add(

        DetalleVenta(

          idVenta:
              pedido.idVentaOrigen ??
                  0,

          idUnidad:
              detalle
                  .idUnidadRegistrada!,

          cantidad: 1,

          precioUnitario:
              detalle
                  .precioUnitario,
        ),
      );

      await _unidadRepository
          .desactivar(
        detalle
            .idUnidadRegistrada!,
      );
    }

    // Si NO existe venta origen
    // crear venta nueva

    if (pedido.idVentaOrigen ==
        null) {

      final venta = Venta(

        idUsuario:
            pedido.idUsuario,

        idOrdenOrigen:
            pedido.idOrdenOrigen,

        nombreCliente:
            pedido.nombreCliente,

        fecha:
            DateTime.now(),

        total:
            pedido.total,

        estado:
            EstadoVenta
                .completada,
      );

      await _ventaRepository
          .insertarVentaYDetalles(

        venta: venta,

        detalles:
            detallesVenta,
      );

    } else {

      // Reutilizar venta existente

      await _ventaRepository
          .insertarDetallesVenta(

        idVenta:
            pedido.idVentaOrigen!,

        detalles:
            detallesVenta,
      );
    }

    // Marcar pedido completado

    await _pedidoRepository
        .actualizarEstado(

      idPedido: idPedido,

      estado:
          EstadoPedido
              .completado,
    );
  }

  Future<bool>
      eliminarDetallePedido({
    required int idPedido,
    required int idDetallePedido,
  }) async {

    await _pedidoRepository
        .eliminarDetallePedido(
      idDetallePedido,
    );

    final restantes =
        await _pedidoRepository
            .contarDetalles(
      idPedido,
    );

    if (restantes <= 0) {

      await _pedidoRepository
          .eliminarPedidoCompleto(
        idPedido,
      );

      return true;
    }

    return false;
  }
}