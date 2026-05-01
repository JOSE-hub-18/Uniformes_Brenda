import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AgregarPrendasPedidoScreen extends StatefulWidget {
  const AgregarPrendasPedidoScreen({super.key});

  @override
  State<AgregarPrendasPedidoScreen> createState() => _AgregarPrendasPedidoScreenState();
}

class _AgregarPrendasPedidoScreenState extends State<AgregarPrendasPedidoScreen> {
  String? _escuelaSeleccionada;
  String? _prendaSeleccionada;

  final List<String> _escuelas = ['UACJ', 'ESC. PRIMARIA FLOR', 'CBTIS 114'];
  final List<String> _prendas = ['Playera', 'Falda', 'Pantalón'];

  final List<Map<String, dynamic>> _prendasDisponibles = [
    {'titulo': 'ESC. PRIMARIA FLOR - Playera', 'talla': 'M', 'stock': 8, 'precio': 120.0},
    {'titulo': 'ESC. PRIMARIA FLOR - Falda', 'talla': 'M', 'stock': 3, 'precio': 180.0},
  ];

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required void Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Color(0xFF999999))),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
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
          'Agregar prendas',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildDropdown(
              hint: 'Escuela', value: _escuelaSeleccionada, items: _escuelas, onChanged: (val) => setState(() => _escuelaSeleccionada = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Prenda', value: _prendaSeleccionada, items: _prendas, onChanged: (val) => setState(() => _prendaSeleccionada = val),
            ),
            const SizedBox(height: 32),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prendasDisponibles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _prendasDisponibles[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E0E0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333))),
                            const SizedBox(height: 4),
                            Text('Talla ${item['talla']}', style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
                            Text('Stock: ${item['stock']}', style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${item['precio'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1452BD))),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1452BD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                              child: const Text('+ Agregar', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // BOTONES DE GUARDAR / CANCELAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para guardar las prendas añadidas al pedido original
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Verde
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Cierra la pantalla
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Rojo
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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