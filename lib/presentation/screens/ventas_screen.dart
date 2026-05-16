// lib/presentation/screens/ventas_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/ventas_provider.dart';

import 'bottom_nav_bar.dart';
import 'revisar_venta_screen.dart';

/// Pantalla que lista las ventas registradas y permite filtrarlas por año y mes.
/// 
/// - Usa [VentasProvider] para obtener y observar el listado de ventas.
/// - Permite navegar a la vista de revisión de una venta individual.
class VentasScreen
    extends StatefulWidget {

  const VentasScreen({
    super.key,
  });

  @override
  State<VentasScreen>
      createState() =>
          _VentasScreenState();
}

/// Estado de la pantalla de ventas.
/// 
/// - Mantiene filtros locales (_anioSeleccionado, _mesSeleccionado).
/// - Solicita la carga inicial de ventas en `initState`.
class _VentasScreenState
    extends State<VentasScreen> {

  // Filtro de año seleccionado por el usuario.
  int? _anioSeleccionado;

  // Filtro de mes seleccionado por el usuario.
  int? _mesSeleccionado;

  @override
  void initState() {

    super.initState();

    // Cargar ventas después del primer frame para asegurar que el contexto esté disponible.
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {

        context
            .read<
                VentasProvider>()
            .cargarVentas();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    // Observa el provider para reconstruir la UI cuando cambien las ventas o el estado.
    final provider =
        context.watch<
            VentasProvider>();

    // Copia local de las ventas que será filtrada según selección del usuario.
    List ventasFiltradas =
        provider.ventas;

    // FILTRADO: año

    if (_anioSeleccionado !=
        null) {

      ventasFiltradas =
          ventasFiltradas
              .where(
        (v) {

          return v.fecha.year ==
              _anioSeleccionado;
        },
      ).toList();
    }

    // FILTRADO: mes

    if (_mesSeleccionado !=
        null) {

      ventasFiltradas =
          ventasFiltradas
              .where(
        (v) {

          return v.fecha.month ==
              _mesSeleccionado;
        },
      ).toList();
    }

    // CÁLCULO: obtener años únicos para el dropdown de filtro

    final anios =
        provider.ventas
            .map(
              (v) =>
                  v.fecha.year,
            )
            .toSet()
            .toList()

          ..sort();

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

          'Ventas',

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

      // Cuerpo: muestra indicador de carga, estado vacío o lista filtrable de ventas.
      body:
          provider.cargando

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : provider
                      .ventas
                      .isEmpty

                  // Estado cuando no existen ventas registradas en el sistema.
                  ? const Center(
                      child: Text(
                        'No hay ventas registradas',
                      ),
                    )

                  : SingleChildScrollView(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),

                      child: Column(

                        children: [

                          // ── FILTRO: AÑO ───────────────────────────────────────
                          DropdownButtonFormField<int>(

                            value:
                                _anioSeleccionado,

                            decoration:
                                InputDecoration(

                              labelText:
                                  'Filtrar por año',

                              filled: true,

                              fillColor:
                                  Colors.white,

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),

                            // Opciones generadas a partir de los años presentes en las ventas.
                            items:
                                anios.map(
                              (anio) {

                                return DropdownMenuItem<int>(

                                  value:
                                      anio,

                                  child:
                                      Text(
                                    anio.toString(),
                                  ),
                                );
                              },
                            ).toList(),

                            // Al cambiar el año, actualizar el estado local y reiniciar mes si se limpia año.
                            onChanged:
                                (value) {

                              setState(() {

                                _anioSeleccionado =
                                    value;

                                // Reiniciar mes
                                // si se limpia año

                                if (value ==
                                    null) {

                                  _mesSeleccionado =
                                      null;
                                }
                              });
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ── FILTRO: MES ───────────────────────────────────────
                          DropdownButtonFormField<int>(

                            value:
                                _mesSeleccionado,

                            decoration:
                                InputDecoration(

                              labelText:
                                  'Filtrar por mes',

                              filled: true,

                              fillColor:
                                  Colors.white,

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),

                            // Si no hay año seleccionado, no mostrar opciones de mes.
                            items: _anioSeleccionado ==
                                    null

                                ? []

                                : List.generate(
                                    12,
                                    (index) {

                                    final mes =
                                        index + 1;

                                    return DropdownMenuItem<int>(

                                      value:
                                          mes,

                                      child:
                                          Text(
                                        _nombreMes(
                                          mes,
                                        ),
                                      ),
                                    );
                                  },
                                  ),

                            // Si no hay año seleccionado, deshabilitar el control.
                            onChanged:
                                _anioSeleccionado ==
                                        null

                                    ? null

                                    : (value) {

                                        setState(() {

                                          _mesSeleccionado =
                                              value;
                                        });
                                      },
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // Si después de aplicar filtros no hay ventas, mostrar mensaje.
                          if (ventasFiltradas
                              .isEmpty)

                            const Center(

                              child: Text(
                                'No hay ventas para ese filtro',
                              ),
                            )

                          else

                            // Lista de ventas filtradas.
                            ListView.separated(

                              shrinkWrap: true,

                              physics:
                                  const NeverScrollableScrollPhysics(),

                              itemCount:
                                  ventasFiltradas
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

                                final venta =
                                    ventasFiltradas[
                                        index];

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

                                      // Identificador de la venta.
                                      Text(

                                        'Venta #${venta.id}',

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

                                      // Nombre del cliente o texto por defecto si no existe.
                                      Text(

                                        venta.nombreCliente ??
                                            'Sin cliente',

                                        style:
                                            const TextStyle(

                                          color:
                                              Color(
                                            0xFF888888,
                                          ),

                                          fontSize:
                                              14,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 2,
                                      ),

                                      // Fecha de la venta (representación por defecto).
                                      Text(

                                        venta.fecha
                                            .toString(),

                                        style:
                                            const TextStyle(

                                          color:
                                              Color(
                                            0xFF888888,
                                          ),

                                          fontSize:
                                              14,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      Row(

                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,

                                        children: [

                                          // Badge de estado (confirmada).
                                          Container(

                                            padding:
                                                const EdgeInsets.symmetric(

                                              horizontal:
                                                  12,

                                              vertical:
                                                  6,
                                            ),

                                            decoration:
                                                BoxDecoration(

                                              color:
                                                  const Color(
                                                0xFF4CAF50,
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(
                                                20,
                                              ),
                                            ),

                                            child:
                                                const Text(

                                              'Confirmada',

                                              style:
                                                  TextStyle(

                                                color:
                                                    Color(
                                                  0xFF0A3614,
                                                ),

                                                fontWeight:
                                                    FontWeight.bold,

                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ),

                                          Row(

                                            children: [

                                              // Monto total de la venta.
                                              Text(

                                                '\$${venta.total.toStringAsFixed(2)}',

                                                style:
                                                    const TextStyle(

                                                  color:
                                                      Color(
                                                    0xFF1452BD,
                                                  ),

                                                  fontWeight:
                                                      FontWeight.bold,

                                                  fontSize:
                                                      16,
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 18,
                                              ),

                                              // Botón para ver detalles de la venta.
                                              TextButton(

                                                onPressed:
                                                    () {

                                                  Navigator.push(

                                                    context,

                                                    MaterialPageRoute(

                                                      builder:
                                                          (_) =>
                                                              RevisarVentaScreen(

                                                        idVenta:
                                                            venta.id!,
                                                      ),
                                                    ),
                                                  );
                                                },

                                                style:
                                                    TextButton.styleFrom(

                                                  padding:
                                                      const EdgeInsets.symmetric(

                                                    horizontal:
                                                        16,

                                                    vertical:
                                                        8,
                                                  ),

                                                  minimumSize:
                                                      Size.zero,

                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),

                                                child:
                                                    const Text(

                                                  'Ver',

                                                  style:
                                                      TextStyle(

                                                    color:
                                                        Color(
                                                      0xFF1452BD,
                                                    ),

                                                    fontWeight:
                                                        FontWeight.bold,

                                                    fontSize:
                                                        16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

  /// Devuelve el nombre del mes en español para un número de mes (1-12).
  String _nombreMes(
    int mes,
  ) {

    const meses = [

      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return meses[
        mes - 1];
  }
}
