// lib/data/repositories/backup_repository.dart

import 'dart:io';

import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

/// Repositorio encargado de gestionar la creación física de archivos de backup
/// de la base de datos SQLite en el almacenamiento local del dispositivo.
class BackupRepository {
  /// Genera una copia del archivo de base de datos activo en el directorio de backups.
  /// El nombre del archivo incluye la fecha y hora de creación con formato
  /// 'backup_uniformes_YYYY_MM_DD_HH_mm.db' para facilitar su identificación.
  /// Retorna la ruta absoluta del archivo de backup generado.
  Future<String> crearBackup() async {
    final db = await DatabaseHelper.instance.database;

    final dbPath = db.path;

    final backupDir = await _obtenerDirectorioBackups();

    final now = DateTime.now();

    final nombreBackup =
        'backup_uniformes_'
        '${now.year}_'
        '${now.month.toString().padLeft(2, '0')}_'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}_'
        '${now.minute.toString().padLeft(2, '0')}.db';

    final backupPath = join(backupDir.path, nombreBackup);

    await File(dbPath).copy(backupPath);

    return backupPath;
  }

  /// Retorna el directorio donde se almacenan los backups dentro del
  /// directorio de documentos de la aplicación.
  /// Si el directorio no existe, lo crea de forma recursiva.
  Future<Directory> _obtenerDirectorioBackups() async {
    final documentos = await getApplicationDocumentsDirectory();

    final backupDir = Directory(join(documentos.path, 'backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }
}
