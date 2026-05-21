// lib/business/usecases/print_usecase.dart

import '../../data/repositories/unidad_repository.dart';

import '../services/print_service.dart';

/// Caso de uso que gestiona la impresión de etiquetas QR para unidades de inventario.
/// Coordina la creación de unidades en el repositorio, el envío a la impresora
/// y el rollback de unidades que no pudieron imprimirse.
class PrintUseCase {
  /// Servicio de impresión utilizado para conectar y enviar comandos a la impresora.
  final PrintService printer;

  /// Repositorio de unidades para insertar y eliminar registros durante el proceso.
  final UnidadRepository repo;

  PrintUseCase({required this.printer, required this.repo});

  /// Inserta e imprime la cantidad indicada de unidades para el inventario dado.
  /// Establece una única conexión BLE para todas las impresiones del lote.
  /// Por cada unidad, inserta el registro en el repositorio antes de imprimir.
  /// Si la impresión de una unidad falla, elimina el registro recién insertado
  /// para mantener la consistencia entre las unidades físicas y los registros del sistema,
  /// y detiene el proceso retornando un resumen parcial de la operación.
  /// La desconexión de la impresora se ejecuta siempre en el bloque finally.
  Future<String> ejecutar(int idInventario, int cantidad) async {
    if (cantidad <= 0) {
      throw Exception("Cantidad inválida");
    }

    int impresas = 0;

    try {
      await printer.conectar();

      for (int i = 0; i < cantidad; i++) {
        final ids = await repo.insertarUnidades(idInventario, 1);

        final id = ids.first;

        try {
          await printer.imprimirQR(id.toString());

          impresas++;
        } catch (e) {
          /// Rollback de la unidad insertada si la impresión falla,
          /// para evitar registros sin etiqueta física generada.
          await repo.eliminar(id);

          final noImpresas = cantidad - impresas;

          return "Se imprimieron $impresas, fallaron $noImpresas";
        }
      }

      return "Se imprimieron $impresas correctamente";
    } finally {
      await printer.desconectar();
    }
  }

  /// Reimprime la etiqueta QR de una unidad existente sin crear un nuevo registro.
  /// Útil para reponer etiquetas dañadas o perdidas de unidades ya registradas en el sistema.
  /// La conexión se establece con un timeout de 15 segundos.
  /// La desconexión se ejecuta siempre en el bloque finally.
  Future<void> imprimirQrExistente(int idUnidad) async {
    try {
      await printer.conectar().timeout(const Duration(seconds: 15));

      await printer.imprimirQR(idUnidad.toString());
    } finally {
      await printer.desconectar();
    }
  }
}
