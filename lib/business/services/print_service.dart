// lib/business/services/print_service.dart

import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Contrato base para servicios de impresión.
/// Define las operaciones mínimas requeridas para gestionar
/// la conexión con una impresora y ejecutar impresiones.
abstract class PrintService {

  Future<void> conectar();

  Future<void> desconectar();

  Future<void> imprimirQR(
    String id,
  );
}

/// Implementación de [PrintService] para impresoras térmicas
/// que se comunican mediante Bluetooth Low Energy (BLE).
/// Utiliza el protocolo TSPL para el envío de comandos de impresión.
class BlePrintService
    implements PrintService {

  /// UUID del servicio BLE expuesto por la impresora.
  /// Obtenido mediante herramienta nRF Connect u similar.
  static const String
      serviceUuid =
      "49535343-fe7d-4ae5-8fa9-9fafd205e455";

  /// UUID de la característica BLE utilizada para el envío de datos a la impresora.
  static const String
      charUuid =
      "49535343-8841-43f4-a8d4-ecbe34729bb3";

  /// Dirección MAC de la impresora térmica objetivo.
  static const String
      printerMac =
      "66:32:DA:6B:86:A7";

  /// Referencia al dispositivo BLE conectado. Null si no hay conexión activa.
  BluetoothDevice?
      _device;

  /// Característica BLE utilizada para escribir los datos de impresión.
  /// Null si no se ha establecido la conexión o no se encontró la característica.
  BluetoothCharacteristic?
      _char;

  /// Establece la conexión BLE con la impresora.
  /// Busca el dispositivo en la lista de dispositivos vinculados por su dirección MAC,
  /// se conecta a él y descubre los servicios y características disponibles.
  /// Lanza una excepción si la impresora no está vinculada
  /// o si no se encuentra el servicio o la característica requerida.
  Future<void>
      _conectar() async {

    print(
      "Iniciando conexion BLE",
    );

    final bonded =
        await FlutterBluePlus
            .bondedDevices;

    print(
      "Dispositivos vinculados: ${bonded.length}",
    );

    for (final d
        in bonded) {

      print(
        "${d.platformName} - ${d.remoteId}",
      );
    }

    /// Busca la impresora en los dispositivos vinculados comparando
    /// la dirección MAC de forma insensible a mayúsculas.
    for (final d
        in bonded) {

      if (d.remoteId
              .toString()
              .toUpperCase() ==
          printerMac
              .toUpperCase()) {

        print(
          "Impresora encontrada",
        );

        _device = d;

        break;
      }
    }

    if (_device ==
        null) {

      throw Exception(
        "Impresora no encontrada",
      );
    }

    print(
      "Conectando...",
    );

    await _device!
        .connect(

      timeout:
          const Duration(
        seconds: 5,
      ),

      autoConnect: false,
    );

    /// Espera breve posterior a la conexión para permitir
    /// que el stack BLE estabilice el enlace antes de descubrir servicios.
    await Future.delayed(

      const Duration(
        seconds: 1,
      ),
    );

    print(
      "Descubriendo servicios...",
    );

    final services =
        await _device!
            .discoverServices();

    /// Itera sobre los servicios descubiertos buscando el UUID de servicio
    /// y dentro de él la característica de escritura requerida.
    for (final s
        in services) {

      print(
        "Service: ${s.uuid}",
      );

      if (s.uuid
              .toString()
              .toLowerCase() ==
          serviceUuid) {

        for (final c
            in s.characteristics) {

          print(

            "Char: ${c.uuid} | "
            "write: ${c.properties.write} | "
            "writeNoResp: ${c.properties.writeWithoutResponse}",
          );

          if (c.uuid
                  .toString()
                  .toLowerCase() ==
              charUuid) {

            print(
              "Characteristic encontrada",
            );

            _char = c;

            return;
          }
        }
      }
    }

    throw Exception(
      "Characteristic no encontrada",
    );
  }

  /// Desconecta el dispositivo BLE actualmente conectado.
  Future<void>
      _desconectar() async {

    print(
      "Desconectando...",
    );

    await _device
        ?.disconnect();
  }

  // IMPLEMENTACION INTERFAZ

  @override
  Future<void>
      conectar() async {

    await _conectar();
  }

  @override
  Future<void>
      desconectar() async {

    await _desconectar();
  }

  /// Genera y envía un comando TSPL a la impresora para imprimir
  /// una etiqueta con código QR e identificador en texto.
  /// El comando se fragmenta en paquetes de 20 bytes con un retardo
  /// de 80ms entre cada uno para respetar los límites de transferencia BLE.
  /// Lanza una excepción si no hay una conexión activa al momento de imprimir.
  @override
  Future<void>
      imprimirQR(
    String id,
  ) async {

    if (_char ==
        null) {

      throw Exception(
        "No conectado",
      );
    }

    print(
      "Imprimiendo: $id",
    );

    /// Comando TSPL que define el tamaño de la etiqueta (40x30mm),
    /// el espaciado entre etiquetas, el código QR y el texto identificador.
    final tspl =

        "SIZE 40 mm,30 mm\r\n"

        "GAP 3 mm,0\r\n"

        "CLS\r\n"

        "QRCODE 10,10,L,5,A,0,\"$id\"\r\n"

        "TEXT 10,150,\"0\",0,2,2,\"$id\"\r\n"

        "PRINT 1\r\n";

    final bytes =
        utf8.encode(
      tspl,
    );

    /// Envía los bytes del comando en fragmentos de 20 bytes usando escritura
    /// sin respuesta (writeWithoutResponse), con retardo entre fragmentos
    /// para evitar desbordamiento en el buffer BLE de la impresora.
    for (
      int i = 0;
      i < bytes.length;
      i += 20
    ) {

      final end =

          (i + 20 <
                  bytes.length)

              ? i + 20

              : bytes.length;

      await _char!
          .write(

        bytes.sublist(
          i,
          end,
        ),

        withoutResponse:
            true,
      );

      await Future.delayed(

        const Duration(
          milliseconds: 80,
        ),
      );
    }
  }
}