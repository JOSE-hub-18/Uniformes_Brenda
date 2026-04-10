import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class TallaRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE
  Future<int> insertar(Talla talla) async {
    final db = await _db;
    return await db.insert(
      'tallas',
      talla.toMap()..remove('id_talla'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ
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

  Future<List<Talla>> obtenerTodas() async {
    final db = await _db;
    final maps = await db.query('tallas', orderBy: 'talla ASC');
    return maps.map((m) => Talla.fromMap(m)).toList();
  }

  // UPDATE
  Future<int> actualizar(Talla talla) async {
    final db = await _db;
    return await db.update(
      'tallas',
      talla.toMap(),
      where: 'id_talla = ?',
      whereArgs: [talla.idTalla],
    );
  }

  // DELETE
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'tallas',
      where: 'id_talla = ?',
      whereArgs: [id],
    );
  }
}