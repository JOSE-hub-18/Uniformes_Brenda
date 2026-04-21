import '../../data/repositories/unidad_repository.dart';
import '../services/print_service.dart';

class PrintUseCase {
  final PrintService printer;
  final UnidadRepository repo;

  PrintUseCase(this.printer, this.repo);

  Future<String> ejecutar(int idInventario, int cantidad) async {
    if (cantidad <= 0) {
      throw Exception("Cantidad inválida");
    }

    int impresas = 0;

    try {
      //  Conectar UNA vez
      await printer.conectar();

      for (int i = 0; i < cantidad; i++) {
        // Insertar unidad
        final ids = await repo.insertarUnidades(idInventario, 1);
        final id = ids.first;

        try {
          // Imprimir
          await printer.imprimirQR(id.toString());
          impresas++;
        } catch (e) {
          //  Las etiquetas se registra-imprime una por una, si falla una, se elimina y se cancela la orden
          await repo.eliminar(id);

          final noImpresas = cantidad - impresas;

          return "Se imprimieron $impresas, fallaron $noImpresas";
        }
      }

      return "Se imprimieron $impresas correctamente";
    } finally {
      // Desconectar
      await printer.desconectar();
    }
  }
}