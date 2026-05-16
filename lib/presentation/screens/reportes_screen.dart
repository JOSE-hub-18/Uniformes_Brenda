// lib/presentation/screens/reportes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/reporte_repository.dart';
import '../../data/repositories/escuela_repository.dart';
import '../providers/reportes_provider.dart';

class ReportesScreen extends StatelessWidget {

  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => ReportesProvider(
        repository: ReporteRepository(),
        escuelaRepository: EscuelaRepository(),
      )..inicializar(),
      child: const _ReportesView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VISTA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class _ReportesView extends StatelessWidget {

  const _ReportesView();

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<ReportesProvider>();

    return Scaffold(

      backgroundColor: const Color(0xFFF3F8FD),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reportes',
          style: TextStyle(
            color: Color(0xFF1452BD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF1452BD),
        ),
      ),

      body: provider.cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1452BD)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Filtros ──────────────────────────────────────────────
                  _FiltrosSection(provider: provider),

                  const SizedBox(height: 20),

                  // ── Resumen ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total recaudado',
                          valor: '\$${provider.totalVendido.toStringAsFixed(2)}',
                          icono: Icons.attach_money,
                          color: const Color(0xFF34A853),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Prendas vendidas',
                          valor: provider.cantidadVentas.toString(),
                          icono: Icons.shopping_bag_outlined,
                          color: const Color(0xFF1452BD),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Escuelas (solo si no hay escuela filtrada) ───────────
                  if (provider.idEscuelaSeleccionada == null) ...[
                    _SectionTitle(titulo: 'Ventas por escuela'),
                    const SizedBox(height: 10),
                    if (provider.escuelasMasVentas.isEmpty)
                      _EmptyState(mensaje: 'Sin ventas en este periodo')
                    else
                      _RankingCard(
                        items: provider.escuelasMasVentas.map((item) {
                          final total = (item['total'] as num?)?.toDouble() ?? 0;
                          final cantidad = (item['cantidad'] as num?)?.toInt() ?? 0;
                          return _RankingItem(
                            nombre: item['escuela'].toString(),
                            monto: total,
                            subtitulo: '$cantidad prendas',
                            proporcion: provider.maxTotalEscuela > 0
                                ? total / provider.maxTotalEscuela
                                : 0,
                          );
                        }).toList(),
                        esDinero: true,
                      ),
                    const SizedBox(height: 24),
                  ],

                  // ── Prendas ──────────────────────────────────────────────
                  _SectionTitle(
                    titulo: provider.idEscuelaSeleccionada == null
                        ? 'Ventas por tipo de prenda'
                        : 'Prendas — ${provider.nombreEscuelaSeleccionada}',
                  ),
                  const SizedBox(height: 10),
                  if (provider.prendasMasVendidas.isEmpty)
                    _EmptyState(mensaje: 'Sin ventas en este periodo')
                  else
                    _RankingCard(
                      items: provider.prendasMasVendidas.map((item) {
                        final cantidad = (item['cantidad'] as num?)?.toInt() ?? 0;
                        final total = (item['total'] as num?)?.toDouble() ?? 0;
                        return _RankingItem(
                          nombre: item['prenda'].toString(),
                          monto: total,
                          subtitulo: '$cantidad piezas',
                          proporcion: provider.maxCantidadPrenda > 0
                              ? cantidad / provider.maxCantidadPrenda
                              : 0,
                        );
                      }).toList(),
                      esDinero: true,
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTROS
// ─────────────────────────────────────────────────────────────────────────────

class _FiltrosSection extends StatelessWidget {

  final ReportesProvider provider;

  const _FiltrosSection({required this.provider});

  static const _inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF1452BD)),
    ),
  );

  @override
  Widget build(BuildContext context) {

    final anios = List.generate(5, (i) => DateTime.now().year - i);

    const meses = [
      null, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
    ];
    const nombresMes = [
      'Todo el a\u00f1o', 'Enero', 'Febrero', 'Marzo', 'Abril',
      'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre',
      'Octubre', 'Noviembre', 'Diciembre',
    ];

    return Column(
      children: [

        // Anio y Mes en fila
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: provider.year,
                decoration: _inputDecoration.copyWith(labelText: 'A\u00f1o'),
                items: anios.map((a) => DropdownMenuItem(
                  value: a,
                  child: Text(a.toString()),
                )).toList(),
                onChanged: (v) { if (v != null) provider.cambiarYear(v); },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: provider.month,
                decoration: _inputDecoration.copyWith(labelText: 'Mes'),
                items: List.generate(13, (i) => DropdownMenuItem(
                  value: meses[i],
                  child: Text(nombresMes[i]),
                )),
                onChanged: (v) => provider.cambiarMonth(v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Escuela — ancho completo
        DropdownButtonFormField<int?>(
          value: provider.idEscuelaSeleccionada,
          decoration: _inputDecoration.copyWith(labelText: 'Escuela'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todas las escuelas'),
            ),
            ...provider.escuelas.map((e) => DropdownMenuItem(
              value: e.idEscuela,
              child: Text(e.nombre),
            )),
          ],
          onChanged: (v) => provider.cambiarEscuela(v),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TÍTULO DE SECCIÓN
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {

  final String titulo;

  const _SectionTitle({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF888888),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD (resumen superior)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {

  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatCard({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icono, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RANKING CARD + ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _RankingItem {
  final String nombre;
  final double monto;
  final String subtitulo;
  final double proporcion; // 0.0 – 1.0

  const _RankingItem({
    required this.nombre,
    required this.monto,
    required this.subtitulo,
    required this.proporcion,
  });
}

class _RankingCard extends StatelessWidget {

  final List<_RankingItem> items;
  final bool esDinero;

  const _RankingCard({
    required this.items,
    this.esDinero = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {

          final item = items[index];
          final esTop = index == 0;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [

                    // Número de ranking
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: esTop
                            ? const Color(0xFF1452BD)
                            : const Color(0xFFE6F1FB),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: esTop
                                ? Colors.white
                                : const Color(0xFF1452BD),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Nombre
                    Expanded(
                      child: Text(
                        item.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Barra + cifras
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            width: 72,
                            height: 5,
                            child: LinearProgressIndicator(
                              value: item.proporcion.clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFFE0E7F5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1452BD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          esDinero
                              ? '\$${item.monto.toStringAsFixed(2)}'
                              : item.monto.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          item.subtitulo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {

  final String mensaje;

  const _EmptyState({required this.mensaje});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}