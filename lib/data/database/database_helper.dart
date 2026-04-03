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

  // dat03
  Future<void> _onCreate(Database db, int version) async {
    
  }
}