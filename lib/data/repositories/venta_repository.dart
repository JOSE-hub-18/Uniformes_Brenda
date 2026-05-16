// lib/data/repositories/venta_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

import '../../models/models.dart';

class VentaRepository {

  Future<Database> get _db async =>
      await DatabaseHelper
          .instance
          .database;

  // Inserta una venta junto con sus detalles

  Future<int> insertarVentaYDetalles({

    required Venta venta,

    required List<DetalleVenta>
        detalles,
  }) async {

    final db = await _db;

    return await db.transaction(

      (txn) async {

        final idVenta =
            await txn.insert(

          'ventas',

          venta.toMap()
            ..remove('id'),

          conflictAlgorithm:
              ConflictAlgorithm
                  .abort,
        );

        for (final detalle
            in detalles) {

          final detalleMap =
              detalle.toMap()

                ..remove('id')

                ..['id_venta'] =
                    idVenta;

          await txn.insert(

            'detalle_venta',

            detalleMap,

            conflictAlgorithm:
                ConflictAlgorithm
                    .abort,
          );
        }

        return idVenta;
      },
    );
  }

  // Insertar detalles a una venta existente

  Future<void> insertarDetallesVenta({

    required int idVenta,

    required List<DetalleVenta>
        detalles,
  }) async {

    final db = await _db;

    await db.transaction(

      (txn) async {

        for (final detalle
            in detalles) {

          final detalleMap =
              detalle.toMap()

                ..remove('id')

                ..['id_venta'] =
                    idVenta;

          await txn.insert(

            'detalle_venta',

            detalleMap,

            conflictAlgorithm:
                ConflictAlgorithm
                    .abort,
          );
        }
      },
    );
  }

  // Eliminar detalle de venta

  Future<void>
      eliminarDetalleVenta(
    int idDetalleVenta,
  ) async {

    final db = await _db;

    await db.delete(

      'detalle_venta',

      where: 'id = ?',

      whereArgs: [
        idDetalleVenta,
      ],
    );
  }

  // Contar detalles restantes

  Future<int>
      contarDetallesVenta(
    int idVenta,
  ) async {

    final db = await _db;

    final resultado =
        await db.rawQuery(

      '''
      SELECT COUNT(*) as total
      FROM detalle_venta
      WHERE id_venta = ?
      ''',

      [
        idVenta,
      ],
    );

    return Sqflite
        .firstIntValue(
      resultado,
    )!;
  }

  // Cambia el estado de la venta a cancelada

  Future<void>
      actualizarEstadoCancelado(
    int idVenta,
  ) async {

    final db = await _db;

    await db.update(

      'ventas',

      {
        'estado':
            EstadoVenta
                .cancelada
                .toDb(),
      },

      where: 'id = ?',

      whereArgs: [
        idVenta,
      ],
    );
  }

  // Obtener una venta por id

  Future<Venta?> obtenerPorId(
    int id,
  ) async {

    final db = await _db;

    final maps =
        await db.query(

      'ventas',

      where: 'id = ?',

      whereArgs: [
        id,
      ],

      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Venta.fromMap(
      maps.first,
    );
  }

  // Listar todas las ventas

  Future<List<Venta>>
      obtenerTodas() async {

    final db = await _db;

    final maps =
        await db.query(

      'ventas',

      orderBy:
          'fecha DESC',
    );

    return maps
        .map(
          (m) =>
              Venta.fromMap(m),
        )
        .toList();
  }

  // Ventas por usuario

  Future<List<Venta>>
      obtenerPorUsuario(
    int idUsuario,
  ) async {

    final db = await _db;

    final maps =
        await db.query(

      'ventas',

      where:
          'id_usuario = ?',

      whereArgs: [
        idUsuario,
      ],

      orderBy:
          'fecha DESC',
    );

    return maps
        .map(
          (m) =>
              Venta.fromMap(m),
        )
        .toList();
  }

  // Obtener detalles completos de una venta

  Future<List<Map<String, dynamic>>>
      obtenerDetallesPorVenta(
    int idVenta,
  ) async {

    final db = await _db;

    final resultado =
        await db.rawQuery(

      '''
      SELECT

        dv.id,
        dv.id_venta,
        dv.id_unidad,
        dv.cantidad,
        dv.precio_unitario,

        u.id_inventario,

        e.nombre as escuela,
        p.nombre as prenda,
        t.talla

      FROM detalle_venta dv

      INNER JOIN unidades u
        ON u.id = dv.id_unidad

      INNER JOIN inventario i
        ON i.id = u.id_inventario

      INNER JOIN escuelas e
        ON e.id_escuela = i.id_escuela

      INNER JOIN prendas p
        ON p.id_prenda = i.id_prenda

      INNER JOIN tallas t
        ON t.id_talla = i.id_talla

      WHERE dv.id_venta = ?
      ''',

      [
        idVenta,
      ],
    );

    return resultado;
  }

  // Eliminar venta

  Future<int> eliminar(
    int id,
  ) async {

    final db = await _db;

    return await db.delete(

      'ventas',

      where: 'id = ?',

      whereArgs: [
        id,
      ],
    );
  }
}