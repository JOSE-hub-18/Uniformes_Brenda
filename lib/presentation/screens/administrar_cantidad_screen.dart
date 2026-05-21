import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_provider.dart';
import '../../data/repositories/unidad_repository.dart';
import 'qr_screen.dart';
import '../../business/usecases/restar_unidades_usecase.dart';

/// Pantalla para modificar la cantidad de unidades de un inventario específico.
///
/// Expone dos operaciones: agregar unidades mediante impresión de QRs,
/// y restar unidades mediante escaneo de QRs físicos.
/// Requiere [idInventario] para identificar el inventario sobre el que opera.
class AdministrarCantidadScreen extends StatefulWidget {
  /// Identificador único del inventario a administrar.
  final int idInventario;

  const AdministrarCantidadScreen({super.key, required this.idInventario});

  @override
  State<AdministrarCantidadScreen> createState() =>
      _AdministrarCantidadScreenState();
}

/// Estado interno de [AdministrarCantidadScreen].
///
/// Gestiona el ciclo de vida del controlador de texto,
/// la instancia del caso de uso y la limpieza del estado del provider.
class _AdministrarCantidadScreenState extends State<AdministrarCantidadScreen> {
  /// Controlador vinculado al campo de entrada de cantidad.
  /// Se inicializa en "1" como valor mínimo operativo.
  late TextEditingController _controller;

  /// Repositorio de acceso a datos de unidades.
  /// Se inyecta directamente en [_restarUseCase].
  final _unidadRepo = UnidadRepository();

  /// Caso de uso encargado de ejecutar la lógica de negocio
  /// para restar unidades mediante validación de QR.
  late final RestarUnidadesUseCase _restarUseCase;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1");

    _restarUseCase = RestarUnidadesUseCase(_unidadRepo);

    // Se ejecuta en microtask para garantizar que el contexto
    // esté completamente montado antes de acceder al provider.
    Future.microtask(() {
      context.read<PrintProvider>().limpiarMensaje();
    });
  }

  // SUMAR
  /// Valida la cantidad ingresada y muestra un diálogo de confirmación
  /// antes de ejecutar la operación de agregar unidades.
  ///
  /// Regla de negocio: no se permite agregar si la cantidad es menor o igual a cero.
  /// Al confirmar, delega la operación a [PrintProvider.agregarUnidades],
  /// el cual gestiona la impresión de QRs para las nuevas unidades.
  void _confirmarAgregar() {
    final cantidad = int.tryParse(_controller.text) ?? 0;

    // Regla de negocio: cantidad debe ser mayor a cero para proceder.
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

  // RESTAR
  /// Navega a [QRScannerScreen] y procesa el resultado del escaneo
  /// ejecutando [RestarUnidadesUseCase].
  ///
  /// Mapea cada valor de [ResultadoRestarUnidad] a un [ScanFeedback]
  /// con el tipo de resultado y mensaje correspondiente.
  ///
  /// Reglas de negocio aplicadas:
  /// - Una unidad ya desactivada no puede restarse de nuevo.
  /// - Solo se pueden restar unidades que pertenezcan al inventario indicado.
  /// - El QR debe tener un formato válido reconocido por el sistema.
  Future<void> _confirmarRestar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          onScan: (qr) async {
            final r = await _restarUseCase.ejecutar(qr, widget.idInventario);

            switch (r) {
              // Operación exitosa: la unidad fue desactivada correctamente.
              case ResultadoRestarUnidad.ok:
                return ScanFeedback(
                  resultado: ResultadoScan.ok,
                  mensaje: "Unidad eliminada",
                );

              // La unidad escaneada ya se encontraba desactivada previamente.
              case ResultadoRestarUnidad.yaDesactivada:
                return ScanFeedback(
                  resultado: ResultadoScan.duplicado,
                  mensaje: "Ya estaba eliminada",
                );

              // El QR es válido pero corresponde a un inventario distinto.
              case ResultadoRestarUnidad.noPertenece:
                return ScanFeedback(
                  resultado: ResultadoScan.error,
                  mensaje: "No pertenece a esta prenda",
                );

              // El QR no tiene registro en la base de datos.
              case ResultadoRestarUnidad.noExiste:
                return ScanFeedback(
                  resultado: ResultadoScan.error,
                  mensaje: "No existe",
                );

              // El QR no cumple con el formato esperado por el sistema.
              case ResultadoRestarUnidad.qrInvalido:
              default:
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

  /// Construye la interfaz de la pantalla.
  ///
  /// Compone: campo de entrada de cantidad, botones de sumar y restar,
  /// y área de mensaje reactivo al estado de [PrintProvider].
  @override
  Widget build(BuildContext context) {
    // Suscripción reactiva al provider; reconstruye el widget ante cualquier cambio.
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

          // INPUT CANTIDAD
          // Acepta únicamente valores numéricos enteros.
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

          // BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RESTAR
              // No depende del estado loading porque no usa PrintProvider.
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
              // Se deshabilita mientras provider.loading sea true
              // para evitar solicitudes duplicadas durante la impresión.
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

          // MENSAJE DEL PROVIDER
          // Se renderiza condicionalmente; permanece oculto si el mensaje está vacío.
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
