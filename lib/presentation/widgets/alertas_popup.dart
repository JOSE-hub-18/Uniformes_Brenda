import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/alertas_provider.dart';

class AlertasPopup
    extends StatelessWidget {

  const AlertasPopup({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        context.watch<
            AlertasProvider>();

    return Dialog(

      backgroundColor:
          Colors.transparent,

      insetPadding:
          const EdgeInsets.symmetric(

        horizontal: 24,
        vertical: 40,
      ),

      child: Container(

        constraints:
            const BoxConstraints(
          maxHeight: 600,
        ),

        padding:
            const EdgeInsets.all(
          22,
        ),

        decoration:
            BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(

                  'Notificaciones',

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Color(
                      0xFF1452BD,
                    ),
                  ),
                ),

                IconButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            if (!provider
                .hayAlertas)

              const Expanded(

                child: Center(

                  child: Text(

                    'No hay alertas activas',

                    style: TextStyle(

                      fontSize: 16,

                      color:
                          Colors.grey,
                    ),
                  ),
                ),
              ),

            if (provider
                .hayAlertas)

              Expanded(

                child:
                    SingleChildScrollView(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // Agotados

                      if (provider
                          .agotados
                          .isNotEmpty) ...[

                        const Text(

                          'Agotados',

                          style: TextStyle(

                            fontSize: 18,

                            fontWeight:
                                FontWeight
                                    .bold,

                            color:
                                Colors.red,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        ...provider
                            .agotados
                            .map(

                          (alerta) {

                            return _ItemAlerta(

                              color:
                                  Colors.red,

                              titulo:
                                  alerta.prenda,

                              subtitulo:
                                  '${alerta.escuela} • ${alerta.talla}',

                              stock:
                                  'Sin stock',
                            );
                          },
                        ),

                        const SizedBox(
                          height: 24,
                        ),
                      ],

                      // Criticos

                      if (provider
                          .criticos
                          .isNotEmpty) ...[

                        const Text(

                          'Stock Critico',

                          style: TextStyle(

                            fontSize: 18,

                            fontWeight:
                                FontWeight
                                    .bold,

                            color:
                                Color(
                              0xFFFF9800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        ...provider
                            .criticos
                            .map(

                          (alerta) {

                            return _ItemAlerta(

                              color:
                                  const Color(
                                0xFFFF9800,
                              ),

                              titulo:
                                  alerta.prenda,

                              subtitulo:
                                  '${alerta.escuela} • ${alerta.talla}',

                              stock:
                                  '${alerta.stock} restantes',
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemAlerta
    extends StatelessWidget {

  final Color color;

  final String titulo;

  final String subtitulo;

  final String stock;

  const _ItemAlerta({

    required this.color,

    required this.titulo,

    required this.subtitulo,

    required this.stock,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(

        color:
            color.withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(

            Icons.warning_amber_rounded,

            color: color,

            size: 28,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  titulo,

                  style:
                      const TextStyle(

                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(

                  subtitulo,

                  style:
                      const TextStyle(

                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(

                  stock,

                  style:
                      TextStyle(

                    color: color,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}