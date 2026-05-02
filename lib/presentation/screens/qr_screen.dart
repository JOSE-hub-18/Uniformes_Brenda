import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../business/usecases/restar_unidades_usecase.dart';

class QRScannerScreen extends StatefulWidget {
  final Future<ResultadoRestarUnidad> Function(String qr) onScan;

  const QRScannerScreen({
    super.key,
    required this.onScan,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool _procesando = false;
  Color _feedbackColor = Colors.transparent;
  String _mensaje = "";

  Future<void> _handleScan(String qr) async {
    if (_procesando) return;

    _procesando = true;

    final resultado = await widget.onScan(qr);

    setState(() {
      switch (resultado) {
        case ResultadoRestarUnidad.ok:
          _feedbackColor = Colors.green;
          _mensaje = "Eliminado";
          break;
        case ResultadoRestarUnidad.yaDesactivada:
          _feedbackColor = Colors.red;
          _mensaje = "Ya eliminado";
          break;
        case ResultadoRestarUnidad.noPertenece:
          _feedbackColor = Colors.red;
          _mensaje = "No pertenece";
          break;
        case ResultadoRestarUnidad.noExiste:
          _feedbackColor = Colors.red;
          _mensaje = "No existe";
          break;
        default:
          _feedbackColor = Colors.red;
          _mensaje = "Error";
      }
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _feedbackColor = Colors.transparent;
        _mensaje = "";
      });
    }

    _procesando = false;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null) {
                _handleScan(barcode);
              }
            },
          ),

          CustomPaint(
            painter: QRScannerOverlay(_feedbackColor),
            child: Container(),
          ),

          // MENSAJE
          if (_mensaje.isNotEmpty)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: _feedbackColor,
                  child: Text(
                    _mensaje,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // panel inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Apunte la cámara hacia el código QR',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
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

class QRScannerOverlay extends CustomPainter {
  final Color feedbackColor;

  QRScannerOverlay(this.feedbackColor);

  @override
  void paint(Canvas canvas, Size size) {
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.3),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hole = Path()..addRect(scanArea);

    final finalPath =
        Path.combine(PathOperation.difference, background, hole);

    final overlayPaint = Paint()
      ..color = feedbackColor == Colors.transparent
          ? const Color(0x80000000)
          : feedbackColor.withOpacity(0.3);

    canvas.drawPath(finalPath, overlayPaint);

    final cornerPaint = Paint()
      ..color = feedbackColor == Colors.transparent
          ? const Color(0xFFFFC107)
          : feedbackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const l = 30.0;

    canvas.drawLine(Offset(scanArea.left, scanArea.top),
        Offset(scanArea.left + l, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.top),
        Offset(scanArea.left, scanArea.top + l), cornerPaint);

    canvas.drawLine(Offset(scanArea.right, scanArea.top),
        Offset(scanArea.right - l, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top),
        Offset(scanArea.right, scanArea.top + l), cornerPaint);

    canvas.drawLine(Offset(scanArea.left, scanArea.bottom),
        Offset(scanArea.left + l, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom),
        Offset(scanArea.left, scanArea.bottom - l), cornerPaint);

    canvas.drawLine(Offset(scanArea.right, scanArea.bottom),
        Offset(scanArea.right - l, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom),
        Offset(scanArea.right, scanArea.bottom - l), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant QRScannerOverlay oldDelegate) {
    return oldDelegate.feedbackColor != feedbackColor;
  }
}