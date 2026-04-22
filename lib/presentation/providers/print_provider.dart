import 'package:flutter/material.dart';
import '../../business/usecases/print_usecase.dart';

class PrintProvider with ChangeNotifier {
  final PrintUseCase useCase;

  bool loading = false;
  String mensaje = "";

  PrintProvider(this.useCase);

  Future<void> agregarUnidades(int idInventario, int cantidad) async {
    // evitar doble ejecución
    if (loading) return;

    // validar cantidad
    if (cantidad <= 0) {
      mensaje = "Cantidad inválida";
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      // l[ogica
      mensaje = await useCase.ejecutar(idInventario, cantidad);
    } catch (e) {
      mensaje = "Error: $e";
    }

    loading = false;
    notifyListeners();
  }

  // limpiar mensaje
  void limpiarMensaje() {
    mensaje = "";
    notifyListeners();
  }
}