import 'package:flutter/material.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

/// Provider de estado para el flujo de registro de inventario.
///
/// Gestiona la carga de catálogos de prendas, tallas y escuelas,
/// y expone la operación de agregar nuevas escuelas al sistema.
class RegistrarInventarioProvider extends ChangeNotifier {
  /// Repositorio de acceso a datos de prendas.
  final PrendaRepository prendaRepository;

  /// Repositorio de acceso a datos de tallas.
  final TallaRepository tallaRepository;

  /// Repositorio de acceso a datos de escuelas.
  final EscuelaRepository escuelaRepository;

  /// Crea una instancia de [RegistrarInventarioProvider] con los repositorios requeridos.
  RegistrarInventarioProvider({
    required this.prendaRepository,
    required this.tallaRepository,
    required this.escuelaRepository,
  });

  /// Lista de prendas disponibles en el catálogo.
  List<Prenda> prendas = [];

  /// Lista de tallas disponibles en el catálogo.
  List<Talla> tallas = [];

  /// Lista de escuelas disponibles en el catálogo.
  List<Escuela> escuelas = [];

  /// Indica si hay una operación de carga en curso.
  bool cargando = false;

  /// Carga los catálogos de prendas, tallas y escuelas desde sus repositorios.
  ///
  /// Activa el indicador de carga durante la operación y lo desactiva al finalizar.
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
  /// Inserta una nueva escuela en el repositorio y actualiza la lista local.
  ///
  /// Regla de negocio: el nombre no puede estar vacío o contener solo espacios.
  /// Retorna la instancia de [Escuela] insertada con su ID asignado,
  /// o null si el nombre no es válido.
  Future<Escuela?> agregarEscuela(String nombre) async {
    if (nombre.trim().isEmpty) return null;

    final nueva = Escuela(nombre: nombre.trim());

    final id = await escuelaRepository.insertar(nueva);

    final escuelaInsertada = Escuela(idEscuela: id, nombre: nueva.nombre);

    escuelas = await escuelaRepository.obtenerTodas();
    notifyListeners();

    return escuelaInsertada;
  }
}
