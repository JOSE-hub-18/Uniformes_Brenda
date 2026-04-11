// lib/data/repositories/backup_repository.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class BackupRepository {

  // Crea una copia del archivo de la base de datos
  Future<String> crearBackup() async {
    final db = await DatabaseHelper.instance.database;

    final dbPath = db.path;

    final folder = await getDatabasesPath();

    final backupPath = join(
      folder,
      'backup_uniformes_${DateTime.now().millisecondsSinceEpoch}.db',
    );

    await File(dbPath).copy(backupPath);

    return backupPath;
  }

  // Restaura la base de datos desde un backup existente
  Future<void> restaurarBackup(String backupPath) async {
    final db = await DatabaseHelper.instance.database;

    final dbPath = db.path;

    // Cierra la base antes de reemplazarla
    await db.close();

    final backupFile = File(backupPath);

    if (!await backupFile.exists()) {
      throw Exception('El archivo de respaldo no existe');
    }

    await backupFile.copy(dbPath);
  }
}