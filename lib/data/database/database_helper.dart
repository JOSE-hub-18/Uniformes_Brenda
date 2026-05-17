// database_helper.dart

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper que gestiona el ciclo de vida de la base de datos SQLite local.
/// Implementa el patrón Singleton para garantizar una única instancia
/// de la base de datos durante toda la ejecución de la aplicación.
class DatabaseHelper {

  /// Instancia única del helper accesible globalmente.
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  /// Referencia a la base de datos abierta. Null hasta la primera inicialización.
  static Database? _database;

  DatabaseHelper._internal();

  /// Retorna la instancia de la base de datos, inicializándola si aún no existe.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();

    return _database!;
  }

  /// Obtiene la ruta del sistema de archivos y abre la base de datos.
  /// Habilita las llaves foráneas mediante PRAGMA en la configuración inicial.
  /// El manejador de actualizaciones está definido pero vacío,
  /// pendiente de implementación para futuras migraciones de esquema.
  Future<Database> _initDB() async {

    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      'uniformes.db',
    );

    return await openDatabase(
      path,

      version: 1,

      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },

      onCreate: _onCreate,

      onUpgrade:
          (db, oldVersion,
              newVersion) async {},
    );
  }

  /// Crea el esquema completo de la base de datos en la primera ejecución.
  /// Define todas las tablas, restricciones de llaves foráneas y unicidad,
  /// e inserta los datos iniciales requeridos para el funcionamiento del sistema.
  Future<void> _onCreate(
    Database db,
    int version,
  ) async {

    /// Tabla de usuarios del sistema. El campo [usuario] es único
    /// y [password_hash] almacena el hash SHA-256 con salt de la contraseña.
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        nombre TEXT NOT NULL,

        usuario TEXT NOT NULL UNIQUE,

        password_hash TEXT NOT NULL,

        activo INTEGER NOT NULL DEFAULT 1,

        rol TEXT
      )
    ''');

    /// Tabla de escuelas a las que se asocian los registros de inventario.
    await db.execute('''
      CREATE TABLE escuelas (
        id_escuela INTEGER PRIMARY KEY AUTOINCREMENT,

        nombre TEXT NOT NULL
      )
    ''');

    /// Catálogo de tipos de prenda disponibles en el sistema.
    await db.execute('''
      CREATE TABLE prendas (
        id_prenda INTEGER PRIMARY KEY AUTOINCREMENT,

        nombre TEXT NOT NULL
      )
    ''');

    /// Catálogo de tallas disponibles. El campo [talla] es único
    /// para evitar duplicados en el catálogo.
    await db.execute('''
      CREATE TABLE tallas (
        id_talla INTEGER PRIMARY KEY AUTOINCREMENT,

        talla TEXT NOT NULL UNIQUE
      )
    ''');

    /// Tabla de inventario que representa cada combinación única de
    /// escuela, prenda y talla con su precio asignado.
    /// La restricción UNIQUE sobre (id_escuela, id_prenda, id_talla)
    /// garantiza que no existan registros duplicados por combinación.
    await db.execute('''
      CREATE TABLE inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_escuela INTEGER NOT NULL,

        id_prenda INTEGER NOT NULL,

        id_talla INTEGER NOT NULL,

        precio REAL NOT NULL,

        FOREIGN KEY (id_escuela)
          REFERENCES escuelas(id_escuela),

        FOREIGN KEY (id_prenda)
          REFERENCES prendas(id_prenda),

        FOREIGN KEY (id_talla)
          REFERENCES tallas(id_talla),

        UNIQUE (
          id_escuela,
          id_prenda,
          id_talla
        )
      )
    ''');

    /// Tabla de unidades físicas asociadas a un registro de inventario.
    /// Cada unidad representa una prenda física identificable por QR.
    /// [activo] indica si la unidad está disponible (1) o fue vendida/dada de baja (0).
    /// [pendiente_impresion] indica si la etiqueta QR aún no ha sido impresa.
    await db.execute('''
  CREATE TABLE unidades (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    id_inventario INTEGER NOT NULL,

    activo INTEGER NOT NULL DEFAULT 1,

    pendiente_impresion INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (id_inventario)
      REFERENCES inventario(id)
  )
''');

    /// Tabla de órdenes que agrupa ventas y pedidos generados en una misma transacción.
    /// Permite vincular una venta directa con su pedido asociado dentro de una orden mixta.
    await db.execute('''
      CREATE TABLE ordenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_usuario INTEGER NOT NULL,

        nombre_cliente TEXT,

        fecha TEXT NOT NULL,

        FOREIGN KEY (id_usuario)
          REFERENCES usuarios(id)
      )
    ''');

    /// Tabla de ventas completadas. Puede estar vinculada a una orden de origen
    /// cuando proviene de una transacción mixta con pedido.
    /// [estado] por defecto es 'completada' al momento de la inserción.
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_usuario INTEGER NOT NULL,

        id_orden_origen INTEGER,

        nombre_cliente TEXT,

        fecha TEXT NOT NULL,

        total REAL NOT NULL,

        estado TEXT NOT NULL
          DEFAULT 'completada',

        FOREIGN KEY (id_usuario)
          REFERENCES usuarios(id),

        FOREIGN KEY (id_orden_origen)
          REFERENCES ordenes(id)
      )
    ''');

    /// Tabla de detalle de venta. Cada registro representa una unidad física
    /// incluida en la venta con su precio al momento de la transacción.
    await db.execute('''
      CREATE TABLE detalle_venta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_venta INTEGER NOT NULL,

        id_unidad INTEGER NOT NULL,

        cantidad INTEGER NOT NULL,

        precio_unitario REAL NOT NULL,

        FOREIGN KEY (id_venta)
          REFERENCES ventas(id),

        FOREIGN KEY (id_unidad)
          REFERENCES unidades(id)
      )
    ''');

    /// Tabla de pedidos pendientes de entrega. Puede vincularse a una venta de origen
    /// cuando se generó como parte de una orden mixta.
    /// [estado] refleja el ciclo de vida del pedido (pendiente/completado).
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_usuario INTEGER NOT NULL,

        id_orden_origen INTEGER NOT NULL,

        id_venta_origen INTEGER,

        nombre_cliente TEXT,

        fecha TEXT NOT NULL,

        total REAL NOT NULL,

        estado TEXT NOT NULL,

        FOREIGN KEY (id_usuario)
          REFERENCES usuarios(id),

        FOREIGN KEY (id_orden_origen)
          REFERENCES ordenes(id),

        FOREIGN KEY (id_venta_origen)
          REFERENCES ventas(id)
      )
    ''');

    /// Tabla de detalle de pedido. Cada registro representa una prenda encargada
    /// identificada por su inventario. [id_unidad_registrada] se asigna al momento
    /// de la entrega y [registrado] cambia a 1 cuando la unidad física es confirmada.
    await db.execute('''
      CREATE TABLE detalle_pedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        id_pedido INTEGER NOT NULL,

        id_inventario INTEGER NOT NULL,

        id_unidad_registrada INTEGER,

        registrado INTEGER NOT NULL DEFAULT 0,

        precio_unitario REAL NOT NULL,

        FOREIGN KEY (id_pedido)
          REFERENCES pedidos(id),

        FOREIGN KEY (id_inventario)
          REFERENCES inventario(id),

        FOREIGN KEY (id_unidad_registrada)
          REFERENCES unidades(id)
      )
    ''');

    /// Inserción del usuario administrador inicial del sistema.
    /// La contraseña se hashea con SHA-256 usando el mismo salt
    /// definido en [LoginUseCase] para mantener consistencia.
    const password = '1234';

    const salt =
        'uniformes_brenda_salt';

    final bytes = utf8.encode(
      password + salt,
    );

    final passwordHash =
        sha256
            .convert(bytes)
            .toString();

    await db.rawInsert('''
      INSERT INTO usuarios (
        nombre,
        usuario,
        password_hash,
        activo,
        rol
      )
      VALUES (?, ?, ?, ?, ?)
    ''', [
      'Administrador Principal',
      'admin',
      passwordHash,
      1,
      'admin',
    ]);

    /// Catálogo inicial de prendas disponibles en el sistema.
    /// Estos valores son fijos y se insertan una única vez al crear la base de datos.
    final prendas = [
      'Jumper',
      'Playera Polo',
      'Playera Deportiva',
      'Chamarra',
      'Falda',
      'Pantalón',
      'Pantalonera',
    ];

    for (final p in prendas) {
      await db.insert(
        'prendas',
        {
          'nombre': p,
        },
      );
    }

    /// Catálogo inicial de tallas disponibles en el sistema.
    /// Incluye tallas numéricas de niño y tallas estándar de adulto.
    final tallas = [
      '4',
      '6',
      '8',
      '10',
      '12',
      '14',
      '16',
      'CH',
      'M',
      'G',
    ];

    for (final t in tallas) {
      await db.insert(
        'tallas',
        {
          'talla': t,
        },
      );
    }
  }
}