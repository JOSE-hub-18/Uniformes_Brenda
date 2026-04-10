import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class EscuelaRepository {

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE
  Future<int> insertar(Escuela escuela) async {
    final db = await _db;
    return await db.insert(
      'escuelas',
      escuela.toMap()..remove('id_escuela'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ
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

  Future<List<Escuela>> obtenerTodas() async {
    final db = await _db;
    final maps = await db.query('escuelas', orderBy: 'nombre ASC');
    return maps.map((m) => Escuela.fromMap(m)).toList();
  }

  // UPDATE
  Future<int> actualizar(Escuela escuela) async {
    final db = await _db;
    return await db.update(
      'escuelas',
      escuela.toMap(),
      where: 'id_escuela = ?',
      whereArgs: [escuela.idEscuela],
    );
  }

  // DELETE
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'escuelas',
      where: 'id_escuela = ?',
      whereArgs: [id],
    );
  }
}