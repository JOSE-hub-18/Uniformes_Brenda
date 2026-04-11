// lib/data/repositories/venta_repository.dart

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class VentaRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // Inserta una venta junto con sus detalles
  Future<int> insertarVentaYDetalles({
    required Venta venta,
    required List<DetalleVenta> detalles,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      final idVenta = await txn.insert(
        'ventas',
        venta.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      for (final detalle in detalles) {
        final detalleMap = detalle.toMap()
          ..remove('id')
          ..['id_venta'] = idVenta;

        await txn.insert(
          'detalle_venta',
          detalleMap,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      return idVenta;
    });
  }

  // Cambia el estado de la venta a cancelada
  Future<void> actualizarEstadoCancelado(int idVenta) async {
    final db = await _db;

    await db.update(
      'ventas',
      {'estado': EstadoVenta.cancelada.toDb()},
      where: 'id = ?',
      whereArgs: [idVenta],
    );
  }

  // Obtener una venta por id
  Future<Venta?> obtenerPorId(int id) async {
    final db = await _db;

    final maps = await db.query(
      'ventas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Venta.fromMap(maps.first);
  }

  // Listar todas las ventas
  Future<List<Venta>> obtenerTodas() async {
    final db = await _db;

    final maps = await db.query(
      'ventas',
      orderBy: 'fecha DESC',
    );

    return maps.map((m) => Venta.fromMap(m)).toList();
  }

  // Ventas por usuario
  Future<List<Venta>> obtenerPorUsuario(int idUsuario) async {
    final db = await _db;

    final maps = await db.query(
      'ventas',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha DESC',
    );

    return maps.map((m) => Venta.fromMap(m)).toList();
  }

  // Obtener detalles de una venta
  Future<List<DetalleVenta>> obtenerDetallesPorVenta(int idVenta) async {
    final db = await _db;

    final maps = await db.query(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );

    return maps.map((m) => DetalleVenta.fromMap(m)).toList();
  }

  // Eliminar venta
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete(
      'ventas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}