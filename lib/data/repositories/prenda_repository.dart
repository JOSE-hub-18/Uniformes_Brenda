import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/models.dart';

/// Repositorio encargado de gestionar las operaciones
/// CRUD relacionadas con la entidad Prenda.
class PrendaRepository {
  /// Obtiene una instancia activa de la base de datos.
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Inserta una nueva prenda en la base de datos.
  ///
  /// El identificador primario es eliminado del mapa
  /// antes de la inserción para permitir el autoincremento.
  ///
  /// La operación utiliza conflicto tipo abort
  /// para evitar inserciones duplicadas o inválidas.
  Future<int> insertar(Prenda prenda) async {
    final db = await _db;
    return await db.insert(
      'prendas',
      prenda.toMap()..remove('id_prenda'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Obtiene una prenda mediante su identificador.
  ///
  /// Retorna null cuando no existe un registro asociado.
  Future<Prenda?> obtenerPorId(int id) async {
    final db = await _db;
    final maps = await db.query(
      'prendas',
      where: 'id_prenda = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Prenda.fromMap(maps.first);
  }

  /// Obtiene todas las prendas registradas
  /// ordenadas alfabéticamente por nombre.
  Future<List<Prenda>> obtenerTodas() async {
    final db = await _db;

    final maps = await db.query('prendas', orderBy: 'nombre ASC');

    return maps.map((m) => Prenda.fromMap(m)).toList();
  }

  /// Actualiza la información de una prenda existente.
  ///
  /// La actualización se realiza utilizando
  /// el identificador primario de la entidad.
  Future<int> actualizar(Prenda prenda) async {
    final db = await _db;

    return await db.update(
      'prendas',
      prenda.toMap(),
      where: 'id_prenda = ?',
      whereArgs: [prenda.idPrenda],
    );
  }

  /// Elimina una prenda mediante su identificador.
  Future<int> eliminar(int id) async {
    final db = await _db;

    return await db.delete('prendas', where: 'id_prenda = ?', whereArgs: [id]);
  }
}
