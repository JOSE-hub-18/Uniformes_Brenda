// models.dart

// ─────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────

enum RolUsuario { admin, vendedor }

enum EstadoVenta {
  completada,
  cancelada,
  pendiente,
}

enum EstadoPedido {
  pendiente,
  completado,
  cancelado,
}

// ─────────────────────────────────────────────────────────────
// EXTENSIONS
// ─────────────────────────────────────────────────────────────

extension RolUsuarioExt on RolUsuario {
  String toDb() => name;
}

extension RolUsuarioParse on String {
  RolUsuario? toRolUsuario() {
    try {
      return RolUsuario.values.firstWhere(
        (e) => e.name == this,
      );
    } catch (_) {
      return null;
    }
  }
}

extension EstadoVentaExt on EstadoVenta {
  String toDb() => name;
}

extension EstadoVentaParse on String {
  EstadoVenta toEstadoVenta() {
    return EstadoVenta.values.firstWhere(
      (e) => e.name == this,
      orElse: () => EstadoVenta.completada,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ORDEN
// ─────────────────────────────────────────────────────────────

class Orden {
  int? id;

  int idUsuario;

  String? nombreCliente;

  DateTime fecha;

  Orden({
    this.id,
    required this.idUsuario,
    this.nombreCliente,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'nombre_cliente': nombreCliente,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Orden.fromMap(
    Map<String, dynamic> map,
  ) {
    return Orden(
      id: map['id'],
      idUsuario: map['id_usuario'],
      nombreCliente:
          map['nombre_cliente'],
      fecha: DateTime.parse(
        map['fecha'],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// USUARIO
// ─────────────────────────────────────────────────────────────

class Usuario {
  int? id;

  String nombre;

  String usuario;

  String passwordHash;

  bool activo;

  RolUsuario? rol;

  Usuario({
    this.id,
    required this.nombre,
    required this.usuario,
    required this.passwordHash,
    this.activo = true,
    this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'password_hash':
          passwordHash,
      'activo': activo ? 1 : 0,
      'rol': rol?.toDb(),
    };
  }

  factory Usuario.fromMap(
    Map<String, dynamic> map,
  ) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      usuario: map['usuario'],
      passwordHash:
          map['password_hash'],
      activo: map['activo'] == 1,
      rol: map['rol'] != null
          ? (map['rol'] as String)
              .toRolUsuario()
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ESCUELA
// ─────────────────────────────────────────────────────────────

class Escuela {
  int? idEscuela;

  String nombre;

  Escuela({
    this.idEscuela,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_escuela': idEscuela,
      'nombre': nombre,
    };
  }

  factory Escuela.fromMap(
    Map<String, dynamic> map,
  ) {
    return Escuela(
      idEscuela:
          map['id_escuela'],
      nombre: map['nombre'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRENDA
// ─────────────────────────────────────────────────────────────

class Prenda {
  int? idPrenda;

  String nombre;

  Prenda({
    this.idPrenda,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_prenda': idPrenda,
      'nombre': nombre,
    };
  }

  factory Prenda.fromMap(
    Map<String, dynamic> map,
  ) {
    return Prenda(
      idPrenda:
          map['id_prenda'],
      nombre: map['nombre'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TALLA
// ─────────────────────────────────────────────────────────────

class Talla {
  int? idTalla;

  String talla;

  Talla({
    this.idTalla,
    required this.talla,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_talla': idTalla,
      'talla': talla,
    };
  }

  factory Talla.fromMap(
    Map<String, dynamic> map,
  ) {
    return Talla(
      idTalla:
          map['id_talla'],
      talla: map['talla'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INVENTARIO
// ─────────────────────────────────────────────────────────────

class Inventario {
  int? id;

  int idEscuela;

  int idPrenda;

  int idTalla;

  double precio;

  Inventario({
    this.id,
    required this.idEscuela,
    required this.idPrenda,
    required this.idTalla,
    required this.precio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_escuela': idEscuela,
      'id_prenda': idPrenda,
      'id_talla': idTalla,
      'precio': precio,
    };
  }

  factory Inventario.fromMap(
    Map<String, dynamic> map,
  ) {
    return Inventario(
      id: map['id'],
      idEscuela:
          map['id_escuela'],
      idPrenda:
          map['id_prenda'],
      idTalla:
          map['id_talla'],
      precio:
          (map['precio'] as num)
              .toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// UNIDAD
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
// UNIDAD
// ─────────────────────────────────────────────────────────────

class Unidad {

  int? id;

  int idInventario;

  bool activo;

  bool pendienteImpresion;

  Unidad({
    this.id,
    required this.idInventario,
    this.activo = true,
    this.pendienteImpresion =
        false,
  });

  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'id_inventario':
          idInventario,

      'activo':
          activo ? 1 : 0,

      'pendiente_impresion':
          pendienteImpresion
              ? 1
              : 0,
    };
  }

  factory Unidad.fromMap(
    Map<String, dynamic> map,
  ) {

    return Unidad(

      id: map['id'],

      idInventario:
          map['id_inventario'],

      activo:
          map['activo'] == 1,

      pendienteImpresion:
          map['pendiente_impresion'] ==
              1,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VENTA
// ─────────────────────────────────────────────────────────────

class Venta {
  int? id;

  int idUsuario;

  int? idOrdenOrigen;

  String? nombreCliente;

  DateTime fecha;

  double total;

  EstadoVenta estado;

  Venta({
    this.id,
    required this.idUsuario,
    this.idOrdenOrigen,
    this.nombreCliente,
    required this.fecha,
    required this.total,
    this.estado =
        EstadoVenta.completada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'id_orden_origen':
          idOrdenOrigen,
      'nombre_cliente':
          nombreCliente,
      'fecha':
          fecha.toIso8601String(),
      'total': total,
      'estado': estado.toDb(),
    };
  }

  factory Venta.fromMap(
    Map<String, dynamic> map,
  ) {
    return Venta(
      id: map['id'],
      idUsuario:
          map['id_usuario'],
      idOrdenOrigen:
          map['id_orden_origen'],
      nombreCliente:
          map['nombre_cliente'],
      fecha: DateTime.parse(
        map['fecha'],
      ),
      total:
          (map['total'] as num)
              .toDouble(),
      estado:
          (map['estado']
                  as String)
              .toEstadoVenta(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DETALLE VENTA
// ─────────────────────────────────────────────────────────────

class DetalleVenta {
  int? id;

  int idVenta;

  int idUnidad;

  int cantidad;

  double precioUnitario;

  DetalleVenta({
    this.id,
    required this.idVenta,
    required this.idUnidad,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venta': idVenta,
      'id_unidad': idUnidad,
      'cantidad': cantidad,
      'precio_unitario':
          precioUnitario,
    };
  }

  factory DetalleVenta.fromMap(
    Map<String, dynamic> map,
  ) {
    return DetalleVenta(
      id: map['id'],
      idVenta:
          map['id_venta'],
      idUnidad:
          map['id_unidad'],
      cantidad:
          map['cantidad'],
      precioUnitario:
          (map['precio_unitario']
                  as num)
              .toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PEDIDO
// ─────────────────────────────────────────────────────────────

class Pedido {
  int? id;

  int idUsuario;

  int idOrdenOrigen;

  int? idVentaOrigen;

  String? nombreCliente;

  DateTime fecha;

  double total;

  EstadoPedido estado;

  Pedido({
    this.id,
    required this.idUsuario,
    required this.idOrdenOrigen,
    this.idVentaOrigen,
    this.nombreCliente,
    required this.fecha,
    required this.total,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'id_orden_origen':
          idOrdenOrigen,
      'id_venta_origen':
          idVentaOrigen,
      'nombre_cliente':
          nombreCliente,
      'fecha':
          fecha.toIso8601String(),
      'total': total,
      'estado': estado.name,
    };
  }

  factory Pedido.fromMap(
    Map<String, dynamic> map,
  ) {
    return Pedido(
      id: map['id'],
      idUsuario:
          map['id_usuario'],
      idOrdenOrigen:
          map['id_orden_origen'],
      idVentaOrigen:
          map['id_venta_origen'],
      nombreCliente:
          map['nombre_cliente'],
      fecha: DateTime.parse(
        map['fecha'],
      ),
      total:
          (map['total'] as num)
              .toDouble(),
      estado:
          EstadoPedido.values
              .firstWhere(
        (e) =>
            e.name ==
            map['estado'],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DETALLE PEDIDO
// ─────────────────────────────────────────────────────────────

class DetallePedido {
  int? id;

  int idPedido;

  int idInventario;

  int? idUnidadRegistrada;

  bool registrado;

  double precioUnitario;

  DetallePedido({
    this.id,
    required this.idPedido,
    required this.idInventario,
    this.idUnidadRegistrada,
    this.registrado = false,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pedido': idPedido,
      'id_inventario':
          idInventario,
      'id_unidad_registrada':
          idUnidadRegistrada,
      'registrado':
          registrado ? 1 : 0,
      'precio_unitario':
          precioUnitario,
    };
  }

  factory DetallePedido.fromMap(
    Map<String, dynamic> map,
  ) {
    return DetallePedido(
      id: map['id'],
      idPedido:
          map['id_pedido'],
      idInventario:
          map['id_inventario'],
      idUnidadRegistrada:
          map[
              'id_unidad_registrada'],
      registrado:
          map['registrado'] == 1,
      precioUnitario:
          (map['precio_unitario']
                  as num)
              .toDouble(),
    );
  }
}