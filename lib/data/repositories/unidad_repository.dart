import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class UnidadRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE — inserta N unidades nuevas, retorna los IDs generados 
  Future<List<int>> insertarUnidades(int idInventario, int cantidad) async {
    final db = await _db;
    final ids = <int>[];

    await db.transaction((txn) async {
      for (int i = 0; i < cantidad; i++) {
        final id = await txn.insert(
          'unidades',
          {'id_inventario': idInventario, 'activo': 1},
        );
        ids.add(id);
      }
    });

    return ids;
  }

  // READ
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

  Future<List<Unidad>> obtenerPorInventario(int idInventario) async {
    final db = await _db;
    final maps = await db.query(
      'unidades',
      where: 'id_inventario = ? AND activo = 1',
      whereArgs: [idInventario],
    );
    return maps.map((m) => Unidad.fromMap(m)).toList();
  }

  // UPDATE 
  Future<int> desactivar(int id) async {
    final db = await _db;
    return await db.update(
      'unidades',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE —
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'unidades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}