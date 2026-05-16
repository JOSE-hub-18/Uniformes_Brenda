// lib/presentation/screens/pedidos_pendientes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pedidos_pendientes_provider.dart';

import '../../models/models.dart';

import 'nueva_orden_screen.dart';
import 'revisar_pedido_screen.dart';
import 'bottom_nav_bar.dart';

class PedidosPendientesScreen
    extends StatefulWidget {

  const PedidosPendientesScreen({
    super.key,
  });

  @override
  State<
          PedidosPendientesScreen>
      createState() =>
          _PedidosPendientesScreenState();
}

class _PedidosPendientesScreenState
    extends State<
        PedidosPendientesScreen> {

  @override
  void initState() {

    super.initState();

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

      bottomNavigationBar:
          const BottomNavBar(),
    );
  }

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

          Text(
            'Cliente: ${pedido.nombreCliente ?? 'Sin nombre'}',
          ),

          const SizedBox(
            height: 4,
          ),

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

              TextButton(

  onPressed: () async {

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