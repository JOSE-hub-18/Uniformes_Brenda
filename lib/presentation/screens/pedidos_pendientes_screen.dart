import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'agregar_orden_screen.dart'; // Importamos la pantalla que creamos antes
import 'revisar_pedido_screen.dart';

class PedidosPendientesScreen extends StatelessWidget {
  const PedidosPendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados (Mock data) para construir la lista visualmente
    final List<Map<String, dynamic>> pedidos = [
      {'id': '001', 'cliente': 'John Doe', 'prendas': 3, 'estado': 'Pendiente'},
      {'id': '002', 'cliente': 'John Doe', 'prendas': 10, 'estado': 'Pendiente'},
      {'id': '003', 'cliente': 'Jane Doe', 'prendas': 5, 'estado': 'Pendiente'},
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
          'Pedidos Pendientes',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // BOTÓN: + Nuevo pedido
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Navegación hacia la pantalla de Agregar Pedido
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarPedidoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3388D6), // Azul vibrante del mockup
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0, // Sin sombra para que se vea más plano y moderno
                ),
                child: const Text(
                  '+ Nuevo pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // LISTA DE PEDIDOS PENDIENTES
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
              itemCount: pedidos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                // 👇 AQUÍ SE ENVÍA EL CONTEXT 👇
                return _buildPedidoCard(context, pedido);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // WIDGET REUTILIZABLE: Tarjeta de Pedido
  // 👇 AQUÍ SE RECIBE EL CONTEXT 👇
  Widget _buildPedidoCard(BuildContext context, Map<String, dynamic> pedido) {
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
          // Título
          Text(
            'Pedido #${pedido['id']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          
          // Detalles
          Text(
            'Cliente: ${pedido['cliente']}',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            '${pedido['prendas']} prendas',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          
          const SizedBox(height: 12),
          
          // Fila inferior: Etiqueta y Botón "Ver"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Etiqueta amarilla de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECCC15), // Amarillo del mockup
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pedido['estado'],
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              
              // Texto clickeable "Ver" más grande y con mejor área táctil
              TextButton(
                onPressed: () {
                  // AHORA ESTE CONTEXT SÍ FUNCIONA
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RevisarPedidoScreen(), // Navega a la nueva pantalla
                    ),
                  );
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
                    fontSize: 16, // Letra más grande
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