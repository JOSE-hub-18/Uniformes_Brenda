import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class RevisarVentaScreen extends StatelessWidget {
  const RevisarVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data de la venta
    final String numVenta = '001';
    final String cliente = 'John Doe';

    // Lista de prendas vendidas (asumimos 1 de cada una para el ejemplo)
    final List<Map<String, dynamic>> prendas = [
      {'titulo': 'ESC. PRIMARIA FLOR - Chamarra', 'talla': 'M', 'precio': 350.0},
      {'titulo': 'ESC. PRIMARIA FLOR - Falda', 'talla': 'M', 'precio': 180.0},
      {'titulo': 'ESC. PRIMARIA FLOR - Playera', 'talla': 'M', 'precio': 120.0},
    ];

    // Cálculos dinámicos (Como la cantidad es estática en la venta ya completada, contamos el largo de la lista)
    final int totalPiezas = prendas.length;
    final double totalPrecio = prendas.fold(0, (sum, item) => sum + item['precio']);

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
          'Revisar Venta',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO DE LA VENTA
            Text('Venta #$numVenta', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const SizedBox(height: 4),
            Text(cliente, style: const TextStyle(fontSize: 16, color: Color(0xFF888888))),
            const SizedBox(height: 24),

            // LISTA DE PRENDAS CON BOTÓN DE DEVOLUCIÓN
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Talla ${item['talla']}', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
                          
                          // TEXTO CLICKABLE DE DEVOLUCIÓN
                          GestureDetector(
                            onTap: () {
                              // Aquí irá la lógica de devolución en el futuro
                              // Por ejemplo, abrir un pop-up que pregunte "¿Seguro que desea devolver esta prenda?"
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 4.0),
                              child: Text(
                              'Devolución',
                              style: TextStyle(
                                color: Color(0xFFD32F2F), // Rojo
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            ),
                          ),
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

            const SizedBox(height: 32), // Espacio final antes del NavBar
            // Botones omitidos exitosamente
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}