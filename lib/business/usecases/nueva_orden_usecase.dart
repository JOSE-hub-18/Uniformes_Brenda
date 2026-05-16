// lib/domain/usecases/nueva_orden_usecase.dart

import '../../data/repositories/inventario_repository.dart';
import '../../data/repositories/orden_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/unidad_repository.dart';
import '../../data/repositories/venta_repository.dart';

import '../../models/models.dart';

import 'qr_usecase.dart';

/// Clasifica el origen de un item dentro de una orden.
/// [venta] indica que el item tiene una unidad física escaneada o resuelta.
/// [pedido] indica que el item es un encargo sin unidad física asignada aún.
enum TipoItemOrden {
  venta,
  pedido,
}

/// Representa un item individual dentro de una orden en construcción.
/// Puede tener una unidad física asignada ([idUnidad]) si proviene de un escaneo QR,
/// o carecer de ella si fue agregado manualmente como pedido.
class ItemOrden {

  /// Identificador del registro de inventario al que pertenece este item.
  final int idInventario;

  /// Precio unitario tomado del inventario al momento de agregar el item.
  final double precioUnitario;

  /// Identificador de la unidad física asignada. Null si es un pedido sin unidad resuelta.
  final int? idUnidad;

  /// Indica si el item se procesará como venta directa o como pedido.
  final TipoItemOrden tipo;

  const ItemOrden({
    required this.idInventario,
    required this.precioUnitario,
    required this.tipo,
    this.idUnidad,
  });

  /// Retorna true si el item tiene una unidad física asignada.
  bool get tieneUnidadResuelta =>
      idUnidad != null;
}

/// Indica el tipo de transacción que resultó de la confirmación de la orden.
enum TipoConfirmacion {
  venta,
  pedido,
}

/// Resultado de la confirmación de una orden o sub-orden.
/// Contiene los identificadores generados y el resumen de la transacción.
class NuevaOrdenResult {

  /// Identificador de la venta generada. Null si la confirmación fue de pedido.
  final int? idVenta;

  /// Identificador del pedido generado. Null si la confirmación fue de venta.
  final int? idPedido;

  /// Tipo de transacción que representa este resultado.
  final TipoConfirmacion tipo;

  /// Suma total de los precios unitarios de los items procesados.
  final double total;

  /// Cantidad de prendas incluidas en la transacción.
  final int totalPrendas;

  const NuevaOrdenResult({
    this.idVenta,
    this.idPedido,
    required this.tipo,
    required this.total,
    required this.totalPrendas,
  });
}

/// Caso de uso que gestiona la creación de órdenes mixtas,
/// combinando items de venta directa (con unidad física) y pedidos (sin unidad asignada).
/// Coordina la validación, resolución de unidades, persistencia de ventas,
/// pedidos y la orden raíz que los agrupa.
class NuevaOrdenUseCase {

  final InventarioRepository
      _inventarioRepository;

  final UnidadRepository
      _unidadRepository;

  final VentaRepository
      _ventaRepository;

  final PedidoRepository
      _pedidoRepository;

  final OrdenRepository
      _ordenRepository;

  final QrUseCase
      _qrUseCase;

  NuevaOrdenUseCase({
    required InventarioRepository
        inventarioRepository,

    required UnidadRepository
        unidadRepository,

    required VentaRepository
        ventaRepository,

    required PedidoRepository
        pedidoRepository,

    required OrdenRepository
        ordenRepository,

    required QrUseCase
        qrUseCase,
  })  : _inventarioRepository =
            inventarioRepository,
        _unidadRepository =
            unidadRepository,
        _ventaRepository =
            ventaRepository,
        _pedidoRepository =
            pedidoRepository,
        _ordenRepository =
            ordenRepository,
        _qrUseCase =
            qrUseCase;

  /// Agrega un item a la orden mediante escaneo de código QR.
  /// Valida que la unidad exista, esté activa y no haya sido agregada previamente.
  /// Retorna un [ItemOrden] de tipo [TipoItemOrden.venta] con la unidad física asignada.
  Future<ItemOrden> agregarPorQr({
    required String qr,
    required List<ItemOrden>
        itemsActuales,
  }) async {

    final unidad =
        await _qrUseCase
            .obtenerUnidad(
      qr.trim(),
    );

    if (unidad == null) {

      throw StateError(
        'El QR escaneado no corresponde a ninguna unidad.',
      );
    }

    if (!unidad.activo) {

      throw StateError(
        'Esta unidad ya fue vendida o no está disponible.',
      );
    }

    /// Regla de negocio: no se permite agregar la misma unidad física más de una vez en la orden.
    final yaAgregado =
        itemsActuales.any(
      (i) =>
          i.idUnidad ==
          unidad.id,
    );

    if (yaAgregado) {

      throw StateError(
        'Esta unidad ya fue agregada a la orden.',
      );
    }

    final inventario =
        await _inventarioRepository
            .obtenerPorId(
      unidad.idInventario,
    );

    if (inventario == null) {

      throw StateError(
        'No se encontró el inventario de esta unidad.',
      );
    }

    return ItemOrden(

      idInventario:
          inventario.id!,

      precioUnitario:
          inventario.precio,

      idUnidad:
          unidad.id,

      tipo:
          TipoItemOrden.venta,
    );
  }

  /// Agrega un item a la orden de forma manual mediante el identificador de inventario.
  /// No requiere unidad física; el item se tratará como pedido.
  /// Retorna un [ItemOrden] de tipo [TipoItemOrden.pedido] sin unidad asignada.
  Future<ItemOrden> agregarManual({
    required int idInventario,
    required List<ItemOrden>
        itemsActuales,
  }) async {

    final inventario =
        await _inventarioRepository
            .obtenerPorId(
      idInventario,
    );

    if (inventario == null) {

      throw StateError(
        'El inventario seleccionado no existe.',
      );
    }

    return ItemOrden(

      idInventario:
          idInventario,

      precioUnitario:
          inventario.precio,

      tipo:
          TipoItemOrden.pedido,
    );
  }

  /// Confirma una orden mixta que puede contener items de venta y de pedido.
  /// Crea primero el registro de orden raíz y luego procesa cada grupo por separado.
  /// Si existen items de venta, se procesan primero y su identificador se vincula
  /// al pedido resultante para mantener la trazabilidad entre ambas transacciones.
  Future<void> confirmarMixto({
    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,
  }) async {

    if (items.isEmpty) {

      throw StateError(
        'La orden no tiene prendas agregadas.',
      );
    }

    final orden = Orden(

      idUsuario:
          idUsuario,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),
    );

    final idOrden =
        await _ordenRepository
            .insertar(
      orden,
    );

    final ventas = items
        .where(
          (i) =>
              i.tipo ==
              TipoItemOrden
                  .venta,
        )
        .toList();

    final pedidos = items
        .where(
          (i) =>
              i.tipo ==
              TipoItemOrden
                  .pedido,
        )
        .toList();

    int? idVentaOrigen;

    if (ventas.isNotEmpty) {

      final resultadoVenta =
          await _confirmarVenta(

        items: ventas,

        idUsuario:
            idUsuario,

        nombreCliente:
            nombreCliente,

        idOrdenOrigen:
            idOrden,
      );

      idVentaOrigen =
          resultadoVenta.idVenta;
    }

    if (pedidos.isNotEmpty) {

      await _confirmarPedido(

        items: pedidos,

        idUsuario:
            idUsuario,

        nombreCliente:
            nombreCliente,

        idOrdenOrigen:
            idOrden,

        idVentaOrigen:
            idVentaOrigen,
      );
    }
  }

  /// Procesa los items de tipo venta dentro de una orden.
  /// Resuelve las unidades físicas de los items que no las tengan asignadas,
  /// verifica que cada unidad siga disponible, persiste la venta con sus detalles
  /// y desactiva las unidades vendidas para retirarlas del stock disponible.
  Future<NuevaOrdenResult>
      _confirmarVenta({
    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,

    required int
        idOrdenOrigen,
  }) async {

    final itemsResueltos =
        await _resolverUnidades(
      items,
    );

    /// Verificación de disponibilidad previa a la escritura:
    /// garantiza que ninguna unidad haya sido vendida entre el momento
    /// en que se agregó a la orden y la confirmación.
    for (final item
        in itemsResueltos) {

      final unidad =
          await _unidadRepository
              .obtenerPorId(
        item.idUnidad!,
      );

      if (unidad == null ||
          !unidad.activo) {

        throw StateError(
          'Una unidad ya no está disponible.',
        );
      }
    }

    final total =
        _calcularTotal(
      itemsResueltos,
    );

    final venta = Venta(

      idUsuario:
          idUsuario,

      idOrdenOrigen:
          idOrdenOrigen,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),

      total:
          total,

      estado:
          EstadoVenta
              .completada,
    );

    final detalles =
        itemsResueltos
            .map(
              (item) =>
                  DetalleVenta(

                idVenta: 0,

                idUnidad:
                    item.idUnidad!,

                cantidad: 1,

                precioUnitario:
                    item
                        .precioUnitario,
              ),
            )
            .toList();

    final idVenta =
        await _ventaRepository
            .insertarVentaYDetalles(

      venta: venta,

      detalles:
          detalles,
    );

    /// Desactivación de unidades tras la persistencia exitosa de la venta.
    /// Una unidad desactivada no puede ser vendida ni asignada a nuevas órdenes.
    for (final item
        in itemsResueltos) {

      await _unidadRepository
          .desactivar(
        item.idUnidad!,
      );
    }

    return NuevaOrdenResult(

      idVenta:
          idVenta,

      tipo:
          TipoConfirmacion
              .venta,

      total:
          total,

      totalPrendas:
          itemsResueltos.length,
    );
  }

  /// Procesa los items de tipo pedido dentro de una orden.
  /// Crea el pedido en estado pendiente con sus detalles sin unidad física asignada.
  /// Puede vincularse a una venta previa de la misma orden mediante [idVentaOrigen].
  Future<NuevaOrdenResult>
      _confirmarPedido({

    required List<ItemOrden>
        items,

    required int idUsuario,

    required String?
        nombreCliente,

    required int
        idOrdenOrigen,

    required int?
        idVentaOrigen,
  }) async {

    final total =
        _calcularTotal(
      items,
    );

    final pedido = Pedido(

      idUsuario:
          idUsuario,

      idOrdenOrigen:
          idOrdenOrigen,

      idVentaOrigen:
          idVentaOrigen,

      nombreCliente:
          nombreCliente,

      fecha:
          DateTime.now(),

      total:
          total,

      estado:
          EstadoPedido
              .pendiente,
    );

    final detalles = items
        .map(
          (item) =>
              DetallePedido(

            idPedido: 0,

            idInventario:
                item.idInventario,

            /// La unidad física se asigna posteriormente al registrar la entrega del pedido.
            idUnidadRegistrada:
                null,

            registrado:
                false,

            precioUnitario:
                item.precioUnitario,
          ),
        )
        .toList();

    final idPedido =
        await _pedidoRepository
            .insertarPedidoYDetalles(

      pedido: pedido,

      detalles:
          detalles,
    );

    return NuevaOrdenResult(

      idPedido:
          idPedido,

      tipo:
          TipoConfirmacion
              .pedido,

      total:
          total,

      totalPrendas:
          items.length,
    );
  }

  /// Asigna una unidad física a cada item que aún no tenga una.
  /// Para items sin unidad resuelta, consulta las unidades activas del inventario
  /// y selecciona la primera que no haya sido asignada ya en esta misma operación.
  /// Lanza una excepción si no hay unidades disponibles para algún item.
  Future<List<ItemOrden>>
      _resolverUnidades(
    List<ItemOrden> items,
  ) async {

    final List<ItemOrden>
        resueltos = [];

    /// Conjunto de IDs de unidades ya asignadas, para evitar asignar la misma unidad
    /// a más de un item dentro del mismo proceso de resolución.
    final Set<int>
        unidadesUsadas = items
            .where(
              (i) =>
                  i.tieneUnidadResuelta,
            )
            .map(
              (i) =>
                  i.idUnidad!,
            )
            .toSet();

    for (final item
        in items) {

      if (item
          .tieneUnidadResuelta) {

        resueltos.add(item);

        continue;
      }

      final unidadesDisponibles =
          await _unidadRepository
              .obtenerPorInventario(
        item.idInventario,
      );

      final unidad =
          unidadesDisponibles
              .firstWhere(

        (u) =>
            !unidadesUsadas
                .contains(
          u.id,
        ),

        orElse: () =>
            throw StateError(
          'No hay unidades disponibles.',
        ),
      );

      unidadesUsadas
          .add(unidad.id!);

      resueltos.add(

        ItemOrden(

          idInventario:
              item.idInventario,

          precioUnitario:
              item.precioUnitario,

          idUnidad:
              unidad.id,

          tipo:
              item.tipo,
        ),
      );
    }

    return resueltos;
  }

  /// Calcula el total de la orden sumando el precio unitario de cada item.
  double _calcularTotal(
    List<ItemOrden> items,
  ) {

    return items.fold(

      0,

      (sum, i) =>
          sum +
          i.precioUnitario,
    );
  }
}