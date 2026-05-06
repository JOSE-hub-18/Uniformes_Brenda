import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AdministrarVentasScreen extends StatelessWidget {
  const AdministrarVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados (Mock data) enfocados en ventas confirmadas
    final List<Map<String, dynamic>> ventas = [
      {'id': '001', 'cliente': 'John Doe', 'prendas': 2, 'estado': 'Confirmado'},
      {'id': '002', 'cliente': 'Jane Smith', 'prendas': 5, 'estado': 'Confirmado'},
      {'id': '003', 'cliente': 'Carlos Ruiz', 'prendas': 1, 'estado': 'Confirmado'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF), // Fondo azul claro consistente
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Administrar Ventas',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // LISTA DE VENTAS (Sin el botón de "Nuevo Pedido" arriba)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
              itemCount: ventas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final venta = ventas[index];
                return _buildVentaCard(context, venta);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // WIDGET REUTILIZABLE: Tarjeta de Venta
  Widget _buildVentaCard(BuildContext context, Map<String, dynamic> venta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)), // Borde gris sutil
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título cambiado a "Venta #"
          Text(
            'Venta #${venta['id']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          
          // Detalles
          Text(
            'Cliente: ${venta['cliente']}',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            '${venta['prendas']} prendas',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          
          const SizedBox(height: 12),
          
          // Fila inferior: Etiqueta y Botón "Ver"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Etiqueta verde de estado "Confirmado"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Verde basado en tu imagen
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  venta['estado'],
                  style: const TextStyle(
                    color: Color(0xFF0A3614), // Verde oscuro/casi negro para contraste
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  ),
                ),
              ),
              
              // Texto clickeable "Ver"
              TextButton(
                onPressed: () {
                  // Futura navegación para ver el detalle de la venta
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    color: Color(0xFF1452BD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Letra grande para área táctil
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}