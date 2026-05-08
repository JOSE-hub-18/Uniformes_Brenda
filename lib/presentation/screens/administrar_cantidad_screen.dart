import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_provider.dart';
import '../../data/repositories/unidad_repository.dart';
import 'qr_screen.dart';
import '../../business/usecases/restar_unidades_usecase.dart';

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
  final _unidadRepo = UnidadRepository();
  late final RestarUnidadesUseCase _restarUseCase;

  @override
  void initState() {
    super.initState();
    // Inicializa el campo de texto con "1" por defecto
    _controller = TextEditingController(text: "1");
    
    // Inicializa el caso de uso para restar unidades
    _restarUseCase = RestarUnidadesUseCase(_unidadRepo);

    // Limpia cualquier mensaje previo del provider al entrar a la pantalla
    Future.microtask(() {
      context.read<PrintProvider>().limpiarMensaje();
    });
  }

  /// Muestra un diálogo de confirmación antes de SUMAR unidades
  /// Si el usuario confirma, se imprimen QRs y se agregan las unidades al inventario
  void _confirmarAgregar() {
    final cantidad = int.tryParse(_controller.text) ?? 0;

    // Si la cantidad es 0 o negativa, no hace nada
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
              // Icono decorativo de QR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5FAFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Color(0xFF1452BD), size: 40),
              ),
              const SizedBox(height: 24),
              
              // Título del diálogo
              const Text(
                '¿Imprimir y sumar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),
              
              // Mensaje explicativo
              const Text(
                'Para sumar a la cantidad es necesario imprimir los QR a continuación.\n\n¿Desea continuar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
              ),
              const SizedBox(height: 32),
              
              // Botones de acción
              Row(
                children: [
                  // Botón "No" - Cancela la operación
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
                  
                  // Botón "Sí" - Ejecuta la impresión y suma de unidades
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Llama al provider para agregar unidades e imprimir QRs
                        await context.read<PrintProvider>().agregarUnidades(
                              widget.idInventario,
                              cantidad,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
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

  /// Abre el escáner QR para RESTAR una unidad específica
  /// Valida que el QR escaneado pertenezca a este inventario y lo desactiva
  Future<void> _confirmarRestar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          // Callback que se ejecuta cada vez que se escanea un QR
          onScan: (qr) async {
            // Ejecuta el caso de uso para validar y restar la unidad
            final r = await _restarUseCase.ejecutar(
              qr,
              widget.idInventario,
            );

            // Regresa feedback visual según el resultado
            switch (r) {
              case ResultadoRestarUnidad.ok:
                return ScanFeedback(
                  resultado: ResultadoScan.ok,
                  mensaje: "Unidad eliminada",
                );

              case ResultadoRestarUnidad.yaDesactivada:
                return ScanFeedback(
                  resultado: ResultadoScan.duplicado,
                  mensaje: "Ya estaba eliminada",
                );

              case ResultadoRestarUnidad.noPertenece:
                return ScanFeedback(
                  resultado: ResultadoScan.error,
                  mensaje: "No pertenece a esta prenda",
                );

              case ResultadoRestarUnidad.noExiste:
                return ScanFeedback(
                  resultado: ResultadoScan.error,
                  mensaje: "No existe",
                );

              case ResultadoRestarUnidad.qrInvalido:
                return ScanFeedback(
                  resultado: ResultadoScan.error,
                  mensaje: "QR inválido",
                );
            }
          },
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. CUADRO DE CANTIDAD - Input donde se escribe cuántas unidades sumar
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

              // 2. BOTONES DE ACCIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BOTÓN RESTAR (-) - Abre el escáner QR
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

                  // BOTÓN SUMAR (+) - Imprime QRs y suma unidades
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
                      // Muestra un loading spinner si está procesando
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

              // 3. INSTRUCCIONES
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

              // 4. MENSAJE DE RESULTADO - Muestra feedback del provider
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