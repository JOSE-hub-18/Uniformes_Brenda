// lib/domain/usecases/alertas_stock_usecase.dart

import '../../data/repositories/inventario_repository.dart';

/// Define los niveles de severidad para las alertas de stock.
enum TipoAlerta { agotado, critico }

/// Modelo que representa una alerta de stock para un item de inventario específico.
/// Contiene la información del item afectado, su stock actual y el tipo de alerta generada.
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

/// Agrupa el resultado de la consulta de alertas de stock,
/// separando los items agotados de los que están en nivel crítico.
class AlertasStockResult {
  final List<AlertaStock> agotados;
  final List<AlertaStock> criticos;

  const AlertasStockResult({required this.agotados, required this.criticos});

  /// Retorna la lista combinada de todas las alertas, con los agotados primero.
  List<AlertaStock> get todas => [...agotados, ...criticos];

  /// Retorna true si existe al menos una alerta activa entre agotados y críticos.
  bool get hayAlertas => agotados.isNotEmpty || criticos.isNotEmpty;

  int get totalAgotados => agotados.length;
  int get totalCriticos => criticos.length;
}

/// Caso de uso encargado de detectar y clasificar alertas de stock en el inventario.
/// Consulta el repositorio de inventario para identificar items agotados y críticos,
/// y expone métodos para obtener el resultado completo, filtrado o resumido.
class AlertasStockUseCase {
  final InventarioRepository _inventarioRepository;

  /// Umbral de stock crítico (inclusive). Items con stock igual o inferior
  /// a este valor y mayor a 0 se clasifican como críticos.
  static const int umbralCritico = 3;

  AlertasStockUseCase({required InventarioRepository inventarioRepository})
    : _inventarioRepository = inventarioRepository;

  /// Retorna todas las alertas activas agrupadas en agotados y críticos.
  Future<AlertasStockResult> obtenerAlertas() async {
    final agotados = await _obtenerAgotados();
    final criticos = await _obtenerCriticos();

    return AlertasStockResult(agotados: agotados, criticos: criticos);
  }

  /// Retorna únicamente los items sin stock (0 unidades disponibles).
  Future<List<AlertaStock>> obtenerAgotados() async {
    return await _obtenerAgotados();
  }

  /// Retorna únicamente los items con stock menor o igual a [umbralCritico] y mayor a 0.
  Future<List<AlertaStock>> obtenerCriticos() async {
    return await _obtenerCriticos();
  }

  /// Verifica si un item específico del inventario tiene una alerta activa.
  /// Consulta el stock actual del item y lo compara contra las reglas de negocio:
  /// stock igual a 0 genera alerta de agotado, stock menor o igual a [umbralCritico]
  /// genera alerta crítica. Retorna null si el item no tiene alerta activa.
  Future<AlertaStock?> verificarItem(int idInventario) async {
    final stock = await _inventarioRepository.contarStock(idInventario);

    if (stock == 0) {
      final agotados = await _obtenerAgotados();
      return agotados.where((a) => a.idInventario == idInventario).firstOrNull;
    }

    if (stock <= umbralCritico) {
      final criticos = await _obtenerCriticos();
      return criticos.where((a) => a.idInventario == idInventario).firstOrNull;
    }

    return null;
  }

  /// Genera un texto resumido con el conteo de alertas activas,
  /// apto para mostrar en badges o notificaciones.
  /// Retorna null si no hay alertas activas.
  /// Ejemplo de salida: "2 agotados · 5 críticos".
  Future<String?> obtenerResumen() async {
    final resultado = await obtenerAlertas();

    if (!resultado.hayAlertas) return null;

    final partes = <String>[];

    if (resultado.totalAgotados > 0) {
      partes.add(
        '${resultado.totalAgotados} agotado${resultado.totalAgotados > 1 ? 's' : ''}',
      );
    }

    if (resultado.totalCriticos > 0) {
      partes.add(
        '${resultado.totalCriticos} crítico${resultado.totalCriticos > 1 ? 's' : ''}',
      );
    }

    return partes.join(' · ');
  }

  /// Obtiene del repositorio los items con stock agotado y los mapea
  /// a instancias de [AlertaStock] con tipo [TipoAlerta.agotado].
  Future<List<AlertaStock>> _obtenerAgotados() async {
    final rows = await _inventarioRepository.obtenerStockAgotado();

    return rows
        .map(
          (row) => AlertaStock(
            idInventario: row['id'] as int,
            escuela: row['escuela'] as String,
            prenda: row['prenda'] as String,
            talla: row['talla'] as String,
            precio: (row['precio'] as num).toDouble(),
            stock: 0,
            tipo: TipoAlerta.agotado,
          ),
        )
        .toList();
  }

  /// Obtiene del repositorio los items con stock crítico y los mapea
  /// a instancias de [AlertaStock] con tipo [TipoAlerta.critico].
  Future<List<AlertaStock>> _obtenerCriticos() async {
    final rows = await _inventarioRepository.obtenerStockCritico();

    return rows
        .map(
          (row) => AlertaStock(
            idInventario: row['id'] as int,
            escuela: row['escuela'] as String,
            prenda: row['prenda'] as String,
            talla: row['talla'] as String,
            precio: (row['precio'] as num).toDouble(),
            stock: row['stock'] as int,
            tipo: TipoAlerta.critico,
          ),
        )
        .toList();
  }
}
