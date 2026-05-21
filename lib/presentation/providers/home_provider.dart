import 'package:flutter/material.dart';

/// Provider de estado para la pantalla principal de la aplicación.
///
/// Gestiona el nombre del usuario autenticado y centraliza
/// la navegación hacia las secciones principales del sistema.
class HomeProvider extends ChangeNotifier {
  /// Nombre del usuario actualmente autenticado.
  /// Valor por defecto: 'Usuario'.
  String _userName = 'Usuario';

  /// Expone el nombre del usuario a los widgets consumidores.
  String get userName => _userName;

  /// Actualiza el nombre del usuario y notifica a los listeners.
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // Métodos para las acciones de los botones
  /// Navega a la pantalla de inventario.
  void navigateToInventory(BuildContext context) {
    Navigator.pushNamed(context, '/inventory');
  }

  /// Navega a la pantalla de órdenes.
  /// Actualmente deshabilitado.
  void navigateToOrders(BuildContext context) {
    // Navigator.pushNamed(context, '/orders');
  }

  /// Navega a la pantalla de nueva orden.
  /// Actualmente deshabilitado.
  void navigateToNewOrder(BuildContext context) {
    // Navigator.pushNamed(context, '/new-order');
  }
}
