// lib/presentation/screens/revisar_pedido_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';

import '../providers/pedidos_pendientes_provider.dart';
import 'qr_screen.dart';

/// Pantalla encargada de mostrar el detalle de un pedido pendiente,
/// permitiendo registrar unidades mediante códigos QR,
/// eliminar prendas del pedido y completar el pedido cuando
/// todas las unidades han sido registradas.
class RevisarPedidoScreen
    extends StatefulWidget {

  /// Identificador único del pedido que será consultado.
  final int idPedido;

  /// Constructor principal de la pantalla de revisión de pedidos.
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

/// Estado asociado a la pantalla RevisarPedidoScreen.
///
/// Gestiona la carga de detalles del pedido,
/// el registro de códigos QR y las acciones
/// relacionadas con el flujo operativo del pedido.
class _RevisarPedidoScreenState
    extends State<
        RevisarPedidoScreen> {

  @override
  void initState() {

    super.initState();

    // Ejecuta la carga del detalle del pedido
    // una vez que el primer frame de la interfaz
    // ha sido renderizado completamente.
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {

        // Solicita al provider la información
        // detallada del pedido seleccionado.
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

    // Obtiene la instancia observable del provider
    // para reconstruir la interfaz cuando existan cambios.
    final provider =
        context.watch<
            PedidosPendientesProvider>();

    // Lista de prendas o detalles asociados al pedido.
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

          // Retorna a la pantalla anterior.
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

              // Separador visual entre elementos
              // de la lista de detalles.
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 16,
              ),

              itemBuilder:
                  (context, index) {

                // Información correspondiente
                // al detalle actual del pedido.
                final detalle =
                    detalles[index];

                // Determina si la prenda ya cuenta
                // con una unidad registrada mediante QR.
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

                                // Nombre de la prenda solicitada.
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

                                // Escuela asociada al pedido.
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

                                // Talla solicitada de la prenda.
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

                          // Bloquea interacciones mientras exista
                          // una operación de carga en proceso.
                          AbsorbPointer(

                            absorbing:
                                provider
                                    .cargando,

                            child:
                                GestureDetector(

                              onTap:
                                  () async {

                                // Verifica si la prenda actual
                                // es el último detalle del pedido.
                                final ultimo =
                                    detalles.length ==
                                        1;

                                if (ultimo) {

                                  // Solicita confirmación antes de eliminar
                                  // completamente el pedido.
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

                                  // Cancela la operación si el usuario
                                  // no confirmó la eliminación.
                                  if (confirmar !=
                                      true) {
                                    return;
                                  }
                                }

                                // Elimina el detalle del pedido seleccionado.
                                final eliminado =
                                    await provider
                                        .eliminarDetallePedido(

                                  idPedido:
                                      widget.idPedido,

                                  idDetallePedido:
                                      detalle['id'],
                                );

                                // Verifica que el contexto
                                // siga montado antes de interactuar
                                // con la interfaz.
                                if (!context
                                    .mounted) {
                                  return;
                                }

                                // Si el pedido completo fue eliminado,
                                // se retorna a la pantalla anterior.
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

                                // Mensaje mostrado cuando únicamente
                                // se elimina una prenda específica.
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

                      // Se muestra únicamente si la prenda
                      // aún no tiene una unidad registrada.
                      if (!registrado)

                        SizedBox(

                          width:
                              double.infinity,

                          child:
                              ElevatedButton.icon(

                            onPressed:
                                () async {

                              // Navega hacia la pantalla
                              // encargada del escaneo QR.
                              await Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                      (_) =>
                                          QRScannerScreen(

                                    mostrarMensaje:
                                        false,

                                    // Callback ejecutado al detectar
                                    // un código QR válido.
                                    onScan:
                                        (String qr)
                                            async {

                                      try {

                                        // Intenta registrar el QR
                                        // para el detalle seleccionado.
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

                                        // Regla de negocio:
                                        // un QR únicamente puede pertenecer
                                        // a un pedido activo a la vez.
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

                                          // Solicita confirmación para mover
                                          // la unidad registrada desde
                                          // otro pedido al pedido actual.
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

                                          // Cancela el movimiento
                                          // si el usuario no confirma.
                                          if (mover !=
                                              true) {

                                            return ScanFeedback(
                                              resultado:
                                                  ResultadoScan.error,

                                              mensaje:
                                                  'Movimiento cancelado',
                                            );
                                          }

                                          // Fuerza la reasignación del QR
                                          // al pedido actual.
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

                                        // Retorna automáticamente
                                        // a la pantalla anterior
                                        // tras un registro exitoso.
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

                                        // Retorna información del error
                                        // ocurrido durante el proceso
                                        // de registro del QR.
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

                      // Sección visible únicamente
                      // cuando la prenda ya fue registrada.
                      if (registrado)

                        Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // Indicador visual de registro exitoso.
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

                                  // Solicita confirmación antes
                                  // de eliminar el registro QR.
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

                                  // Cancela la operación
                                  // si el usuario no confirma.
                                  if (confirmar !=
                                      true) {
                                    return;
                                  }

                                  // Elimina la relación
                                  // entre el QR y el detalle del pedido.
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

          // Contenedor inferior con la acción
          // principal para completar el pedido.
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

                    // Regla de negocio:
                    // el pedido únicamente puede completarse
                    // cuando todos los detalles han sido registrados.
                    detalles.isNotEmpty &&
                            detalles.every(
                              (d) =>
                                  d['registrado'] ==
                                  1,
                            )

                        ? () async {

                            try {

                              // Marca el pedido como completado.
                              await provider
                                  .completarPedido(
                                widget.idPedido,
                              );

                              if (!context
                                  .mounted) {
                                return;
                              }

                              // Recarga el inventario de la escuela
                              // actualmente seleccionada para reflejar
                              // los cambios posteriores al completado.
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

// Retorna indicando que existieron cambios
// sobre el pedido actual.
Navigator.pop(
  context,
  true,
);

                            } catch (e) {

                              // Manejo de errores durante
                              // el proceso de completado.
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