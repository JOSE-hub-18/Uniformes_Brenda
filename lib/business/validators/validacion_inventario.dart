import '../../models/models.dart';

class ValidacionInventario {

  // valida que escuela, prenda y talla no sean nulos o vacíos
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

  // valida que el precio no sea menor o igual a 0
  static void validarPrecio(Inventario inventario) {
    if (inventario.precio <= 0) {
      throw Exception("El precio debe ser mayor a 0");
    }
  }

  // valida cantidad de unidades a insertar
  static void validarCantidadUnidades(int cantidad) {
    if (cantidad < 1 || cantidad > 9999) {
      throw Exception("Cantidad no permitida");
    }
  }

  // valida que el inventario no esté asociado a ventas activas antes de eliminarlo
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