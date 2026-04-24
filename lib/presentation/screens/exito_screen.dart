import 'package:flutter/material.dart';

class ExitoScreen extends StatefulWidget {
  const ExitoScreen({super.key});

  @override
  State<ExitoScreen> createState() => _ExitoScreenState();
}

class _ExitoScreenState extends State<ExitoScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Iniciamos el temporizador de 1100 ms
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        // Esta instrucción cierra la pantalla actual y regresa a la anterior.
        // Si quieres regresar directamente al Inventario saltando la de Administrar,
        // usamos popUntil.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), // Verde de tu diseño
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(Icons.check, color: Colors.white, size: 80),
            ),
            const SizedBox(height: 32),
            const Text(
              'Los cambios se han\nrealizado correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF333333)
              ),
            ),
          ],
        ),
      ),
    );
  }
}