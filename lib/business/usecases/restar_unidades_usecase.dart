import '../../data/repositories/unidad_repository.dart';

enum ResultadoRestarUnidad {
  ok,
  qrInvalido,
  noExiste,
  noPertenece,
  yaDesactivada,
}

class RestarUnidadesUseCase {
  final UnidadRepository unidadRepository;

  RestarUnidadesUseCase(this.unidadRepository);

  Future<ResultadoRestarUnidad> ejecutar(
    String qr,
    int idInventario,
  ) async {
    // limpiar QR
    final match = RegExp(r'\d+').firstMatch(qr);
    final id = int.tryParse(match?.group(0) ?? '');

    if (id == null) {
      return ResultadoRestarUnidad.qrInvalido;
    }

    final unidad = await unidadRepository.obtenerPorId(id);

    if (unidad == null) {
      return ResultadoRestarUnidad.noExiste;
    }

    // VALIDACIÓN NUEVA
    if (!unidad.activo) {
      return ResultadoRestarUnidad.yaDesactivada;
    }

    final pertenece =
        await unidadRepository.pertenece(id, idInventario);

    if (!pertenece) {
      return ResultadoRestarUnidad.noPertenece;
    }

    await unidadRepository.desactivar(id);

    return ResultadoRestarUnidad.ok;
  }
}