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
    
    // Temporizador de 1100 ms
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        // Regresa a la pantalla anterior (AdministrarPrendaScreen)
        Navigator.of(context).pop();
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
                color: Color(0xFF4CAF50),
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