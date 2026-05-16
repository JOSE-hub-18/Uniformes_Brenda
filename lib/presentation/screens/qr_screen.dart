import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

/// Resultado genérico para cualquier pantalla

enum ResultadoScan {

  ok,

  error,

  duplicado,
}

/// Modelo de feedback configurable

class ScanFeedback {

  final ResultadoScan
      resultado;

  final String
      mensaje;

  ScanFeedback({

    required this.resultado,

    required this.mensaje,
  });
}

class QRScannerScreen
    extends StatefulWidget {

  /// Callback que cada pantalla define

  final Future<ScanFeedback>
      Function(String qr)
          onScan;

  /// Mostrar o no mensaje

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

class _QRScannerScreenState
    extends State<
        QRScannerScreen> {

  late final MobileScannerController
      controller;

  bool _procesando =
      false;

  String _mensaje = "";

  Color _colorMensaje =
      Colors.transparent;

  @override
  void initState() {

    super.initState();

    controller =
        MobileScannerController();
  }

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

          // Cámara

          MobileScanner(

            controller:
                controller,

            fit:
                BoxFit.cover,

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

          // Overlay visual

          CustomPaint(

            painter:
                QRScannerOverlay(),

            child:
                Container(),
          ),

          // MENSAJE

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

          // Panel inferior

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

/// Overlay visual del scanner

class QRScannerOverlay
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

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

    final hole = Path()

      ..addRect(
        scanArea,
      );

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

    canvas.drawPath(
      finalPath,
      overlayPaint,
    );

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

    // Superior izquierda

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

    return false;
  }
}