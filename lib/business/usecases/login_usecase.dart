// dart converter para generar hash de contraseñas
//crypto para hashing 
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/models.dart';

/// Caso de uso para el inicio de sesión.
/// Se encarga de validar credenciales y retornar el usuario autenticado.
class LoginUseCase {


  Future<Usuario?> execute(
      List<Usuario> usuarios,
      String username,
      String password) async {

    // Validar campos vacíos
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Campos obligatorios");
    }

    try {
      // Buscar usuario por nombre de usuario
      final user = usuarios.firstWhere((u) => u.usuario == username);
      // Verificar si el usuario está activo
      if (!user.activo) {
        throw Exception("Usuario inactivo");
      }

      // Convertir la contraseña ingresada a hash
      final hashedInput = _hashPassword(password);

      // Comparar hash generado con el almacenado
      if (hashedInput != user.passwordHash) {
        throw Exception("Credenciales inválidas");
      }

      // Login exitoso
      return user;

    } catch (e) {
      // Usuario no encontrado 
      throw Exception("Credenciales inválidas");
    }
  }

  /// Genera un hash SHA-256 con salt 
  String _hashPassword(String password) {
    const salt = "uniformes_brenda_salt"; 
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }
}