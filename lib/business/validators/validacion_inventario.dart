import '../../models/models.dart';

/// Clase utilitaria que centraliza las validaciones de negocio
/// aplicables a los registros de inventario.
/// Todos sus métodos son estáticos y lanzan excepciones ante datos inválidos.
class ValidacionInventario {

  /// Verifica que los identificadores de escuela, prenda y talla
  /// sean valores positivos válidos.
  static void validarCamposObligatorios(Inventario inventario) {
    if (inventario.idEscuela <= 0) {
      throw Exception("La escuela es obligatoria");
    }

    if (inventario.idPrenda <= 0) {
      throw Exception("La prenda es obligatoria");
    }

    if (inventario.idTalla <= 0) {
      throw Exception("La talla es obligatoria");
    }
  }

  /// Verifica que el precio del inventario sea mayor a cero.
  static void validarPrecio(Inventario inventario) {
    if (inventario.precio <= 0) {
      throw Exception("El precio debe ser mayor a 0");
    }
  }

  /// Verifica que la cantidad de unidades a insertar esté dentro del rango permitido (1-9999).
  static void validarCantidadUnidades(int cantidad) {
    if (cantidad < 1 || cantidad > 9999) {
      throw Exception("Cantidad no permitida");
    }
  }

  /// Verifica que el registro de inventario no tenga ventas activas asociadas
  /// antes de permitir su eliminación.
  /// Recibe una función delegada para consultar las ventas activas,
  /// manteniendo esta clase desacoplada de los repositorios.
  static Future<void> validarEliminacion(
    int idInventario,
    Future<bool> Function(int) tieneVentasActivas,
  ) async {
    if (await tieneVentasActivas(idInventario)) {
      throw Exception(
        "No se puede eliminar el inventario porque tiene ventas activas"
      );
    }
  }
}