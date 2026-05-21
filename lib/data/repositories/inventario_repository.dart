// lib/data/repositories/inventario_repository.dart

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio que gestiona las operaciones de acceso a datos
/// para la tabla de inventario y sus consultas relacionadas con stock.
class InventarioRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta un nuevo registro de inventario.
  /// Si ya existe la misma combinación de escuela, prenda y talla,
  /// la operación se ignora sin lanzar error.
  Future<int> insertar(Inventario inventario) async {
    final db = await _db;

    return await db.insert(
      'inventario',
      inventario.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Retorna el registro de inventario con el identificador indicado.
  /// Retorna null si no existe.
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

  /// Retorna todos los registros de inventario sin filtro aplicado.
  Future<List<Inventario>> obtenerTodos() async {
    final db = await _db;

    final maps = await db.query('inventario');

    return maps.map((m) => Inventario.fromMap(m)).toList();
  }

  /// Retorna todos los registros de inventario asociados a una escuela específica.
  Future<List<Inventario>> obtenerPorEscuela(int idEscuela) async {
    final db = await _db;

    final maps = await db.query(
      'inventario',
      where: 'id_escuela = ?',
      whereArgs: [idEscuela],
    );

    return maps.map((m) => Inventario.fromMap(m)).toList();
  }

  /// Busca un registro de inventario por la combinación exacta de escuela, prenda y talla.
  /// Retorna null si no existe ningún registro con esa combinación.
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

  /// Actualiza el registro de inventario identificado por su id.
  Future<int> actualizar(Inventario inventario) async {
    final db = await _db;

    return await db.update(
      'inventario',
      inventario.toMap(),
      where: 'id = ?',
      whereArgs: [inventario.id],
    );
  }

  /// Elimina el registro de inventario con el identificador indicado.
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete('inventario', where: 'id = ?', whereArgs: [id]);
  }

  /// Retorna el conteo de unidades activas asociadas a un registro de inventario.
  /// Utilizado para determinar el stock disponible en tiempo real.
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

  /// Retorna el inventario de una escuela enriquecido con nombre de prenda,
  /// talla, precio y stock actual. Permite filtrar opcionalmente por prenda.
  /// Los resultados se ordenan por nombre de prenda y talla de forma ascendente.
  Future<List<Map<String, dynamic>>> obtenerInventarioFiltrado({
    required int idEscuela,
    int? idPrenda,
  }) async {
    final db = await _db;

    final where = idPrenda != null
        ? 'i.id_escuela = ? AND i.id_prenda = ?'
        : 'i.id_escuela = ?';

    final args = idPrenda != null ? [idEscuela, idPrenda] : [idEscuela];

    return await db.rawQuery('''
      SELECT 
        e.nombre AS escuela,
        p.nombre AS prenda,
        p.id_prenda,
        t.talla,
        i.precio,
        i.id,
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

  /// Retorna el inventario completo de todas las escuelas con nombre de escuela,
  /// prenda, talla, precio y stock actual calculado por subconsulta.
  /// Ordenado por escuela, prenda y talla de forma ascendente.
  Future<List<Map<String, dynamic>>> obtenerInventarioCompleto() async {
    final db = await _db;

    final resultado = await db.rawQuery('''
    SELECT 
      e.nombre AS escuela,
      p.nombre AS prenda,
      t.talla AS talla,

      i.id AS idInventario,

      i.precio AS precio,

      (
        SELECT COUNT(*)
        FROM unidades u
        WHERE u.id_inventario = i.id
        AND u.activo = 1
      ) AS stock

    FROM inventario i

    JOIN escuelas e
      ON i.id_escuela = e.id_escuela

    JOIN prendas p
      ON i.id_prenda = p.id_prenda

    JOIN tallas t
      ON i.id_talla = t.id_talla

    ORDER BY
      e.nombre ASC,
      p.nombre ASC,
      t.talla ASC
  ''');

    return resultado;
  }

  /// Retorna los registros de inventario cuyo stock activo es igual a cero.
  /// Utilizado por [AlertasStockUseCase] para generar alertas de agotado.
  Future<List<Map<String, dynamic>>> obtenerStockAgotado() async {
    final db = await _db;

    return await db.rawQuery('''

    SELECT

      i.id,

      e.nombre AS escuela,

      p.nombre AS prenda,

      t.talla AS talla,

      i.precio,

      0 AS stock

    FROM inventario i

    JOIN escuelas e
      ON e.id_escuela =
         i.id_escuela

    JOIN prendas p
      ON p.id_prenda =
         i.id_prenda

    JOIN tallas t
      ON t.id_talla =
         i.id_talla

    WHERE (

      SELECT COUNT(*)

      FROM unidades u

      WHERE
        u.id_inventario = i.id
        AND u.activo = 1

    ) = 0

    ORDER BY
      e.nombre,
      p.nombre,
      t.talla
  ''');
  }

  /// Retorna los registros de inventario con stock activo entre 1 y 3 unidades (inclusive).
  /// Utilizado por [AlertasStockUseCase] para generar alertas de stock crítico.
  /// Los resultados se ordenan por stock ascendente para priorizar los más críticos.
  Future<List<Map<String, dynamic>>> obtenerStockCritico() async {
    final db = await _db;

    return await db.rawQuery('''

    SELECT

      i.id,

      e.nombre AS escuela,

      p.nombre AS prenda,

      t.talla AS talla,

      i.precio,

      (

        SELECT COUNT(*)

        FROM unidades u

        WHERE
          u.id_inventario = i.id
          AND u.activo = 1

      ) AS stock

    FROM inventario i

    JOIN escuelas e
      ON e.id_escuela =
         i.id_escuela

    JOIN prendas p
      ON p.id_prenda =
         i.id_prenda

    JOIN tallas t
      ON t.id_talla =
         i.id_talla

    WHERE (

      SELECT COUNT(*)

      FROM unidades u

      WHERE
        u.id_inventario = i.id
        AND u.activo = 1

    ) BETWEEN 1 AND 3

    ORDER BY
      stock ASC,
      e.nombre,
      p.nombre,
      t.talla
  ''');
  }
}
