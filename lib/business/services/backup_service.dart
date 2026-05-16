// lib/business/services/backup_service.dart

import 'dart:io';

import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_repository.dart';

/// Modelo que representa la información de un archivo de backup generado.
class BackupInfo {

  /// Ruta absoluta del archivo de backup en el sistema de archivos.
  final String ruta;

  /// Nombre del archivo de backup.
  final String nombre;

  /// Fecha y hora en que fue creado el archivo de backup.
  final DateTime fechaCreacion;

  /// Tamaño del archivo de backup en bytes.
  final int tamanoBytes;

  const BackupInfo({

    required this.ruta,

    required this.nombre,

    required this.fechaCreacion,

    required this.tamanoBytes,
  });

  /// Retorna el tamaño del archivo en formato legible (B, KB o MB)
  /// según el rango en que se encuentre el valor en bytes.
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

/// Modelo que representa el resultado de una operación de backup.
/// Indica si la operación fue exitosa, un mensaje descriptivo
/// y, opcionalmente, la información del backup generado.
class BackupResult {

  /// Indica si la operación de backup se completó sin errores.
  final bool exitoso;

  /// Mensaje descriptivo del resultado de la operación.
  final String mensaje;

  /// Información del backup generado. Null si la operación falló.
  final BackupInfo? backup;

  const BackupResult({

    required this.exitoso,

    required this.mensaje,

    this.backup,
  });
}

/// Servicio que gestiona las operaciones de backup de la base de datos.
/// Permite crear, listar, compartir y eliminar backups,
/// además de mantener un límite máximo de archivos almacenados.
class BackupService {

  /// Repositorio que ejecuta la creación física del archivo de backup.
  final BackupRepository
      _backupRepository;

  /// Número máximo de backups que se conservan en el directorio.
  /// Los backups más antiguos se eliminan automáticamente al superar este límite.
  static const int
      _maxBackups = 5;

  BackupService({

    required BackupRepository
        backupRepository,
  }) : _backupRepository =
            backupRepository;

  /// Crea un nuevo archivo de backup de la base de datos.
  /// Una vez creado, ejecuta la limpieza de backups antiguos
  /// para mantener el límite definido por [_maxBackups].
  /// Retorna un [BackupResult] con el resultado de la operación.
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

  /// Crea un nuevo backup y lo comparte inmediatamente a través del sistema
  /// de compartición nativo del dispositivo.
  /// Si la creación falla, retorna el resultado sin intentar compartir.
  /// Si el backup se crea pero no se puede compartir, retorna el error
  /// manteniendo la referencia al backup generado.
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

  /// Obtiene la lista de backups disponibles en el directorio de backups,
  /// ordenados de más reciente a más antiguo.
  /// Filtra únicamente archivos con el prefijo 'backup_uniformes_' y extensión '.db'.
  /// Retorna una lista vacía si el directorio no existe o si ocurre un error.
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

      /// Los backups se ordenan descendentemente por fecha de creación
      /// para que el más reciente aparezca primero en la lista.
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

  /// Comparte un archivo de backup existente mediante el sistema nativo del dispositivo.
  /// Verifica que el archivo exista en el sistema de archivos antes de intentar compartirlo.
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

  /// Elimina el archivo de backup del sistema de archivos.
  /// Si el archivo no existe, la operación se considera exitosa
  /// para mantener consistencia con el estado esperado.
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

  /// Elimina los backups más antiguos cuando se supera el límite de [_maxBackups].
  /// La lista ya viene ordenada de más reciente a más antiguo,
  /// por lo que se eliminan los elementos al final de la lista.
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

  /// Retorna el directorio donde se almacenan los backups.
  /// Si el directorio no existe, lo crea de forma recursiva.
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