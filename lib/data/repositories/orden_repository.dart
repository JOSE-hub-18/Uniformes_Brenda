// orden_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../../models/models.dart';

class OrdenRepository {
  Future<Database> get _db async =>
      await DatabaseHelper
          .instance.database;

  Future<int> insertar(
    Orden orden,
  ) async {
    final db = await _db;

    return await db.insert(
      'ordenes',
      orden.toMap()
        ..remove('id'),
    );
  }

  Future<Orden?> obtenerPorId(
    int id,
  ) async {
    final db = await _db;

    final maps = await db.query(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Orden.fromMap(
      maps.first,
    );
  }

  Future<List<Orden>>
      obtenerTodas() async {
    final db = await _db;

    final maps = await db.query(
      'ordenes',
      orderBy: 'fecha DESC',
    );

    return maps
        .map(
          (m) => Orden.fromMap(m),
        )
        .toList();
  }
}