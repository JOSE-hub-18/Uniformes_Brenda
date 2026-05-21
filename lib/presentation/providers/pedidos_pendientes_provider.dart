// lib/presentation/providers/pedidos_pendientes_provider.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';

import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../../business/usecases/pedidos_pendientes_usecase.dart';
import '../../business/usecases/qr_usecase.dart';

/// Provider de estado para la gestión de pedidos pendientes.
///
/// Coordina [PedidoPendienteUseCase] para cargar, registrar, desregistrar
/// y completar pedidos, notificando a los widgets suscritos ante cada cambio.
class PedidosPendientesProvider extends ChangeNotifier {
  /// Caso de uso que encapsula la lógica de negocio de pedidos pendientes.
  final PedidoPendienteUseCase _useCase;

  /// Crea una instancia de [PedidosPendientesProvider] inyectando los
  /// repositorios y el caso de uso de QR necesarios para el flujo de pedidos.
  PedidosPendientesProvider({
    required PedidoRepository pedidoRepository,

    required UnidadRepository unidadRepository,

    required VentaRepository ventaRepository,

    required QrUseCase qrUseCase,
  }) : _useCase = PedidoPendienteUseCase(
         pedidoRepository: pedidoRepository,

         unidadRepository: unidadRepository,

         ventaRepository: ventaRepository,

         qrUseCase: qrUseCase,
       );

  /// Lista de pedidos pendientes cargados desde el repositorio.
  List<Pedido> _pedidos = [];

  /// Expone la lista de pedidos pendientes a los widgets consumidores.
  List<Pedido> get pedidos => _pedidos;

  /// Lista de detalles del pedido actualmente seleccionado.
  List<Map<String, dynamic>> _detalles = [];

  /// Expone los detalles del pedido seleccionado a los widgets consumidores.
  List<Map<String, dynamic>> get detalles => _detalles;

  /// Indica si hay una operación asíncrona en curso.
  bool _cargando = false;

  /// Expone el estado de carga a los widgets consumidores.
  bool get cargando => _cargando;

  /// Mensaje del último error ocurrido. Null si no hay error activo.
  String? error;

  /// Carga la lista de pedidos pendientes desde [PedidoPendienteUseCase].
  ///
  /// Activa el indicador de carga durante la operación y lo desactiva al finalizar.
  /// En caso de error, almacena el mensaje en [error].
  Future<void> cargarPedidos() async {
    _cargando = true;

    notifyListeners();

    try {
      _pedidos = await _useCase.obtenerPedidosPendientes();

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }

  /// Carga los detalles del pedido identificado por [idPedido].
  ///
  /// Incluye información enriquecida de cada línea de detalle.
  /// Activa el indicador de carga durante la operación.
  Future<void> cargarDetalles(int idPedido) async {
    _cargando = true;

    notifyListeners();

    try {
      _detalles = await _useCase.obtenerDetallesConInfo(idPedido);

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }

  /// Registra un QR escaneado contra un detalle de pedido específico.
  ///
  /// Retorna un mapa con información del conflicto si la unidad escaneada
  /// no corresponde al inventario esperado, o null si el registro fue exitoso.
  /// El parámetro [forzarMovimiento] permite ignorar conflictos de inventario.
  /// Recarga los detalles del pedido al finalizar la operación.
  Future<Map<String, dynamic>?> registrarQrPedido({
    required int idPedido,

    required int idDetallePedido,

    required int idInventarioEsperado,

    required String qr,

    bool forzarMovimiento = false,
  }) async {
    _cargando = true;

    notifyListeners();

    try {
      final conflicto = await _useCase.registrarQrPedido(
        idPedido: idPedido,

        idDetallePedido: idDetallePedido,

        idInventarioEsperado: idInventarioEsperado,

        qr: qr,

        forzarMovimiento: forzarMovimiento,
      );

      await cargarDetalles(idPedido);

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

  /// Desregistra la unidad asociada a un detalle de pedido, revirtiendo su registro.
  ///
  /// Recarga los detalles del pedido al finalizar.
  /// Propaga la excepción al caller en caso de error.
  Future<void> desregistrarUnidad({
    required int idPedido,
    required int idDetallePedido,
  }) async {
    _cargando = true;

    notifyListeners();

    try {
      await _useCase.desregistrarUnidad(idDetallePedido);

      await cargarDetalles(idPedido);

      error = null;
    } catch (e) {
      error = e.toString();

      rethrow;
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }

  /// Elimina un detalle de pedido y recarga el estado del provider.
  ///
  /// Retorna true si el pedido completo fue eliminado como consecuencia
  /// de eliminar su último detalle, en cuyo caso limpia [_detalles].
  /// Retorna false si el pedido aún tiene otros detalles pendientes.
  Future<bool> eliminarDetallePedido({
    required int idPedido,
    required int idDetallePedido,
  }) async {
    _cargando = true;

    notifyListeners();

    try {
      final pedidoEliminado = await _useCase.eliminarDetallePedido(
        idPedido: idPedido,

        idDetallePedido: idDetallePedido,
      );

      // Recargar pedidos reales
      await cargarPedidos();

      // Pedido completo eliminado: se limpian los detalles en memoria.
      if (pedidoEliminado) {
        _detalles = [];

        notifyListeners();

        return true;
      }

      // Recargar detalles reales del pedido que aún persiste.
      await cargarDetalles(idPedido);

      return false;
    } catch (e) {
      error = e.toString();

      rethrow;
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }

  /// Verifica si todos los detalles del pedido identificado por [idPedido]
  /// han sido registrados con QR.
  ///
  /// Retorna true si el pedido está listo para ser completado.
  Future<bool> pedidoCompleto(int idPedido) async {
    return await _useCase.pedidoCompleto(idPedido);
  }

  /// Marca el pedido como completado y recarga la lista de pedidos pendientes.
  ///
  /// Limpia [_detalles] al finalizar ya que el pedido deja de estar pendiente.
  /// Propaga la excepción al caller en caso de error.
  Future<void> completarPedido(int idPedido) async {
    _cargando = true;

    notifyListeners();

    try {
      await _useCase.completarPedido(idPedido);

      // Recargar lista real de pedidos pendientes tras completar.
      await cargarPedidos();

      // Limpiar detalles del pedido completado.
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
