// lib/data/repositories/unidad_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

import '../../models/models.dart';

class UnidadRepository {

  Future<Database> get _db async =>
      await DatabaseHelper
          .instance
          .database;

  // Inserta varias unidades nuevas

  Future<List<int>>
      insertarUnidades(
    int idInventario,
    int cantidad,
  ) async {

    final db = await _db;

    final ids = <int>[];

    await db.transaction(
      (txn) async {

        for (
          int i = 0;
          i < cantidad;
          i++
        ) {

          final id =
              await txn.insert(

            'unidades',

            {
              'id_inventario':
                  idInventario,

              'activo': 1,

              'pendiente_impresion':
                  0,
            },
          );

          ids.add(id);
        }
      },
    );

    return ids;
  }

  // Obtener una unidad por id

  Future<Unidad?> obtenerPorId(
    int id,
  ) async {

    final db = await _db;

    final maps = await db.query(

      'unidades',

      where: 'id = ?',

      whereArgs: [id],

      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Unidad.fromMap(
      maps.first,
    );
  }

  // Verificar pertenencia

  Future<bool> pertenece(
    int idUnidad,
    int idInventario,
  ) async {

    final db = await _db;

    final resultado =
        await db.query(

      'unidades',

      where:
          'id = ? AND id_inventario = ?',

      whereArgs: [
        idUnidad,
        idInventario,
      ],
    );

    return resultado
        .isNotEmpty;
  }

  // Obtener unidades activas

  Future<List<Unidad>>
      obtenerPorInventario(
    int idInventario,
  ) async {

    final db = await _db;

    final maps = await db.query(

      'unidades',

      where:
          'id_inventario = ? AND activo = 1',

      whereArgs: [
        idInventario,
      ],
    );

    return maps
        .map(
          (m) =>
              Unidad.fromMap(m),
        )
        .toList();
  }

  // Marcar como vendida

  Future<int> desactivar(
    int id,
  ) async {

    final db = await _db;

    return await db.update(

      'unidades',

      {
        'activo': 0,
      },

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // Reactivar unidad

  Future<int> reactivar(
    int id,
  ) async {

    final db = await _db;

    return await db.update(

      'unidades',

      {
        'activo': 1,
      },

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // Marcar pendiente impresión

  Future<int>
      marcarPendienteImpresion(
    int idUnidad,
  ) async {

    final db = await _db;

    return await db.update(

      'unidades',

      {
        'pendiente_impresion':
            1,
      },

      where: 'id = ?',

      whereArgs: [idUnidad],
    );
  }

  // Quitar pendiente impresión

  Future<int>
      quitarPendienteImpresion(
    int idUnidad,
  ) async {

    final db = await _db;

    return await db.update(

      'unidades',

      {
        'pendiente_impresion':
            0,
      },

      where: 'id = ?',

      whereArgs: [idUnidad],
    );
  }

  // Obtener pendientes impresión

  Future<List<Map<String, dynamic>>>
      obtenerPendientesImpresion()
      async {

    final db = await _db;

    return await db.rawQuery('''

      SELECT

        u.id AS id_unidad,
        u.id_inventario,

        e.nombre AS escuela,
        p.nombre AS prenda,
        t.talla AS talla

      FROM unidades u

      INNER JOIN inventario i
        ON i.id = u.id_inventario

      INNER JOIN escuelas e
        ON e.id_escuela =
           i.id_escuela

      INNER JOIN prendas p
        ON p.id_prenda =
           i.id_prenda

      INNER JOIN tallas t
        ON t.id_talla =
           i.id_talla

      WHERE
        u.pendiente_impresion = 1
    ''');
  }

  // Eliminar unidad

  Future<int> eliminar(
    int id,
  ) async {

    final db = await _db;

    return await db.delete(

      'unidades',

      where: 'id = ?',

      whereArgs: [id],
    );
  }
}