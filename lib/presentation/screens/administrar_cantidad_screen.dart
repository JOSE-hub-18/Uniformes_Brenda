import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_provider.dart';
import '../../data/repositories/unidad_repository.dart';
import 'qr_screen.dart';
import '../../business/usecases/restar_unidades_usecase.dart';

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

  late final RestarUnidadesUseCase _restarUseCase;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1");

    _restarUseCase = RestarUnidadesUseCase(_unidadRepo);

    Future.microtask(() {
      context.read<PrintProvider>().limpiarMensaje();
    });
  }

  // SUMAR (sin cambios)
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

  // RESTAR (modo continuo con scanner)
  Future<void> _confirmarRestar() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QRScannerScreen(
        onScan: (qr) {
          return _restarUseCase.ejecutar(
            qr,
            widget.idInventario,
          );
        },
      ),
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
          style: TextStyle(
            color: Color(0xFF1452BD),
            fontWeight: FontWeight.bold,
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
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
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

          // BOTONES
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
              GestureDetector(
                onTap: provider.loading ? null : _confirmarAgregar,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F6FAB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // MENSAJE RESULTADO
          if (provider.mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.mensaje,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}