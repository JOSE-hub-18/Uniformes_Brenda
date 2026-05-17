// lib/data/repositories/venta_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

import '../../models/models.dart';

/// Repositorio encargado de gestionar operaciones
/// relacionadas con ventas y detalles de venta.
///
/// Centraliza procesos de registro, consulta,
/// cancelación y eliminación de ventas.
class VentaRepository {

  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async =>
      await DatabaseHelper
          .instance
          .database;

  /// Inserta una venta junto con todos sus detalles asociados.
  ///
  /// La operación se ejecuta dentro de una transacción
  /// para garantizar integridad entre la tabla de ventas
  /// y detalle_venta.
  ///
  /// Retorna el identificador de la venta creada.
  Future<int> insertarVentaYDetalles({

    required Venta venta,

    required List<DetalleVenta>
        detalles,
  }) async {

    final db = await _db;

    return await db.transaction(

      (txn) async {

        // Inserta el registro principal de la venta.
        final idVenta =
            await txn.insert(

          'ventas',

          venta.toMap()
            ..remove('id'),

          conflictAlgorithm:
              ConflictAlgorithm
                  .abort,
        );

        // Inserta todos los detalles asociados
        // a la venta recién creada.
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

  /// Inserta detalles adicionales
  /// a una venta ya existente.
  ///
  /// La operación se ejecuta dentro de una transacción
  /// para mantener consistencia en inserciones múltiples.
  Future<void> insertarDetallesVenta({

    required int idVenta,

    required List<DetalleVenta>
        detalles,
  }) async {

    final db = await _db;

    await db.transaction(

      (txn) async {

        // Inserta cada detalle utilizando
        // la venta existente como referencia.
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

  /// Elimina un detalle específico de venta.
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

  /// Obtiene la cantidad de detalles asociados
  /// a una venta.
  ///
  /// Esta operación puede utilizarse para validar
  /// si una venta conserva productos relacionados.
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

  /// Cambia el estado de una venta a cancelada.
  ///
  /// La operación realiza una cancelación lógica
  /// sin eliminar el registro físicamente.
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

  /// Obtiene una venta mediante su identificador.
  ///
  /// Retorna null cuando el registro no existe.
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

  /// Obtiene todas las ventas registradas
  /// ordenadas por fecha descendente.
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

  /// Obtiene todas las ventas realizadas
  /// por un usuario específico.
  ///
  /// El resultado se ordena por fecha descendente.
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

  /// Obtiene los detalles completos asociados
  /// a una venta.
  ///
  /// La consulta integra información relacionada
  /// con inventario, escuela, prenda y talla.
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

  /// Elimina una venta mediante su identificador.
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