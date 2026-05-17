// lib/data/repositories/unidad_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

import '../../models/models.dart';

/// Repositorio encargado de gestionar las operaciones
/// relacionadas con unidades de inventario.
///
/// Permite administrar activación, impresión,
/// validaciones y consultas asociadas a unidades físicas.
class UnidadRepository {

  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async =>
      await DatabaseHelper
          .instance
          .database;

  /// Inserta múltiples unidades asociadas a un inventario.
  ///
  /// Cada unidad se crea inicialmente como activa
  /// y sin pendiente de impresión.
  ///
  /// La operación se ejecuta dentro de una transacción
  /// para garantizar consistencia en inserciones masivas.
  Future<List<int>>
      insertarUnidades(
    int idInventario,
    int cantidad,
  ) async {

    final db = await _db;

    final ids = <int>[];

    await db.transaction(
      (txn) async {

        // Genera la cantidad solicitada de unidades
        // asociadas al inventario especificado.
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

  /// Obtiene una unidad mediante su identificador.
  ///
  /// Retorna null cuando no existe un registro asociado.
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

  /// Verifica si una unidad pertenece
  /// a un inventario específico.
  ///
  /// Retorna true cuando existe coincidencia
  /// entre la unidad y el inventario indicado.
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

  /// Obtiene todas las unidades activas
  /// asociadas a un inventario.
  ///
  /// Las unidades inactivas o vendidas
  /// son excluidas del resultado.
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

  /// Marca una unidad como inactiva.
  ///
  /// Esta operación representa lógicamente
  /// una unidad vendida o fuera de disponibilidad.
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

  /// Reactiva una unidad previamente desactivada.
  ///
  /// La operación restablece la disponibilidad
  /// de la unidad dentro del inventario.
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

  /// Marca una unidad como pendiente de impresión.
  ///
  /// Esta bandera puede ser utilizada para procesos
  /// relacionados con etiquetas, códigos o tickets.
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

  /// Elimina el estado pendiente de impresión
  /// de una unidad.
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

  /// Obtiene todas las unidades marcadas
  /// como pendientes de impresión.
  ///
  /// La consulta incluye información descriptiva
  /// relacionada con escuela, prenda y talla.
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

  /// Elimina una unidad mediante su identificador.
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