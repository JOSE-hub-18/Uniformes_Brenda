// lib/presentation/providers/reportes_provider.dart

import 'package:flutter/material.dart';

import '../../data/repositories/reporte_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

class ReportesProvider extends ChangeNotifier {

  final ReporteRepository _repository;
  final EscuelaRepository _escuelaRepository;

  ReportesProvider({
    required ReporteRepository repository,
    required EscuelaRepository escuelaRepository,
  })  : _repository = repository,
        _escuelaRepository = escuelaRepository;

  // ─────────────────────────────────────────────────────────
  // ESTADO
  // ─────────────────────────────────────────────────────────

  bool cargando = false;

  int year = DateTime.now().year;
  int? month;
  int? idEscuelaSeleccionada;

  List<Escuela> escuelas = [];

  double totalVendido = 0;
  int cantidadVentas = 0;

  List<Map<String, dynamic>> prendasMasVendidas = [];
  List<Map<String, dynamic>> escuelasMasVentas = [];

  // ─────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────

  Future<void> inicializar() async {
    escuelas = await _escuelaRepository.obtenerTodas();
    await cargarReportes();
  }

  // ─────────────────────────────────────────────────────────
  // CARGA
  // ─────────────────────────────────────────────────────────

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

      // La lista de escuelas solo se muestra cuando no hay una escuela filtrada
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

  // ─────────────────────────────────────────────────────────
  // FILTROS
  // ─────────────────────────────────────────────────────────

  Future<void> cambiarYear(int nuevo) async {
    year = nuevo;
    await cargarReportes();
  }

  Future<void> cambiarMonth(int? nuevo) async {
    month = nuevo;
    await cargarReportes();
  }

  Future<void> cambiarEscuela(int? idEscuela) async {
    idEscuelaSeleccionada = idEscuela;
    await cargarReportes();
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────

  String get nombreMesSeleccionado {
    if (month == null) return 'Todo el año';
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return meses[month!];
  }

  String get nombreEscuelaSeleccionada {
    if (idEscuelaSeleccionada == null) return 'Todas las escuelas';
    return escuelas
        .firstWhere(
          (e) => e.idEscuela == idEscuelaSeleccionada,
          orElse: () => Escuela(idEscuela: 0, nombre: 'Todas las escuelas'),
        )
        .nombre;
  }

  double get maxTotalEscuela {
    if (escuelasMasVentas.isEmpty) return 1;
    return (escuelasMasVentas.first['total'] as num).toDouble();
  }

  double get maxCantidadPrenda {
    if (prendasMasVendidas.isEmpty) return 1;
    return (prendasMasVendidas.first['cantidad'] as num).toDouble();
  }
}