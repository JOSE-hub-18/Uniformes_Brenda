// lib/data/repositories/reporte_repository.dart

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Repositorio encargado de generar consultas
/// estadísticas y métricas utilizadas en reportes.
///
/// Centraliza operaciones agregadas relacionadas con ventas,
/// ingresos, prendas y escuelas.
class ReporteRepository {
  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Obtiene el total monetario vendido filtrando
  /// por año, mes y escuela de forma opcional.
  ///
  /// Las ventas canceladas son excluidas del cálculo.
  ///
  /// Cuando se especifica una escuela, el cálculo se realiza
  /// utilizando joins sobre detalle_venta, unidades e inventario
  /// para identificar únicamente productos asociados.
  Future<double> obtenerTotalVendido({
    required int year,
    int? month,
    int? idEscuela,
  }) async {
    final db = await _db;

    if (idEscuela != null) {
      // Construcción dinámica de filtros para consultas
      // relacionadas con una escuela específica.
      String where = "v.estado != 'cancelada' AND strftime('%Y', v.fecha) = ?";

      final args = <dynamic>[year.toString()];

      // Aplica filtro mensual cuando se especifica.
      if (month != null) {
        where += " AND strftime('%m', v.fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      // Filtra registros asociados a la escuela indicada.
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
      // Construcción dinámica de filtros generales
      // sin segmentación por escuela.
      String where = "estado != 'cancelada' AND strftime('%Y', fecha) = ?";

      final args = <dynamic>[year.toString()];

      // Aplica filtro mensual cuando corresponde.
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

  /// Obtiene la cantidad de ventas realizadas
  /// filtrando por año, mes y escuela opcionalmente.
  ///
  /// Las ventas canceladas son excluidas del conteo.
  Future<int> obtenerCantidadVentas({
    required int year,
    int? month,
    int? idEscuela,
  }) async {
    final db = await _db;

    if (idEscuela != null) {
      // Construcción dinámica de filtros para consultas
      // relacionadas con una escuela específica.
      String where = "v.estado != 'cancelada' AND strftime('%Y', v.fecha) = ?";

      final args = <dynamic>[year.toString()];

      // Aplica filtro mensual cuando se especifica.
      if (month != null) {
        where += " AND strftime('%m', v.fecha) = ?";
        args.add(month.toString().padLeft(2, '0'));
      }

      // Filtra registros asociados a la escuela indicada.
      where += " AND i.id_escuela = ?";
      args.add(idEscuela);

      // Se cuentan ventas distintas para evitar duplicados
      // provocados por múltiples detalles asociados.
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
      // Construcción dinámica de filtros generales.
      String where = "estado != 'cancelada' AND strftime('%Y', fecha) = ?";

      final args = <dynamic>[year.toString()];

      // Aplica filtro mensual cuando corresponde.
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

  /// Obtiene las prendas con mayor volumen de ventas.
  ///
  /// La consulta retorna:
  /// - nombre de la prenda,
  /// - cantidad de piezas vendidas,
  /// - ingreso total generado.
  ///
  /// El resultado se limita a las 10 prendas
  /// con mayor cantidad vendida.
  Future<List<Map<String, dynamic>>> obtenerPrendasMasVendidas({
    required int year,
    int? month,
    int? idEscuela,
  }) async {
    final db = await _db;

    // Filtro base para excluir ventas canceladas
    // y limitar por año.
    String where = "strftime('%Y', v.fecha) = ? AND v.estado != 'cancelada'";

    final args = <dynamic>[year.toString()];

    // Aplica filtro mensual cuando se especifica.
    if (month != null) {
      where += " AND strftime('%m', v.fecha) = ?";
      args.add(month.toString().padLeft(2, '0'));
    }

    // Filtra prendas pertenecientes a una escuela específica.
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

  /// Obtiene las escuelas con mayores ingresos generados.
  ///
  /// La consulta retorna:
  /// - identificador de escuela,
  /// - nombre,
  /// - cantidad de registros vendidos,
  /// - total monetario generado.
  ///
  /// El resultado se limita a las 10 escuelas
  /// con mayor ingreso acumulado.
  Future<List<Map<String, dynamic>>> obtenerEscuelasMasVentas({
    required int year,
    int? month,
  }) async {
    final db = await _db;

    // Filtro base para excluir ventas canceladas
    // y limitar por año.
    String where = "strftime('%Y', v.fecha) = ? AND v.estado != 'cancelada'";

    final args = <dynamic>[year.toString()];

    // Aplica filtro mensual cuando corresponde.
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
