import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_provider.dart';

class AdministrarCantidadScreen extends StatefulWidget {
  final int idInventario;

  const AdministrarCantidadScreen({
    super.key,
    required this.idInventario,
  });

  @override
  State<AdministrarCantidadScreen> createState() =>
      _AdministrarCantidadScreenState();
}

class _AdministrarCantidadScreenState
    extends State<AdministrarCantidadScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1");

    Future.microtask(() {
      context.read<PrintProvider>().limpiarMensaje();
    });
  }

  void _confirmarAgregar() {
    final cantidad = int.tryParse(_controller.text) ?? 0;

    if (cantidad <= 0) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
        child: Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono decorativo para sumar/imprimir
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5FAFF), // Azul muy claro
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Color(0xFF1452BD), size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                '¿Imprimir y sumar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Para sumar a la cantidad es necesario imprimir los QR a continuación.\n\n¿Desea continuar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('No', style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Tu lógica original intacta
                        await context.read<PrintProvider>().agregarUnidades(
                              widget.idInventario,
                              cantidad,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Verde
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sí', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _confirmarRestar() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
        child: Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono decorativo de advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE), // Rojo muy claro
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_circle_outline, color: Color(0xFFC62828), size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                '¿Restar cantidad?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Está seguro que quiere restar esta cantidad a la actual disponible?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('No', style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        
                        // Tu lógica original intacta
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Usar escaneo de QR para restar"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828), // Rojo
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sí, restar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    final provider = context.watch<PrintProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        title: const Text(
          "Administrar Cantidad",
          style: TextStyle(color: Color(0xFF1452BD)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left,
              color: Color(0xFF1452BD)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: Center( // Mantiene todo el grupo centrado verticalmente
        child: SingleChildScrollView( // Previene errores de desbordamiento con el teclado
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hace que la columna solo ocupe el espacio necesario
            children: [
              // 1. CUADRO DE CANTIDAD (Ahora en la parte superior)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1452BD), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. BOTONES DE ACCIÓN (+ y -)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _confirmarRestar,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC62828), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.remove, color: Color(0xFFC62828), size: 36),
                    ),
                  ),

                  const SizedBox(width: 48),

                  GestureDetector(
                    onTap: provider.loading ? null : _confirmarAgregar,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: provider.loading 
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Icon(Icons.add, color: Colors.white, size: 36),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // 3. BLOQUE DE INSTRUCCIONES (Ahora debajo del cuadro y botones)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Escriba la cantidad en el cuadro y utilice los botones para sumar (+) o restar (-) esas unidades del inventario.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. MENSAJE DE RESULTADO
              SizedBox(
                height: 60,
                child: provider.mensaje.isNotEmpty
                    ? Text(
                        provider.mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}