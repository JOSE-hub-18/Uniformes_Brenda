// lib/presentation/providers/reportes_provider.dart

import 'package:flutter/material.dart';

import '../../data/repositories/reporte_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

/// Provider de estado para la pantalla de reportes de ventas.
///
/// Gestiona los filtros de año, mes y escuela, y consume [ReporteRepository]
/// para obtener los indicadores de ventas y los rankings de prendas y escuelas.
class ReportesProvider extends ChangeNotifier {
  /// Repositorio de acceso a datos de reportes de ventas.
  final ReporteRepository _repository;

  /// Repositorio de acceso a datos de escuelas para poblar el filtro.
  final EscuelaRepository _escuelaRepository;

  /// Crea una instancia de [ReportesProvider] con los repositorios requeridos.
  ReportesProvider({
    required ReporteRepository repository,
    required EscuelaRepository escuelaRepository,
  }) : _repository = repository,
       _escuelaRepository = escuelaRepository;

  // ESTADO

  /// Indica si hay una operación de carga en curso.
  bool cargando = false;

  /// Año actualmente seleccionado como filtro. Por defecto el año en curso.
  int year = DateTime.now().year;

  /// Mes actualmente seleccionado como filtro. Null indica todos los meses.
  int? month;

  /// ID de la escuela seleccionada como filtro. Null indica todas las escuelas.
  int? idEscuelaSeleccionada;

  /// Lista de escuelas disponibles para el filtro.
  List<Escuela> escuelas = [];

  /// Total monetario de ventas según los filtros activos.
  double totalVendido = 0;

  /// Cantidad de ventas realizadas según los filtros activos.
  int cantidadVentas = 0;

  /// Ranking de prendas más vendidas según los filtros activos.
  List<Map<String, dynamic>> prendasMasVendidas = [];

  /// Ranking de escuelas con más ventas.
  /// Se vacía cuando hay una escuela específica seleccionada como filtro.
  List<Map<String, dynamic>> escuelasMasVentas = [];

  // INIT

  /// Inicializa el provider cargando el catálogo de escuelas y los reportes iniciales.
  Future<void> inicializar() async {
    escuelas = await _escuelaRepository.obtenerTodas();
    await cargarReportes();
  }

  // CARGA

  /// Carga todos los indicadores de reporte aplicando los filtros activos.
  ///
  /// Regla de negocio: el ranking de escuelas solo se calcula cuando no hay
  /// una escuela específica seleccionada como filtro.
  Future<void> cargarReportes() async {
    cargando = true;
    notifyListeners();

    try {
      totalVendido = await _repository.obtenerTotalVendido(
        year: year,
        month: month,
        idEscuela: idEscuelaSeleccionada,
      );

      cantidadVentas = await _repository.obtenerCantidadVentas(
        year: year,
        month: month,
        idEscuela: idEscuelaSeleccionada,
      );

      prendasMasVendidas = await _repository.obtenerPrendasMasVendidas(
        year: year,
        month: month,
        idEscuela: idEscuelaSeleccionada,
      );

      // Regla de negocio: el ranking de escuelas se omite cuando hay un filtro
      // de escuela activo, ya que solo habría un resultado y no tendría sentido comparar.
      if (idEscuelaSeleccionada == null) {
        escuelasMasVentas = await _repository.obtenerEscuelasMasVentas(
          year: year,
          month: month,
        );
      } else {
        escuelasMasVentas = [];
      }
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // FILTROS

  /// Actualiza el filtro de año y recarga los reportes.
  Future<void> cambiarYear(int nuevo) async {
    year = nuevo;
    await cargarReportes();
  }

  /// Actualiza el filtro de mes y recarga los reportes.
  /// Null indica todos los meses del año seleccionado.
  Future<void> cambiarMonth(int? nuevo) async {
    month = nuevo;
    await cargarReportes();
  }

  /// Actualiza el filtro de escuela y recarga los reportes.
  /// Null indica todas las escuelas.
  Future<void> cambiarEscuela(int? idEscuela) async {
    idEscuelaSeleccionada = idEscuela;
    await cargarReportes();
  }

  // HELPERS

  /// Retorna el nombre del mes seleccionado, o 'Todo el año' si no hay mes activo.
  String get nombreMesSeleccionado {
    if (month == null) return 'Todo el año';
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return meses[month!];
  }

  /// Retorna el nombre de la escuela seleccionada, o 'Todas las escuelas' si no hay filtro activo.
  String get nombreEscuelaSeleccionada {
    if (idEscuelaSeleccionada == null) return 'Todas las escuelas';
    return escuelas
        .firstWhere(
          (e) => e.idEscuela == idEscuelaSeleccionada,
          orElse: () => Escuela(idEscuela: 0, nombre: 'Todas las escuelas'),
        )
        .nombre;
  }

  /// Retorna el total de ventas de la escuela con mayor venta para normalizar barras.
  /// Retorna 1 si la lista está vacía para evitar división por cero.
  double get maxTotalEscuela {
    if (escuelasMasVentas.isEmpty) return 1;
    return (escuelasMasVentas.first['total'] as num).toDouble();
  }

  /// Retorna la cantidad de la prenda más vendida para normalizar barras.
  /// Retorna 1 si la lista está vacía para evitar división por cero.
  double get maxCantidadPrenda {
    if (prendasMasVendidas.isEmpty) return 1;
    return (prendasMasVendidas.first['cantidad'] as num).toDouble();
  }
}
