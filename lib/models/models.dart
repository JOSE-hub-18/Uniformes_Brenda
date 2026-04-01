// ENUMS
// IMPORTANTE: TOMAP Y FORMMAP SOLO LO USA DATOS, CERO VALERO PARA USTEDES
// NEGOCIO USA LOS ENUMS Y LOS MISMOS MODELOS
// ui SOLO PROPIEDADES
enum RolUsuario { admin, vendedor }

enum EstadoVenta { completada, cancelada }

enum TipoMovimiento { entrada, salida }

// Extension enums

extension RolUsuarioExt on RolUsuario {
  String toDb() => name;
}

extension RolUsuarioParse on String {
  RolUsuario? toRolUsuario() {
    try {
      return RolUsuario.values.firstWhere((e) => e.name == this);
    } catch (_) {
      return null;
    }
  }
}

extension EstadoVentaExt on EstadoVenta {
  String toDb() => name;
}

extension EstadoVentaParse on String {
  EstadoVenta toEstadoVenta() =>
      EstadoVenta.values.firstWhere(
        (e) => e.name == this,
        orElse: () => EstadoVenta.completada,
      );
}

extension TipoMovimientoExt on TipoMovimiento {
  String toDb() => name;
}

extension TipoMovimientoParse on String {
  TipoMovimiento toTipoMovimiento() =>
      TipoMovimiento.values.firstWhere(
        (e) => e.name == this,
        orElse: () => TipoMovimiento.entrada,
      );
}

// Usuario

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
      'password_hash': passwordHash,
      'activo': activo ? 1 : 0,
      'rol': rol?.toDb(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      usuario: map['usuario'],
      passwordHash: map['password_hash'],
      activo: map['activo'] == 1,
      rol: map['rol'] != null ? (map['rol'] as String).toRolUsuario() : null,
    );
  }
}

// escuela

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

  factory Escuela.fromMap(Map<String, dynamic> map) {
    return Escuela(
      idEscuela: map['id_escuela'],
      nombre: map['nombre'],
    );
  }
}

// ropita

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

  factory Prenda.fromMap(Map<String, dynamic> map) {
    return Prenda(
      idPrenda: map['id_prenda'],
      nombre: map['nombre'],
    );
  }
}

// talla

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

  factory Talla.fromMap(Map<String, dynamic> map) {
    return Talla(
      idTalla: map['id_talla'],
      talla: map['talla'],
    );
  }
}

// inventario

class Inventario {
  int? id;
  int idEscuela;
  int idPrenda;
  int idTalla;
  int stock;
  double precio;

  Inventario({
    this.id,
    required this.idEscuela,
    required this.idPrenda,
    required this.idTalla,
    required this.stock,
    required this.precio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_escuela': idEscuela,
      'id_prenda': idPrenda,
      'id_talla': idTalla,
      'stock': stock,
      'precio': precio,
    };
  }

  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
      id: map['id'],
      idEscuela: map['id_escuela'],
      idPrenda: map['id_prenda'],
      idTalla: map['id_talla'],
      stock: map['stock'],
      precio: (map['precio'] as num).toDouble(),
    );
  }
}

// venta

class Venta {
  int? id;
  int idUsuario;
  DateTime fecha;
  double total;
  EstadoVenta estado;

  Venta({
    this.id,
    required this.idUsuario,
    required this.fecha,
    required this.total,
    this.estado = EstadoVenta.completada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'estado': estado.toDb(),
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      idUsuario: map['id_usuario'],
      fecha: DateTime.parse(map['fecha']),
      total: (map['total'] as num).toDouble(),
      estado: (map['estado'] as String).toEstadoVenta(),
    );
  }
}

// detalle venta

class DetalleVenta {
  int? id;
  int idVenta;
  int idInventario;
  int cantidad;
  double precioUnitario;

  DetalleVenta({
    this.id,
    required this.idVenta,
    required this.idInventario,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venta': idVenta,
      'id_inventario': idInventario,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }

  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      id: map['id'],
      idVenta: map['id_venta'],
      idInventario: map['id_inventario'],
      cantidad: map['cantidad'],
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
    );
  }
}

// movimeinto

class Movimiento {
  int? id;
  int idInventario;
  int? idVenta;
  TipoMovimiento tipo;
  int cantidad;
  String? motivo;
  DateTime fecha;

  Movimiento({
    this.id,
    required this.idInventario,
    this.idVenta,
    required this.tipo,
    required this.cantidad,
    this.motivo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_inventario': idInventario,
      'id_venta': idVenta,
      'tipo': tipo.toDb(),
      'cantidad': cantidad,
      'motivo': motivo,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'],
      idInventario: map['id_inventario'],
      idVenta: map['id_venta'],
      tipo: (map['tipo'] as String).toTipoMovimiento(),
      cantidad: map['cantidad'],
      motivo: map['motivo'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}