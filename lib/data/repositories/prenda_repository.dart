import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class PrendaRepository {

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE
  Future<int> insertar(Prenda prenda) async {
    final db = await _db;
    return await db.insert(
      'prendas',
      prenda.toMap()..remove('id_prenda'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ
  Future<Prenda?> obtenerPorId(int id) async {
    final db = await _db;
    final maps = await db.query(
      'prendas',
      where: 'id_prenda = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Prenda.fromMap(maps.first);
  }

  Future<List<Prenda>> obtenerTodas() async {
    final db = await _db;
    final maps = await db.query('prendas', orderBy: 'nombre ASC');
    return maps.map((m) => Prenda.fromMap(m)).toList();
  }

  // UPDATE
  Future<int> actualizar(Prenda prenda) async {
    final db = await _db;
    return await db.update(
      'prendas',
      prenda.toMap(),
      where: 'id_prenda = ?',
      whereArgs: [prenda.idPrenda],
    );
  }

  // DELETE
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'prendas',
      where: 'id_prenda = ?',
      whereArgs: [id],
    );
  }
}