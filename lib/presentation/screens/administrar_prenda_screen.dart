import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business/providers/inventario_provider.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../models/models.dart';

import 'bottom_nav_bar.dart';
import 'administrar_cantidad_screen.dart';

/// Pantalla para visualizar y modificar los datos de una prenda de inventario.
///
/// Permite editar el precio, consultar la cantidad disponible, navegar a
/// [AdministrarCantidadScreen] para modificar unidades, y eliminar el registro
/// del inventario.
class AdministrarPrendaScreen extends StatefulWidget {
  /// Identificador único del registro de inventario.
  final int idInventario;

  /// Nombre de la escuela asociada al inventario.
  final String nombreEscuela;

  /// Nombre de la prenda asociada al inventario.
  final String nombrePrenda;

  /// Talla de la prenda.
  final String talla;

  /// Cantidad inicial de unidades disponibles al abrir la pantalla.
  final int cantidad;

  const AdministrarPrendaScreen({
    super.key,
    required this.idInventario,
    required this.nombreEscuela,
    required this.nombrePrenda,
    required this.talla,
    required this.cantidad,
  });

  @override
  State<AdministrarPrendaScreen> createState() =>
      _AdministrarPrendaScreenState();
}

/// Estado interno de [AdministrarPrendaScreen].
///
/// Gestiona la carga del inventario, la edición del precio,
/// la actualización de cantidad y las operaciones de guardado y eliminación.
class _AdministrarPrendaScreenState
    extends State<AdministrarPrendaScreen> {
  /// Repositorio de acceso a datos del inventario.
  final _inventarioRepo = InventarioRepository();

  /// Instancia del inventario cargado desde la base de datos.
  /// Es null mientras se encuentra en estado de carga.
  Inventario? inventario;

  /// Indica si los datos del inventario están siendo cargados.
  bool cargando = true;

  /// Cantidad actual de unidades, sincronizada con [InventarioProvider].
  late int cantidadActual;

  /// Controlador del campo de texto para editar el precio del inventario.
  final TextEditingController _precioController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Se inicializa con la cantidad recibida como parámetro.
    cantidadActual = widget.cantidad;

    _cargarDatos();
  }

  /// Carga los datos del inventario desde el repositorio usando [idInventario].
  ///
  /// Actualiza [_precioController] con el precio actual y establece
  /// [cargando] en false al finalizar.
  Future<void> _cargarDatos() async {
    final data =
        await _inventarioRepo.obtenerPorId(
      widget.idInventario,
    );

    if (data != null) {
      _precioController.text =
          data.precio.toString();
    }

    setState(() {
      inventario = data;
      cargando = false;
    });
  }

  // RECARGAR cantidad desde provider
  /// Sincroniza [cantidadActual] con el stock registrado en [InventarioProvider].
  ///
  /// Busca el item correspondiente a [idInventario] en la lista del provider
  /// y actualiza el estado local. Si el item no existe, no realiza cambios.
  void _actualizarCantidadDesdeProvider() {
    final provider =
        context.read<InventarioProvider>();

    final item =
        provider.itemsInventario.firstWhere(
      (e) => e['id'] == widget.idInventario,
      orElse: () => {},
    );

    if (item.isNotEmpty) {
      setState(() {
        cantidadActual = item['stock'] ?? 0;
      });
    }
  }

  /// Persiste el precio editado en la base de datos.
  ///
  /// Regla de negocio: el precio debe ser un valor numérico válido.
  /// Si [inventario] es null o el precio no es parseable, la operación se cancela.
  /// Al completarse, cierra la pantalla devolviendo true al caller.
  Future<void> _guardarCambios() async {
    if (inventario == null) return;

    final nuevoPrecio =
        double.tryParse(
      _precioController.text,
    );

    if (nuevoPrecio == null) return;

    inventario!.precio = nuevoPrecio;

    await _inventarioRepo.actualizar(
      inventario!,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  /// Elimina el registro de inventario identificado por [idInventario].
  ///
  /// Al completarse, cierra la pantalla devolviendo true al caller.
  Future<void> _eliminar() async {
    await _inventarioRepo.eliminar(
      widget.idInventario,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  /// Muestra un diálogo de confirmación antes de ejecutar [_guardarCambios].
  void _dialogoGuardar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '¿Guardar cambios?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _guardarCambios();
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de ejecutar [_eliminar].
  void _dialogoEliminar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '¿Eliminar prenda?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminar();
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  /// Construye la interfaz de la pantalla.
  ///
  /// Muestra un indicador de carga mientras [cargando] es true.
  /// Si [inventario] es null tras la carga, muestra un mensaje de error.
  /// En caso exitoso, renderiza los datos de la prenda, el campo de precio,
  /// el acceso a [AdministrarCantidadScreen], y los botones de guardar y eliminar.
  @override
  Widget build(BuildContext context) {
    // Estado de carga: muestra indicador mientras se obtienen los datos.
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Estado de error: el inventario no fue encontrado en la base de datos.
    if (inventario == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No se encontró el registro',
          ),
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
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(
          'Administrar Prenda',
          style: TextStyle(
            color:
                Color(0xFF1452BD),
            fontWeight:
                FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            Text(
              'Escuela: ${widget.nombreEscuela}',
            ),

            const SizedBox(height: 20),

            Text(
              'Prenda: ${widget.nombrePrenda}',
            ),

            const SizedBox(height: 20),

            Text(
              'Talla: ${widget.talla}',
            ),

            const SizedBox(height: 20),

            // Muestra la cantidad sincronizada con el provider tras volver de AdministrarCantidadScreen.
            Text(
              'Cantidad disponible: $cantidadActual',
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller:
                  _precioController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: 'Precio',
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment:
                  Alignment.centerRight,

              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdministrarCantidadScreen(
                        idInventario:
                            widget
                                .idInventario,
                      ),
                    ),
                  );

                  // IMPORTANTE
                  // Se recarga el inventario del provider al regresar de AdministrarCantidadScreen
                  // para reflejar los cambios de cantidad realizados en esa pantalla.
                  await context
                      .read
                          InventarioProvider>()
                      .recargarEscuelas();

                  _actualizarCantidadDesdeProvider();
                },

                child: const Text(
                  'Administrar Cantidad',
                  style: TextStyle(
                    color:
                        Color(0xFF1452BD),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    _dialogoGuardar,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                ),

                child: const Text(
                  'Guardar Cambios',
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    _dialogoEliminar,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                child: const Text(
                  'Eliminar Prenda',
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}