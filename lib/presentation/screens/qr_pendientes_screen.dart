import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../data/repositories/unidad_repository.dart';

import '../providers/qr_pendientes_provider.dart';
import '../providers/print_provider.dart';

/// Pantalla que muestra las unidades cuyo QR está pendiente de impresión.
/// 
/// - Componente de tipo [StatelessWidget] que crea y provee un [QrPendientesProvider].
/// - El proveedor carga los pendientes al inicializarse mediante `cargarPendientes()`.
class QrPendientesScreen
    extends StatelessWidget {

  /// Constructor por defecto.
  const QrPendientesScreen({
    super.key,
  });

  /// Construye el árbol de widgets y envuelve la vista en un [ChangeNotifierProvider].
  /// 
  /// - Se inyecta una instancia de [QrPendientesProvider] con su repositorio.
  /// - Se llama a `cargarPendientes()` inmediatamente para iniciar la carga de datos.
  @override
  Widget build(
    BuildContext context,
  ) {

    return ChangeNotifierProvider(

      create: (_) =>
          QrPendientesProvider(

        repository:
            UnidadRepository(),
      )
            ..cargarPendientes(),

      child: const
          _QrPendientesView(),
    );
  }
}

/// Vista interna que consume [QrPendientesProvider] y renderiza la UI.
/// 
/// - Muestra estados: cargando, vacío o lista de pendientes.
/// - Permite reimprimir QRs y actualizar el estado en el repositorio.
class _QrPendientesView
    extends StatelessWidget {

  const _QrPendientesView();

  @override
  Widget build(
    BuildContext context,
  ) {

    // Observa el proveedor para reconstruir la vista cuando cambian los pendientes.
    final provider =
        context.watch<
            QrPendientesProvider>();

    return Scaffold(

      // Color de fondo consistente con el resto de pantallas.
      backgroundColor:
          const Color(
        0xFFF5FAFF,
      ),

      appBar: AppBar(

        // AppBar transparente sin elevación para diseño plano.
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
          onPressed: () {

            Navigator.pop(
              context,
            );
          },
        ),

        title: const Text(

          'QR Pendientes',

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

      // Cuerpo: muestra un indicador de carga, mensaje vacío o la lista de pendientes.
      body:
          provider.cargando

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : provider
                      .pendientes
                      .isEmpty

                  ? const Center(

                      child: Text(
                        'No hay QR pendientes',
                      ),
                    )

                  : ListView.separated(

                      padding:
                          const EdgeInsets.all(
                        24,
                      ),

                      itemCount:
                          provider
                              .pendientes
                              .length,

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
                            provider
                                .pendientes[index];

                        return Container(

                          padding:
                              const EdgeInsets.all(
                            18,
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

                              // Nombre de la escuela asociada al QR pendiente.
                              Text(

                                item[
                                    'escuela'],

                                style:
                                    const TextStyle(

                                  fontWeight:
                                      FontWeight.bold,

                                  fontSize:
                                      18,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              // Nombre de la prenda.
                              Text(
                                item['prenda'],
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              // Talla de la unidad.
                              Text(
                                'Talla ${item['talla']}',
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              SizedBox(

                                width:
                                    double.infinity,

                                child:
                                    ElevatedButton.icon(

                                  // Acción principal: reimprimir el QR y actualizar el estado.
                                  onPressed:
                                      () async {

                                    try {

                                      // Llama al PrintProvider para imprimir el QR existente.
                                      await context
                                          .read<PrintProvider>()
                                          .imprimirQrExistente(

                                        item['id_unidad'],
                                      );

                                      // Marca la unidad como ya impresa en el repositorio.
                                      await UnidadRepository()
                                          .quitarPendienteImpresion(

                                        item['id_unidad'],
                                      );

                                      // Recarga la lista de pendientes desde el proveedor.
                                      await provider
                                          .cargarPendientes();

                                      // Verifica que el contexto siga montado antes de mostrar UI.
                                      if (!context
                                          .mounted) {
                                        return;
                                      }

                                      // Notificación de éxito al usuario.
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(

                                        const SnackBar(

                                          content:
                                              Text(
                                            'QR reimpreso correctamente',
                                          ),
                                        ),
                                      );

                                    } catch (_) {

                                      // En caso de error, verificar contexto y notificar.
                                      if (!context
                                          .mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(

                                        const SnackBar(

                                          content:
                                              Text(
                                            'No se pudo imprimir el QR',
                                          ),
                                        ),
                                      );
                                    }
                                  },

                                  // Estilos del botón de reimpresión.
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

                                  icon:
                                      const Icon(
                                    Icons.print,
                                  ),

                                  label:
                                      const Text(

                                    'Reimprimir',

                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
