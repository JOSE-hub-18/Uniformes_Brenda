import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_nav_bar.dart';
import '../../business/usecases/registrar_inventario_usecase.dart';
import '../../presentation/providers/registrar_inventario_provider.dart';

/// Pantalla para registrar una nueva prenda en el inventario.
/// 
/// - Presenta un formulario con campos: tipo de prenda, precio, talla y escuela.
/// - Utiliza un caso de uso [RegistrarInventarioUseCase] para ejecutar la operación
///   de registro y muestra retroalimentación al usuario mediante SnackBars.
class RegistrarPrendaScreen extends StatefulWidget {
  final RegistrarInventarioUseCase registrarInventarioUseCase;

  /// Constructor que recibe el caso de uso responsable de registrar el inventario.
  const RegistrarPrendaScreen({
    super.key,
    required this.registrarInventarioUseCase,
  });

  @override
  State<RegistrarPrendaScreen> createState() => _RegistrarPrendaScreenState();
}

/// Estado de la pantalla de registro de prenda.
/// 
/// - Mantiene el estado del formulario, controladores y selecciones locales.
/// - Carga catálogos iniciales desde [RegistrarInventarioProvider] en initState.
class _RegistrarPrendaScreenState extends State<RegistrarPrendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();

  // Identificadores seleccionados en los dropdowns.
  int? _idPrendaSeleccionado;
  int? _idTallaSeleccionada;
  int? _idEscuela;

  // Indicador local de carga para deshabilitar la UI mientras se ejecuta la operación.
  bool _cargando = false;

  @override
  void initState() {
    super.initState();

    // Solicita la carga de catálogos (prendas, tallas, escuelas) al provider
    // tan pronto como el microtask se ejecute, evitando llamadas directas en el constructor.
    Future.microtask(() {
      context.read<RegistrarInventarioProvider>().cargarCatalogos();
    });
  }

  @override
  void dispose() {
    // Liberar recursos del controlador de texto para evitar fugas de memoria.
    _precioController.dispose();
    super.dispose();
  }

  /// Valida el formulario y ejecuta el caso de uso para registrar la prenda.
  /// 
  /// Reglas de negocio y comportamiento:
  /// - Valida que el formulario sea válido y que los dropdowns tengan selección.
  /// - Muestra un SnackBar si faltan campos obligatorios.
  /// - Mientras se ejecuta el caso de uso, `_cargando` es true para deshabilitar el botón.
  /// - Al finalizar, muestra un SnackBar con el resultado: éxito o errores detallados.
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
        // Caso de éxito global: notificar al usuario.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );
      } else {
        // Si hay errores parciales, concatenar mensajes y mostrarlos.
        final errores = resultado.resultados
            .where((r) => !r.exitoso)
            .map((r) => r.mensajeError ?? 'Error')
            .join('\n');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errores)),
        );
      }

    } catch (e) {
      // Manejo de excepciones: notificar y restaurar estado de carga.
      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// Muestra un diálogo para crear una nueva escuela.
  /// 
  /// - Si el usuario ingresa un nombre válido, delega en el provider para crearla.
  /// - Si la creación es exitosa, selecciona la escuela recién creada en el formulario.
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

  /// Estilo reutilizable para los campos de entrada del formulario.
  /// 
  /// - Aplica fondo blanco, bordes y color de borde consistente con el diseño.
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

    // Observa el provider para obtener catálogos y estado de carga.
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
      // Si el provider está cargando catálogos, mostrar indicador central.
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
                        // Botón para agregar una nueva escuela mediante diálogo.
                        IconButton(
                          onPressed: _mostrarDialogoEscuela,
                          icon: const Icon(Icons.add, color: Color(0xFF1452BD)),
                        )
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Botón principal para guardar cambios; deshabilitado si _cargando es true.
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
                            : const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // Barra de navegación inferior reutilizable.
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
