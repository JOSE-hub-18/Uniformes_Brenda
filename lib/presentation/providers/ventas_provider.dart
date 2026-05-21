// lib/presentation/providers/ventas_provider.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';

import '../../data/repositories/venta_repository.dart';

import '../../business/usecases/ventas_usecase.dart';

import 'alertas_provider.dart';

/// Provider de estado para la gestión del historial de ventas.
///
/// Consume [VentasUseCase] para obtener el listado de ventas y sus detalles,
/// y coordina con [AlertasProvider] para refrescar alertas de stock
/// ante operaciones que modifiquen el inventario.
class VentasProvider extends ChangeNotifier {
  /// Caso de uso que encapsula la lógica de negocio de ventas.
  final VentasUseCase _useCase;

  /// Referencia al provider de alertas para refrescarlas ante cambios de stock.
  final AlertasProvider alertasProvider;

  /// Crea una instancia de [VentasProvider] inyectando el repositorio
  /// y el provider de alertas requeridos.
  VentasProvider({
    required VentaRepository ventaRepository,

    required this.alertasProvider,
  }) : _useCase = VentasUseCase(ventaRepository: ventaRepository);

  /// Lista de ventas cargadas desde el repositorio.
  List<Venta> _ventas = [];

  /// Expone la lista de ventas a los widgets consumidores.
  List<Venta> get ventas => _ventas;

  /// Lista de detalles de la venta actualmente seleccionada.
  List<Map<String, dynamic>> _detalles = [];

  /// Expone los detalles de la venta seleccionada a los widgets consumidores.
  List<Map<String, dynamic>> get detalles => _detalles;

  /// Indica si hay una operación asíncrona en curso.
  bool _cargando = false;

  /// Expone el estado de carga a los widgets consumidores.
  bool get cargando => _cargando;

  /// Mensaje del último error ocurrido. Null si no hay error activo.
  String? error;

  /// Carga el historial completo de ventas desde [VentasUseCase].
  ///
  /// Activa el indicador de carga durante la operación y lo desactiva al finalizar.
  /// En caso de error, almacena el mensaje en [error].
  Future<void> cargarVentas() async {
    _cargando = true;

    notifyListeners();

    try {
      _ventas = await _useCase.obtenerVentas();

      error = null;
    } catch (e) {
      error = e.toString();
    }

    _cargando = false;

    notifyListeners();
  }

  /// Carga los detalles de la venta identificada por [idVenta].
  ///
  /// Activa el indicador de carga durante la operación y lo desactiva al finalizar.
  /// En caso de error, almacena el mensaje en [error].
  Future<void> cargarDetalles(int idVenta) async {
    _cargando = true;

    notifyListeners();

    try {
      _detalles = await _useCase.obtenerDetallesVenta(idVenta);

      error = null;
    } catch (e) {
      error = e.toString();
    }

    _cargando = false;

    notifyListeners();
  }

  // Refrescar alertas manualmente
  // cuando exista devolucion,
  // cancelacion o cambios stock
  /// Refresca las alertas de stock a través de [AlertasProvider].
  ///
  /// Se invoca manualmente ante operaciones que modifiquen el inventario,
  /// como devoluciones, cancelaciones o ajustes de stock.
  Future<void> refrescarAlertas() async {
    await alertasProvider.refrescar();
  }
}
