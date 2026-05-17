import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio encargado de gestionar las operaciones
/// CRUD relacionadas con la entidad Talla.
class TallaRepository {

  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta una nueva talla en la base de datos.
  ///
  /// El identificador primario es removido del mapa
  /// antes de la inserción para permitir autoincremento.
  ///
  /// La operación utiliza conflicto tipo abort
  /// para evitar registros duplicados o inválidos.
  Future<int> insertar(Talla talla) async {
    final db = await _db;

    return await db.insert(
      'tallas',
      talla.toMap()..remove('id_talla'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Obtiene una talla mediante su identificador.
  ///
  /// Retorna null cuando el registro no existe.
  Future<Talla?> obtenerPorId(int id) async {
    final db = await _db;

    final maps = await db.query(
      'tallas',
      where: 'id_talla = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Talla.fromMap(maps.first);
  }

  /// Obtiene todas las tallas registradas
  /// ordenadas ascendentemente por nombre de talla.
  Future<List<Talla>> obtenerTodas() async {
    final db = await _db;

    final maps = await db.query(
      'tallas',
      orderBy: 'talla ASC',
    );

    return maps
        .map((m) => Talla.fromMap(m))
        .toList();
  }

  /// Actualiza la información de una talla existente.
  ///
  /// La operación utiliza el identificador primario
  /// como criterio de actualización.
  Future<int> actualizar(Talla talla) async {
    final db = await _db;

    return await db.update(
      'tallas',
      talla.toMap(),
      where: 'id_talla = ?',
      whereArgs: [talla.idTalla],
    );
  }

  /// Elimina una talla mediante su identificador.
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete(
      'tallas',
      where: 'id_talla = ?',
      whereArgs: [id],
    );
  }
}