import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';
import 'bottom_nav_bar.dart';
import 'registrar_prenda_screen.dart'; // Ajusta la ruta según tu estructura de carpetas
import '../../business/usecases/registrar_inventario_usecase.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF), // Fondo claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icono de retroceso con doble flecha
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inventario',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1452BD), size: 32),
            onPressed: () {
              final tuUseCase = RegistrarInventarioUseCase(
                inventarioRepository: InventarioRepository(),
                prendaRepository: PrendaRepository(),
                tallaRepository: TallaRepository(),
                escuelaRepository: EscuelaRepository(),
              );

              // 2. Ejecutamos la navegación que proporcionaste
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrarPrendaScreen(
                    registrarInventarioUseCase: tuUseCase,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // El Consumer redibuja la pantalla cuando el Provider lo notifica
      body: Consumer<InventarioProvider>(
        builder: (context, provider, child) {
          if (provider.cargando && provider.escuelas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 1. Selector de Escuelas (Dropdown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Container(
                  // Línea azul inferior del Dropdown
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1452BD), width: 1.5))
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: provider.escuelaSeleccionada?.idEscuela,
                      hint: const Text('(Nombre de la escuela)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF333333)),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          provider.cargarInventario(newValue); // Petición de filtrado
                        }
                      },
                      items: provider.escuelas.map((escuela) {
                        return DropdownMenuItem<int>(
                          value: escuela.idEscuela,
                          child: Text(escuela.nombre, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 2. Lista de Inventario Filtrada
              Expanded(
                child: provider.cargando
                    ? const Center(child: CircularProgressIndicator())
                    : provider.itemsInventario.isEmpty
                        ? const Center(child: Text('No hay prendas registradas para esta escuela.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: provider.itemsInventario.length,
                            itemBuilder: (context, index) {
                              final item = provider.itemsInventario[index];
                              return _ItemInventario(item: item);
                            },
                          ),
              ),
            ],
          );
        },
      ),
      // 3. Barra de navegación inferior
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// --- Componentes Privados para mantener el código limpio ---

class _ItemInventario extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemInventario({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      // Línea separadora azul gruesa
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1452BD), width: 2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['prenda'] ?? '(Tipo de prenda)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 12),
          Text('Talla: ${item['talla'] ?? '(Talla)'}', style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          const SizedBox(height: 12),
          Text('Precio: \$${item['precio']?.toString() ?? '(Precio)'}', style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          const SizedBox(height: 12),
          Text('Cantidad: ${item['stock']?.toString() ?? '(Cantidad)'}', style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navegar a edición o detalle
              },
              child: const Text('Administrar', style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

