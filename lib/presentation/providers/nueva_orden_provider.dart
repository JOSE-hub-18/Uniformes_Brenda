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

/// Provider de estado para el flujo de creación de una nueva orden.
///
/// Coordina la interacción entre [NuevaOrdenUseCase], [InventarioRepository]
/// y [AlertasProvider] para gestionar los items de la orden, ya sea por
/// escaneo de QR (venta) o por selección manual (pedido).
class NuevaOrdenProvider extends ChangeNotifier {
  /// Caso de uso que encapsula la lógica de negocio para crear órdenes.
  final NuevaOrdenUseCase _useCase;

  /// Repositorio para obtener el inventario disponible.
  final InventarioRepository _inventarioRepository;

  /// Referencia al provider de alertas para refrescarlas al confirmar una orden.
  final AlertasProvider alertasProvider;

  /// Crea una instancia de [NuevaOrdenProvider] inyectando todos los repositorios
  /// y casos de uso necesarios para el flujo de nueva orden.
  NuevaOrdenProvider({
    required InventarioRepository inventarioRepository,

    required UnidadRepository unidadRepository,

    required VentaRepository ventaRepository,

    required PedidoRepository pedidoRepository,

    required OrdenRepository ordenRepository,

    required QrUseCase qrUseCase,

    required this.alertasProvider,
  }) : _inventarioRepository = inventarioRepository,

       _useCase = NuevaOrdenUseCase(
         inventarioRepository: inventarioRepository,

         unidadRepository: unidadRepository,

         ventaRepository: ventaRepository,

         pedidoRepository: pedidoRepository,

         ordenRepository: ordenRepository,

         qrUseCase: qrUseCase,
       );

  // Estado

  /// Lista de items agregados a la orden actual.
  final List<ItemOrden> _items = [];

  /// Expone los items de la orden actual como lista de solo lectura.
  List<ItemOrden> get items => _items;

  /// Lista del inventario completo disponible para selección manual.
  List<Map<String, dynamic>> _inventario = [];

  /// Expone el inventario disponible a los widgets consumidores.
  List<Map<String, dynamic>> get inventario => _inventario;

  /// Indica si hay una operación asíncrona en curso.
  bool _cargando = false;

  /// Expone el estado de carga a los widgets consumidores.
  bool get cargando => _cargando;

  /// Mensaje de error del último fallo ocurrido. Null si no hay error.
  String? error;

  // Cargar inventario propio
  /// Obtiene el inventario completo desde [InventarioRepository] y notifica a los listeners.
  Future<void> cargarInventario() async {
    _inventario = await _inventarioRepository.obtenerInventarioCompleto();

    notifyListeners();
  }

  // Totales
  /// Calcula el total monetario de la orden sumando el precio unitario de cada item.
  double get total {
    return _items.fold(0, (sum, item) => sum + item.precioUnitario);
  }

  /// Retorna el número total de prendas agregadas a la orden.
  int get totalPrendas => _items.length;

  // Agregar QR = Venta
  /// Agrega un item a la orden mediante escaneo de QR, correspondiente a una venta.
  ///
  /// Delega la validación y búsqueda del item a [NuevaOrdenUseCase.agregarPorQr].
  /// Lanza una excepción si el QR es inválido, ya fue agregado, o no pertenece al inventario.
  Future<void> agregarQr(String qr) async {
    try {
      final item = await _useCase.agregarPorQr(qr: qr, itemsActuales: _items);

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
  /// Agrega un item a la orden mediante selección manual de inventario, correspondiente a un pedido.
  ///
  /// Delega la lógica de validación a [NuevaOrdenUseCase.agregarManual].
  /// Lanza una excepción si el inventario no tiene stock disponible o ya fue agregado.
  Future<void> agregarManual({required int idInventario}) async {
    try {
      final item = await _useCase.agregarManual(
        idInventario: idInventario,

        itemsActuales: _items,
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
  /// Elimina un [ItemOrden] de la lista de items de la orden actual.
  void eliminarItem(ItemOrden item) {
    _items.remove(item);

    notifyListeners();
  }

  // Limpiar
  /// Vacía la lista de items de la orden sin persistir cambios.
  void limpiar() {
    _items.clear();

    notifyListeners();
  }

  // Confirmar
  /// Confirma y persiste la orden actual ejecutando [NuevaOrdenUseCase.confirmarMixto].
  ///
  /// Activa el indicador de carga durante la operación.
  /// Al completarse exitosamente, limpia los items y refresca [AlertasProvider].
  /// En caso de error, propaga la excepción al caller para manejo en la UI.
  Future<void> confirmar({
    required int idUsuario,

    required String? nombreCliente,
  }) async {
    _cargando = true;

    notifyListeners();

    try {
      await _useCase.confirmarMixto(
        items: _items,

        idUsuario: idUsuario,

        nombreCliente: nombreCliente,
      );

      _items.clear();

      error = null;

      // Se refrescan las alertas de stock tras confirmar la orden
      // para reflejar los cambios de inventario generados.
      await alertasProvider.refrescar();
    } catch (e) {
      error = e.toString();

      rethrow;
    } finally {
      _cargando = false;

      notifyListeners();
    }
  }
}
