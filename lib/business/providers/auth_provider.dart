// lib/business/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../../data/repositories/usuario_repository.dart';
import '../usecases/login_usecase.dart';
import '../../models/models.dart';

/// Proveedor de estado para la autenticación de usuarios.
class AuthProvider extends ChangeNotifier {
  /// Repositorio encargado de obtener los datos de usuarios.
  final _usuarioRepo = UsuarioRepository();

  /// Caso de uso que ejecuta la lógica de autenticación.
  final _loginUseCase = LoginUseCase();

  /// Indica si hay una operación asíncrona en curso.
  bool _cargando = false;

  /// Mensaje de error producido durante el último intento de autenticación. Null si no hay error.
  String? _error;

  /// Usuario autenticado actualmente. Null si no hay sesión activa.
  Usuario? _usuarioActual;

  /// Getters
  bool get cargando => _cargando;
  String? get error => _error;
  Usuario? get usuarioActual => _usuarioActual;

  /// Retorna true si existe un usuario autenticado en sesión.
  bool get estaAutenticado => _usuarioActual != null;

  /// Ejecuta el flujo de autenticación con las credenciales proporcionadas.
  /// Obtiene la lista de usuarios desde el repositorio y delega la validación
  /// al caso de uso [LoginUseCase].
  /// Retorna true si las credenciales son válidas, false en caso contrario.
  /// En caso de error durante la operación, se establece un mensaje genérico
  /// para evitar exponer detalles internos del sistema.
  Future<bool> login(String usuario, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final usuarios = await _usuarioRepo.obtenerTodos();

      final user = await _loginUseCase.execute(usuarios, usuario, password);

      if (user != null) {
        _usuarioActual = user;
        _error = null;
        _cargando = false;
        notifyListeners();
        return true;
      }

      /// Regla de negocio: no se distingue entre usuario inexistente
      /// y contraseña incorrecta para evitar enumeración de usuarios.
      _error = 'Usuario o contraseña incorrectos';
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      /// Cualquier excepción durante el proceso de autenticación se trata
      /// como credenciales inválidas, sin exponer el error real al cliente.
      _error = 'Usuario o contraseña incorrectos';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión del usuario actual limpiando el estado de autenticación.
  void logout() {
    _usuarioActual = null;
    _error = null;
    notifyListeners();
  }

  /// Limpia el mensaje de error actual y notifica a los listeners.
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
