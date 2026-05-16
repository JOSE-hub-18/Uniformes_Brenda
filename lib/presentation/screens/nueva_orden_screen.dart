// lib/presentation/screens/agregar_pedido_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/inventario_provider.dart';

import '../providers/nueva_orden_provider.dart';
import '../../business/usecases/nueva_orden_usecase.dart';

import 'bottom_nav_bar.dart';
import 'qr_screen.dart';

/// Pantalla para crear una nueva orden o venta.
/// 
/// - Permite seleccionar escuela, prenda y talla desde el inventario.
/// - Soporta agregar ítems manualmente o mediante escaneo de QR.
/// - Muestra las prendas agregadas agrupadas por inventario y permite confirmar la orden.
class AgregarPedidoScreen
    extends StatefulWidget {
  const AgregarPedidoScreen({
    super.key,
  });

  @override
  State<AgregarPedidoScreen>
      createState() =>
          _AgregarPedidoScreenState();
}

/// Estado de la pantalla de agregar pedido.
/// 
/// - Mantiene controladores y selección local para filtros (escuela, prenda, talla).
/// - Inicializa la carga de inventario a través de `NuevaOrdenProvider`.
class _AgregarPedidoScreenState
    extends State<
        AgregarPedidoScreen> {
  final TextEditingController
      _clienteController =
      TextEditingController();

  // Selecciones locales para filtrar el inventario.
  String? _escuelaSeleccionada;
  String? _prendaSeleccionada;
  String? _tallaSeleccionada;

  @override
  void initState() {
    super.initState();

    // Después del primer frame, solicita al provider cargar el inventario.
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      final provider =
          context.read<
              NuevaOrdenProvider>();

      await provider.cargarInventario();
    });
  }

  @override
  void dispose() {
    // Liberar recursos del controlador de texto.
    _clienteController.dispose();
    super.dispose();
  }

  // Helpers UI

  /// Contenedor estilizado que envuelve campos de entrada.
  /// 
  /// - Aplica fondo blanco, radio de borde y sombra ligera.
  Widget _buildInputDecoration({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Dropdown reutilizable con estilo consistente.
  /// 
  /// - `value`: valor seleccionado.
  /// - `items`: lista de opciones.
  /// - `onChanged`: callback al cambiar selección.
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?)
        onChanged,
  }) {
    return _buildInputDecoration(
      child: DropdownButtonFormField<
          String>(
        isExpanded: true,
        value: value,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.black,
          size: 24,
        ),
        decoration:
            const InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  maxLines: 1,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// Agrupa un `ItemOrden` con otros del mismo inventario y tipo.
  /// 
  /// - Busca los metadatos del inventario (escuela, prenda, talla).
  /// - Calcula la cantidad de ítems iguales en la orden y el precio total.
  Map<String, dynamic> _agruparItem({
    required ItemOrden item,
    required List<ItemOrden> items,
    required List<
            Map<String, dynamic>>
        inventario,
  }) {
    final inventarioItem =
        inventario.firstWhere(
      (e) =>
          e['idInventario'] ==
          item.idInventario,
      orElse: () => {
        'escuela': '',
        'prenda': '',
        'talla': '',
      },
    );

    final cantidad = items
        .where(
          (i) =>
              i.idInventario ==
                  item.idInventario &&
              i.tipo == item.tipo,
        )
        .length;

    return {
      'idInventario':
          item.idInventario,
      'titulo':
          '${inventarioItem['escuela']} - ${inventarioItem['prenda']}',
      'talla':
          inventarioItem['talla'],
      'cantidad': cantidad,
      'precio':
          item.precioUnitario *
              cantidad,
      'tipo': item.tipo,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Observa el provider para reconstruir cuando cambian datos de la orden.
    final nuevaOrdenProvider =
        context.watch<
            NuevaOrdenProvider>();

    final itemsInventario =
        nuevaOrdenProvider.inventario;

    final itemsOrden =
        nuevaOrdenProvider.items;

    // FILTROS

    // Extrae escuelas únicas del inventario.
    final escuelas = itemsInventario
        .map(
          (e) => e['escuela']
              .toString(),
        )
        .toSet()
        .toList();

    // Extrae prendas filtrando por escuela seleccionada si aplica.
    final prendas = itemsInventario
        .where((item) {
          if (_escuelaSeleccionada ==
              null) {
            return true;
          }

          return item['escuela'] ==
              _escuelaSeleccionada;
        })
        .map(
          (e) =>
              e['prenda'].toString(),
        )
        .toSet()
        .toList();

    // Extrae tallas filtrando por escuela y prenda seleccionadas si aplican.
    final tallas = itemsInventario
        .where((item) {
          final escuelaOk =
              _escuelaSeleccionada ==
                      null ||
                  item['escuela'] ==
                      _escuelaSeleccionada;

          final prendaOk =
              _prendaSeleccionada ==
                      null ||
                  item['prenda'] ==
                      _prendaSeleccionada;

          return escuelaOk &&
              prendaOk;
        })
        .map(
          (e) =>
              e['talla'].toString(),
        )
        .toSet()
        .toList();

    // FILTRADO

    // Si no hay selección completa, no mostrar resultados; en caso contrario filtrar.
    final prendasFiltradas =
        (_escuelaSeleccionada ==
                    null ||
                _prendaSeleccionada ==
                    null ||
                _tallaSeleccionada ==
                    null)
            ? <Map<String,
                dynamic>>[]
            : itemsInventario
                .where((item) {
                return item[
                            'escuela'] ==
                        _escuelaSeleccionada &&
                    item['prenda'] ==
                        _prendaSeleccionada &&
                    item['talla'] ==
                        _tallaSeleccionada;
              }).toList();

    // AGRUPAR ITEMS

    // Construye lista de items agrupados por idInventario y tipo.
    final itemsAgrupados =
        <Map<String, dynamic>>[];

    final procesados = <String>{};

    for (final item in itemsOrden) {
      final key =
          '${item.idInventario}-${item.tipo}';

      if (procesados.contains(key)) {
        continue;
      }

      procesados.add(key);

      itemsAgrupados.add(
        _agruparItem(
          item: item,
          items: itemsOrden,
          inventario:
              itemsInventario,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAFF),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons
                .keyboard_double_arrow_left,
            color:
                Color(0xFF1452BD),
            size: 32,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(
          'Agregar pedido',
          style: TextStyle(
            color:
                Color(0xFF1452BD),
            fontWeight:
                FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color:
                  Color(0xFF1452BD),
              size: 30,
            ),
            // Navega al escáner QR y procesa el resultado mediante el provider.
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QRScannerScreen(
                    onScan:
                        (qr) async {
                      try {
                        final limpio =
                            qr.trim();

                        await nuevaOrdenProvider
                            .agregarQr(
                          limpio,
                        );

                        return ScanFeedback(
                          resultado:
                              ResultadoScan
                                  .ok,
                          mensaje:
                              'Prenda agregada',
                        );
                      } catch (e) {
                        return ScanFeedback(
                          resultado:
                              ResultadoScan
                                  .error,
                          mensaje: e
                              .toString(),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // CLIENTE
            const Text(
              'Nombre del cliente',
              style: TextStyle(
                fontSize: 16,
                color:
                    Color(0xFF333333),
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Campo para ingresar el nombre del cliente.
            _buildInputDecoration(
              child: TextFormField(
                controller:
                    _clienteController,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Ingresa nombre del cliente',
                  border:
                      InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // LABELS
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Escuela',
                    style: TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Prenda',
                    style: TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Talla',
                    style: TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // DROPDOWNS: selección de escuela, prenda y talla.
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value:
                        _escuelaSeleccionada,
                    items: escuelas,
                    onChanged: (val) {
                      setState(() {
                        _escuelaSeleccionada =
                            val;

                        _prendaSeleccionada =
                            null;

                        _tallaSeleccionada =
                            null;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _buildDropdown(
                    value:
                        _prendaSeleccionada,
                    items: prendas,
                    onChanged: (val) {
                      setState(() {
                        _prendaSeleccionada =
                            val;

                        _tallaSeleccionada =
                            null;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _buildDropdown(
                    value:
                        _tallaSeleccionada,
                    items: tallas,
                    onChanged: (val) {
                      setState(() {
                        _tallaSeleccionada =
                            val;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // LISTA DISPONIBLE: muestra las prendas filtradas por selección.
            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  prendasFiltradas.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 16,
              ),
              itemBuilder:
                  (context, index) {
                final item =
                    prendasFiltradas[
                        index];

                return Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
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
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              '${item['escuela']} - ${item['prenda']}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Talla ${item['talla']}',
                            ),

                            Text(
                              'Stock: ${item['stock']}',
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                        children: [
                          Text(
                            '\$${item['precio'].toInt()}',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 16,
                              color:
                                  Color(
                                0xFF1452BD,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          SizedBox(

  height: 36,

  child:
      ElevatedButton(

    // Agrega manualmente el item seleccionado a la orden mediante el provider.
    onPressed:
        () async {

      await nuevaOrdenProvider
          .agregarManual(
        idInventario:
            item[
                'idInventario'],
      );
    },

    style:
        ElevatedButton
            .styleFrom(

      backgroundColor:
          const Color(
        0xFF1452BD,
      ),

      elevation: 3,

      animationDuration:
          const Duration(
        milliseconds: 120,
      ),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
    ),

    child: const Text(

      'Agregar',

      style: TextStyle(
        color: Colors.white,
        fontWeight:
            FontWeight.bold,
      ),
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

            const SizedBox(height: 32),

            // PRENDAS AGREGADAS: sección que muestra los ítems agrupados.
            const Text(
              'Prendas Agregadas',
              style: TextStyle(
                fontSize: 18,
                color:
                    Color(0xFF888888),
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  itemsAgrupados.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 16,
              ),
              itemBuilder:
                  (context, index) {
                final item =
                    itemsAgrupados[
                        index];

                final esVenta =
                    item['tipo'] ==
                        TipoItemOrden
                            .venta;

                return Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
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
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              item[
                                  'titulo'],
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    14,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Talla ${item['talla']}',
                            ),

                            Text(
                              'Cantidad: ${item['cantidad']}',
                            ),

                            const SizedBox(
  height: 12,
),

Row(
  children: [

    // Badge que indica si el ítem es venta o pedido.
    Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(

        color: esVenta
            ? Colors.green
            : Colors.orange,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Text(

        esVenta
            ? 'VENTA'
            : 'PEDIDO',

        style:
            const TextStyle(

          color: Colors.white,

          fontWeight:
              FontWeight.bold,

          fontSize: 12,
        ),
      ),
    ),

    const Spacer(),

    // Acción para eliminar un grupo de ítems (busca el primer item coincidente y lo elimina).
    GestureDetector(

      onTap: () {

        final itemEliminar =
            itemsOrden.firstWhere(
          (i) =>
              i.idInventario ==
                  item[
                      'idInventario'] &&
              i.tipo ==
                  item['tipo'],
        );

        nuevaOrdenProvider
            .eliminarItem(
          itemEliminar,
        );
      },

      child: Container(

        padding:
            const EdgeInsets.all(
          5,
        ),

        decoration:
            const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),

        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 14,
        ),
      ),
    ),
  ],
),

                            
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // Precio total del grupo de ítems.
                      Text(
                        '\$${item['precio'].toInt()}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize: 16,
                          color: Color(
                            0xFF1452BD,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // CONFIRMAR: botón que confirma la orden y actualiza inventario.
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
    () async {

  try {

    await nuevaOrdenProvider
        .confirmar(
      idUsuario: 1,

      nombreCliente:
          _clienteController
              .text,
    );

    if (!context.mounted) {
      return;
    }

    // Si hay una escuela seleccionada en InventarioProvider, recargar su inventario.
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

ScaffoldMessenger.of(
  context,
).showSnackBar(

  const SnackBar(
    content: Text(
      'Orden confirmada correctamente',
    ),
  ),
);

  } catch (e) {

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
},
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF4CAF50,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),
                ),
                child: const Text(
                  'Confirmar Orden',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Barra de navegación inferior reutilizable.
      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}
