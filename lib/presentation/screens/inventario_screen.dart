// lib/presentation/screens/inventario_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../business/providers/inventario_provider.dart';

import 'bottom_nav_bar.dart';
import 'administrar_prenda_screen.dart';
import 'registrar_prenda_screen.dart';
import 'qr_pendientes_screen.dart';

import '../../business/usecases/registrar_inventario_usecase.dart';

import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../data/repositories/talla_repository.dart';
import '../../data/repositories/escuela_repository.dart';

/// Pantalla de gestión de inventario.
/// 
/// Componente de tipo [StatelessWidget] que muestra controles para:
/// - seleccionar una escuela,
/// - filtrar por prenda,
/// - navegar a pantallas de registro y administración de prendas,
/// - ver QR pendientes.
/// La lógica de negocio relacionada con la carga y filtrado del inventario se
/// delega al proveedor [InventarioProvider].
class InventarioScreen
    extends StatelessWidget {

  /// Constructor por defecto de la pantalla de inventario.
  const InventarioScreen({
    super.key,
  });

  /// Construye la interfaz principal de inventario.
  /// 
  /// - Define un [Scaffold] con [AppBar], cuerpo y barra de navegación inferior.
  /// - El botón de añadir en la AppBar crea un [RegistrarInventarioUseCase]
  ///   con los repositorios necesarios y navega a [RegistrarPrendaScreen].
  /// - Tras regresar de la pantalla de registro se solicita recargar las escuelas
  ///   mediante `InventarioProvider.recargarEscuelas()`.
  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5FAFF,
      ),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(

          'Inventario',

          style: TextStyle(

            color:
                Color(
              0xFF1452BD,
            ),

            fontWeight:
                FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(

              Icons.add,

              color:
                  Color(
                0xFF1452BD,
              ),

              size: 30,
            ),

            // Acción del botón "add" en la AppBar:
            // - Construye el caso de uso `RegistrarInventarioUseCase` con los repositorios.
            // - Navega a la pantalla de registro de prenda.
            // - Al volver, solicita al proveedor recargar la lista de escuelas.
            onPressed: () {

              final useCase =
                  RegistrarInventarioUseCase(

                inventarioRepository:
                    InventarioRepository(),

                prendaRepository:
                    PrendaRepository(),

                tallaRepository:
                    TallaRepository(),

                escuelaRepository:
                    EscuelaRepository(),
              );

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      RegistrarPrendaScreen(

                    registrarInventarioUseCase:
                        useCase,
                  ),
                ),
              ).then(
                (_) {

                  context
                      .read<
                          InventarioProvider>()
                      .recargarEscuelas();
                },
              );
            },
          ),
        ],
      ),

      body:
          Consumer<
              InventarioProvider>(

        // Consumer escucha cambios en InventarioProvider y reconstruye el cuerpo.
        builder:
            (
          context,
          provider,
          child,
        ) {

          return Column(

            children: [

              Padding(

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                // Dropdown para seleccionar la escuela.
                child:
                    DropdownButton<int>(

                  value:
                      provider
                          .escuelaSeleccionada
                          ?.idEscuela,

                  hint:
                      const Text(
                    'Selecciona escuela',
                  ),

                  isExpanded: true,

                  // Al cambiar la escuela se carga el inventario correspondiente.
                  onChanged:
                      (value) {

                    if (value !=
                        null) {

                      provider
                          .cargarInventario(
                        value,
                      );
                    }
                  },

                  // Genera las opciones del dropdown a partir de provider.escuelas.
                  items:
                      provider
                          .escuelas
                          .map(
                    (e) {

                      return DropdownMenuItem<int>(

                        value:
                            e.idEscuela,

                        child: Text(
                          e.nombre,
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),

              // Si hay una escuela seleccionada, muestra el filtro por prenda.
              if (provider
                      .escuelaSeleccionada !=
                  null)

                Padding(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  child:
                      DropdownButton<int>(

                    value:
                        provider
                            .idPrendaSeleccionada,

                    hint:
                        const Text(
                      'Filtrar por prenda',
                    ),

                    isExpanded: true,

                    // Al seleccionar una prenda se delega al proveedor la lógica.
                    onChanged:
                        (value) {

                      provider
                          .seleccionarPrenda(
                        value,
                      );
                    },

                    items:
                        provider
                            .prendas
                            .map(
                      (p) {

                        return DropdownMenuItem<int>(

                          value:
                              p.idPrenda,

                          child: Text(
                            p.nombre,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),

              const SizedBox(
                height: 14,
              ),

              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child:
                    SizedBox(

                  width:
                      double.infinity,

                  // Botón que navega a la pantalla de QR pendientes.
                  child:
                      ElevatedButton.icon(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const QrPendientesScreen(),
                        ),
                      );
                    },

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(
                        0xFF1452BD,
                      ),

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    icon:
                        const Icon(
                      Icons.print,
                    ),

                    label:
                        const Text(

                      'QR Pendientes',

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Expanded(

                // Estado condicional del contenido principal:
                // - Si no hay escuela seleccionada: mensaje para seleccionar una escuela.
                // - Si la escuela está seleccionada pero no hay items: mensaje "No hay registros".
                // - Si hay items: muestra la lista agrupada por prenda.
                child:
                    provider
                                .escuelaSeleccionada ==
                            null

                        ? const Center(

                            child: Text(
                              'Selecciona una escuela',
                            ),
                          )

                        : provider
                                .itemsInventario
                                .isEmpty

                            ? const Center(

                                child: Text(
                                  'No hay registros',
                                ),
                              )

                            : _ListaInventario(

                                items:
                                    provider
                                        .itemsInventario
                                        .cast<
                                            Map<String, dynamic>>(),
                              ),
              ),
            ],
          );
        },
      ),

      // Barra de navegación inferior reutilizable.
      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}

/// Lista que renderiza los elementos del inventario agrupados por prenda.
/// 
/// - Recibe una lista de mapas con los campos esperados: 'prenda', 'talla',
///   'precio', 'stock', 'id', 'escuela'.
/// - Implementa lógica simple para mostrar un header cada vez que cambia la prenda.
class _ListaInventario
    extends StatelessWidget {

  /// Lista de items de inventario representados como mapas dinámicos.
  final List<Map<String, dynamic>>
      items;

  /// Constructor que recibe la lista de items.
  const _ListaInventario({
    required this.items,
  });

  /// Construye el [ListView] agrupando por el campo 'prenda'.
  /// 
  /// - Mantiene una variable local `ultimaPrenda` para detectar cambios de grupo.
  /// - Cada vez que `item['prenda']` difiere de `ultimaPrenda` se renderiza un header.
  @override
  Widget build(
    BuildContext context,
  ) {

    String? ultimaPrenda;

    return ListView.builder(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      itemCount:
          items.length,

      itemBuilder:
          (
        context,
        index,
      ) {

        final item =
            items[index];

        // Determina si se debe mostrar el encabezado de prenda para este item.
        final mostrarHeader =
            item['prenda'] !=
                ultimaPrenda;

        ultimaPrenda =
            item['prenda'];

        return Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            if (mostrarHeader)

              Padding(

                padding:
                    const EdgeInsets.only(
                  top: 16,
                ),

                child: Text(

                  item['prenda'],

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize:
                        16,

                    color:
                        Color(
                      0xFF1452BD,
                    ),
                  ),
                ),
              ),

            // Renderiza la fila de detalle del inventario.
            _ItemInventario(
              item: item,
            ),
          ],
        );
      },
    );
  }
}

/// Widget que representa una fila de inventario con datos básicos y acción.
/// 
/// - Muestra talla, precio y cantidad.
/// - Proporciona un botón "Administrar" que navega a [AdministrarPrendaScreen]
///   pasando los parámetros necesarios (idInventario, nombreEscuela, nombrePrenda,
///   talla, cantidad).
/// - Tras regresar de la pantalla de administración se solicita recargar las escuelas.
class _ItemInventario
    extends StatelessWidget {

  /// Mapa con los datos del item de inventario.
  final Map<String, dynamic>
      item;

  /// Constructor que recibe el item.
  const _ItemInventario({
    required this.item,
  });

  /// Construye la representación visual del item.
  @override
  Widget build(
    BuildContext context,
  ) {

    return Container(

      padding:
          const EdgeInsets.only(
        top: 12,
        bottom: 12,
      ),

      decoration:
          const BoxDecoration(

        border: Border(

          bottom: BorderSide(

            color:
                Color(
              0xFF1452BD,
            ),

            width: 1.5,
          ),
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          // Muestra la talla del item.
          Text(
            'Talla: ${item['talla']}',
          ),

          const SizedBox(
            height: 6,
          ),

          // Muestra el precio del item.
          Text(
            'Precio: \$${item['precio']}',
          ),

          const SizedBox(
            height: 6,
          ),

          // Muestra la cantidad en stock.
          Text(
            'Cantidad: ${item['stock']}',
          ),

          Align(

            alignment:
                Alignment.centerRight,

            child: TextButton(

              // Acción del botón "Administrar":
              // - Navega a AdministrarPrendaScreen con los datos del item.
              // - Al volver, solicita recargar las escuelas en el proveedor.
              onPressed: () {

                final idInventario =
                    item['id'];

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        AdministrarPrendaScreen(

                      idInventario:
                          idInventario,

                      nombreEscuela:
                          item['escuela'] ??
                              'Sin Escuela',

                      nombrePrenda:
                          item['prenda'] ??
                              'Prenda',

                      talla:
                          item['talla'] ??
                              'Talla',

                      cantidad:
                          item['stock'] ??
                              0,
                    ),
                  ),
                ).then(
                  (_) {

                    context
                        .read<
                            InventarioProvider>()
                        .recargarEscuelas();
                  },
                );
              },

              child:
                  const Text(

                'Administrar',

                style: TextStyle(

                  color:
                      Color(
                    0xFF1452BD,
                  ),

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
