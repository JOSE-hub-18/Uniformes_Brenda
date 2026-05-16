// lib/presentation/screens/pedidos_pendientes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pedidos_pendientes_provider.dart';

import '../../models/models.dart';

import 'nueva_orden_screen.dart';
import 'revisar_pedido_screen.dart';
import 'bottom_nav_bar.dart';

/// Pantalla que muestra la lista de pedidos pendientes.
/// 
/// - Componente de tipo [StatefulWidget] que consulta al proveedor
///   [PedidosPendientesProvider] para obtener los pedidos pendientes.
/// - Permite crear un nuevo pedido y revisar pedidos existentes.
/// - La recarga de datos se realiza en `initState` mediante el provider.
class PedidosPendientesScreen
    extends StatefulWidget {

  /// Constructor por defecto de la pantalla de pedidos pendientes.
  const PedidosPendientesScreen({
    super.key,
  });

  @override
  State<
          PedidosPendientesScreen>
      createState() =>
          _PedidosPendientesScreenState();
}

/// Estado asociado a [PedidosPendientesScreen].
/// 
/// - Inicializa la carga de pedidos pendientes una vez que el primer frame
///   ha sido renderizado.
/// - Observa cambios en el provider para actualizar la UI.
class _PedidosPendientesScreenState
    extends State<
        PedidosPendientesScreen> {

  @override
  void initState() {

    super.initState();

    // Ejecuta la carga de pedidos después del primer frame para evitar
    // llamadas al provider antes de que el contexto esté completamente disponible.
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {

        await context
            .read<
                PedidosPendientesProvider>()
            .cargarPedidos();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    // Observa el provider para reconstruir la pantalla cuando cambien los pedidos.
    final provider =
        context.watch<
            PedidosPendientesProvider>();

    final pedidos =
        provider.pedidos;

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5FAFF,
      ),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons
                .keyboard_double_arrow_left,
            color:
                Color(
              0xFF1452BD,
            ),
            size: 32,
          ),

          // Acción para regresar a la pantalla anterior.
          onPressed: () =>
              Navigator.pop(
            context,
          ),
        ),

        title: const Text(
          'Pedidos Pendientes',
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
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),

        child: Column(

          children: [

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                // Botón para crear un nuevo pedido; navega a la pantalla de agregar pedido.
                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder:
                          (_) =>
                              const AgregarPedidoScreen(),
                    ),
                  );
                },

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                    0xFF3388D6,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  elevation: 0,
                ),

                child: const Text(
                  '+ Nuevo pedido',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Lista de tarjetas de pedidos; usa ListView.separated para separación visual.
            ListView.separated(

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount:
                  pedidos.length,

              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 16,
              ),

              itemBuilder:
                  (context, index) {

                final pedido =
                    pedidos[index];

                return _buildPedidoCard(
                  context,
                  pedido,
                );
              },
            ),
          ],
        ),
      ),

      // Barra de navegación inferior reutilizable.
      bottomNavigationBar:
          const BottomNavBar(),
    );
  }

  /// Construye la tarjeta visual que representa un pedido pendiente.
  /// 
  /// - Muestra información básica: id, cliente, fecha y estado.
  /// - Incluye acción "Ver" que navega a [RevisarPedidoScreen] y espera un
  ///   resultado booleano que indica si el pedido fue eliminado o modificado.
  /// - Si el resultado es `true`, se recargan los pedidos desde el provider.
  Widget _buildPedidoCard(
    BuildContext context,
    Pedido pedido,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE0E0E0,
          ),
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // Identificador del pedido.
          Text(
            'Pedido #${pedido.id}',

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // Nombre del cliente; si no existe, se muestra 'Sin nombre'.
          Text(
            'Cliente: ${pedido.nombreCliente ?? 'Sin nombre'}',
          ),

          const SizedBox(
            height: 4,
          ),

          // Fecha del pedido formateada manualmente (día/mes/año).
          Text(
            'Fecha: ${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}',
          ),

          const SizedBox(
            height: 12,
          ),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              // Badge de estado: en esta pantalla todos los pedidos listados son "Pendiente".
              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      const Color(
                    0xFFECCC15,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: const Text(
                  'Pendiente',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              // Botón "Ver" que abre la pantalla de revisión del pedido.
              TextButton(

  onPressed: () async {

  // Navega a RevisarPedidoScreen y espera un booleano indicando si el pedido fue eliminado.
  final eliminado =
      await Navigator.push<bool>(
    context,

    MaterialPageRoute(
      builder:
          (_) =>
              RevisarPedidoScreen(
        idPedido:
            pedido.id!,
      ),
    ),
  );

  // Si el pedido fue eliminado (true) y el contexto sigue montado, recargar la lista.
  if (eliminado == true &&
      context.mounted) {

    await context
        .read<
            PedidosPendientesProvider>()
        .cargarPedidos();
  }
},

                child: const Text(

                  'Ver',

                  style: TextStyle(

                    color:
                        Color(
                      0xFF1452BD,
                    ),

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
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
