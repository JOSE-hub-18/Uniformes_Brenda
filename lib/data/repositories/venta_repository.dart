import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class VentaRepository {
  // DB
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE
 // CREATE
Future<int> insertarVentaCompleta({
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

      // desactivar unidad
      await txn.update(
        'unidades',
        {'activo': 0},
        where: 'id = ?',
        whereArgs: [detalle.idUnidad],
      );
    }

    return idVenta;
  });
}
  
  // READ — Ventas
  

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

  Future<List<Venta>> obtenerTodas() async {
    final db = await _db;
    final maps = await db.query('ventas', orderBy: 'fecha DESC');
    return maps.map((m) => Venta.fromMap(m)).toList();
  }

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

  // READ — Detalles
  Future<List<DetalleVenta>> obtenerDetallesPorVenta(int idVenta) async {
    final db = await _db;
    final maps = await db.query(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    return maps.map((m) => DetalleVenta.fromMap(m)).toList();
  }

  // UPDATE 
  Future<int> cancelarVenta(int idVenta) async {
  final db = await _db;

  return await db.transaction((txn) async {
    // 1. Cambiar estado
    final rows = await txn.update(
      'ventas',
      {'estado': EstadoVenta.cancelada.toDb()},
      where: 'id = ?',
      whereArgs: [idVenta],
    );

    // 2. Reactivar unidades
    final detalles = await txn.query(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );

    for (final d in detalles) {
      await txn.update(
        'unidades',
        {'activo': 1},
        where: 'id = ?',
        whereArgs: [d['id_unidad']],
      );
    }

    return rows;
  });
}

  // DELETE 
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'ventas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> cerrarPedido(int idVenta) async {
  final db = await _db;
  return await db.update(
    'ventas',
    {'estado': EstadoVenta.completada.toDb()},
    where: 'id = ? AND estado = ?',
    whereArgs: [idVenta, EstadoVenta.pendiente.toDb()],
  );
}

Future<List<Venta>> obtenerPedidosPendientes() async {
  final db = await _db;
  final maps = await db.query(
    'ventas',
    where: 'estado = ?',
    whereArgs: [EstadoVenta.pendiente.toDb()],
    orderBy: 'fecha DESC',
  );
  return maps.map((m) => Venta.fromMap(m)).toList();
}
}

