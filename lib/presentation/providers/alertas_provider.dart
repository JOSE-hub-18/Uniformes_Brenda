// lib/presentation/providers/alertas_provider.dart

import 'package:flutter/material.dart';

import '../../business/usecases/alertas_stock_usecase.dart';

class AlertasProvider
    extends ChangeNotifier {

  final AlertasStockUseCase
      _useCase;

  AlertasProvider({
    required AlertasStockUseCase
        useCase,
  }) : _useCase = useCase;

  bool _cargando = false;

  bool get cargando =>
      _cargando;

  List<AlertaStock>
      _agotados = [];

  List<AlertaStock>
      _criticos = [];

  List<AlertaStock>
      get agotados =>
          _agotados;

  List<AlertaStock>
      get criticos =>
          _criticos;

  bool get hayAlertas =>

      _agotados.isNotEmpty ||

      _criticos.isNotEmpty;

  int get totalAlertas =>

      _agotados.length +

      _criticos.length;

  // Todas juntas
  // agotados primero

  List<AlertaStock>
      get todas => [

            ..._agotados,

            ..._criticos,
          ];

  // Cargar alertas

  Future<void>
      cargarAlertas()
      async {

    _cargando = true;

    notifyListeners();

    try {

      final resultado =
          await _useCase
              .obtenerAlertas();

      _agotados =
          resultado.agotados;

      _criticos =
          resultado.criticos;

    } catch (e) {

      _agotados = [];

      _criticos = [];
    }

    _cargando = false;

    notifyListeners();
  }

  // Refrescar silenciosamente
  // sin loading visual

  Future<void>
      refrescar()
      async {

    try {

      final resultado =
          await _useCase
              .obtenerAlertas();

      _agotados =
          resultado.agotados;

      _criticos =
          resultado.criticos;

      notifyListeners();

    } catch (_) {}
  }

  // Limpiar memoria local

  void limpiar() {

    _agotados = [];

    _criticos = [];

    notifyListeners();
  }
}