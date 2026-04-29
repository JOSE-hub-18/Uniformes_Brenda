import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';
import 'bottom_nav_bar.dart';
import 'administrar_prenda_screen.dart';
import 'registrar_prenda_screen.dart';
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
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inventario',
          style: TextStyle(
            color: Color(0xFF1452BD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1452BD), size: 30),
            onPressed: () {
              final useCase = RegistrarInventarioUseCase(
                inventarioRepository: InventarioRepository(),
                prendaRepository: PrendaRepository(),
                tallaRepository: TallaRepository(),
                escuelaRepository: EscuelaRepository(),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegistrarPrendaScreen(
                    registrarInventarioUseCase: useCase,
                  ),
                ),
              ).then((_) {
                context.read<InventarioProvider>().recargarEscuelas();
              });
            },
          ),
        ],
      ),
      body: Consumer<InventarioProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<int>(
                  value: provider.escuelaSeleccionada?.idEscuela,
                  hint: const Text('Selecciona escuela'),
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      provider.cargarInventario(value);
                    }
                  },
                  items: provider.escuelas.map((e) {
                    return DropdownMenuItem<int>(
                      value: e.idEscuela,
                      child: Text(e.nombre),
                    );
                  }).toList(),
                ),
              ),

              if (provider.escuelaSeleccionada != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<int>(
                    value: provider.idPrendaSeleccionada,
                    hint: const Text('Filtrar por prenda'),
                    isExpanded: true,
                    onChanged: (value) {
                      provider.seleccionarPrenda(value);
                    },
                    items: provider.prendas.map((p) {
                      return DropdownMenuItem<int>(
                        value: p.idPrenda,
                        child: Text(p.nombre),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 10),

              Expanded(
                child: provider.escuelaSeleccionada == null
                    ? const Center(child: Text('Selecciona una escuela'))
                    : provider.itemsInventario.isEmpty
                        ? const Center(child: Text('No hay registros'))
                        : _ListaInventario(
                            items: provider.itemsInventario
                                .cast<Map<String, dynamic>>(),
                          ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class _ListaInventario extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _ListaInventario({required this.items});

  @override
  Widget build(BuildContext context) {
    String? ultimaPrenda;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        final mostrarHeader = item['prenda'] != ultimaPrenda;
        ultimaPrenda = item['prenda'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mostrarHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  item['prenda'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1452BD),
                  ),
                ),
              ),
            _ItemInventario(item: item),
          ],
        );
      },
    );
  }
}

class _ItemInventario extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemInventario({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1452BD),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Talla: ${item['talla']}'),
          const SizedBox(height: 6),
          Text('Precio: \$${item['precio']}'),
          const SizedBox(height: 6),
          Text('Cantidad: ${item['stock']}'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final idInventario = item['id'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdministrarPrendaScreen(
                      idInventario: idInventario,
                      nombreEscuela: item['escuela'] ?? 'Sin Escuela',
                      nombrePrenda: item['prenda'] ?? 'Prenda',
                      talla: item['talla'] ?? 'Talla',
                      cantidad: item['stock'] ?? 0,
                    ),
                  ),
                ).then((_) {
                  context.read<InventarioProvider>().recargarEscuelas();
                });
              },
              child: const Text(
                'Administrar',
                style: TextStyle(
                  color: Color(0xFF1452BD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}