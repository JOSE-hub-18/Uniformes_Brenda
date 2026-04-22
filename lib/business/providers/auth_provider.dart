import 'package:flutter/material.dart';
import '../../data/repositories/usuario_repository.dart';
import '../usecases/login_usecase.dart';
import '../../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final _usuarioRepo = UsuarioRepository();
  final _loginUseCase = LoginUseCase();

  bool _cargando = false;
  String? _error;
  Usuario? _usuarioActual;

  // Getters
  bool get cargando => _cargando;
  String? get error => _error;
  Usuario? get usuarioActual => _usuarioActual;
  bool get estaAutenticado => _usuarioActual != null;

  /// Método de login
  Future<bool> login(String usuario, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final usuarios = await _usuarioRepo.obtenerTodos();

      final user = await _loginUseCase.execute(
        usuarios,
        usuario,
        password,
      );

      if (user != null) {
        _usuarioActual = user;
        _error = null;
        _cargando = false;
        notifyListeners();
        return true;
      }

      _error = 'Usuario o contraseña incorrectos';
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Usuario o contraseña incorrectos';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// Método de logout
  void logout() {
    _usuarioActual = null;
    _error = null;
    notifyListeners();
  }

  /// Limpiar errores
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}