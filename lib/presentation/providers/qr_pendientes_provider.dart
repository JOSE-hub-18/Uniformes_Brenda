import 'package:flutter/material.dart';

import '../../data/repositories/unidad_repository.dart';

class QrPendientesProvider
    extends ChangeNotifier {

  final UnidadRepository
      _repository;

  QrPendientesProvider({
    required UnidadRepository
        repository,
  }) : _repository =
            repository;

  List<Map<String, dynamic>>
      _pendientes = [];

  List<Map<String, dynamic>>
      get pendientes =>
          _pendientes;

  bool _cargando = false;

  bool get cargando =>
      _cargando;

  Future<void>
      cargarPendientes()
      async {

    _cargando = true;

    notifyListeners();

    try {

      _pendientes =
          await _repository
              .obtenerPendientesImpresion();

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }
}