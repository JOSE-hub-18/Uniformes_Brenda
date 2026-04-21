import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class PrintService {
  Future<void> conectar();
  Future<void> desconectar();
  Future<void> imprimirQR(String id);
}

class BlePrintService implements PrintService {
  //IDs del servicio bluetooth de la impresora, consultar con nrfconnect
  static const String serviceUuid =
      "49535343-fe7d-4ae5-8fa9-9fafd205e455";

  static const String charUuid =
      "49535343-8841-43f4-a8d4-ecbe34729bb3";
//MAC de la impresora
  static const String printerMac = "66:32:DA:6B:86:A7";

  BluetoothDevice? _device;
  BluetoothCharacteristic? _char;

  // conexion
  Future<void> _conectar() async {
    print("Iniciando conexión BLE");

    final bonded = await FlutterBluePlus.bondedDevices;

    print("Dispositivos vinculados: ${bonded.length}");

    for (final d in bonded) {
      print("${d.platformName} - ${d.remoteId}");
    }

    for (final d in bonded) {
      if (d.remoteId.toString().toUpperCase() ==
          printerMac.toUpperCase()) {
        print("Impresora encontrada");
        _device = d;
        break;
      }
    }

    if (_device == null) {
      throw Exception("Impresora no encontrada");
    }

    print("Conectando...");
    await _device!.connect(
      timeout: const Duration(seconds: 5),
      autoConnect: false,
    );

    await Future.delayed(const Duration(seconds: 1));

    print("Descubriendo servicios...");
    final services = await _device!.discoverServices();

    for (var s in services) {
      print("Service: ${s.uuid}");

      if (s.uuid.toString().toLowerCase() == serviceUuid) {
        for (var c in s.characteristics) {
          print(
              "Char: ${c.uuid} | write: ${c.properties.write} | writeNoResp: ${c.properties.writeWithoutResponse}");

          if (c.uuid.toString().toLowerCase() == charUuid) {
            print("Characteristic encontrada");
            _char = c;
            return;
          }
        }
      }
    }

    throw Exception("Characteristic no encontrada");
  }

  Future<void> _desconectar() async {
    print("Desconectando...");
    await _device?.disconnect();
  }

  
  // IMPLEMENTACIÓN INTERFAZ
  
  @override
  Future<void> conectar() async {
    await _conectar();
  }

  @override
  Future<void> desconectar() async {
    await _desconectar();
  }

  // impresinon
  @override
  Future<void> imprimirQR(String id) async {
    if (_char == null) throw Exception("No conectado");

    print("Imprimiendo: $id");

    String tspl =
        "SIZE 40 mm,30 mm\r\n"
        "GAP 3 mm,0\r\n"
        "CLS\r\n"
        "QRCODE 10,10,L,5,A,0,\"$id\"\r\n"
        "TEXT 10,150,\"0\",0,2,2,\"$id\"\r\n"
        "PRINT 1\r\n";

    List<int> bytes = utf8.encode(tspl);

    for (int i = 0; i < bytes.length; i += 20) {
      int end = (i + 20 < bytes.length) ? i + 20 : bytes.length;

      await _char!.write(
        bytes.sublist(i, end),
        withoutResponse: true,
      );

      await Future.delayed(const Duration(milliseconds: 80));
    }
  }
}