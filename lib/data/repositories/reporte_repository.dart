// lib/data/repositories/reporte_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class ReporteRepository {

  Future<Database> get _db async =>
      await DatabaseHelper.instance.database;

  // ─────────────────────────────────────────────────────────
  // TOTALES
  // ─────────────────────────────────────────────────────────

  Future<double> obtenerTotalVendido({
    required int year,
    int? month,
    int? idEscuela,
  }) async {

    final db = await _db;

    if (idEscuela != null) {

      // Con filtro de escuela necesitamos join con detalle_venta
      String where =
          "v.estado != 'cancelada' AND strftime('%Y', v.fecha) = ?";

      final args = <dynamic>[year.toString()];

      if (month != null) {
        where += " AND strftime('%m', v.fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      where += " AND i.id_escuela = ?";
      args.add(idEscuela);

      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(dv.precio_unitario * dv.cantidad), 0) as total
        FROM ventas v
        INNER JOIN detalle_venta dv ON dv.id_venta = v.id
        INNER JOIN unidades u ON u.id = dv.id_unidad
        INNER JOIN inventario i ON i.id = u.id_inventario
        WHERE $where
      ''', args);

      return (result.first['total'] as num?)?.toDouble() ?? 0;

    } else {

      String where =
          "estado != 'cancelada' AND strftime('%Y', fecha) = ?";

      final args = <dynamic>[year.toString()];

      if (month != null) {
        where += " AND strftime('%m', fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      final result = await db.query(
        'ventas',
        columns: ['COALESCE(SUM(total), 0) as total'],
        where: where,
        whereArgs: args,
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0;
    }
  }

  Future<int> obtenerCantidadVentas({
    required int year,
    int? month,
    int? idEscuela,
  }) async {

    final db = await _db;

    if (idEscuela != null) {

      String where =
          "v.estado != 'cancelada' AND strftime('%Y', v.fecha) = ?";

      final args = <dynamic>[year.toString()];

      if (month != null) {
        where += " AND strftime('%m', v.fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      where += " AND i.id_escuela = ?";
      args.add(idEscuela);

      // Contamos ventas distintas que tienen al menos un item de esa escuela
      final result = await db.rawQuery('''
        SELECT COUNT(DISTINCT v.id) as cantidad
        FROM ventas v
        INNER JOIN detalle_venta dv ON dv.id_venta = v.id
        INNER JOIN unidades u ON u.id = dv.id_unidad
        INNER JOIN inventario i ON i.id = u.id_inventario
        WHERE $where
      ''', args);

      return (result.first['cantidad'] as int?) ?? 0;

    } else {

      String where =
          "estado != 'cancelada' AND strftime('%Y', fecha) = ?";

      final args = <dynamic>[year.toString()];

      if (month != null) {
        where += " AND strftime('%m', fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      final result = await db.rawQuery('''
        SELECT COUNT(*) as cantidad
        FROM ventas
        WHERE $where
      ''', args);

      return (result.first['cantidad'] as int?) ?? 0;
    }
  }

  // ─────────────────────────────────────────────────────────
  // PRENDAS MÁS VENDIDAS
  // Devuelve nombre de prenda, cantidad de piezas e ingreso total
  // ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerPrendasMasVendidas({
    required int year,
    int? month,
    int? idEscuela,
  }) async {

    final db = await _db;

    String where =
        "strftime('%Y', v.fecha) = ? AND v.estado != 'cancelada'";

    final args = <dynamic>[year.toString()];

    if (month != null) {
      where += " AND strftime('%m', v.fecha) = ?";
      args.add(month.toString().padLeft(2, '0'));
    }

    if (idEscuela != null) {
      where += " AND i.id_escuela = ?";
      args.add(idEscuela);
    }

    return await db.rawQuery('''
      SELECT
        p.nombre          AS prenda,
        COUNT(*)          AS cantidad,
        SUM(dv.precio_unitario * dv.cantidad) AS total

      FROM detalle_venta dv

      INNER JOIN ventas v
        ON v.id = dv.id_venta

      INNER JOIN unidades u
        ON u.id = dv.id_unidad

      INNER JOIN inventario i
        ON i.id = u.id_inventario

      INNER JOIN prendas p
        ON p.id_prenda = i.id_prenda

      WHERE $where

      GROUP BY p.id_prenda, p.nombre

      ORDER BY cantidad DESC

      LIMIT 10
    ''', args);
  }

  // ─────────────────────────────────────────────────────────
  // ESCUELAS CON MÁS INGRESOS
  // ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerEscuelasMasVentas({
    required int year,
    int? month,
  }) async {

    final db = await _db;

    String where =
        "strftime('%Y', v.fecha) = ? AND v.estado != 'cancelada'";

    final args = <dynamic>[year.toString()];

    if (month != null) {
      where += " AND strftime('%m', v.fecha) = ?";
      args.add(month.toString().padLeft(2, '0'));
    }

    return await db.rawQuery('''
      SELECT
        e.id_escuela                                        AS id_escuela,
        e.nombre                                            AS escuela,
        COUNT(DISTINCT dv.id)                               AS cantidad,
        SUM(dv.precio_unitario * dv.cantidad)               AS total

      FROM detalle_venta dv

      INNER JOIN ventas v
        ON v.id = dv.id_venta

      INNER JOIN unidades u
        ON u.id = dv.id_unidad

      INNER JOIN inventario i
        ON i.id = u.id_inventario

      INNER JOIN escuelas e
        ON e.id_escuela = i.id_escuela

      WHERE $where

      GROUP BY e.id_escuela, e.nombre

      ORDER BY total DESC

      LIMIT 10
    ''', args);
  }
}