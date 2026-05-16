// lib/presentation/screens/revisar_venta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';

import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../providers/ventas_provider.dart';
import '../providers/print_provider.dart';

import 'bottom_nav_bar.dart';

class RevisarVentaScreen
    extends StatefulWidget {

  final int idVenta;

  const RevisarVentaScreen({
    super.key,
    required this.idVenta,
  });

  @override
  State<
          RevisarVentaScreen>
      createState() =>
          _RevisarVentaScreenState();
}

class _RevisarVentaScreenState
    extends State<
        RevisarVentaScreen> {

  final _ventaRepository =
      VentaRepository();

  final _unidadRepository =
      UnidadRepository();

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {

        context
            .read<
                VentasProvider>()
            .cargarDetalles(
          widget.idVenta,
        );
      },
    );
  }

  Future<void>
      _devolverPrenda({

    required int idDetalleVenta,

    required int idUnidad,

    required int idInventario,
  }) async {

    // Reactivar unidad

    await _unidadRepository
        .reactivar(
      idUnidad,
    );

    // Eliminar detalle venta

    await _ventaRepository
        .eliminarDetalleVenta(
      idDetalleVenta,
    );

    // Reimprimir QR

    if (!mounted) {
      return;
    }

    try {

  await context
      .read<PrintProvider>()
      .imprimirQrExistente(
    idUnidad,
  );

  await _unidadRepository
      .quitarPendienteImpresion(
    idUnidad,
  );

} catch (_) {

  await _unidadRepository
      .marcarPendienteImpresion(
    idUnidad,
  );

  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(

    const SnackBar(
      content: Text(
        'No se pudo imprimir el QR.\nLa prenda quedó pendiente de impresión.',
      ),
    ),
  );
}

    // Contar detalles restantes

    final restantes =
        await _ventaRepository
            .contarDetallesVenta(
      widget.idVenta,
    );

    // Si ya no quedan prendas
    // eliminar venta completa

    if (restantes <= 0) {

      await _ventaRepository
          .eliminar(
        widget.idVenta,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Venta eliminada completamente',
          ),
        ),
      );

      await context
    .read<VentasProvider>()
    .cargarVentas();

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

Navigator.pop(
  context,
  true,
);

      return;
    }

    // Recargar detalles

    if (!mounted) {
      return;
    }

    await context
        .read<VentasProvider>()
        .cargarDetalles(
      widget.idVenta,
    );

    await context
    .read<VentasProvider>()
    .cargarVentas();

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

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      const SnackBar(
        content: Text(
          'Prenda devuelta correctamente',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        context.watch<
            VentasProvider>();

    final detalles =
        provider.detalles;

    final total =
        detalles.fold<double>(

      0,

      (
        suma,
        item,
      ) {

        return suma +
            ((item[
                        'precio_unitario']
                    as num)
                .toDouble());
      },
    );

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

          'Revisar Venta',

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

      body:
          provider.cargando

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal: 24,
                    vertical: 16,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        'Venta #${widget.idVenta}',

                        style:
                            const TextStyle(

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,

                          color:
                              Color(
                            0xFF333333,
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
                            detalles.length,

                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 16,
                        ),

                        itemBuilder:
                            (
                          context,
                          index,
                        ) {

                          final item =
                              detalles[index];

                          return Container(

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

                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xFFE0E0E0,
                                ),
                              ),
                            ),

                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

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

                                            item[
                                                'prenda'],

                                            style:
                                                const TextStyle(

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize:
                                                  16,

                                              color:
                                                  Color(
                                                0xFF333333,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 4,
                                          ),

                                          Text(

                                            '${item['escuela']} • Talla ${item['talla']}',

                                            style:
                                                const TextStyle(

                                              color:
                                                  Color(
                                                0xFF777777,
                                              ),

                                              fontSize:
                                                  13,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 4,
                                          ),

                                          Text(

                                            'Unidad #${item['id_unidad']}',

                                            style:
                                                const TextStyle(

                                              color:
                                                  Color(
                                                0xFF999999,
                                              ),

                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(

                                      '\$${(item['precio_unitario'] as num).toStringAsFixed(0)}',

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
                                  ],
                                ),

                                const SizedBox(
                                  height: 14,
                                ),

                                Align(

                                  alignment:
                                      Alignment
                                          .centerRight,

                                  child:
                                      GestureDetector(

                                    onTap:
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
                                              'Devolver prenda',
                                            ),

                                            content:
                                                const Text(
                                              '¿Seguro que deseas devolver esta prenda?',
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
                                                  'Devolver',
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

                                      await _devolverPrenda(

                                        idDetalleVenta:
                                            item['id'],

                                        idUnidad:
                                            item['id_unidad'],

                                        idInventario:
                                            item['id_inventario'],
                                      );
                                    },

                                    child:
                                        const Padding(

                                      padding:
                                          EdgeInsets.symmetric(

                                        vertical:
                                            8,

                                        horizontal:
                                            4,
                                      ),

                                      child:
                                          Text(

                                        'Devolución',

                                        style:
                                            TextStyle(

                                          color:
                                              Color(
                                            0xFFD32F2F,
                                          ),

                                          fontWeight:
                                              FontWeight.bold,

                                          fontSize:
                                              18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      Container(

                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFFE0E0E0,
                            ),
                          ),
                        ),

                        child: Column(

                          children: [

                            Row(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                const Text(

                                  'Prendas',

                                  style:
                                      TextStyle(

                                    fontSize: 16,

                                    color:
                                        Color(
                                      0xFF666666,
                                    ),
                                  ),
                                ),

                                Text(

                                  '${detalles.length} piezas',

                                  style:
                                      const TextStyle(

                                    fontSize: 16,

                                    color:
                                        Color(
                                      0xFF666666,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Row(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                const Text(

                                  'TOTAL',

                                  style:
                                      TextStyle(

                                    fontSize: 18,

                                    fontWeight:
                                        FontWeight.bold,

                                    color:
                                        Color(
                                      0xFF333333,
                                    ),
                                  ),
                                ),

                                Text(

                                  '\$${total.toStringAsFixed(2)}',

                                  style:
                                      const TextStyle(

                                    fontSize: 18,

                                    fontWeight:
                                        FontWeight.bold,

                                    color:
                                        Color(
                                      0xFF333333,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                ),

      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}