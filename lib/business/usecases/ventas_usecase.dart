// lib/business/usecases/ventas_usecase.dart

import '../../models/models.dart';

import '../../data/repositories/venta_repository.dart';

class VentasUseCase {

  final VentaRepository
      _ventaRepository;

  VentasUseCase({
    required VentaRepository
        ventaRepository,
  }) : _ventaRepository =
            ventaRepository;

  Future<List<Venta>>
      obtenerVentas() async {

    return await _ventaRepository
        .obtenerTodas();
  }

  Future<Venta?> obtenerVenta(
    int idVenta,
  ) async {

    return await _ventaRepository
        .obtenerPorId(
      idVenta,
    );
  }

  Future<List<Map<String, dynamic>>>
      obtenerDetallesVenta(
    int idVenta,
  ) async {

    return await _ventaRepository
        .obtenerDetallesPorVenta(
      idVenta,
    );
  }
}