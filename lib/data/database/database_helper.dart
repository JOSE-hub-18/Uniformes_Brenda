import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  // solteroton (singleton)
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  DatabaseHelper._internal();

  // acceso
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Inic.
  Future<Database> _initDB() async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'uniformes.db');

    return await openDatabase(
      path,
      version: 1,

      // Para Foreign keys (FK) 
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,

      onUpgrade: (db, oldVersion, newVersion) async {
        
      },
    );
  }

  // Tableishons
  Future<void> _onCreate(Database db, int version) async {

    // Usuarios
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

    // Escuelas
    await db.execute('''
      CREATE TABLE escuelas (
        id_escuela INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Prendas
    await db.execute('''
      CREATE TABLE prendas (
        id_prenda INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Tallas
    await db.execute('''
      CREATE TABLE tallas (
        id_talla INTEGER PRIMARY KEY AUTOINCREMENT,
        talla TEXT NOT NULL UNIQUE
      )
    ''');

    // Inventario
    await db.execute('''
      CREATE TABLE inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_escuela INTEGER NOT NULL,
        id_prenda INTEGER NOT NULL,
        id_talla INTEGER NOT NULL,
        precio REAL NOT NULL,
        FOREIGN KEY (id_escuela) REFERENCES escuelas(id_escuela),
        FOREIGN KEY (id_prenda) REFERENCES prendas(id_prenda),
        FOREIGN KEY (id_talla) REFERENCES tallas(id_talla),
        UNIQUE (id_escuela, id_prenda, id_talla)
      )
    ''');

    // Unidades
    await db.execute('''
      CREATE TABLE unidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_inventario INTEGER NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_inventario) REFERENCES inventario(id)
      )
    ''');

    // Ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        nombre_cliente TEXT,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'completada',
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
      )
    ''');

    // Detalle de ventas
    await db.execute('''
      CREATE TABLE detalle_venta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_venta INTEGER NOT NULL,
        id_unidad INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        FOREIGN KEY (id_venta) REFERENCES ventas(id),
        FOREIGN KEY (id_unidad) REFERENCES unidades(id)
      )
    ''');

    // Usuario inicial
    const password = '1234';
    const salt = 'uniformes_brenda_salt';
    final bytes = utf8.encode(password + salt);
    final passwordHash = sha256.convert(bytes).toString();

    await db.rawInsert('''
      INSERT INTO usuarios (nombre, usuario, password_hash, activo, rol)
      VALUES (?, ?, ?, ?, ?)
    ''', ['Administrador Principal', 'admin', passwordHash, 1, 'admin']);

    // Prendas fijas
    final prendas = [
      'Jumper',
      'Playera Polo',
      'Playera Deportiva',
      'Chamarra',
      'Falda',
      'Pantalón',
      'Pantalonera'
    ];

    for (final p in prendas) {
      await db.insert('prendas', {'nombre': p});
    }

    //  Tallas fijas
    final tallas = [
      '4','6','8','10','12','14','16',
      'CH','M','G'
    ];

    for (final t in tallas) {
      await db.insert('tallas', {'talla': t});
    }
  }
}