// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../providers/alertas_provider.dart';

import '../widgets/alertas_popup.dart';

import 'bottom_nav_bar.dart';
import 'nueva_orden_screen.dart';
import 'pedidos_pendientes_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';

import '../../business/services/backup_service.dart';

import '../../data/repositories/backup_repository.dart';

class HomeScreen
    extends StatelessWidget {

  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return const HomeView();
  }
}

class HomeView
    extends StatelessWidget {

  const HomeView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        Provider.of<HomeProvider>(
      context,
    );

    final alertasProvider =
        Provider.of<AlertasProvider>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF3F8FD,
      ),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        actions: [

          Padding(

            padding:
                const EdgeInsets.only(
              right: 14,
            ),

            child: Stack(

              clipBehavior:
                  Clip.none,

              children: [

                IconButton(

                  icon: const Icon(

                    Icons
                        .notifications_outlined,

                    size: 32,

                    color:
                        Color(
                      0xFF1452BD,
                    ),
                  ),

                  onPressed: () {

                    showDialog(

                      context: context,

                      barrierColor:
                          Colors.black45,

                      builder: (_) {

                        return const AlertasPopup();
                      },
                    );
                  },
                ),

                if (alertasProvider
                    .hayAlertas)

                  Positioned(

                    right: 4,

                    top: 4,

                    child: Container(

                      padding:
                          const EdgeInsets
                              .all(5),

                      decoration:
                          const BoxDecoration(

                        color:
                            Colors.red,

                        shape:
                            BoxShape.circle,
                      ),

                      child: Text(

                        alertasProvider
                            .totalAlertas
                            .toString(),

                        style:
                            const TextStyle(

                          color:
                              Colors.white,

                          fontSize: 10,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Padding(

        padding:
            const EdgeInsets.symmetric(

          horizontal: 24,
          vertical: 10,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(
              height: 10,
            ),

            const Text(

              'Hola, Brenda',

              style: TextStyle(

                fontSize: 30,

                fontWeight:
                    FontWeight.bold,

                color:
                    Color(
                  0xFF1452BD,
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(

              'Selecciona una opcion',

              style: TextStyle(

                fontSize: 16,

                color:
                    Color(
                  0xFF666666,
                ),
              ),
            ),

            const SizedBox(
              height: 34,
            ),

            _HomeButton(

              label:
                  'Nueva Venta/Pedido',

              icon:
                  Icons.add_shopping_cart,

              backgroundColor:
                  const Color(
                0xFF1452BD,
              ),

              textColor:
                  Colors.white,

              iconColor:
                  Colors.white,

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        const AgregarPedidoScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _HomeButton(

              label:
                  'Ver Pedidos',

              icon:
                  Icons.pending_actions,

              backgroundColor:
                  Colors.white,

              textColor:
                  const Color(
                0xFF333333,
              ),

              iconColor:
                  const Color(
                0xFF4A90E2,
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        const PedidosPendientesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _HomeButton(

              label:
                  'Ver Ventas',

              icon:
                  Icons.point_of_sale,

              backgroundColor:
                  Colors.white,

              textColor:
                  const Color(
                0xFF333333,
              ),

              iconColor:
                  const Color(
                0xFF34A853,
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        const VentasScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _HomeButton(

              label:
                  'Inventario',

              icon:
                  Icons.inventory_2_outlined,

              backgroundColor:
                  Colors.white,

              textColor:
                  const Color(
                0xFF333333,
              ),

              iconColor:
                  const Color(
                0xFFFF9800,
              ),

              onPressed: () {

                provider
                    .navigateToInventory(
                  context,
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _HomeButton(

              label:
                  'Generar Reportes',

              icon:
                  Icons.bar_chart,

              backgroundColor:
                  Colors.white,

              textColor:
                  const Color(
                0xFF333333,
              ),

              iconColor:
                  const Color(
                0xFFE91E63,
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        const ReportesScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            Align(

              alignment:
                  Alignment.centerRight,

              child:
                  SizedBox(

                height: 40,

                child:
                    ElevatedButton.icon(

                  onPressed:
                      () async {

                    final service =
                        BackupService(

                      backupRepository:
                          BackupRepository(),
                    );

                    final resultado =
                        await service
                            .crearYCompartirBackup();

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      SnackBar(

                        content: Text(
                          resultado.mensaje,
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

                    elevation: 1,

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  icon:
                      const Icon(

                    Icons.save_alt,

                    size: 18,
                  ),

                  label:
                      const Text(

                    'Crear respaldo',

                    style: TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}

class _HomeButton
    extends StatelessWidget {

  final String label;

  final IconData icon;

  final VoidCallback
      onPressed;

  final Color
      backgroundColor;

  final Color
      textColor;

  final Color
      iconColor;

  const _HomeButton({

    required this.label,

    required this.icon,

    required this.onPressed,

    required this.backgroundColor,

    required this.textColor,

    required this.iconColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return SizedBox(

      width:
          double.infinity,

      height: 62,

      child:
          ElevatedButton.icon(

        onPressed:
            onPressed,

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
              backgroundColor,

          foregroundColor:
              textColor,

          elevation: 1.5,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              16,
            ),

            side:
                backgroundColor ==
                        Colors.white

                    ? const BorderSide(

                        color:
                            Color(
                          0xFFE5E5E5,
                        ),
                      )

                    : BorderSide.none,
          ),
        ),

        icon:
            Icon(

          icon,

          size: 24,

          color:
              iconColor,
        ),

        label:
            Align(

          alignment:
              Alignment.centerLeft,

          child: Text(

            label,

            style:
                TextStyle(

              fontSize: 17,

              fontWeight:
                  FontWeight.bold,

              color:
                  textColor,
            ),
          ),
        ),
      ),
    );
  }
}