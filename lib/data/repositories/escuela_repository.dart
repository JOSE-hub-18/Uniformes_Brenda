import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio que gestiona las operaciones de acceso a datos
/// para la tabla de escuelas.
class EscuelaRepository {

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta una nueva escuela en la base de datos.
  /// Lanza una excepción si ya existe un registro con el mismo nombre (ConflictAlgorithm.abort).
  Future<int> insertar(Escuela escuela) async {
    final db = await _db;
    return await db.insert(
      'escuelas',
      escuela.toMap()..remove('id_escuela'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Retorna la escuela con el identificador indicado.
  /// Retorna null si no existe.
  Future<Escuela?> obtenerPorId(int id) async {
    final db = await _db;
    final maps = await db.query(
      'escuelas',
      where: 'id_escuela = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Escuela.fromMap(maps.first);
  }

  /// Retorna todas las escuelas registradas, ordenadas alfabéticamente por nombre.
  Future<List<Escuela>> obtenerTodas() async {
    final db = await _db;
    final maps = await db.query('escuelas', orderBy: 'nombre ASC');
    return maps.map((m) => Escuela.fromMap(m)).toList();
  }

  /// Actualiza los datos de una escuela existente identificada por su id.
  Future<int> actualizar(Escuela escuela) async {
    final db = await _db;
    return await db.update(
      'escuelas',
      escuela.toMap(),
      where: 'id_escuela = ?',
      whereArgs: [escuela.idEscuela],
    );
  }

  /// Elimina la escuela con el identificador indicado.
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'escuelas',
      where: 'id_escuela = ?',
      whereArgs: [id],
    );
  }
}