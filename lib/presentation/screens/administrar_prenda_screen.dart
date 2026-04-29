import 'package:flutter/material.dart';
import '../../data/repositories/inventario_repository.dart';
import '../../models/models.dart';
import 'bottom_nav_bar.dart';
import 'administrar_cantidad_screen.dart'; 

class AdministrarPrendaScreen extends StatefulWidget {

  final int idInventario;
  // Agregamos las variables para recibir los datos de la pantalla anterior
  final String nombreEscuela;
  final String nombrePrenda;
  final String talla;
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

  // Ahora solo cargamos el objeto crudo para poder actualizar el precio en SQLite
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

  Future<void> _guardarCambios() async {
    if (inventario == null) return;

    final nuevoPrecio = double.tryParse(_precioController.text);

    if (nuevoPrecio == null) return;

    inventario!.precio = nuevoPrecio;

    await _inventarioRepo.actualizar(inventario!);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    await _inventarioRepo.eliminar(widget.idInventario);

    if (!mounted) return;

    Navigator.pop(context);
  }

void _dialogoGuardar() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), // Lo hace menos ancho
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF1452BD), size: 48),
              const SizedBox(height: 16),
              const Text(
                '¿Guardar cambios?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Está seguro que desea guardar los cambios?',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('No', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _guardarCambios();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sí', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

void _dialogoEliminar() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                '¿Eliminar prenda?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('No', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _eliminar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sí', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD), size: 32),
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
            const SizedBox(height: 23),

            // Inyectamos las variables que recibimos de la vista de inventario
            Text(
              'Nombre de la escuela: ${widget.nombreEscuela}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            Text(
              'Tipo de prenda: ${widget.nombrePrenda}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            Text(
              'Talla: ${widget.talla}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // Precio Editable
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Precio: ',
                  prefixStyle: TextStyle(color: Color(0xFF999999), fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
              ),
            ),

            const SizedBox(height: 40),

            // Inyectamos la cantidad que recibimos de la vista de inventario
            Text(
              'Cantidad disponible: ${widget.cantidad}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            
            const SizedBox(height: 12),

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
                    fontSize: 16,
                    color: Color(0xFF1452BD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botones
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _dialogoGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _dialogoEliminar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Eliminar Prenda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}