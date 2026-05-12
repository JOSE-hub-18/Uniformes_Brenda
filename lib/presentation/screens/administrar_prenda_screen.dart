import 'package:flutter/material.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../models/models.dart';
import 'bottom_nav_bar.dart';
import 'administrar_cantidad_screen.dart';

class AdministrarPrendaScreen extends StatefulWidget {
  final int idInventario;

  const AdministrarPrendaScreen({
    super.key,
    required this.idInventario,
  });

  @override
  State<AdministrarPrendaScreen> createState() => _AdministrarPrendaScreenState();
}

class _AdministrarPrendaScreenState extends State<AdministrarPrendaScreen> {
  final _inventarioRepo = InventarioRepository();

  Inventario? inventario;
  bool cargando = true;

  final TextEditingController _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Cargar datos del inventario desde la BD
  Future<void> _cargarDatos() async {
    final data = await _inventarioRepo.obtenerPorId(widget.idInventario);

    if (data != null) {
      _precioController.text = data.precio.toString();
    }

    setState(() {
      inventario = data;
      cargando = false;
    });
  }

  // Guardar cambios de precio en la BD
  Future<void> _guardarCambios() async {
    if (inventario == null) return;

    final nuevoPrecio = double.tryParse(_precioController.text);

    if (nuevoPrecio == null) return;

    inventario!.precio = nuevoPrecio;

    await _inventarioRepo.actualizar(inventario!);

    if (!mounted) return;

    // Regresa true para indicar que hubo cambios
    Navigator.pop(context, true);
  }

  // Eliminar todo el registro de inventario
  Future<void> _eliminar() async {
    await _inventarioRepo.eliminar(widget.idInventario);

    if (!mounted) return;

    // Regresa true para recargar la lista en pantalla anterior
    Navigator.pop(context, true);
  }

  // Diálogo de confirmación para guardar cambios
  void _dialogoGuardar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Guardar cambios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              _guardarCambios();
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  // Diálogo simple de confirmación para eliminar

  void _dialogoEliminar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar prenda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              _eliminar();
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga datos
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si no encontró el inventario
    if (inventario == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el registro')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Administrar Prenda',
          style: TextStyle(
            color: Color(0xFF1452BD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Mostrar ID del inventario (solo lectura)
            Text('ID Inventario: ${inventario!.id}'),
            const SizedBox(height: 20),

            // Mostrar talla (solo lectura)
            Text('Talla: ${inventario!.idTalla}'),
            const SizedBox(height: 20),

            // Campo editable para cambiar precio
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio',
              ),
            ),

            const SizedBox(height: 30),

            // Botón para ir a administrar cantidad (sumar/restar unidades)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdministrarCantidadScreen(
                        idInventario: widget.idInventario,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Administrar Cantidad',
                  style: TextStyle(
                    color: Color(0xFF1452BD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Botón verde para guardar cambios de precio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _dialogoGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Guardar Cambios'),
              ),
            ),

            const SizedBox(height: 10),

            // Botón rojo para eliminar toda la prenda del inventario
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _dialogoEliminar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar Prenda'),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavBar(),
    );
  }
}