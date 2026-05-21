// lib/data/repositories/pedido_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio encargado de gestionar las operaciones
/// relacionadas con pedidos y detalles de pedido en la base de datos.
class PedidoRepository {
  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta un pedido junto con todos sus detalles asociados
  /// dentro de una transacción atómica.
  ///
  /// La operación garantiza consistencia entre la tabla de pedidos
  /// y la tabla de detalle_pedido.
  Future<int> insertarPedidoYDetalles({
    required Pedido pedido,
    required List<DetallePedido> detalles,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Inserta el registro principal del pedido.
      final idPedido = await txn.insert('pedidos', {
        'id_usuario': pedido.idUsuario,

        'id_orden_origen': pedido.idOrdenOrigen,

        'id_venta_origen': pedido.idVentaOrigen,

        'nombre_cliente': pedido.nombreCliente,

        'fecha': pedido.fecha.toIso8601String(),

        'total': pedido.total,

        'estado': pedido.estado.name,
      });

      // Inserta cada detalle asociado al pedido recién creado.
      for (final detalle in detalles) {
        await txn.insert('detalle_pedido', {
          'id_pedido': idPedido,

          'id_inventario': detalle.idInventario,

          'id_unidad_registrada': detalle.idUnidadRegistrada,

          'registrado': detalle.registrado ? 1 : 0,

          'precio_unitario': detalle.precioUnitario,
        });
      }

      return idPedido;
    });
  }

  /// Obtiene todos los pedidos registrados
  /// ordenados por fecha descendente.
  Future<List<Pedido>> obtenerTodos() async {
    final db = await _db;

    final maps = await db.query('pedidos', orderBy: 'fecha DESC');

    return maps.map((m) => Pedido.fromMap(m)).toList();
  }

  /// Obtiene un pedido específico mediante su identificador.
  ///
  /// Retorna null si no existe un registro asociado.
  Future<Pedido?> obtenerPorId(int idPedido) async {
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

    return Pedido.fromMap(maps.first);
  }

  /// Obtiene todos los detalles asociados a un pedido.
  Future<List<DetallePedido>> obtenerDetalles(int idPedido) async {
    final db = await _db;

    final maps = await db.query(
      'detalle_pedido',
      where: 'id_pedido = ?',
      whereArgs: [idPedido],
    );

    return maps.map((m) => DetallePedido.fromMap(m)).toList();
  }

  /// Obtiene los detalles de un pedido junto con
  /// información descriptiva proveniente de tablas relacionadas.
  ///
  /// La consulta integra información de escuela,
  /// prenda y talla asociadas al inventario.
  Future<List<Map<String, dynamic>>> obtenerDetallesConInfo(
    int idPedido,
  ) async {
    final db = await _db;

    return await db.rawQuery(
      '''
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
    ''',
      [idPedido],
    );
  }

  /// Actualiza el estado actual de un pedido.
  Future<int> actualizarEstado({
    required int idPedido,
    required EstadoPedido estado,
  }) async {
    final db = await _db;

    return await db.update(
      'pedidos',
      {'estado': estado.name},
      where: 'id = ?',
      whereArgs: [idPedido],
    );
  }

  /// Registra una unidad física dentro de un detalle de pedido.
  ///
  /// La operación marca el detalle como registrado
  /// y asocia la unidad correspondiente.
  Future<int> registrarUnidad({
    required int idDetallePedido,
    required int idUnidad,
  }) async {
    final db = await _db;

    return await db.update(
      'detalle_pedido',
      {'id_unidad_registrada': idUnidad, 'registrado': 1},
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

  /// Elimina el registro de una unidad asociada
  /// a un detalle de pedido.
  ///
  /// La operación restablece el estado de registro
  /// a pendiente.
  Future<int> desregistrarUnidad(int idDetallePedido) async {
    final db = await _db;

    return await db.update(
      'detalle_pedido',
      {'id_unidad_registrada': null, 'registrado': 0},
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

  /// Obtiene el registro activo asociado a una unidad específica.
  ///
  /// Se considera activo cuando el detalle se encuentra
  /// marcado como registrado.
  Future<Map<String, dynamic>?> obtenerRegistroActivoPorUnidad(
    int idUnidad,
  ) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
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
  ''',
      [idUnidad],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  /// Verifica si todos los detalles de un pedido
  /// han sido registrados.
  ///
  /// Un pedido se considera completo cuando no existen
  /// registros pendientes.
  Future<bool> pedidoCompleto(int idPedido) async {
    final db = await _db;

    final pendientes = await db.rawQuery(
      '''
      SELECT COUNT(*) total

      FROM detalle_pedido

      WHERE id_pedido = ?
      AND registrado = 0
    ''',
      [idPedido],
    );

    final total = Sqflite.firstIntValue(pendientes) ?? 0;

    return total == 0;
  }

  /// Elimina un detalle específico de pedido.
  Future<int> eliminarDetallePedido(int idDetallePedido) async {
    final db = await _db;

    return await db.delete(
      'detalle_pedido',
      where: 'id = ?',
      whereArgs: [idDetallePedido],
    );
  }

  /// Obtiene la cantidad total de detalles
  /// asociados a un pedido.
  Future<int> contarDetalles(int idPedido) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) total

      FROM detalle_pedido

      WHERE id_pedido = ?
    ''',
      [idPedido],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Elimina un pedido y todos sus detalles asociados
  /// dentro de una transacción.
  ///
  /// La eliminación respeta la integridad lógica
  /// entre tablas relacionadas.
  Future<void> eliminarPedidoCompleto(int idPedido) async {
    final db = await _db;

    await db.transaction((txn) async {
      // Elimina primero los detalles relacionados
      // para evitar inconsistencias referenciales.
      await txn.delete(
        'detalle_pedido',
        where: 'id_pedido = ?',
        whereArgs: [idPedido],
      );

      // Elimina el pedido principal.
      await txn.delete('pedidos', where: 'id = ?', whereArgs: [idPedido]);
    });
  }

  /// Elimina un pedido mediante su identificador.
  Future<int> eliminar(int idPedido) async {
    final db = await _db;

    return await db.delete('pedidos', where: 'id = ?', whereArgs: [idPedido]);
  }
}
