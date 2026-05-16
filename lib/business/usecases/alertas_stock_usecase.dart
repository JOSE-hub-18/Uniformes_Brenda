// lib/domain/usecases/alertas_stock_usecase.dart

import '../../data/repositories/inventario_repository.dart';

// ── Tipos de alerta ────────────────────────────────────────────────────────

enum TipoAlerta { agotado, critico }

// ── Modelo de alerta ───────────────────────────────────────────────────────

class AlertaStock {
  final int idInventario;
  final String escuela;
  final String prenda;
  final String talla;
  final double precio;
  final int stock;
  final TipoAlerta tipo;

  const AlertaStock({
    required this.idInventario,
    required this.escuela,
    required this.prenda,
    required this.talla,
    required this.precio,
    required this.stock,
    required this.tipo,
  });

  /// Mensaje descriptivo de la alerta
  String get mensaje {
    switch (tipo) {
      case TipoAlerta.agotado:
        return '⛔ Sin stock — $escuela · $prenda · Talla $talla';
      case TipoAlerta.critico:
        return '⚠️ Stock crítico ($stock piezas) — $escuela · $prenda · Talla $talla';
    }
  }

  /// Prioridad numérica para ordenar (agotado primero)
  int get prioridad => tipo == TipoAlerta.agotado ? 0 : 1;
}

// ── Resultado global ───────────────────────────────────────────────────────

class AlertasStockResult {
  final List<AlertaStock> agotados;
  final List<AlertaStock> criticos;

  const AlertasStockResult({
    required this.agotados,
    required this.criticos,
  });

  /// Todas las alertas juntas, agotados primero
  List<AlertaStock> get todas => [...agotados, ...criticos];

  bool get hayAlertas => agotados.isNotEmpty || criticos.isNotEmpty;

  int get totalAgotados => agotados.length;
  int get totalCriticos => criticos.length;
}

// ── UseCase ────────────────────────────────────────────────────────────────

class AlertasStockUseCase {
  final InventarioRepository _inventarioRepository;

  /// Umbral de stock crítico (inclusive). Por defecto: 3 unidades.
  static const int umbralCritico = 3;

  AlertasStockUseCase({
    required InventarioRepository inventarioRepository,
  }) : _inventarioRepository = inventarioRepository;

  // ── Obtener todas las alertas ──────────────────────────────────────────

  /// Devuelve todas las alertas activas: agotados y críticos.
  Future<AlertasStockResult> obtenerAlertas() async {
    final agotados = await _obtenerAgotados();
    final criticos = await _obtenerCriticos();

    return AlertasStockResult(
      agotados: agotados,
      criticos: criticos,
    );
  }

  // ── Obtener solo agotados ──────────────────────────────────────────────

  /// Devuelve únicamente los ítems sin stock (0 unidades activas).
  Future<List<AlertaStock>> obtenerAgotados() async {
    return await _obtenerAgotados();
  }

  // ── Obtener solo críticos ──────────────────────────────────────────────

  /// Devuelve únicamente los ítems con stock <= [umbralCritico] pero > 0.
  Future<List<AlertaStock>> obtenerCriticos() async {
    return await _obtenerCriticos();
  }

  // ── Verificar alerta por inventario específico ─────────────────────────

  /// Verifica si un ítem específico tiene alerta activa.
  /// Útil para mostrar indicador en listas de inventario.
  Future<AlertaStock?> verificarItem(int idInventario) async {
    final stock = await _inventarioRepository.contarStock(idInventario);

    if (stock == 0) {
      // Buscar info del item en agotados
      final agotados = await _obtenerAgotados();
      return agotados
          .where((a) => a.idInventario == idInventario)
          .firstOrNull;
    }

    if (stock <= umbralCritico) {
      // Buscar info del item en críticos
      final criticos = await _obtenerCriticos();
      return criticos
          .where((a) => a.idInventario == idInventario)
          .firstOrNull;
    }

    return null; // Sin alerta
  }

  // ── Resumen para badge/notificación ───────────────────────────────────

  /// Devuelve un texto corto para mostrar en badges o notificaciones.
  /// Ej: "2 agotados · 5 críticos"
  Future<String?> obtenerResumen() async {
    final resultado = await obtenerAlertas();

    if (!resultado.hayAlertas) return null;

    final partes = <String>[];

    if (resultado.totalAgotados > 0) {
      partes.add('${resultado.totalAgotados} agotado${resultado.totalAgotados > 1 ? 's' : ''}');
    }

    if (resultado.totalCriticos > 0) {
      partes.add('${resultado.totalCriticos} crítico${resultado.totalCriticos > 1 ? 's' : ''}');
    }

    return partes.join(' · ');
  }

  // ── Helpers privados ───────────────────────────────────────────────────

  Future<List<AlertaStock>> _obtenerAgotados() async {
    final rows = await _inventarioRepository.obtenerStockAgotado();

    return rows.map((row) => AlertaStock(
      idInventario: row['id'] as int,
      escuela: row['escuela'] as String,
      prenda: row['prenda'] as String,
      talla: row['talla'] as String,
      precio: (row['precio'] as num).toDouble(),
      stock: 0,
      tipo: TipoAlerta.agotado,
    )).toList();
  }

  Future<List<AlertaStock>> _obtenerCriticos() async {
    final rows = await _inventarioRepository.obtenerStockCritico();

    return rows.map((row) => AlertaStock(
      idInventario: row['id'] as int,
      escuela: row['escuela'] as String,
      prenda: row['prenda'] as String,
      talla: row['talla'] as String,
      precio: (row['precio'] as num).toDouble(),
      stock: row['stock'] as int,
      tipo: TipoAlerta.critico,
    )).toList();
  }
}
