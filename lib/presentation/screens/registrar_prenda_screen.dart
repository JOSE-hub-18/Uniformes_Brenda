import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import '../../business/usecases/registrar_inventario_usecase.dart';

class RegistrarPrendaScreen extends StatefulWidget {
  final RegistrarInventarioUseCase registrarInventarioUseCase;

  const RegistrarPrendaScreen({
    super.key,
    required this.registrarInventarioUseCase,
  });

  @override
  State<RegistrarPrendaScreen> createState() => _RegistrarPrendaScreenState();
}

class _RegistrarPrendaScreenState extends State<RegistrarPrendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _escuelaController = TextEditingController();
  
  int? _idPrendaSeleccionado;
  int? _idTallaSeleccionada;
  int? _idEscuela;
  bool _cargando = false;

  @override
  void dispose() {
    _precioController.dispose();
    _escuelaController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        final resultado = await widget.registrarInventarioUseCase.ejecutar(
          idPrenda: _idPrendaSeleccionado!,
          precio: double.parse(_precioController.text),
          idsTallas: [_idTallaSeleccionada!], // Por ahora solo una talla
          idEscuela: _idEscuela ?? 1, // Temporal: ajustar según tu lógica
        );

        setState(() => _cargando = false);

        if (!mounted) return;

        if (resultado.todosExitosos) {
          // Mostrar diálogo de confirmación
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confirmado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Prenda registrada exitosamente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // Redirigir a inventario después de 1.5 segundos
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.of(context).pop(); // Cierra el diálogo
            Navigator.of(context).pop(); // Regresa a inventario
          });
        } else {
          // Mostrar errores
          final errores = resultado.resultados
              .where((r) => !r.exitoso)
              .map((r) => r.mensajeError ?? 'Error desconocido')
              .join('\n');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errores),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        setState(() => _cargando = false);
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Registrar Nueva Prenda',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Tipo de Prenda
              const Text(
                'Tipo de Prenda',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _idPrendaSeleccionado,
                hint: const Text('Selecciona una opción', style: TextStyle(color: Colors.grey)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                // TODO: Cargar desde la BD, esto es temporal
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Camisa')),
                  DropdownMenuItem(value: 2, child: Text('Pantalón')),
                  DropdownMenuItem(value: 3, child: Text('Falda')),
                  DropdownMenuItem(value: 4, child: Text('Suéter')),
                  DropdownMenuItem(value: 5, child: Text('Chamarra')),
                ],
                onChanged: (value) {
                  setState(() {
                    _idPrendaSeleccionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un tipo de prenda';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Precio
              const Text(
                'Precio',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ingresa Precio de Venta',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el precio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingresa un precio válido mayor a cero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Talla
              const Text(
                'Talla',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _idTallaSeleccionada,
                hint: const Text('Selecciona una opción', style: TextStyle(color: Colors.grey)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                // TODO: Cargar desde la BD, esto es temporal
                items: const [
                  DropdownMenuItem(value: 1, child: Text('XS')),
                  DropdownMenuItem(value: 2, child: Text('S')),
                  DropdownMenuItem(value: 3, child: Text('M')),
                  DropdownMenuItem(value: 4, child: Text('L')),
                  DropdownMenuItem(value: 5, child: Text('XL')),
                  DropdownMenuItem(value: 6, child: Text('XXL')),
                ],
                onChanged: (value) {
                  setState(() {
                    _idTallaSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una talla';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Escuela
              const Text(
                'Escuela',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _escuelaController,
                decoration: InputDecoration(
                  hintText: 'Ingresa Nombre de Escuela',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre de la escuela';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Botón Guardar Cambios
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón Cancelar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
