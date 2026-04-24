import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import 'bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFECF6FE), // Fondo principal
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFE8FC), // Header
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF226DAA)),
            onPressed: () {
              // Navegar a notificaciones
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, //centrar botones
          children: [
            // Saludo
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón Inventario
            _HomeButton(
              label: 'Inventario',
              onPressed: () => provider.navigateToInventory(context),
            ),
            
            const SizedBox(height: 20),
            
            // Botón Ver Pedidos
            _HomeButton(
              label: 'Ver Pedidos',
              onPressed: () => provider.navigateToOrders(context),
            ),
            
            const SizedBox(height: 20),
            
            // Botón Nuevo Pedido
            _HomeButton(
              label: 'Nuevo Pedido',
              onPressed: () => provider.navigateToNewOrder(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// Widget reutilizable para los botones principales
class _HomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const _HomeButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF226DAA), // Azul de los botones
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

