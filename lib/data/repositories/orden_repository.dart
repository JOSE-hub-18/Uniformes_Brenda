// orden_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio que gestiona las operaciones de acceso a datos
/// para la tabla de órdenes.
class OrdenRepository {
  Future<Database> get _db async =>
      await DatabaseHelper
          .instance.database;

  /// Inserta una nueva orden en la base de datos y retorna su identificador generado.
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

  /// Retorna la orden con el identificador indicado.
  /// Retorna null si no existe ninguna orden con ese id.
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

  /// Retorna todas las órdenes registradas, ordenadas por fecha descendente.
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