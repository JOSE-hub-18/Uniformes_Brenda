import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  String _userName = 'Usuario';
  
  String get userName => _userName;
  
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
  
  // Métodos para las acciones de los botones
  void navigateToInventory(BuildContext context) {
    Navigator.pushNamed(context, '/inventory');
    
  }
  
  void navigateToOrders(BuildContext context) {
    // Navigator.pushNamed(context, '/orders');
    
  }
  
  void navigateToNewOrder(BuildContext context) {
    // Navigator.pushNamed(context, '/new-order');
    
  }
}