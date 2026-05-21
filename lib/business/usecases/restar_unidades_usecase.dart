import '../../data/repositories/unidad_repository.dart';

/// Define los posibles resultados de intentar desactivar una unidad mediante QR.
enum ResultadoRestarUnidad {
  /// La unidad fue desactivada correctamente.
  ok,

  /// El contenido del QR no contiene un identificador numérico válido.
  qrInvalido,

  /// No existe ninguna unidad con el identificador extraído del QR.
  noExiste,

  /// La unidad existe pero no pertenece al inventario indicado.
  noPertenece,

  /// La unidad ya estaba desactivada previamente.
  yaDesactivada,
}

/// Caso de uso que gestiona la baja de una unidad física de inventario mediante escaneo QR.
/// Extrae el identificador del QR, valida la existencia y estado de la unidad,
/// verifica su pertenencia al inventario indicado y la desactiva si todas las
/// validaciones son satisfactorias.
class RestarUnidadesUseCase {
  final UnidadRepository unidadRepository;

  RestarUnidadesUseCase(this.unidadRepository);

  /// Ejecuta el proceso de desactivación de una unidad a partir de su código QR.
  /// Extrae la primera secuencia numérica del QR para obtener el identificador.
  /// Valida que la unidad exista, esté activa y pertenezca al inventario recibido
  /// antes de proceder con la desactivación.
  /// Retorna un [ResultadoRestarUnidad] que describe el resultado de la operación.
  Future<ResultadoRestarUnidad> ejecutar(String qr, int idInventario) async {
    final match = RegExp(r'\d+').firstMatch(qr);
    final id = int.tryParse(match?.group(0) ?? '');

    if (id == null) {
      return ResultadoRestarUnidad.qrInvalido;
    }

    final unidad = await unidadRepository.obtenerPorId(id);

    if (unidad == null) {
      return ResultadoRestarUnidad.noExiste;
    }

    /// Regla de negocio: una unidad ya desactivada no puede volver a restarse,
    /// ya que representa una prenda que fue vendida o dada de baja con anterioridad.
    if (!unidad.activo) {
      return ResultadoRestarUnidad.yaDesactivada;
    }

    final pertenece = await unidadRepository.pertenece(id, idInventario);

    if (!pertenece) {
      return ResultadoRestarUnidad.noPertenece;
    }

    await unidadRepository.desactivar(id);

    return ResultadoRestarUnidad.ok;
  }
}
