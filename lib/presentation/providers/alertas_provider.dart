// lib/presentation/providers/alertas_provider.dart

import 'package:flutter/material.dart';

import '../../business/usecases/alertas_stock_usecase.dart';

/// Provider de estado para la gestión de alertas de stock del inventario.
///
/// Consume [AlertasStockUseCase] para obtener los registros de inventario
/// en estado agotado o crítico, y notifica a los widgets suscritos ante
/// cualquier cambio de estado.
class AlertasProvider extends ChangeNotifier {
  /// Caso de uso encargado de obtener las alertas de stock.
  final AlertasStockUseCase _useCase;

  /// Crea una instancia de [AlertasProvider] con el [useCase] requerido.
  AlertasProvider({required AlertasStockUseCase useCase}) : _useCase = useCase;

  /// Indica si hay una operación de carga en curso.
  bool _cargando = false;

  /// Expone el estado de carga a los widgets consumidores.
  bool get cargando => _cargando;

  /// Lista de inventarios con stock en cero.
  List<AlertaStock> _agotados = [];

  /// Lista de inventarios con stock por debajo del umbral crítico.
  List<AlertaStock> _criticos = [];

  /// Expone los registros de inventario agotados.
  List<AlertaStock> get agotados => _agotados;

  /// Expone los registros de inventario en estado crítico.
  List<AlertaStock> get criticos => _criticos;

  /// Retorna true si existe al menos una alerta activa de cualquier tipo.
  bool get hayAlertas => _agotados.isNotEmpty || _criticos.isNotEmpty;

  /// Retorna el total de alertas activas sumando agotados y críticos.
  int get totalAlertas => _agotados.length + _criticos.length;

  // Todas juntas
  // agotados primero
  /// Retorna la lista unificada de alertas, con agotados antes que críticos.
  List<AlertaStock> get todas => [..._agotados, ..._criticos];

  // Cargar alertas
  /// Ejecuta [AlertasStockUseCase.obtenerAlertas] y actualiza el estado local.
  ///
  /// Activa el indicador de carga antes de la llamada y lo desactiva al terminar.
  /// En caso de error, reinicia ambas listas a vacío para evitar datos inconsistentes.
  Future<void> cargarAlertas() async {
    _cargando = true;

    notifyListeners();

    try {
      final resultado = await _useCase.obtenerAlertas();

      _agotados = resultado.agotados;

      _criticos = resultado.criticos;
    } catch (e) {
      // En caso de error se limpian las listas para evitar mostrar datos desactualizados.
      _agotados = [];

      _criticos = [];
    }

    _cargando = false;

    notifyListeners();
  }

  // Refrescar silenciosamente
  // sin loading visual
  /// Actualiza las alertas desde el caso de uso sin activar el indicador de carga.
  ///
  /// Diseñado para refrescos en segundo plano donde no se requiere feedback visual.
  /// Los errores se suprimen silenciosamente para no interrumpir la UI.
  Future<void> refrescar() async {
    try {
      final resultado = await _useCase.obtenerAlertas();

      _agotados = resultado.agotados;

      _criticos = resultado.criticos;

      notifyListeners();
    } catch (_) {}
  }

  // Limpiar memoria local
  /// Reinicia las listas de alertas a vacío y notifica a los listeners.
  ///
  /// Se utiliza al cerrar sesión o al salir de la sección de alertas.
  void limpiar() {
    _agotados = [];

    _criticos = [];

    notifyListeners();
  }
}
