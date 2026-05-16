import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../../models/models.dart';

/// Resultado del intento de registro de inventario para una talla específica.
/// Indica si la operación fue exitosa e incluye el mensaje de error en caso de fallo.
class RegistroTallaResult {
  final int idTalla;
  final String nombreTalla;
  final bool exitoso;

  /// Mensaje descriptivo del error ocurrido. Null si el registro fue exitoso.
  final String? mensajeError;

  const RegistroTallaResult({
    required this.idTalla,
    required this.nombreTalla,
    required this.exitoso,
    this.mensajeError,
  });
}

/// Resultado global del caso de uso al finalizar el registro de todas las tallas.
/// Agrupa los resultados individuales y expone conteos de éxitos y fallos.
class RegistrarInventarioResult {
  final List<RegistroTallaResult> resultados;
  final int totalExitosos;
  final int totalFallidos;

  const RegistrarInventarioResult({
    required this.resultados,
    required this.totalExitosos,
    required this.totalFallidos,
  });

  /// Retorna true si ningún registro falló.
  bool get todosExitosos => totalFallidos == 0;

  /// Retorna true si al menos un registro fue exitoso.
  bool get algunoExitoso => totalExitosos > 0;
}

/// Caso de uso que gestiona el registro de items de inventario
/// para una combinación de prenda, escuela y una o más tallas.
/// Valida la existencia de los catálogos involucrados y aplica
/// la regla de unicidad por combinación antes de insertar cada registro.
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

  /// Registra un item de inventario por cada talla seleccionada
  /// para la combinación de prenda y escuela indicadas.
  /// Valida que el precio sea mayor a cero, que se haya seleccionado
  /// al menos una talla, y que tanto la prenda como la escuela existan en el sistema.
  /// Por cada talla, verifica que no exista ya una combinación registrada
  /// antes de intentar la inserción. Los resultados individuales se acumulan
  /// y se retornan en un [RegistrarInventarioResult] con el resumen de la operación.
  Future<RegistrarInventarioResult> ejecutar({
    required int idPrenda,
    required double precio,
    required List<int> idsTallas,
    required int idEscuela,
  }) async {

    if (precio <= 0) {
      throw ArgumentError('El precio debe ser mayor a cero.');
    }

    if (idsTallas.isEmpty) {
      throw ArgumentError('Debes seleccionar al menos una talla.');
    }

    final prenda = await _prendaRepository.obtenerPorId(idPrenda);
    if (prenda == null) {
      throw StateError('La prenda seleccionada no existe.');
    }

    final escuela = await _escuelaRepository.obtenerPorId(idEscuela);
    if (escuela == null) {
      throw StateError('La escuela seleccionada no existe.');
    }

    /// Carga previa de todas las tallas requeridas para evitar
    /// consultas repetidas al repositorio dentro del ciclo de registro.
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

      /// Regla de negocio: no se permite registrar más de un item de inventario
      /// para la misma combinación de escuela, prenda y talla.
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