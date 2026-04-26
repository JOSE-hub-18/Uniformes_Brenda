import 'package:flutter/material.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

class RegistrarInventarioProvider extends ChangeNotifier {

  final PrendaRepository prendaRepository;
  final TallaRepository tallaRepository;
  final EscuelaRepository escuelaRepository;

  RegistrarInventarioProvider({
    required this.prendaRepository,
    required this.tallaRepository,
    required this.escuelaRepository,
  });

  List<Prenda> prendas = [];
  List<Talla> tallas = [];
  List<Escuela> escuelas = [];

  bool cargando = false;

  Future<void> cargarCatalogos() async {
    cargando = true;
    notifyListeners();

    prendas = await prendaRepository.obtenerTodas();
    tallas = await tallaRepository.obtenerTodas();
    escuelas = await escuelaRepository.obtenerTodas();

    cargando = false;
    notifyListeners();
  }

  // retorno de escuela insertada
  Future<Escuela?> agregarEscuela(String nombre) async {
    if (nombre.trim().isEmpty) return null;

    final nueva = Escuela(nombre: nombre.trim());

    final id = await escuelaRepository.insertar(nueva);

    final escuelaInsertada = Escuela(
      idEscuela: id,
      nombre: nueva.nombre,
    );

    escuelas = await escuelaRepository.obtenerTodas();
    notifyListeners();

    return escuelaInsertada;
  }
}