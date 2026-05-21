import 'package:flutter/material.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../models/models.dart';

/// Proveedor de estado para el módulo de inventario.
/// Gestiona la carga y filtrado de inventario por escuela y prenda,
/// así como el estado de selección activa del usuario.
/// Extiende [ChangeNotifier] para notificar cambios a los widgets suscritos.
class InventarioProvider extends ChangeNotifier {
  /// Repositorio encargado de obtener y filtrar los registros de inventario.
  final _inventarioRepo = InventarioRepository();

  /// Repositorio encargado de obtener el catálogo de escuelas.
  final _escuelaRepo = EscuelaRepository();

  /// Repositorio encargado de obtener el catálogo de prendas.
  final _prendaRepo = PrendaRepository();

  /// Indica si hay una operación asíncrona en curso.
  bool _cargando = false;

  /// Lista de escuelas disponibles cargadas al inicializar el proveedor.
  List<Escuela> _escuelas = [];

  /// Lista de prendas disponibles cargadas al inicializar el proveedor.
  List<Prenda> _prendas = [];

  /// Escuela seleccionada actualmente para filtrar el inventario.
  Escuela? _escuelaSeleccionada;

  /// Identificador de la prenda seleccionada como filtro adicional. Null si no se aplica filtro por prenda.
  int? _idPrendaSeleccionada;

  /// Lista de items del inventario resultante del filtrado aplicado.
  List<Map<String, dynamic>> _itemsInventario = [];

  bool get cargando => _cargando;
  List<Escuela> get escuelas => _escuelas;
  List<Prenda> get prendas => _prendas;
  Escuela? get escuelaSeleccionada => _escuelaSeleccionada;
  int? get idPrendaSeleccionada => _idPrendaSeleccionada;
  List<Map<String, dynamic>> get itemsInventario => _itemsInventario;

  /// Constructor que dispara la carga inicial de catálogos al instanciar el proveedor.
  InventarioProvider() {
    _inicializarDatos();
  }

  /// Carga los catálogos de escuelas y prendas necesarios para el funcionamiento del módulo.
  /// En caso de error, inicializa las listas vacías para evitar estados inconsistentes.
  Future<void> _inicializarDatos() async {
    _cargando = true;

    notifyListeners();

    try {
      _escuelas = await _escuelaRepo.obtenerTodas();

      _prendas = await _prendaRepo.obtenerTodas();

      _escuelaSeleccionada = null;
    } catch (e) {
      _escuelas = [];
      _prendas = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga el inventario filtrado por la escuela indicada y,
  /// opcionalmente, por la prenda actualmente seleccionada.
  /// Actualiza [_escuelaSeleccionada] buscando la coincidencia en el catálogo local.
  Future<void> cargarInventario(int idEscuela) async {
    _cargando = true;

    notifyListeners();

    try {
      _escuelaSeleccionada = _escuelas.firstWhere(
        (e) => e.idEscuela == idEscuela,
      );

      _itemsInventario = await _inventarioRepo.obtenerInventarioFiltrado(
        idEscuela: idEscuela,
        idPrenda: _idPrendaSeleccionada,
      );
    } catch (e) {
      _itemsInventario = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza el filtro de prenda seleccionada y recarga el inventario
  /// si hay una escuela activa. Un valor null elimina el filtro por prenda.
  Future<void> seleccionarPrenda(int? idPrenda) async {
    _idPrendaSeleccionada = idPrenda;

    if (_escuelaSeleccionada != null) {
      await cargarInventario(_escuelaSeleccionada!.idEscuela!);
    }
  }

  /// Recarga el catálogo de escuelas desde el repositorio y,
  /// si hay una escuela seleccionada, recarga también el inventario activo
  /// para reflejar cualquier cambio reciente en los datos.
  Future<void> recargarEscuelas() async {
    _escuelas = await _escuelaRepo.obtenerTodas();

    if (_escuelaSeleccionada != null) {
      await cargarInventario(_escuelaSeleccionada!.idEscuela!);
    }

    notifyListeners();
  }
}
