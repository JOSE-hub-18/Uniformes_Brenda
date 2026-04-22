import 'package:flutter/material.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/escuela_repository.dart'; 
import '../../models/models.dart';
// Asegúrate de importar tu repositorio de escuelas si lo tienes


class InventarioProvider extends ChangeNotifier {
  final _inventarioRepo = InventarioRepository();
  final _escuelaRepo = EscuelaRepository(); 

  bool _cargando = false;
  List<Escuela> _escuelas = [];
  Escuela? _escuelaSeleccionada;
  List<Map<String, dynamic>> _itemsInventario = [];

  // Getters para que la vista solo lea
  bool get cargando => _cargando;
  List<Escuela> get escuelas => _escuelas;
  Escuela? get escuelaSeleccionada => _escuelaSeleccionada;
  List<Map<String, dynamic>> get itemsInventario => _itemsInventario;

  InventarioProvider() {
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    _cargando = true;
    notifyListeners();

    try {

      _escuelas = await _escuelaRepo.obtenerTodas();

      if (!_escuelas.any((e) => e.nombre == 'CBTIS 114')) {
        _escuelas.add(Escuela(idEscuela: 1, nombre: 'CBTIS 114'));
      }
      if (!_escuelas.any((e) => e.nombre == 'Colegio de Bachilleres 9')) {
        _escuelas.add(Escuela(idEscuela: 2, nombre: 'Colegio de Bachilleres 9'));
      }

      // Si hay escuelas, seleccionamos la primera por defecto y cargamos su inventario
      if (_escuelas.isNotEmpty) {
        _escuelaSeleccionada = _escuelas.first;
        await cargarInventario(_escuelaSeleccionada!.idEscuela!);
      }
    } catch (e) {

      _escuelas = [Escuela(idEscuela: 1, nombre: 'CBTIS 114'),
        Escuela(idEscuela: 2, nombre: 'Colegio de Bachilleres 9'),];
        
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Este es el método que llama a la consulta de tu repositorio
  Future<void> cargarInventario(int idEscuela) async {
    _cargando = true;
    notifyListeners();

    try {
      // Actualizamos la escuela seleccionada
      _escuelaSeleccionada = _escuelas.firstWhere((e) => e.idEscuela == idEscuela);

      // Llamamos al método filtrado de tu archivo inventario_repository.dart
      _itemsInventario = await _inventarioRepo.obtenerInventarioFiltrado(
        idEscuela: idEscuela,
      );
    } catch (e) {
      _itemsInventario = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}