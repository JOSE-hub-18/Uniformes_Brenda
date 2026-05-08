import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'agregar_prendas_pedido_screen.dart'; // La siguiente pantalla que crearemos

class RevisarPedidoScreen extends StatefulWidget {
  const RevisarPedidoScreen({super.key});

  @override
  State<RevisarPedidoScreen> createState() => _RevisarPedidoScreenState();
}

class _RevisarPedidoScreenState extends State<RevisarPedidoScreen> {
  // Mock data del pedido
  final String numPedido = '001';
  final String cliente = 'John Doe';
  final String estado = 'Pendiente';

  // Lista de prendas con estado para poder modificarlas
  List<Map<String, dynamic>> prendas = [
    {'titulo': 'ESC. PRIMARIA FLOR - Chamarra', 'talla': 'M', 'precio': 350.0, 'cantidad': 1},
    {'titulo': 'ESC. PRIMARIA FLOR - Falda', 'talla': 'M', 'precio': 180.0, 'cantidad': 1},
    {'titulo': 'ESC. PRIMARIA FLOR - Playera', 'talla': 'M', 'precio': 120.0, 'cantidad': 1},
  ];

  // Cálculos dinámicos
  int get totalPiezas => prendas.fold(0, (sum, item) => sum + (item['cantidad'] as int));
  double get totalPrecio => prendas.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad']));

  void _actualizarCantidad(int index, int cambio) {
    setState(() {
      int nuevaCantidad = prendas[index]['cantidad'] + cambio;
      if (nuevaCantidad > 0) {
        prendas[index]['cantidad'] = nuevaCantidad;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Revisar Pedido',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO DEL PEDIDO
            Text('Pedido #$numPedido', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const SizedBox(height: 4),
            Text(cliente, style: const TextStyle(fontSize: 16, color: Color(0xFF888888))),
            const SizedBox(height: 2),
            Text(estado, style: const TextStyle(fontSize: 16, color: Color(0xFF888888))),
            const SizedBox(height: 24),

            // LISTA DE PRENDAS
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prendas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = prendas[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['titulo'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
                            ),
                          ),
                          Text(
                            '\$${item['precio'].toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1452BD)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Talla ${item['talla']}', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
                          
                          // CONTROLES DE CANTIDAD (+ / -)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _actualizarCantidad(index, -1),
                                child: const Icon(Icons.remove_circle_outline, color: Color(0xFF888888), size: 28),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  '${item['cantidad']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _actualizarCantidad(index, 1),
                                child: const Icon(Icons.add_circle_outline, color: Color(0xFF1452BD), size: 28),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // CAJA DE RESUMEN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prendas', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                      Text('$totalPiezas piezas', style: const TextStyle(fontSize: 16, color: Color(0xFF666666))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                      Text('\$${totalPrecio.toInt()}', style: const TextStyle(fontSize: 16, color: Color(0xFF666666))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Color(0xFFE0E0E0), thickness: 1.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      Text('\$${totalPrecio.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // BOTONES FINALES
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Verde
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
                child: const Text('Completar pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AgregarPrendasPedidoScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3388D6), // Azul
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
                child: const Text('+ Agregar prendas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}