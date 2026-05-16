// lib/presentation/providers/pedidos_pendientes_provider.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';

import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../../business/usecases/pedidos_pendientes_usecase.dart';
import '../../business/usecases/qr_usecase.dart';

class PedidosPendientesProvider
    extends ChangeNotifier {

  final PedidoPendienteUseCase
      _useCase;

  PedidosPendientesProvider({
    required PedidoRepository
        pedidoRepository,

    required UnidadRepository
    unidadRepository,

required VentaRepository
    ventaRepository,

required QrUseCase
    qrUseCase,
}) : _useCase =
          PedidoPendienteUseCase(
        pedidoRepository:
            pedidoRepository,

        unidadRepository:
            unidadRepository,

        ventaRepository:
            ventaRepository,

        qrUseCase:
            qrUseCase,
      );

  List<Pedido> _pedidos = [];

  List<Pedido> get pedidos =>
      _pedidos;

  List<Map<String, dynamic>>
      _detalles = [];

  List<Map<String, dynamic>>
      get detalles => _detalles;

  bool _cargando = false;

  bool get cargando =>
      _cargando;

  String? error;

  Future<void> cargarPedidos()
      async {

    _cargando = true;

    notifyListeners();

    try {

      _pedidos =
          await _useCase
              .obtenerPedidosPendientes();

      error = null;

    } catch (e) {

      error = e.toString();

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }

  Future<void> cargarDetalles(
    int idPedido,
  ) async {

    _cargando = true;

    notifyListeners();

    try {

      _detalles =
          await _useCase
              .obtenerDetallesConInfo(
        idPedido,
      );

      error = null;

    } catch (e) {

      error = e.toString();

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>
      registrarQrPedido({

    required int idPedido,

    required int idDetallePedido,

    required int
        idInventarioEsperado,

    required String qr,

    bool forzarMovimiento =
        false,
  }) async {

    _cargando = true;

    notifyListeners();

    try {

      final conflicto =
          await _useCase
              .registrarQrPedido(

        idPedido:
            idPedido,

        idDetallePedido:
            idDetallePedido,

        idInventarioEsperado:
            idInventarioEsperado,

        qr: qr,

        forzarMovimiento:
            forzarMovimiento,
      );

      await cargarDetalles(
        idPedido,
      );

      error = null;

      return conflicto;

    } catch (e) {

      error = e.toString();

      rethrow;

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }

  Future<void> desregistrarUnidad({
    required int idPedido,
    required int idDetallePedido,
  }) async {

    _cargando = true;

    notifyListeners();

    try {

      await _useCase
          .desregistrarUnidad(
        idDetallePedido,
      );

      await cargarDetalles(
        idPedido,
      );

      error = null;

    } catch (e) {

      error = e.toString();

      rethrow;

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }

  Future<bool> eliminarDetallePedido({
    required int idPedido,
    required int idDetallePedido,
  }) async {

    _cargando = true;

    notifyListeners();

    try {

      final pedidoEliminado =
          await _useCase
              .eliminarDetallePedido(
        idPedido: idPedido,

        idDetallePedido:
            idDetallePedido,
      );

      // Recargar pedidos reales

      await cargarPedidos();

      // Pedido completo eliminado

      if (pedidoEliminado) {

        _detalles = [];

        notifyListeners();

        return true;
      }

      // Recargar detalles reales

      await cargarDetalles(
        idPedido,
      );

      return false;

    } catch (e) {

      error = e.toString();

      rethrow;

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }

  Future<bool> pedidoCompleto(
    int idPedido,
  ) async {

    return await _useCase
        .pedidoCompleto(
      idPedido,
    );
  }

  Future<void> completarPedido(
  int idPedido,
) async {

  _cargando = true;

  notifyListeners();

  try {

    await _useCase
        .completarPedido(
      idPedido,
    );

    // Recargar lista real

    await cargarPedidos();

    // Limpiar detalles

    _detalles = [];

    error = null;

  } catch (e) {

    error = e.toString();

    rethrow;

  } finally {

    _cargando = false;

    notifyListeners();
  }
}
}