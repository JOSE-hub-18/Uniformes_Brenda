// lib/presentation/screens/revisar_pedido_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';

import '../providers/pedidos_pendientes_provider.dart';
import 'qr_screen.dart';

class RevisarPedidoScreen
    extends StatefulWidget {

  final int idPedido;

  const RevisarPedidoScreen({
    super.key,
    required this.idPedido,
  });

  @override
  State<
          RevisarPedidoScreen>
      createState() =>
          _RevisarPedidoScreenState();
}

class _RevisarPedidoScreenState
    extends State<
        RevisarPedidoScreen> {

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {

        await context
            .read<
                PedidosPendientesProvider>()
            .cargarDetalles(
          widget.idPedido,
        );
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

    final detalles =
        provider.detalles;

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

        title: Text(
          'Pedido #${widget.idPedido}',

          style: const TextStyle(
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

      body: Column(

        children: [

          Expanded(

            child:
                ListView.separated(

              padding:
                  const EdgeInsets.all(
                24,
              ),

              itemCount:
                  detalles.length,

              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 16,
              ),

              itemBuilder:
                  (context, index) {

                final detalle =
                    detalles[index];

                final registrado =
                    detalle[
                            'registrado'] ==
                        1;

                return Container(

                  key: ValueKey(
                    detalle['id'],
                  ),

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.white,

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
                        CrossAxisAlignment
                            .start,

                    children: [

                      Row(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Expanded(

                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  detalle[
                                      'prenda'],

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    fontSize:
                                        18,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  detalle[
                                      'escuela'],

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .black,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  'Talla ${detalle['talla']}',

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          AbsorbPointer(

                            absorbing:
                                provider
                                    .cargando,

                            child:
                                GestureDetector(

                              onTap:
                                  () async {

                                final ultimo =
                                    detalles.length ==
                                        1;

                                if (ultimo) {

                                  final confirmar =
                                      await showDialog<bool>(

                                    context:
                                        context,

                                    builder:
                                        (_) {

                                      return AlertDialog(

                                        title:
                                            const Text(
                                          'Eliminar pedido',
                                        ),

                                        content:
                                            const Text(
                                          'Esta es la última prenda del pedido.\n\n¿Deseas eliminar completamente el pedido?',
                                        ),

                                        actions: [

                                          TextButton(

                                            onPressed:
                                                () {

                                              Navigator.pop(
                                                context,
                                                false,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Cancelar',
                                            ),
                                          ),

                                          TextButton(

                                            onPressed:
                                                () {

                                              Navigator.pop(
                                                context,
                                                true,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Eliminar',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmar !=
                                      true) {
                                    return;
                                  }
                                }

                                final eliminado =
                                    await provider
                                        .eliminarDetallePedido(

                                  idPedido:
                                      widget.idPedido,

                                  idDetallePedido:
                                      detalle['id'],
                                );

                                if (!context
                                    .mounted) {
                                  return;
                                }

                                if (eliminado) {

                                  ScaffoldMessenger
                                          .of(
                                    context,
                                  ).showSnackBar(

                                    const SnackBar(
                                      content:
                                          Text(
                                        'Pedido eliminado correctamente',
                                      ),
                                    ),
                                  );

                                  Navigator.pop(
                                    context,
                                    true,
                                  );

                                  return;
                                }

                                ScaffoldMessenger
                                        .of(
                                  context,
                                ).showSnackBar(

                                  const SnackBar(
                                    content:
                                        Text(
                                      'Prenda eliminada correctamente',
                                    ),
                                  ),
                                );
                              },

                              child: Container(

                                padding:
                                    const EdgeInsets.all(
                                  4,
                                ),

                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Colors
                                          .red,

                                  shape:
                                      BoxShape
                                          .circle,
                                ),

                                child:
                                    const Icon(
                                  Icons.close,

                                  color:
                                      Colors
                                          .white,

                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      if (!registrado)

                        SizedBox(

                          width:
                              double.infinity,

                          child:
                              ElevatedButton.icon(

                            onPressed:
                                () async {

                              await Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                      (_) =>
                                          QRScannerScreen(

                                    mostrarMensaje:
                                        false,

                                    onScan:
                                        (String qr)
                                            async {

                                      try {

                                        final conflicto =
                                            await provider
                                                .registrarQrPedido(

                                          idPedido:
                                              widget.idPedido,

                                          idDetallePedido:
                                              detalle[
                                                  'id'],

                                          idInventarioEsperado:
                                              detalle[
                                                  'id_inventario'],

                                          qr: qr,
                                        );

                                        if (conflicto !=
                                                null &&
                                            conflicto[
                                                    'conflicto'] ==
                                                true) {

                                          if (!context
                                              .mounted) {

                                            return ScanFeedback(
                                              resultado:
                                                  ResultadoScan.error,

                                              mensaje:
                                                  'Operación cancelada',
                                            );
                                          }

                                          final mover =
                                              await showDialog<bool>(

                                            context:
                                                context,

                                            builder:
                                                (_) {

                                              return AlertDialog(

                                                title:
                                                    const Text(
                                                  'Mover QR',
                                                ),

                                                content:
                                                    Text(
                                                  'Esta unidad ya está registrada en el Pedido #${conflicto['pedido_anterior']}.\n\n¿Deseas moverla a este pedido?',
                                                ),

                                                actions: [

                                                  TextButton(

                                                    onPressed:
                                                        () {

                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      );
                                                    },

                                                    child:
                                                        const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),

                                                  TextButton(

                                                    onPressed:
                                                        () {

                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      );
                                                    },

                                                    child:
                                                        const Text(
                                                      'Mover',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (mover !=
                                              true) {

                                            return ScanFeedback(
                                              resultado:
                                                  ResultadoScan.error,

                                              mensaje:
                                                  'Movimiento cancelado',
                                            );
                                          }

                                          await provider
                                              .registrarQrPedido(

                                            idPedido:
                                                widget.idPedido,

                                            idDetallePedido:
                                                detalle[
                                                    'id'],

                                            idInventarioEsperado:
                                                detalle[
                                                    'id_inventario'],

                                            qr: qr,

                                            forzarMovimiento:
                                                true,
                                          );
                                        }

                                        if (!context
                                            .mounted) {

                                          return ScanFeedback(
                                            resultado:
                                                ResultadoScan.ok,

                                            mensaje:
                                                'QR registrado',
                                          );
                                        }

                                        Navigator.pop(
                                          context,
                                        );

                                        return ScanFeedback(

                                          resultado:
                                              ResultadoScan.ok,

                                          mensaje:
                                              'QR registrado',
                                        );

                                      } catch (e) {

                                        return ScanFeedback(

                                          resultado:
                                              ResultadoScan.error,

                                          mensaje:
                                              e.toString(),
                                        );
                                      }
                                    },
                                  ),
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
                            ),

                            icon: const Icon(
                              Icons
                                  .qr_code_scanner,

                              color:
                                  Colors.white,
                            ),

                            label:
                                const Text(
                              'Escanear QR',

                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .white,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                      if (registrado)

                        Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Container(

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    12,

                                vertical:
                                    10,
                              ),

                              decoration:
                                  BoxDecoration(

                                color:
                                    Colors
                                        .green,

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child: Row(

                                children: [

                                  const Icon(
                                    Icons
                                        .check_circle,

                                    color:
                                        Colors
                                            .white,
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Expanded(

                                    child: Text(

                                      'QR #${detalle['id_unidad_registrada']} registrado',

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors
                                                .white,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            SizedBox(

                              width:
                                  double.infinity,

                              child:
                                  ElevatedButton(

                                onPressed:
                                    () async {

                                  final confirmar =
                                      await showDialog<bool>(

                                    context:
                                        context,

                                    builder:
                                        (_) {

                                      return AlertDialog(

                                        title:
                                            const Text(
                                          'Quitar registro',
                                        ),

                                        content:
                                            const Text(
                                          '¿Seguro que deseas quitar el registro QR?',
                                        ),

                                        actions: [

                                          TextButton(

                                            onPressed:
                                                () {

                                              Navigator.pop(
                                                context,
                                                false,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Cancelar',
                                            ),
                                          ),

                                          TextButton(

                                            onPressed:
                                                () {

                                              Navigator.pop(
                                                context,
                                                true,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Quitar',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmar !=
                                      true) {
                                    return;
                                  }

                                  await provider
                                      .desregistrarUnidad(

                                    idPedido:
                                        widget.idPedido,

                                    idDetallePedido:
                                        detalle[
                                            'id'],
                                  );

                                  if (!context
                                      .mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger
                                          .of(
                                    context,
                                  ).showSnackBar(

                                    const SnackBar(
                                      content:
                                          Text(
                                        'Registro QR eliminado',
                                      ),
                                    ),
                                  );
                                },

                                style:
                                    ElevatedButton.styleFrom(

                                  backgroundColor:
                                      Colors
                                          .red,

                                  foregroundColor:
                                      Colors
                                          .white,
                                ),

                                child:
                                    const Text(
                                  'Desregistrar',
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
          ),

          Container(

            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                const BoxDecoration(
              color: Colors.white,
            ),

            child: SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:

                    detalles.isNotEmpty &&
                            detalles.every(
                              (d) =>
                                  d['registrado'] ==
                                  1,
                            )

                        ? () async {

                            try {

                              await provider
                                  .completarPedido(
                                widget.idPedido,
                              );

                              if (!context
                                  .mounted) {
                                return;
                              }

                              if (context
        .read<InventarioProvider>()
        .escuelaSeleccionada !=
    null) {

  await context
      .read<InventarioProvider>()
      .cargarInventario(

    context
        .read<InventarioProvider>()
        .escuelaSeleccionada!
        .idEscuela!,
  );
}

if (!context.mounted) {
  return;
}

ScaffoldMessenger
        .of(
  context,
).showSnackBar(

  const SnackBar(
    content:
        Text(
      'Pedido completado correctamente',
    ),
  ),
);

Navigator.pop(
  context,
  true,
);

                            } catch (e) {

                              if (!context
                                  .mounted) {
                                return;
                              }

                              ScaffoldMessenger
                                      .of(
                                context,
                              ).showSnackBar(

                                SnackBar(
                                  content:
                                      Text(
                                    e.toString(),
                                  ),
                                ),
                              );
                            }
                          }

                        : null,

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
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                child: const Text(

                  'Completar Pedido',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}