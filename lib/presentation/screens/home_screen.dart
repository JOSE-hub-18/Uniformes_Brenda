import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import 'bottom_nav_bar.dart';
import 'agregar_orden_screen.dart';
import 'pedidos_pendientes_screen.dart';
import 'administrar_ventas_screen.dart';

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
  iconSize: 40,
  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF226DAA)),
  onPressed: () {
    // Datos de prueba temporales.
    // Reemplazar esta lista con los datos reales del Provider o BD.
    final mockNotifications = [
      NotificationData(
        title: 'Stock Agotado',
        titleColor: Colors.red.shade700,
        school: 'Escuela Técnica 1',
        type: 'Pantalón',
        size: 'M',
        price: '\$250.00',
        stock: 'Existencia: 0 unidades',
      ),
      NotificationData(
        title: 'Stock Crítico',
        titleColor: Colors.orange.shade700,
        school: 'Colegio del Norte',
        type: 'Falda',
        size: 'S',
        price: '\$200.00',
        stock: 'Existencia: Quedan 3 unidades',
      ),
      NotificationData(
        title: 'Stock Crítico',
        titleColor: Colors.orange.shade700,
        school: 'Colegio del Norte',
        type: 'Falda',
        size: 'S',
        price: '\$200.00',
        stock: 'Existencia: Quedan 3 unidades',
      ),
    ];

    _showNotificationsDialog(context, provider, mockNotifications);
  },
),
          const SizedBox(width: 10),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PedidosPendientesScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Botón Nueva Orden
            _HomeButton(
              label: 'Nueva Orden',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgregarPedidoScreen(),
                  ),
                );
              }
            ),

            const SizedBox(height: 20),

            // Boton: Administrar Ventas
            _HomeButton(
              label: 'Administrar Ventas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdministrarVentasScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

// --- CAMBIO: Ahora recibe el HomeProvider ---
void _showNotificationsDialog(BuildContext context, HomeProvider provider, List<NotificationData> notifications) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Título del Pop up ---
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF226DAA),
                  ),
                ),
              ),
              const Divider(height: 1),

              // --- Lista de Notificaciones Dinámica ---
              Flexible(
                child: notifications.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No hay notificaciones recientes.", style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        shrinkWrap: true, // Para que tome solo el espacio necesario
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return _buildNotificationItem(
                            title: item.title,
                            titleColor: item.titleColor,
                            school: item.school,
                            type: item.type,
                            size: item.size,
                            price: item.price,
                            stock: item.stock,
                          );
                        },
                      ),
              ),

              const Divider(height: 1),

              // --- Botón Inferior ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      provider.navigateToInventory(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF226DAA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver Inventario',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Widget auxiliar para cada item de notificación
// Widget auxiliar para cada item de notificación
Widget _buildNotificationItem({
  required String title,
  required Color titleColor,
  required String school,
  required String type,
  required String size,
  required String price,
  required String stock,
}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(school, style: const TextStyle(color: Color(0xFF424242))),
        Text(type, style: const TextStyle(color: Color(0xFF424242))),
        Text(size, style: const TextStyle(color: Color(0xFF424242))),
        Text(price, style: const TextStyle(color: Color(0xFF424242))),
        Text(
          stock,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF212121)),
        ),
      ],
    ),
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

//Datos que se necesitan para mostrar la información en las notificaciones
class NotificationData {
  final String title;
  final Color titleColor;
  final String school;
  final String type;
  final String size;
  final String price;
  final String stock;

  NotificationData({
    required this.title,
    required this.titleColor,
    required this.school,
    required this.type,
    required this.size,
    required this.price,
    required this.stock,
  });
}