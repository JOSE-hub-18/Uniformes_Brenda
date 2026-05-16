import 'package:flutter/material.dart';

/// Pantalla de confirmación visual que indica el éxito de una operación.
///
/// Componente de tipo [StatefulWidget] diseñado para notificar de forma efímera
/// al usuario que una transacción o modificación de datos ha culminado exitosamente.
class ExitoScreen extends StatefulWidget {
  /// Constructor principal de la clase [ExitoScreen].
  const ExitoScreen({super.key});

  @override
  State<ExitoScreen> createState() => _ExitoScreenState();
}

/// Estado asociado al componente [ExitoScreen].
///
/// Gestiona el ciclo de vida del widget y controla la lógica de tiempo para la
/// destrucción y desapilación de la pantalla de la pila de navegación.
class _ExitoScreenState extends State<ExitoScreen> {
  
  /// Subsistema de inicialización del estado del widget.
  ///
  /// Invoca la ejecución asíncrona de la regla de negocio encargada del cierre
  /// automático de la interfaz mediante un retraso programado.
  @override
  void initState() {
    super.initState();
    
    // Regla de negocio: Temporizador de persistencia visual establecido en 1100 milisegundos.
    Future.delayed(const Duration(milliseconds: 1100), () {
      // Control de flujo: Verifica la vigencia del widget en el árbol antes de alterar la navegación.
      if (mounted) {
        // Remueve la pantalla actual del flujo para retornar a la vista precedente en la pila de navegación.
        Navigator.of(context).pop();
      }
    });
  }

  /// Construye la jerarquía visual de componentes de la interfaz de usuario.
  ///
  /// Retorna una estructura basada en un lienzo [Scaffold] monocromático que aloja
  /// un indicador gráfico circular de confirmación y un bloque textual centralizado.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bloque visual: Contenedor con geometría circular para albergar el icono representativo de éxito.
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(Icons.check, color: Colors.white, size: 80),
            ),
            const SizedBox(height: 32),
            // Bloque de datos: Elemento de texto que declara la confirmación formal del proceso.
            const Text(
              'Los cambios se han\nrealizado correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}