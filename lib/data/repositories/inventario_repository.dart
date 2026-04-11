// lib/data/repositories/inventario_repository.dart

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class InventarioRepository {

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // Insertar un producto en inventario
  Future<int> insertar(Inventario inventario) async {
    final db = await _db;

    return await db.insert(
      'inventario',
      inventario.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obtener por id
  Future<Inventario?> obtenerPorId(int id) async {
    final db = await _db;

    final maps = await db.query(
      'inventario',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Inventario.fromMap(maps.first);
  }

  // Obtener todos
  Future<List<Inventario>> obtenerTodos() async {
    final db = await _db;

    final maps = await db.query('inventario');

    return maps.map((m) => Inventario.fromMap(m)).toList();
  }

  // Obtener por escuela
  Future<List<Inventario>> obtenerPorEscuela(int idEscuela) async {
    final db = await _db;

    final maps = await db.query(
      'inventario',
      where: 'id_escuela = ?',
      whereArgs: [idEscuela],
    );

    return maps.map((m) => Inventario.fromMap(m)).toList();
  }

  // Obtener combinación específica
  Future<Inventario?> obtenerPorCombinacion({
    required int idEscuela,
    required int idPrenda,
    required int idTalla,
  }) async {
    final db = await _db;

    final maps = await db.query(
      'inventario',
      where: 'id_escuela = ? AND id_prenda = ? AND id_talla = ?',
      whereArgs: [idEscuela, idPrenda, idTalla],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Inventario.fromMap(maps.first);
  }

  // Actualizar
  Future<int> actualizar(Inventario inventario) async {
    final db = await _db;

    return await db.update(
      'inventario',
      inventario.toMap(),
      where: 'id = ?',
      whereArgs: [inventario.id],
    );
  }

  // Eliminar
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete(
      'inventario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Conteo de stock real
  Future<int> contarStock(int idInventario) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as total 
      FROM unidades 
      WHERE id_inventario = ? AND activo = 1
      ''',
      [idInventario],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Inventario sin stock
  Future<List<Map<String, dynamic>>> obtenerStockAgotado() async {
    final db = await _db;

    return await db.rawQuery('''
      SELECT e.nombre AS escuela, p.nombre AS prenda,
             t.talla, i.precio,
             (SELECT COUNT(*) FROM unidades u 
              WHERE u.id_inventario = i.id AND u.activo = 1) AS stock
      FROM inventario i
      JOIN escuelas e ON i.id_escuela = e.id_escuela
      JOIN prendas p ON i.id_prenda = p.id_prenda
      JOIN tallas t ON i.id_talla = t.id_talla
      WHERE (SELECT COUNT(*) FROM unidades u 
             WHERE u.id_inventario = i.id AND u.activo = 1) = 0
    ''');
  }

  // Inventario con poco stock
  Future<List<Map<String, dynamic>>> obtenerStockCritico() async {
    final db = await _db;

    return await db.rawQuery('''
      SELECT e.nombre AS escuela, p.nombre AS prenda,
             t.talla, i.precio,
             (SELECT COUNT(*) FROM unidades u 
              WHERE u.id_inventario = i.id AND u.activo = 1) AS stock
      FROM inventario i
      JOIN escuelas e ON i.id_escuela = e.id_escuela
      JOIN prendas p ON i.id_prenda = p.id_prenda
      JOIN tallas t ON i.id_talla = t.id_talla
      WHERE (SELECT COUNT(*) FROM unidades u 
             WHERE u.id_inventario = i.id AND u.activo = 1) > 0
        AND (SELECT COUNT(*) FROM unidades u 
             WHERE u.id_inventario = i.id AND u.activo = 1) <= 3
    ''');
  }

  // Filtro dinámico
  Future<List<Map<String, dynamic>>> obtenerInventarioFiltrado({
    required int idEscuela,
    int? idPrenda,
  }) async {
    final db = await _db;

    final where = idPrenda != null
        ? 'i.id_escuela = ? AND i.id_prenda = ?'
        : 'i.id_escuela = ?';

    final args = idPrenda != null
        ? [idEscuela, idPrenda]
        : [idEscuela];

    return await db.rawQuery('''
      SELECT e.nombre AS escuela, p.nombre AS prenda,
             t.talla, i.precio, i.id,
             (SELECT COUNT(*) FROM unidades u 
              WHERE u.id_inventario = i.id AND u.activo = 1) AS stock
      FROM inventario i
      JOIN escuelas e ON i.id_escuela = e.id_escuela
      JOIN prendas p ON i.id_prenda = p.id_prenda
      JOIN tallas t ON i.id_talla = t.id_talla
      WHERE $where
      ORDER BY p.nombre ASC, t.talla ASC
    ''', args);
  }
}