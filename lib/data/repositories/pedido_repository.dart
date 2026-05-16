// lib/data/repositories/pedido_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../../models/models.dart';

class PedidoRepository {

  Future<Database> get _db async =>
      await DatabaseHelper.instance.database;

  Future<int> insertarPedidoYDetalles({
    required Pedido pedido,
    required List<DetallePedido> detalles,
  }) async {

    final db = await _db;

    return await db.transaction((txn) async {

      final idPedido = await txn.insert(
        'pedidos',
        {
          'id_usuario': pedido.idUsuario,

          'id_orden_origen':
              pedido.idOrdenOrigen,

          'id_venta_origen':
              pedido.idVentaOrigen,

          'nombre_cliente':
              pedido.nombreCliente,

          'fecha':
              pedido.fecha.toIso8601String(),

          'total': pedido.total,

          'estado': pedido.estado.name,
        },
      );

      for (final detalle in detalles) {

        await txn.insert(
          'detalle_pedido',
          {
            'id_pedido': idPedido,

            'id_inventario':
                detalle.idInventario,

            'id_unidad_registrada':
                detalle.idUnidadRegistrada,

            'registrado':
                detalle.registrado ? 1 : 0,

            'precio_unitario':
                detalle.precioUnitario,
          },
        );
      }

      return idPedido;
    });
  }

  Future<List<Pedido>> obtenerTodos() async {

    final db = await _db;

    final maps = await db.query(
      'pedidos',
      orderBy: 'fecha DESC',
    );

    return maps
        .map((m) => Pedido.fromMap(m))
        .toList();
  }

  Future<Pedido?> obtenerPorId(
    int idPedido,
  ) async {

    final db = await _db;

    final maps = await db.query(
      'pedidos',
      where: 'id = ?',
      whereArgs: [idPedido],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Pedido.fromMap(
      maps.first,
    );
  }

  Future<List<DetallePedido>>
      obtenerDetalles(
    int idPedido,
  ) async {

    final db = await _db;

    final maps = await db.query(
      'detalle_pedido',
      where: 'id_pedido = ?',
      whereArgs: [idPedido],
    );

    return maps
        .map(
          (m) =>
              DetallePedido.fromMap(m),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>>
      obtenerDetallesConInfo(
    int idPedido,
  ) async {

    final db = await _db;

    return await db.rawQuery('''
      SELECT

        dp.id,
        dp.id_pedido,
        dp.id_inventario,

        dp.id_unidad_registrada,

        dp.registrado,

        dp.precio_unitario,

        e.nombre AS escuela,
        p.nombre AS prenda,
        t.talla AS talla

      FROM detalle_pedido dp

      INNER JOIN inventario i
        ON i.id = dp.id_inventario

      INNER JOIN escuelas e
        ON e.id_escuela = i.id_escuela

      INNER JOIN prendas p
        ON p.id_prenda = i.id_prenda

      INNER JOIN tallas t
        ON t.id_talla = i.id_talla

      WHERE dp.id_pedido = ?

      ORDER BY p.nombre ASC
    ''', [idPedido]);
  }

  Future<int> actualizarEstado({
    required int idPedido,
    required EstadoPedido estado,
  }) async {

    final db = await _db;

    return await db.update(
      'pedidos',
      {
        'estado': estado.name,
      },
      where: 'id = ?',
      whereArgs: [idPedido],
    );
  }

  Future<int> registrarUnidad({
    required int idDetallePedido,
    required int idUnidad,
  }) async {

    final db = await _db;

    return await db.update(
      'detalle_pedido',
      {
        'id_unidad_registrada':
            idUnidad,

        'registrado': 1,
      },
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

  Future<int> desregistrarUnidad(
    int idDetallePedido,
  ) async {

    final db = await _db;

    return await db.update(
      'detalle_pedido',
      {
        'id_unidad_registrada':
            null,

        'registrado': 0,
      },
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

Future<Map<String, dynamic>?>
    obtenerRegistroActivoPorUnidad(
  int idUnidad,
) async {

  final db = await _db;

  final result =
      await db.rawQuery('''
    SELECT

      dp.id,
      dp.id_pedido,
      dp.id_inventario,
      dp.id_unidad_registrada,

      p.nombre_cliente

    FROM detalle_pedido dp

    INNER JOIN pedidos p
      ON p.id = dp.id_pedido

    WHERE dp.id_unidad_registrada = ?
    AND dp.registrado = 1

    LIMIT 1
  ''', [idUnidad]);

  if (result.isEmpty) {
    return null;
  }

  return result.first;
}
  Future<bool> pedidoCompleto(
    int idPedido,
  ) async {

    final db = await _db;

    final pendientes =
        await db.rawQuery('''
      SELECT COUNT(*) total

      FROM detalle_pedido

      WHERE id_pedido = ?
      AND registrado = 0
    ''', [idPedido]);

    final total =
        Sqflite.firstIntValue(
              pendientes,
            ) ??
            0;

    return total == 0;
  }

  Future<int> eliminarDetallePedido(
    int idDetallePedido,
  ) async {

    final db = await _db;

    return await db.delete(
      'detalle_pedido',
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

  Future<int> contarDetalles(
    int idPedido,
  ) async {

    final db = await _db;

    final result =
        await db.rawQuery('''
      SELECT COUNT(*) total

      FROM detalle_pedido

      WHERE id_pedido = ?
    ''', [idPedido]);

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  Future<void> eliminarPedidoCompleto(
    int idPedido,
  ) async {

    final db = await _db;

    await db.transaction((txn) async {

      await txn.delete(
        'detalle_pedido',
        where: 'id_pedido = ?',
        whereArgs: [idPedido],
      );

      await txn.delete(
        'pedidos',
        where: 'id = ?',
        whereArgs: [idPedido],
      );
    });
  }

  Future<int> eliminar(
    int idPedido,
  ) async {

    final db = await _db;

    return await db.delete(
      'pedidos',
      where: 'id = ?',
      whereArgs: [idPedido],
    );
  }
}