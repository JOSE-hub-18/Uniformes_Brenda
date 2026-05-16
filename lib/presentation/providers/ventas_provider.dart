// lib/presentation/providers/ventas_provider.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';

import '../../data/repositories/venta_repository.dart';

import '../../business/usecases/ventas_usecase.dart';

import 'alertas_provider.dart';

class VentasProvider
    extends ChangeNotifier {

  final VentasUseCase
      _useCase;

  final AlertasProvider
      alertasProvider;

  VentasProvider({

    required VentaRepository
        ventaRepository,

    required this
        .alertasProvider,

  }) : _useCase =
            VentasUseCase(

          ventaRepository:
              ventaRepository,
        );

  List<Venta>
      _ventas = [];

  List<Venta>
      get ventas =>
          _ventas;

  List<Map<String, dynamic>>
      _detalles = [];

  List<Map<String, dynamic>>
      get detalles =>
          _detalles;

  bool _cargando = false;

  bool get cargando =>
      _cargando;

  String? error;

  Future<void>
      cargarVentas()
      async {

    _cargando = true;

    notifyListeners();

    try {

      _ventas =
          await _useCase
              .obtenerVentas();

      error = null;

    } catch (e) {

      error = e.toString();
    }

    _cargando = false;

    notifyListeners();
  }

  Future<void>
      cargarDetalles(
    int idVenta,
  ) async {

    _cargando = true;

    notifyListeners();

    try {

      _detalles =
          await _useCase
              .obtenerDetallesVenta(
        idVenta,
      );

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

  Future<void>
      refrescarAlertas()
      async {

    await alertasProvider
        .refrescar();
  }
}