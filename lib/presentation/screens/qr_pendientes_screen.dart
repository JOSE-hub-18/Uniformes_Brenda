import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../data/repositories/unidad_repository.dart';

import '../providers/qr_pendientes_provider.dart';
import '../providers/print_provider.dart';

class QrPendientesScreen
    extends StatelessWidget {

  const QrPendientesScreen({
    super.key,
  });

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

class _QrPendientesView
    extends StatelessWidget {

  const _QrPendientesView();

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        context.watch<
            QrPendientesProvider>();

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

                              Text(
                                item['prenda'],
                              ),

                              const SizedBox(
                                height: 4,
                              ),

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

                                  onPressed:
                                      () async {

                                    try {

                                      await context
                                          .read<PrintProvider>()
                                          .imprimirQrExistente(

                                        item['id_unidad'],
                                      );

                                      await UnidadRepository()
                                          .quitarPendienteImpresion(

                                        item['id_unidad'],
                                      );

                                      await provider
                                          .cargarPendientes();

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
                                            'QR reimpreso correctamente',
                                          ),
                                        ),
                                      );

                                    } catch (_) {

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