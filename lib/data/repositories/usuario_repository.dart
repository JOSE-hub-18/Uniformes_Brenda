import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

class UsuarioRepository {

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // CREATE
  Future<int> insertar(Usuario usuario) async {
    final db = await _db;
    return await db.insert(
      'usuarios',
      usuario.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ
  Future<Usuario?> obtenerPorId(int id) async {
    final db = await _db;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Usuario.fromMap(maps.first);
  }

  Future<Usuario?> obtenerPorUsuario(String usuario) async {
    final db = await _db;
    final maps = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Usuario.fromMap(maps.first);
  }

  Future<List<Usuario>> obtenerTodos() async {
    final db = await _db;
    final maps = await db.query('usuarios', orderBy: 'nombre ASC');
    return maps.map((m) => Usuario.fromMap(m)).toList();
  }

  Future<List<Usuario>> obtenerActivos() async {
    final db = await _db;
    final maps = await db.query(
      'usuarios',
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return maps.map((m) => Usuario.fromMap(m)).toList();
  }

  // UPDATE
  Future<int> actualizar(Usuario usuario) async {
    final db = await _db;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Desactivar 
  Future<int> desactivar(int id) async {
    final db = await _db;
    return await db.update(
      'usuarios',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}