// lib/presentation/providers/print_provider.dart

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../business/usecases/print_usecase.dart';

import 'alertas_provider.dart';

class PrintProvider
    with ChangeNotifier {

  final PrintUseCase
      useCase;

  final AlertasProvider
      alertasProvider;

  bool loading = false;

  String mensaje = "";

  PrintProvider(

    this.useCase,

    this.alertasProvider,
  );

  // permisos Bluetooth

  Future<bool>
      solicitarPermisosBluetooth()
      async {

    final statusScan =
        await Permission
            .bluetoothScan
            .request();

    final statusConnect =
        await Permission
            .bluetoothConnect
            .request();

    final statusLocation =
        await Permission
            .location
            .request();

    return statusScan
            .isGranted &&
        statusConnect
            .isGranted &&
        statusLocation
            .isGranted;
  }

  Future<void>
      agregarUnidades(
    int idInventario,
    int cantidad,
  ) async {

    // evitar doble ejecución

    if (loading) {
      return;
    }

    // validar cantidad

    if (cantidad <= 0) {

      mensaje =
          "Cantidad inválida";

      notifyListeners();

      return;
    }

    loading = true;

    notifyListeners();

    try {

      // solicitar permisos
      // ANTES de imprimir

      final permisosOk =
          await solicitarPermisosBluetooth();

      if (!permisosOk) {

        mensaje =
            "Se requieren permisos Bluetooth para imprimir";

        throw Exception(
          'No se pudo imprimir',
        );
      }

      // lógica impresión

      mensaje =
          await useCase
              .ejecutar(
        idInventario,
        cantidad,
      );

      // refrescar alertas

      await alertasProvider
          .refrescar();

    } catch (e) {

      mensaje =
          "Error: $e";

      rethrow;

    } finally {

      loading = false;

      notifyListeners();
    }
  }

  // Reimprimir QR existente
  // SIN crear nueva unidad

  Future<void>
      imprimirQrExistente(
    int idUnidad,
  ) async {

    if (loading) {

      throw Exception(
        'Impresión en proceso',
      );
    }

    loading = true;

    notifyListeners();

    try {

      final permisosOk =
          await solicitarPermisosBluetooth();

      if (!permisosOk) {

        mensaje =
            "Se requieren permisos Bluetooth para imprimir";

        throw Exception(
          'No se pudo imprimir',
        );
      }

      await useCase
          .imprimirQrExistente(
        idUnidad,
      );

      mensaje =
          "QR reimpreso correctamente";

    } catch (e) {

      mensaje =
          "Error: $e";

      rethrow;

    } finally {

      loading = false;

      notifyListeners();
    }
  }

  // limpiar mensaje

  void limpiarMensaje() {

    mensaje = "";

    notifyListeners();
  }
}