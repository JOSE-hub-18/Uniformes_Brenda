// lib/business/providers/nueva_orden_provider.dart

import 'package:flutter/material.dart';

import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';
import '../../data/repositories/orden_repository.dart';

import '../../business/usecases/nueva_orden_usecase.dart';
import '../../business/usecases/qr_usecase.dart';

import '../../presentation/providers/alertas_provider.dart';

class NuevaOrdenProvider
    extends ChangeNotifier {

  final NuevaOrdenUseCase
      _useCase;

  final InventarioRepository
      _inventarioRepository;

  final AlertasProvider
      alertasProvider;

  NuevaOrdenProvider({

    required InventarioRepository
        inventarioRepository,

    required UnidadRepository
        unidadRepository,

    required VentaRepository
        ventaRepository,

    required PedidoRepository
        pedidoRepository,

    required OrdenRepository
        ordenRepository,

    required QrUseCase
        qrUseCase,

    required this
        .alertasProvider,

  })  : _inventarioRepository =
            inventarioRepository,

        _useCase =
            NuevaOrdenUseCase(

          inventarioRepository:
              inventarioRepository,

          unidadRepository:
              unidadRepository,

          ventaRepository:
              ventaRepository,

          pedidoRepository:
              pedidoRepository,

          ordenRepository:
              ordenRepository,

          qrUseCase:
              qrUseCase,
        );

  // Estado

  final List<ItemOrden>
      _items = [];

  List<ItemOrden>
      get items => _items;

  List<Map<String, dynamic>>
      _inventario = [];

  List<Map<String, dynamic>>
      get inventario =>
          _inventario;

  bool _cargando = false;

  bool get cargando =>
      _cargando;

  String? error;

  // Cargar inventario propio

  Future<void>
      cargarInventario()
      async {

    _inventario =
        await _inventarioRepository
            .obtenerInventarioCompleto();

    notifyListeners();
  }

  // Totales

  double get total {

    return _items.fold(

      0,

      (sum, item) =>

          sum +
              item.precioUnitario,
    );
  }

  int get totalPrendas =>

      _items.length;

  // Agregar QR = Venta

  Future<void>
      agregarQr(
    String qr,
  ) async {

    try {

      final item =
          await _useCase
              .agregarPorQr(

        qr: qr,

        itemsActuales:
            _items,
      );

      _items.add(item);

      error = null;

      notifyListeners();

    } catch (e) {

      error = e.toString();

      notifyListeners();

      rethrow;
    }
  }

  // Agregar manual = Pedido

  Future<void>
      agregarManual({

    required int
        idInventario,
  }) async {

    try {

      final item =
          await _useCase
              .agregarManual(

        idInventario:
            idInventario,

        itemsActuales:
            _items,
      );

      _items.add(item);

      error = null;

      notifyListeners();

    } catch (e) {

      error = e.toString();

      notifyListeners();

      rethrow;
    }
  }

  // Eliminar

  void eliminarItem(
    ItemOrden item,
  ) {

    _items.remove(item);

    notifyListeners();
  }

  // Limpiar

  void limpiar() {

    _items.clear();

    notifyListeners();
  }

  // Confirmar

  Future<void>
      confirmar({

    required int
        idUsuario,

    required String?
        nombreCliente,
  }) async {

    _cargando = true;

    notifyListeners();

    try {

      await _useCase
          .confirmarMixto(

        items: _items,

        idUsuario:
            idUsuario,

        nombreCliente:
            nombreCliente,
      );

      _items.clear();

      error = null;

      // refrescar alertas

      await alertasProvider
          .refrescar();

    } catch (e) {

      error = e.toString();

      rethrow;

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }
}