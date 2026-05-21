import 'package:flutter/material.dart';
import '../../business/usecases/qr_usecase.dart';
import '../../models/models.dart';

/// Provider de estado para la gestión de unidades obtenidas mediante escaneo de QR.
///
/// Consume [QrUseCase] para resolver los códigos QR escaneados a instancias
/// de [Unidad], manteniendo una lista acumulada de unidades procesadas en la sesión.
class QrProvider extends ChangeNotifier {
  /// Caso de uso encargado de resolver un código QR a una [Unidad].
  final QrUseCase useCase;

  /// Crea una instancia de [QrProvider] con el [useCase] requerido.
  QrProvider(this.useCase);

  /// Lista interna de unidades procesadas en la sesión actual.
  final List<Unidad> _unidades = [];

  /// Indica si hay un procesamiento de QR en curso.
  bool _procesando = false;

  /// Mensaje del último error ocurrido. Null si no hay error activo.
  String? _error;

  /// Expone la lista de unidades como vista de solo lectura.
  List<Unidad> get unidades => List.unmodifiable(_unidades);

  /// Expone el estado de procesamiento a los widgets consumidores.
  bool get procesando => _procesando;

  /// Expone el mensaje de error a los widgets consumidores.
  String? get error => _error;

  /// Procesa un código QR escaneado y agrega la unidad correspondiente a la lista.
  ///
  /// Regla de negocio: no se procesa un nuevo QR si ya hay uno en curso.
  /// Regla de negocio: una unidad ya escaneada no puede agregarse de nuevo.
  /// Si el QR no corresponde a ninguna unidad registrada, establece un mensaje de error.
  Future<void> procesarQr(String qr) async {
    if (_procesando) return;

    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      final unidad = await useCase.obtenerUnidad(qr);

      // Regla de negocio: el QR debe corresponder a una unidad registrada en el sistema.
      if (unidad == null) {
        _error = 'QR no encontrado';
        return;
      }

      // Regla de negocio: no se permite escanear la misma unidad más de una vez.
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

  /// Elimina la unidad identificada por [unidadId] de la lista de unidades procesadas.
  void eliminarUnidad(int unidadId) {
    _unidades.removeWhere((u) => u.id == unidadId);
    notifyListeners();
  }

  /// Reinicia el estado completo del provider, limpiando unidades y errores.
  void limpiar() {
    _unidades.clear();
    _error = null;
    notifyListeners();
  }
}
