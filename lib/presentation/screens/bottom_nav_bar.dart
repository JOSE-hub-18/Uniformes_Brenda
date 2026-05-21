import 'package:flutter/material.dart';

/// Barra de navegación inferior persistente de la aplicación.
///
/// Muestra los accesos directos a la pantalla principal y al cierre de sesión.
/// Utiliza [SafeArea] para evitar superposición con las barras del sistema operativo.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  /// Construye la barra de navegación inferior.
  ///
  /// Compone un contenedor con color de fondo, protección de área segura
  /// y dos botones de navegación: inicio y cierre de sesión.
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
              // Navega a la pantalla principal eliminando todo el historial de navegación.
              IconButton(
                icon: const Icon(Icons.home_outlined, size: 32, color: Color(0xFF1452BD)),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
                }
              ),

              // Botón de cierre de sesión. Lógica pendiente de implementar.
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