import 'package:flutter/material.dart';

import '../../data/repositories/unidad_repository.dart';

/// Provider de estado para la gestión de unidades con QR pendiente de impresión.
///
/// Consume [UnidadRepository] para obtener las unidades que han sido registradas
/// en el sistema pero cuyos QRs aún no han sido impresos físicamente.
class QrPendientesProvider extends ChangeNotifier {
  /// Repositorio de acceso a datos de unidades.
  final UnidadRepository _repository;

  /// Crea una instancia de [QrPendientesProvider] con el [repository] requerido.
  QrPendientesProvider({required UnidadRepository repository})
    : _repository = repository;

  /// Lista de unidades con QR pendiente de impresión.
  List<Map<String, dynamic>> _pendientes = [];

  /// Expone la lista de unidades pendientes a los widgets consumidores.
  List<Map<String, dynamic>> get pendientes => _pendientes;

  /// Indica si hay una operación de carga en curso.
  bool _cargando = false;

  /// Expone el estado de carga a los widgets consumidores.
  bool get cargando => _cargando;

  /// Obtiene desde [UnidadRepository] las unidades con QR pendiente de impresión.
  ///
  /// Activa el indicador de carga durante la operación y lo desactiva al finalizar,
  /// independientemente del resultado mediante el bloque finally.
  Future<void> cargarPendientes() async {
    _cargando = true;

    notifyListeners();

    try {
      _pendientes = await _repository.obtenerPendientesImpresion();
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }
}
