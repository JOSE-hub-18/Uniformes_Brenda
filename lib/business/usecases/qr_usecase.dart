import '../../data/repositories/unidad_repository.dart';
import '../../models/models.dart';

/// Caso de uso que gestiona la interpretación y validación de códigos QR
/// para la identificación de unidades físicas de inventario.
class QrUseCase {
  final UnidadRepository unidadRepository;

  QrUseCase(this.unidadRepository);

  /// Extrae el identificador numérico del contenido del QR y retorna
  /// la unidad correspondiente si existe y está activa.
  /// Utiliza una expresión regular para obtener la primera secuencia
  /// de dígitos del QR, lo que permite tolerar formatos con prefijos o sufijos de texto.
  /// Retorna null si el QR no contiene un número válido,
  /// si la unidad no existe o si está inactiva.
  Future<Unidad?> obtenerUnidad(String qr) async {
  final match = RegExp(r'\d+').firstMatch(qr);

  final id = int.tryParse(
    match?.group(0) ?? '',
  );

  if (id == null) {
    return null;
  }

  final unidad =
      await unidadRepository.obtenerPorId(id);

  if (unidad == null || !unidad.activo) {
    return null;
  }

  return unidad;
}

  /// Verifica si el contenido del QR corresponde a una unidad registrada en el sistema,
  /// independientemente de si está activa o no.
  /// Retorna false si el contenido no es un número entero válido.
  Future<bool> existeQr(String qr) async {
    final id = int.tryParse(qr.trim());

    if (id == null) return false;

    final unidad = await unidadRepository.obtenerPorId(id);
    return unidad != null;
  }
}