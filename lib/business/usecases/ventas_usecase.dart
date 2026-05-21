// lib/business/usecases/ventas_usecase.dart

import '../../models/models.dart';

import '../../data/repositories/venta_repository.dart';

/// Caso de uso que expone las operaciones de consulta sobre el historial de ventas.
/// Actúa como intermediario entre la capa de presentación y el repositorio de ventas.
class VentasUseCase {
  final VentaRepository _ventaRepository;

  VentasUseCase({required VentaRepository ventaRepository})
    : _ventaRepository = ventaRepository;

  /// Retorna todas las ventas registradas en el sistema.
  Future<List<Venta>> obtenerVentas() async {
    return await _ventaRepository.obtenerTodas();
  }

  /// Retorna la venta correspondiente al identificador indicado.
  /// Retorna null si no existe ninguna venta con ese identificador.
  Future<Venta?> obtenerVenta(int idVenta) async {
    return await _ventaRepository.obtenerPorId(idVenta);
  }

  /// Retorna los detalles de una venta enriquecidos con información
  /// de unidad, prenda, talla y escuela para su presentación en pantalla.
  Future<List<Map<String, dynamic>>> obtenerDetallesVenta(int idVenta) async {
    return await _ventaRepository.obtenerDetallesPorVenta(idVenta);
  }
}
