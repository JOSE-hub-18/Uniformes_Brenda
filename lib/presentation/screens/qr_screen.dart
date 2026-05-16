import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

/// Resultado genérico para cualquier pantalla de escaneo.
/// 
/// - `ok`: escaneo exitoso.
/// - `error`: ocurrió un error al procesar el escaneo.
/// - `duplicado`: el código ya fue procesado previamente.
enum ResultadoScan {

  ok,

  error,

  duplicado,
}

/// Modelo de feedback configurable que encapsula el resultado del escaneo
/// y un mensaje legible para mostrar al usuario.
class ScanFeedback {

  /// Resultado del escaneo (ok, error, duplicado).
  final ResultadoScan
      resultado;

  /// Mensaje descriptivo asociado al resultado.
  final String
      mensaje;

  /// Constructor que obliga a proporcionar resultado y mensaje.
  ScanFeedback({

    required this.resultado,

    required this.mensaje,
  });
}

/// Pantalla que implementa un escáner de códigos QR usando `mobile_scanner`.
/// 
/// - Recibe un callback `onScan` que procesa el valor del QR y devuelve un `ScanFeedback`.
/// - `mostrarMensaje` controla si se muestra un mensaje visual tras el escaneo.
class QRScannerScreen
    extends StatefulWidget {

  /// Callback que cada pantalla define para procesar el QR.
  final Future<ScanFeedback>
      Function(String qr)
          onScan;

  /// Indica si se debe mostrar el mensaje de feedback en pantalla.
  final bool
      mostrarMensaje;

  const QRScannerScreen({

    super.key,

    required this.onScan,

    this.mostrarMensaje =
        true,
  });

  @override
  State<QRScannerScreen>
      createState() =>

          _QRScannerScreenState();
}

/// Estado asociado a [QRScannerScreen].
/// 
/// - Controla el `MobileScannerController`.
/// - Gestiona la lógica de procesamiento para evitar reentradas.
/// - Muestra mensajes temporales de resultado con color según el tipo.
class _QRScannerScreenState
    extends State<
        QRScannerScreen> {

  /// Controlador del paquete `mobile_scanner` para manejar la cámara.
  late final MobileScannerController
      controller;

  /// Indicador para evitar procesar múltiples códigos simultáneamente.
  bool _procesando =
      false;

  /// Mensaje temporal que se muestra en pantalla tras el escaneo.
  String _mensaje = "";

  /// Color del contenedor del mensaje (verde/rojo/transparente).
  Color _colorMensaje =
      Colors.transparent;

  @override
  void initState() {

    super.initState();

    // Inicializa el controlador de la cámara.
    controller =
        MobileScannerController();
  }

  /// Maneja el resultado del escaneo.
  /// 
  /// - Evita reentradas usando `_procesando`.
  /// - Llama al callback `widget.onScan` y actualiza el mensaje y color según el feedback.
  /// - Espera un breve lapso para mostrar el mensaje y luego lo oculta.
  Future<void>
      _handleScan(
    String qr,
  ) async {

    if (_procesando) {
      return;
    }

    _procesando = true;

    final feedback =
        await widget.onScan(
      qr,
    );

    if (widget
        .mostrarMensaje) {

      setState(() {

        _mensaje =
            feedback.mensaje;

        switch (
            feedback
                .resultado) {

          case ResultadoScan.ok:

            _colorMensaje =
                Colors.green;

            break;

          case ResultadoScan
                .duplicado:

          case ResultadoScan
                .error:

            _colorMensaje =
                Colors.red;

            break;
        }
      });
    }

    // Mantiene el mensaje visible un breve tiempo para que el usuario lo perciba.
    await Future.delayed(

      const Duration(
        milliseconds: 800,
      ),
    );

    if (widget
            .mostrarMensaje &&
        mounted) {

      setState(() {

        _mensaje = "";

        _colorMensaje =
            Colors.transparent;
      });
    }

    _procesando = false;
  }

  @override
  void dispose() {

    // Detiene la cámara y libera recursos del controlador.
    controller.stop();

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: Stack(

        children: [

          // Cámara: widget que provee la vista previa y detección de códigos.
          MobileScanner(

            controller:
                controller,

            fit:
                BoxFit.cover,

            // Callback que se ejecuta cuando se detectan códigos.
            onDetect:
                (capture) {

              if (_procesando) {
                return;
              }

              final barcode =
                  capture
                      .barcodes
                      .first
                      .rawValue;

              if (barcode !=
                  null) {

                _handleScan(
                  barcode,
                );
              }
            },
          ),

          // Overlay visual que oscurece el área fuera del recuadro de escaneo.
          CustomPaint(

            painter:
                QRScannerOverlay(),

            child:
                Container(),
          ),

          // MENSAJE: muestra feedback temporal en la parte superior si existe.
          if (_mensaje
              .isNotEmpty)

            Positioned(

              top: 100,

              left: 0,

              right: 0,

              child: Center(

                child:
                    Container(

                  padding:
                      const EdgeInsets
                          .symmetric(

                    horizontal:
                        16,

                    vertical:
                        10,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        _colorMensaje,

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  child: Text(

                    _mensaje,

                    style:
                        const TextStyle(

                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Panel inferior con instrucciones y botón cancelar.
          Positioned(

            bottom: 0,

            left: 0,

            right: 0,

            child: Container(

              padding:
                  const EdgeInsets
                      .symmetric(

                horizontal:
                    32,

                vertical:
                    40,
              ),

              decoration:
                  const BoxDecoration(

                color:
                    Color(
                  0xFFF5F5F5,
                ),

                borderRadius:
                    BorderRadius.vertical(

                  top:
                      Radius.circular(
                    24,
                  ),
                ),
              ),

              child: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  // Instrucción para el usuario.
                  const Text(

                    'Apunte la cámara hacia el código QR',

                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(

                    width: 200,

                    child:
                        ElevatedButton(

                      // Acción del botón cancelar: detiene la cámara y cierra la pantalla.
                      onPressed:
                          () async {

                        await controller
                            .stop();

                        if (!mounted) {
                          return;
                        }

                        Navigator.pop(
                          context,
                        );
                      },

                      child:
                          const Text(
                        "Cancelar",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay visual del scanner que dibuja:
/// - una máscara oscura sobre la pantalla,
/// - un recuadro central transparente donde se espera el QR,
/// - esquinas resaltadas en color para guiar al usuario.
class QRScannerOverlay
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    // Área de escaneo centrada en la parte superior-media de la pantalla.
    final scanArea =
        Rect.fromCenter(

      center: Offset(

        size.width / 2,

        size.height * 0.3,
      ),

      width:
          size.width * 0.7,

      height:
          size.width * 0.7,
    );

    // Path que representa todo el fondo.
    final background =
        Path()

          ..addRect(

            Rect.fromLTWH(

              0,

              0,

              size.width,

              size.height,
            ),
          );

    // Path que representa el "agujero" transparente donde se ve la cámara.
    final hole = Path()

      ..addRect(
        scanArea,
      );

    // Combina los paths para obtener la máscara con el hueco central.
    final finalPath =
        Path.combine(

      PathOperation
          .difference,

      background,

      hole,
    );

    final overlayPaint =
        Paint()

          ..color =
              const Color(
            0x80000000,
          );

    // Dibuja la máscara oscura.
    canvas.drawPath(
      finalPath,
      overlayPaint,
    );

    // Color para las esquinas del recuadro de escaneo.
    final cornerPaint =
        Paint()

          ..color =
              const Color(
            0xFFFFC107,
          )

          ..style =
              PaintingStyle
                  .stroke

          ..strokeWidth = 4;

    const l = 30.0;

    // Superior izquierda: dibuja dos líneas formando la esquina.
    canvas.drawLine(

      Offset(
        scanArea.left,
        scanArea.top,
      ),

      Offset(
        scanArea.left + l,
        scanArea.top,
      ),

      cornerPaint,
    );

    canvas.drawLine(

      Offset(
        scanArea.left,
        scanArea.top,
      ),

      Offset(
        scanArea.left,
        scanArea.top + l,
      ),

      cornerPaint,
    );

    // Superior derecha
    canvas.drawLine(

      Offset(
        scanArea.right,
        scanArea.top,
      ),

      Offset(
        scanArea.right - l,
        scanArea.top,
      ),

      cornerPaint,
    );

    canvas.drawLine(

      Offset(
        scanArea.right,
        scanArea.top,
      ),

      Offset(
        scanArea.right,
        scanArea.top + l,
      ),

      cornerPaint,
    );

    // Inferior izquierda
    canvas.drawLine(

      Offset(
        scanArea.left,
        scanArea.bottom,
      ),

      Offset(
        scanArea.left + l,
        scanArea.bottom,
      ),

      cornerPaint,
    );

    canvas.drawLine(

      Offset(
        scanArea.left,
        scanArea.bottom,
      ),

      Offset(
        scanArea.left,
        scanArea.bottom - l,
      ),

      cornerPaint,
    );

    // Inferior derecha
    canvas.drawLine(

      Offset(
        scanArea.right,
        scanArea.bottom,
      ),

      Offset(
        scanArea.right - l,
        scanArea.bottom,
      ),

      cornerPaint,
    );

    canvas.drawLine(

      Offset(
        scanArea.right,
        scanArea.bottom,
      ),

      Offset(
        scanArea.right,
        scanArea.bottom - l,
      ),

      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(

    covariant CustomPainter
        oldDelegate,
  ) {

    // El overlay es estático; no es necesario repintar.
    return false;
  }
}
