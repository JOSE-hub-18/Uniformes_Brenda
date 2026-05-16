// lib/data/repositories/backup_repository.dart

import 'dart:io';

import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

class BackupRepository {

  // Crear copia de la base de datos

  Future<String>
      crearBackup() async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    final dbPath =
        db.path;

    final backupDir =
        await _obtenerDirectorioBackups();

    final now =
        DateTime.now();

    final nombreBackup =

        'backup_uniformes_'

        '${now.year}_'

        '${now.month.toString().padLeft(2, '0')}_'

        '${now.day.toString().padLeft(2, '0')}_'

        '${now.hour.toString().padLeft(2, '0')}_'

        '${now.minute.toString().padLeft(2, '0')}.db';

    final backupPath =
        join(
      backupDir.path,
      nombreBackup,
    );

    await File(dbPath).copy(
      backupPath,
    );

    return backupPath;
  }

  // Obtener directorio backups

  Future<Directory>
      _obtenerDirectorioBackups()
      async {

    final documentos =
        await getApplicationDocumentsDirectory();

    final backupDir =
        Directory(

      join(
        documentos.path,
        'backups',
      ),
    );

    if (!await backupDir
        .exists()) {

      await backupDir.create(
        recursive: true,
      );
    }

    return backupDir;
  }
}