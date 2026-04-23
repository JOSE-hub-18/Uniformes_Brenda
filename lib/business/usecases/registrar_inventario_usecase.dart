import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

/// Resultado de intentar registrar una sola combinación (prenda + talla).
class RegistroTallaResult {
  final int idTalla;
  final String nombreTalla;
  final bool exitoso;
  final String? mensajeError;

  const RegistroTallaResult({
    required this.idTalla,
    required this.nombreTalla,
    required this.exitoso,
    this.mensajeError,
  });
}

/// Resultado global del usecase al finalizar el registro.
class RegistrarInventarioResult {
  final List<RegistroTallaResult> resultados;
  final int totalExitosos;
  final int totalFallidos;

  const RegistrarInventarioResult({
    required this.resultados,
    required this.totalExitosos,
    required this.totalFallidos,
  });

  bool get todosExitosos => totalFallidos == 0;
  bool get algunoExitoso => totalExitosos > 0;
}

class RegistrarInventarioUseCase {
  final InventarioRepository _inventarioRepository;
  final PrendaRepository _prendaRepository;
  final TallaRepository _tallaRepository;
  final EscuelaRepository _escuelaRepository;

  RegistrarInventarioUseCase({
    required InventarioRepository inventarioRepository,
    required PrendaRepository prendaRepository,
    required TallaRepository tallaRepository,
    required EscuelaRepository escuelaRepository,
  })  : _inventarioRepository = inventarioRepository,
        _prendaRepository = prendaRepository,
        _tallaRepository = tallaRepository,
        _escuelaRepository = escuelaRepository;

  /// Registra un ítem de inventario por cada talla seleccionada
  Future<RegistrarInventarioResult> ejecutar({
    required int idPrenda,
    required double precio,
    required List<int> idsTallas,
    required int idEscuela,
  }) async {
    // ── Validaciones generales ──────────────────────────────────────────────

    if (precio <= 0) {
      throw ArgumentError('El precio debe ser mayor a cero.');
    }

    if (idsTallas.isEmpty) {
      throw ArgumentError('Debes seleccionar al menos una talla.');
    }

    // Verificar que la prenda existe
    final prenda = await _prendaRepository.obtenerPorId(idPrenda);
    if (prenda == null) {
      throw StateError('La prenda seleccionada no existe.');
    }

    // Verificar que la escuela existe
    final escuela = await _escuelaRepository.obtenerPorId(idEscuela);
    if (escuela == null) {
      throw StateError('La escuela seleccionada no existe.');
    }

    // Registro por talla
    final tallasMap = <int, Talla>{};
    for (final id in idsTallas) {
      final talla = await _tallaRepository.obtenerPorId(id);
      if (talla != null) tallasMap[id] = talla;
    }

    final List<RegistroTallaResult> resultados = [];

    for (final idTalla in idsTallas) {
      final talla = tallasMap[idTalla];
      if (talla == null) {
        resultados.add(RegistroTallaResult(
          idTalla: idTalla,
          nombreTalla: 'Desconocida',
          exitoso: false,
          mensajeError: 'La talla con ID $idTalla no existe.',
        ));
        continue;
      }

      // Verificar que la combinación no esté ya registrada
      final combinacionExistente =
          await _inventarioRepository.obtenerPorCombinacion(
        idEscuela: idEscuela,
        idPrenda: idPrenda,
        idTalla: idTalla,
      );

      if (combinacionExistente != null) {
        resultados.add(RegistroTallaResult(
          idTalla: idTalla,
          nombreTalla: talla.talla,
          exitoso: false,
          mensajeError:
              'Ya existe un registro para "${prenda.nombre}" '
              'talla "${talla.talla}" en esta escuela.',
        ));
        continue;
      }

      // Insertar el nuevo registro de inventario
      try {
        final nuevoInventario = Inventario(
          idEscuela: idEscuela,
          idPrenda: idPrenda,
          idTalla: idTalla,
          precio: precio,
        );

        await _inventarioRepository.insertar(nuevoInventario);

        resultados.add(RegistroTallaResult(
          idTalla: idTalla,
          nombreTalla: talla.talla,
          exitoso: true,
        ));
      } catch (e) {
        resultados.add(RegistroTallaResult(
          idTalla: idTalla,
          nombreTalla: talla.talla,
          exitoso: false,
          mensajeError: 'Error al insertar: ${e.toString()}',
        ));
      }
    }

    final exitosos = resultados.where((r) => r.exitoso).length;
    final fallidos = resultados.where((r) => !r.exitoso).length;

    return RegistrarInventarioResult(
      resultados: resultados,
      totalExitosos: exitosos,
      totalFallidos: fallidos,
    );
  }
}