import 'package:flutter/material.dart';
import '../../business/usecases/qr_usecase.dart';
import '../../models/models.dart';

class QrProvider extends ChangeNotifier {
  final QrUseCase useCase;

  QrProvider(this.useCase);

  final List<Unidad> _unidades = [];
  bool _procesando = false;
  String? _error;

  List<Unidad> get unidades => List.unmodifiable(_unidades);
  bool get procesando => _procesando;
  String? get error => _error;

  //Procesa un QR escaneado
  Future<void> procesarQr(String qr) async {
    if (_procesando) return;

    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      final unidad = await useCase.obtenerUnidad(qr);

      if (unidad == null) {
        _error = 'QR no encontrado';
        return;
      }

      final yaExiste = _unidades.any((u) => u.id == unidad.id);

      if (yaExiste) {
        _error = 'La unidad ya fue escaneada';
        return;
      }

      _unidades.add(unidad);
    } catch (e) {
      _error = 'Error al procesar QR';
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // Elimina una unidad de la lista
  void eliminarUnidad(int unidadId) {
    _unidades.removeWhere((u) => u.id == unidadId);
    notifyListeners();
  }

  //Limpia el estado completo
  void limpiar() {
    _unidades.clear();
    _error = null;
    notifyListeners();
  }
}