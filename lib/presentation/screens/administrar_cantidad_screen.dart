import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_provider.dart';
import '../../data/repositories/unidad_repository.dart';
import 'qr_screen.dart';

class AdministrarCantidadScreen extends StatefulWidget {
  final int idInventario;

  const AdministrarCantidadScreen({super.key, required this.idInventario});

  @override
  State<AdministrarCantidadScreen> createState() =>
      _AdministrarCantidadScreenState();
}

class _AdministrarCantidadScreenState extends State<AdministrarCantidadScreen> {
  late TextEditingController _controller;
  final _unidadRepo = UnidadRepository();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1");

    // Limpiar mensajes previos del provider
    Future.microtask(() {
      context.read<PrintProvider>().limpiarMensaje();
    });
  }

  // Pide confirmación e imprime QRs de las nuevas unidades
  void _confirmarAgregar() {
    final cantidad = int.tryParse(_controller.text) ?? 0;

    if (cantidad <= 0) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text(
          "¿Para sumar a la cantidad es necesario imprimir los QR a continuación\n\n¿Desea continuar?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Llama al provider para crear unidades e imprimir QRs
              await context.read<PrintProvider>().agregarUnidades(
                widget.idInventario,
                cantidad,
              );
            },
            child: const Text("Si", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // RESTAR unidades
  // Abre escaner QR, valida que pertenezca al inventario, y desactiva la unidad
  Future<void> _confirmarRestar() async {
    // Abrir scanner QR
    final codigoQR = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    // Si cancelo o no escaneo nada
    if (codigoQR == null || !mounted) return;

    //Validar que el codigo sea un numero valido (ID de unidad)
    final idUnidad = int.tryParse(codigoQR.toString());

    if (idUnidad == null) {
      _mostrarError('Codigo QR invalido');
      return;
    }

    // Verificar que la unidad pertenece a ESTE inventario
    final pertenece = await _unidadRepo.pertenece(
      idUnidad,
      widget.idInventario,
    );

    if (!pertenece) {
      _mostrarError('El código QR no pertenece a esta prenda');
      return;
    }

    if (!mounted) return;

    //Pedir confirmacion antes de desactivar
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text(
          "¿Está seguro que quiere marcar esta unidad como inactiva?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); //cierra el dialogo

              // Paso 5 Desactivar la unidad en la BD
              await _unidadRepo.desactivar(idUnidad);

              if (!mounted) return;

              //Mostrar confirmacion de exito
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Unidad desactivada corrrectamente"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Si", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Mostrar error cuando QR es inválido o no pertenece
  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrintProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        title: const Text(
          "Administrar Cantidad",
          style: TextStyle(color: Color(0xFF1452BD),
          fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_double_arrow_left,
            color: Color(0xFF1452BD),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // CUADRO CANTIDAD
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: SizedBox(
                width: 100,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          //  BOTONES de restar y sumar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RESTAR
              GestureDetector(
                onTap: _confirmarRestar,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F6FAB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(width: 40),

              // SUMAR
              //crea nuevas unidades e imprime sus QRS
              GestureDetector(
                onTap: provider.loading ? null : _confirmarAgregar,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F6FAB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          //  MENSAJE RESULTADO
          if (provider.mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(provider.mensaje, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}
