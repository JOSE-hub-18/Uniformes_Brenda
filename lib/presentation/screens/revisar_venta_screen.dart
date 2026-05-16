// lib/presentation/screens/revisar_venta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';

import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../providers/ventas_provider.dart';
import '../providers/print_provider.dart';

import 'bottom_nav_bar.dart';

/// Pantalla para revisar los detalles de una venta.
/// 
/// - Muestra los ítems vendidos asociados a una venta específica.
/// - Permite devolver prendas (reactivar unidad, eliminar detalle de venta),
///   reimprimir QRs y actualizar el inventario y listados relacionados.
class RevisarVentaScreen
    extends StatefulWidget {

  /// Identificador de la venta a revisar.
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

/// Estado asociado a [RevisarVentaScreen].
/// 
/// - Carga los detalles de la venta en `initState`.
/// - Proporciona la lógica para devolver prendas y actualizar vistas relacionadas.
class _RevisarVentaScreenState
    extends State<
        RevisarVentaScreen> {

  // Repositorios utilizados para operaciones de venta y unidad.
  final _ventaRepository =
      VentaRepository();

  final _unidadRepository =
      UnidadRepository();

  @override
  void initState() {

    super.initState();

    // Carga los detalles de la venta después del primer frame.
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

  /// Devuelve una prenda asociada a la venta.
  /// 
  /// Flujo:
  /// 1. Reactiva la unidad en el repositorio de unidades.
  /// 2. Elimina el detalle de venta correspondiente.
  /// 3. Intenta reimprimir el QR; si falla, marca la unidad como pendiente de impresión.
  /// 4. Recalcula si la venta quedó vacía y, en ese caso, elimina la venta completa.
  /// 5. Recarga listados y notifica al usuario mediante SnackBars.
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

      // Si la impresión falla, marcar la unidad como pendiente y notificar.
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

    // Si ya no quedan prendas eliminar venta completa
    if (restantes <= 0) {

      await _ventaRepository
          .eliminar(
        widget.idVenta,
      );

      if (!mounted) {
        return;
      }

      // Notificar eliminación completa de la venta.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Venta eliminada completamente',
          ),
        ),
      );

      // Recargar listado de ventas y, si aplica, el inventario de la escuela seleccionada.
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

      // Cerrar pantalla indicando que hubo un cambio.
      Navigator.pop(
        context,
        true,
      );

      return;
    }

    // Recargar detalles y listados relacionados
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

    // Notificación de éxito al usuario.
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

    // Observa el provider de ventas para obtener detalles y estado de carga.
    final provider =
        context.watch<
            VentasProvider>();

    final detalles =
        provider.detalles;

    // Calcula el total sumando los precios unitarios de los detalles.
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

          // Acción para regresar a la pantalla anterior.
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

      // Cuerpo: indicador de carga o contenido con detalles de la venta.
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

                      // Encabezado con número de venta.
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

                      // Lista de detalles de la venta.
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

                                          // Nombre de la prenda.
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

                                          // Escuela y talla.
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

                                          // Identificador de unidad.
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

                                    // Precio unitario mostrado a la derecha.
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

                                // Acción de devolución: abre diálogo de confirmación y llama a _devolverPrenda.
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

                                      // Ejecuta la devolución con los identificadores necesarios.
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

                      // Resumen de prendas y total.
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

      // Barra de navegación inferior reutilizable.
      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}
