// lib/data/repositories/unidad_repository.dart

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class UnidadRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // Inserta varias unidades nuevas (stock)
  Future<List<int>> insertarUnidades(int idInventario, int cantidad) async {
    final db = await _db;
    final ids = <int>[];

    await db.transaction((txn) async {
      for (int i = 0; i < cantidad; i++) {
        final id = await txn.insert(
          'unidades',
          {
            'id_inventario': idInventario,
            'activo': 1,
          },
        );
        ids.add(id);
      }
    });

    return ids;
  }

  // Obtener una unidad por id
  Future<Unidad?> obtenerPorId(int id) async {
    final db = await _db;

    final maps = await db.query(
      'unidades',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Unidad.fromMap(maps.first);
  }

  // Obtener unidades activas por inventario
  Future<List<Unidad>> obtenerPorInventario(int idInventario) async {
    final db = await _db;

    final maps = await db.query(
      'unidades',
      where: 'id_inventario = ? AND activo = 1',
      whereArgs: [idInventario],
    );

    return maps.map((m) => Unidad.fromMap(m)).toList();
  }

  // Marca una unidad como vendida
  Future<int> desactivar(int id) async {
    final db = await _db;

    return await db.update(
      'unidades',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Vuelve a activar una unidad (cuando se cancela una venta)
  Future<int> reactivar(int id) async {
    final db = await _db;

    return await db.update(
      'unidades',
      {'activo': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar unidad (poco común, pero útil)
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete(
      'unidades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}