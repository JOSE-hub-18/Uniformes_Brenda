import '../../data/repositories/unidad_repository.dart';
import '../../models/models.dart';

class QrUseCase {
  final UnidadRepository unidadRepository;

  QrUseCase(this.unidadRepository);

  /// Convierte el QR a ID y busca la unidad
  Future<Unidad?> obtenerUnidad(String qr) async {
    final id = int.tryParse(qr.trim());

    // QR inválido
    if (id == null) return null;

    return await unidadRepository.obtenerPorId(id);
  }

  /// Verifica si el QR corresponde a una unidad existente
  Future<bool> existeQr(String qr) async {
    final id = int.tryParse(qr.trim());

    if (id == null) return false;

    final unidad = await unidadRepository.obtenerPorId(id);
    return unidad != null;
  }
}