// lib/business/services/backup_service.dart

import 'dart:io';

import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_repository.dart';

class BackupInfo {

  final String ruta;

  final String nombre;

  final DateTime fechaCreacion;

  final int tamanoBytes;

  const BackupInfo({

    required this.ruta,

    required this.nombre,

    required this.fechaCreacion,

    required this.tamanoBytes,
  });

  String get tamanoLegible {

    if (tamanoBytes < 1024) {
      return '$tamanoBytes B';
    }

    if (tamanoBytes <
        1024 * 1024) {

      return
          '${(tamanoBytes / 1024).toStringAsFixed(1)} KB';
    }

    return
        '${(tamanoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BackupResult {

  final bool exitoso;

  final String mensaje;

  final BackupInfo? backup;

  const BackupResult({

    required this.exitoso,

    required this.mensaje,

    this.backup,
  });
}

class BackupService {

  final BackupRepository
      _backupRepository;

  static const int
      _maxBackups = 5;

  BackupService({

    required BackupRepository
        backupRepository,
  }) : _backupRepository =
            backupRepository;

  // Crear backup

  Future<BackupResult>
      crearBackup() async {

    try {

      final ruta =
          await _backupRepository
              .crearBackup();

      final archivo =
          File(ruta);

      final info =
          BackupInfo(

        ruta: ruta,

        nombre:
            basename(ruta),

        fechaCreacion:
            await archivo
                .lastModified(),

        tamanoBytes:
            await archivo
                .length(),
      );

      await _limpiarBackupsAntiguos();

      return BackupResult(

        exitoso: true,

        mensaje:
            'Backup creado correctamente.',

        backup: info,
      );

    } catch (e) {

      return BackupResult(

        exitoso: false,

        mensaje:
            'Error al crear backup: $e',
      );
    }
  }

  // Crear y compartir backup

  Future<BackupResult>
      crearYCompartirBackup()
      async {

    final resultado =
        await crearBackup();

    if (!resultado.exitoso ||
        resultado.backup ==
            null) {

      return resultado;
    }

    try {

      await Share.shareXFiles(

        [
          XFile(
            resultado
                .backup!
                .ruta,
          ),
        ],

        subject:
            'Backup Uniformes Brenda',

        text:
            'Respaldo generado correctamente.',
      );

      return BackupResult(

        exitoso: true,

        mensaje:
            'Backup listo para compartir.',

        backup:
            resultado.backup,
      );

    } catch (e) {

      return BackupResult(

        exitoso: false,

        mensaje:
            'Backup creado pero no se pudo compartir: $e',

        backup:
            resultado.backup,
      );
    }
  }

  // Listar backups

  Future<List<BackupInfo>>
      listarBackups() async {

    try {

      final directorio =
          await _directorioBackups();

      if (!await directorio
          .exists()) {

        return [];
      }

      final archivos =
          directorio
              .listSync()

              .whereType<File>()

              .where(
                (f) {

                  return basename(
                    f.path,
                  ).startsWith(
                        'backup_uniformes_',
                      ) &&
                      f.path.endsWith(
                        '.db',
                      );
                },
              )

              .toList();

      final backups =
          <BackupInfo>[];

      for (final archivo
          in archivos) {

        backups.add(

          BackupInfo(

            ruta:
                archivo.path,

            nombre:
                basename(
              archivo.path,
            ),

            fechaCreacion:
                await archivo
                    .lastModified(),

            tamanoBytes:
                await archivo
                    .length(),
          ),
        );
      }

      backups.sort(
        (a, b) {

          return b
              .fechaCreacion
              .compareTo(
            a.fechaCreacion,
          );
        },
      );

      return backups;

    } catch (_) {

      return [];
    }
  }

  // Compartir backup existente

  Future<BackupResult>
      compartirBackup(
    BackupInfo backup,
  ) async {

    try {

      final archivo =
          File(backup.ruta);

      if (!await archivo
          .exists()) {

        return const BackupResult(

          exitoso: false,

          mensaje:
              'El backup no existe.',
        );
      }

      await Share.shareXFiles(

        [
          XFile(
            backup.ruta,
          ),
        ],

        subject:
            'Backup Uniformes Brenda',

        text:
            'Respaldo: ${backup.nombre}',
      );

      return BackupResult(

        exitoso: true,

        mensaje:
            'Backup compartido.',

        backup: backup,
      );

    } catch (e) {

      return BackupResult(

        exitoso: false,

        mensaje:
            'Error al compartir: $e',
      );
    }
  }

  // Eliminar backup

  Future<BackupResult>
      eliminarBackup(
    BackupInfo backup,
  ) async {

    try {

      final archivo =
          File(backup.ruta);

      if (await archivo
          .exists()) {

        await archivo
            .delete();
      }

      return BackupResult(

        exitoso: true,

        mensaje:
            'Backup eliminado.',

        backup: backup,
      );

    } catch (e) {

      return BackupResult(

        exitoso: false,

        mensaje:
            'Error al eliminar: $e',
      );
    }
  }

  // Helpers privados

  Future<void>
      _limpiarBackupsAntiguos()
      async {

    final backups =
        await listarBackups();

    if (backups.length <=
        _maxBackups) {

      return;
    }

    final aEliminar =
        backups.sublist(
      _maxBackups,
    );

    for (final backup
        in aEliminar) {

      await eliminarBackup(
        backup,
      );
    }
  }

  Future<Directory>
      _directorioBackups()
      async {

    final base =
        await getApplicationDocumentsDirectory();

    final dir = Directory(

      join(
        base.path,
        'backups',
      ),
    );

    if (!await dir.exists()) {

      await dir.create(
        recursive: true,
      );
    }

    return dir;
  }
}