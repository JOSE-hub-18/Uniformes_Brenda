import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../business/usecases/print_usecase.dart';

class PrintProvider with ChangeNotifier {
  final PrintUseCase useCase;

  bool loading = false;
  String mensaje = "";

  PrintProvider(this.useCase);

  // permisos Bluetooth
  Future<bool> solicitarPermisosBluetooth() async {
    final statusScan = await Permission.bluetoothScan.request();
    final statusConnect = await Permission.bluetoothConnect.request();
    final statusLocation = await Permission.location.request();

    return statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted;
  }

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
      //  solicitar permisos ANTES de imprimir
      final permisosOk = await solicitarPermisosBluetooth();

      if (!permisosOk) {
        mensaje = "Se requieren permisos Bluetooth para imprimir";
        loading = false;
        notifyListeners();
        return;
      }

      //  lógica de impresión
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