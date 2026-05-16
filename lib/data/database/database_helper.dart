// database_helper.dart

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  // Singleton
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  // ─────────────────────────────────────────────────────────
  // ACCESS
  // ─────────────────────────────────────────────────────────

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();

    return _database!;
  }

  // ─────────────────────────────────────────────────────────
  // INIT DB
  // ─────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────
  // CREATE TABLES
  // ─────────────────────────────────────────────────────────

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {

    // ───────────────────────────────────────────────────────
    // USUARIOS
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // ESCUELAS
    // ───────────────────────────────────────────────────────

    await db.execute('''
      CREATE TABLE escuelas (
        id_escuela INTEGER PRIMARY KEY AUTOINCREMENT,

        nombre TEXT NOT NULL
      )
    ''');

    // ───────────────────────────────────────────────────────
    // PRENDAS
    // ───────────────────────────────────────────────────────

    await db.execute('''
      CREATE TABLE prendas (
        id_prenda INTEGER PRIMARY KEY AUTOINCREMENT,

        nombre TEXT NOT NULL
      )
    ''');

    // ───────────────────────────────────────────────────────
    // TALLAS
    // ───────────────────────────────────────────────────────

    await db.execute('''
      CREATE TABLE tallas (
        id_talla INTEGER PRIMARY KEY AUTOINCREMENT,

        talla TEXT NOT NULL UNIQUE
      )
    ''');

    // ───────────────────────────────────────────────────────
    // INVENTARIO
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // UNIDADES
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // ORDENES
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // VENTAS
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // DETALLE VENTA
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // PEDIDOS
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // DETALLE PEDIDO
    // ───────────────────────────────────────────────────────

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

    // ───────────────────────────────────────────────────────
    // USUARIO ADMIN
    // ───────────────────────────────────────────────────────

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

    
    // PRENDAS FIJAS
    

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

    
    // TALLAS FIJAS
    // 

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