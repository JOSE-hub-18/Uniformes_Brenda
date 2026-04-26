import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // El color se queda en el contenedor padre para pintar todo el borde inferior
      color: const Color(0xFFD5E8FA), 
      // SafeArea protege a los hijos (los iconos) de las barras del sistema
      child: SafeArea(
        bottom: true, // Le decimos que preste especial atención a la parte de abajo
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined, size: 32, color: Color(0xFF1452BD)), 
                onPressed: () {}
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, size: 32, color: Color(0xFF1452BD)), 
                onPressed: () {}
              ),
              IconButton(
                icon: const Icon(Icons.logout, size: 32, color: Color(0xFF1452BD)), 
                onPressed: () {}
              ),
            ],
          ),
        ),
      ),
    );
  }
}