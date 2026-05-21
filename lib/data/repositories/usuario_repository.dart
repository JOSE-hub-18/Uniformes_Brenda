import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio encargado de gestionar las operaciones
/// CRUD relacionadas con usuarios del sistema.
///
/// Incluye consultas de autenticación lógica,
/// administración de estados y mantenimiento de registros.
class UsuarioRepository {
  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta un nuevo usuario en la base de datos.
  ///
  /// El identificador primario es removido del mapa
  /// antes de la inserción para permitir autoincremento.
  ///
  /// La operación utiliza conflicto tipo abort
  /// para evitar registros inválidos o duplicados.
  Future<int> insertar(Usuario usuario) async {
    final db = await _db;

    return await db.insert(
      'usuarios',
      usuario.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Obtiene un usuario mediante su identificador.
  ///
  /// Retorna null cuando no existe un registro asociado.
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

  /// Obtiene un usuario utilizando el nombre de usuario.
  ///
  /// Esta operación puede ser utilizada para procesos
  /// de autenticación o validación de existencia.
  ///
  /// Retorna null cuando no existe coincidencia.
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

  /// Obtiene todos los usuarios registrados
  /// ordenados alfabéticamente por nombre.
  Future<List<Usuario>> obtenerTodos() async {
    final db = await _db;

    final maps = await db.query('usuarios', orderBy: 'nombre ASC');

    return maps.map((m) => Usuario.fromMap(m)).toList();
  }

  /// Obtiene únicamente los usuarios activos.
  ///
  /// Los registros desactivados son excluidos
  /// del resultado.
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

  /// Actualiza la información de un usuario existente.
  ///
  /// La operación utiliza el identificador primario
  /// como criterio de actualización.
  Future<int> actualizar(Usuario usuario) async {
    final db = await _db;

    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  /// Desactiva un usuario de manera lógica.
  ///
  /// La operación conserva el registro en la base de datos
  /// pero impide que sea considerado activo.
  Future<int> desactivar(int id) async {
    final db = await _db;

    return await db.update(
      'usuarios',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina un usuario mediante su identificador.
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}
