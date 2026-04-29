import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_nav_bar.dart';
import '../../business/usecases/registrar_inventario_usecase.dart';
import '../../presentation/providers/registrar_inventario_provider.dart';

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

  int? _idPrendaSeleccionado;
  int? _idTallaSeleccionada;
  int? _idEscuela;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RegistrarInventarioProvider>().cargarCatalogos();
    });
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {

    if (!_formKey.currentState!.validate()) return;

    if (_idPrendaSeleccionado == null ||
        _idTallaSeleccionada == null ||
        _idEscuela == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final resultado = await widget.registrarInventarioUseCase.ejecutar(
        idPrenda: _idPrendaSeleccionado!,
        precio: double.parse(_precioController.text),
        idsTallas: [_idTallaSeleccionada!],
        idEscuela: _idEscuela!,
      );

      setState(() => _cargando = false);

      if (!mounted) return;

      if (resultado.todosExitosos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );
      } else {
        final errores = resultado.resultados
            .where((r) => !r.exitoso)
            .map((r) => r.mensajeError ?? 'Error')
            .join('\n');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errores)),
        );
      }

    } catch (e) {
      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _mostrarDialogoEscuela() async {
    final controller = TextEditingController();
    final provider = context.read<RegistrarInventarioProvider>();

    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva Escuela'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nueva != null && nueva.trim().isNotEmpty) {
      final escuela = await provider.agregarEscuela(nueva);

      if (escuela != null) {
        setState(() {
          _idEscuela = escuela.idEscuela!;
        });
      }
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<RegistrarInventarioProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left,
              color: Color(0xFF1452BD), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Nueva Prenda',
          style: TextStyle(
            color: Color(0xFF1452BD),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text('Tipo de Prenda'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _idPrendaSeleccionado,
                      hint: const Text('Selecciona una opción'),
                      decoration: _inputDecoration(),
                      items: provider.prendas.map((p) {
                        return DropdownMenuItem(
                          value: p.idPrenda,
                          child: Text(p.nombre),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _idPrendaSeleccionado = v),
                      validator: (v) => v == null ? 'Selecciona prenda' : null,
                    ),

                    const SizedBox(height: 24),

                    const Text('Precio'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration().copyWith(
                        hintText: 'Ingresa Precio de Venta',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Precio requerido';
                        final p = double.tryParse(v);
                        if (p == null || p <= 0) return 'Precio inválido';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text('Talla'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _idTallaSeleccionada,
                      hint: const Text('Selecciona una opción'),
                      decoration: _inputDecoration(),
                      items: provider.tallas.map((t) {
                        return DropdownMenuItem(
                          value: t.idTalla,
                          child: Text(t.talla),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _idTallaSeleccionada = v),
                      validator: (v) => v == null ? 'Selecciona talla' : null,
                    ),

                    const SizedBox(height: 24),

                    const Text('Escuela'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _idEscuela,
                            hint: const Text('Selecciona una opción'),
                            decoration: _inputDecoration(),
                            items: provider.escuelas.map((e) {
                              return DropdownMenuItem(
                                value: e.idEscuela,
                                child: Text(e.nombre),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _idEscuela = v),
                            validator: (v) => v == null ? 'Selecciona escuela' : null,
                          ),
                        ),
                        IconButton(
                          onPressed: _mostrarDialogoEscuela,
                          icon: const Icon(Icons.add, color: Color(0xFF1452BD)),
                        )
                      ],
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Guardar Cambios' , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // Si está cargando, deshabilita el botón; si no, cierra la pantalla
                        onPressed: _cargando ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828), // Rojo oscuro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Misma curvatura que el verde
                          ),
                        ),
                        child: const Text(
                          'Cancelar', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
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