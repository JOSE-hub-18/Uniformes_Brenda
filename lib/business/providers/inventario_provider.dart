import 'package:flutter/material.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../models/models.dart';

class InventarioProvider extends ChangeNotifier {
  final _inventarioRepo = InventarioRepository();
  final _escuelaRepo = EscuelaRepository();
  final _prendaRepo = PrendaRepository();

  bool _cargando = false;

  List<Escuela> _escuelas = [];
  List<Prenda> _prendas = [];

  Escuela? _escuelaSeleccionada;
  int? _idPrendaSeleccionada;

  List<Map<String, dynamic>> _itemsInventario = [];

  bool get cargando => _cargando;
  List<Escuela> get escuelas => _escuelas;
  List<Prenda> get prendas => _prendas;
  Escuela? get escuelaSeleccionada => _escuelaSeleccionada;
  int? get idPrendaSeleccionada => _idPrendaSeleccionada;
  List<Map<String, dynamic>> get itemsInventario => _itemsInventario;

  InventarioProvider() {
    _inicializarDatos();
  }

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

  Future<void> cargarInventario(int idEscuela) async {
    _cargando = true;
    notifyListeners();

    try {
      _escuelaSeleccionada =
          _escuelas.firstWhere((e) => e.idEscuela == idEscuela);

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

  Future<void> seleccionarPrenda(int? idPrenda) async {
    _idPrendaSeleccionada = idPrenda;

    if (_escuelaSeleccionada != null) {
      await cargarInventario(_escuelaSeleccionada!.idEscuela!);
    }
  }

  
  Future<void> recargarEscuelas() async {
    _escuelas = await _escuelaRepo.obtenerTodas();
    notifyListeners();
  }
}