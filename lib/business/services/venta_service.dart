// lib/business/services/venta_service.dart

import '../../data/repositories/venta_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../models/models.dart';

class VentaService {
  final VentaRepository ventaRepo;
  final UnidadRepository unidadRepo;

  VentaService({
    required this.ventaRepo,
    required this.unidadRepo,
  });

  // Crea una venta completa: guarda la venta y sus detalles,
  // y marca las unidades como vendidas
  Future<int> crearVenta({
    required Venta venta,
    required List<DetalleVenta> detalles,
  }) async {

    final idVenta = await ventaRepo.insertarVentaYDetalles(
      venta: venta,
      detalles: detalles,
    );

    for (final d in detalles) {
      await unidadRepo.desactivar(d.idUnidad);
    }

    return idVenta;
  }

  // Cancela una venta: cambia el estado y regresa las unidades al inventario
  Future<void> cancelarVenta(int idVenta) async {

    final detalles = await ventaRepo.obtenerDetallesPorVenta(idVenta);

    await ventaRepo.actualizarEstadoCancelado(idVenta);

    for (final d in detalles) {
      await unidadRepo.reactivar(d.idUnidad);
    }
  }
}