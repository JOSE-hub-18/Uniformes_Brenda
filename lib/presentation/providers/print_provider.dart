// lib/presentation/providers/print_provider.dart

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../business/usecases/print_usecase.dart';

import 'alertas_provider.dart';

/// Provider de estado para la gestión de impresión de QRs via Bluetooth.
///
/// Coordina [PrintUseCase] con la solicitud de permisos de Bluetooth
/// y la actualización de [AlertasProvider] tras cada operación de impresión.
class PrintProvider with ChangeNotifier {
  /// Caso de uso que encapsula la lógica de impresión de QRs.
  final PrintUseCase useCase;

  /// Referencia al provider de alertas para refrescarlas tras agregar unidades.
  final AlertasProvider alertasProvider;

  /// Indica si hay una operación de impresión en curso.
  bool loading = false;

  /// Mensaje de resultado de la última operación ejecutada.
  /// Vacío si no hay mensaje activo.
  String mensaje = "";

  /// Crea una instancia de [PrintProvider] con el [useCase] y [alertasProvider] requeridos.
  PrintProvider(this.useCase, this.alertasProvider);

  // permisos Bluetooth
  /// Solicita los permisos de Bluetooth y ubicación requeridos para la impresión.
  ///
  /// Retorna true únicamente si los tres permisos fueron concedidos:
  /// bluetoothScan, bluetoothConnect y location.
  Future<bool> solicitarPermisosBluetooth() async {
    final statusScan = await Permission.bluetoothScan.request();

    final statusConnect = await Permission.bluetoothConnect.request();

    final statusLocation = await Permission.location.request();

    return statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted;
  }

  /// Agrega unidades al inventario e imprime los QRs correspondientes.
  ///
  /// Regla de negocio: no se ejecuta si ya hay una impresión en curso
  /// o si la cantidad es menor o igual a cero.
  /// Solicita permisos Bluetooth antes de proceder con la impresión.
  /// Al completarse exitosamente, refresca [AlertasProvider].
  /// Propaga la excepción al caller en caso de error.
  Future<void> agregarUnidades(int idInventario, int cantidad) async {
    // Regla de negocio: evitar doble ejecución concurrente.
    if (loading) {
      return;
    }

    // Regla de negocio: la cantidad debe ser mayor a cero.
    if (cantidad <= 0) {
      mensaje = "Cantidad inválida";

      notifyListeners();

      return;
    }

    loading = true;

    notifyListeners();

    try {
      // Se verifican los permisos Bluetooth antes de intentar imprimir.
      final permisosOk = await solicitarPermisosBluetooth();

      if (!permisosOk) {
        mensaje = "Se requieren permisos Bluetooth para imprimir";

        throw Exception('No se pudo imprimir');
      }

      // Ejecuta la lógica de impresión y obtiene el mensaje de resultado.
      mensaje = await useCase.ejecutar(idInventario, cantidad);

      // Se refrescan las alertas de stock tras agregar unidades al inventario.
      await alertasProvider.refrescar();
    } catch (e) {
      mensaje = "Error: $e";

      rethrow;
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  // Reimprimir QR existente
  // SIN crear nueva unidad
  /// Reimprime el QR de una unidad ya existente sin crear un nuevo registro.
  ///
  /// Lanza una excepción si ya hay una impresión en curso.
  /// Solicita permisos Bluetooth antes de proceder.
  /// No modifica el inventario ni actualiza las alertas de stock.
  Future<void> imprimirQrExistente(int idUnidad) async {
    if (loading) {
      throw Exception('Impresión en proceso');
    }

    loading = true;

    notifyListeners();

    try {
      final permisosOk = await solicitarPermisosBluetooth();

      if (!permisosOk) {
        mensaje = "Se requieren permisos Bluetooth para imprimir";

        throw Exception('No se pudo imprimir');
      }

      await useCase.imprimirQrExistente(idUnidad);

      mensaje = "QR reimpreso correctamente";
    } catch (e) {
      mensaje = "Error: $e";

      rethrow;
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  // limpiar mensaje
  /// Reinicia [mensaje] a vacío y notifica a los listeners.
  ///
  /// Se invoca al iniciar una pantalla para evitar mostrar mensajes residuales.
  void limpiarMensaje() {
    mensaje = "";

    notifyListeners();
  }
}
