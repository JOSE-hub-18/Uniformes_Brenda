import '../../models/models.dart'; 


abstract class AuthRepository {
  Future<Usuario?> getUsuario(String usuario);
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Usuario> execute(String usuario, String password) async {
    // 1. Validar campos
    if (usuario.trim().isEmpty) {
      throw Exception("El usuario es obligatorio");
    }

    if (password.isEmpty) {
      throw Exception("La contraseña es obligatoria");
    }

    // Buscar usuario
    final user = await repository.getUsuario(usuario);

    if (user == null) {
      throw Exception("Usuario no existe");
    }

    //Validar si está activo
    if (!user.activo) {
      throw Exception("Usuario inactivo");
    }

    // Validar contraseña
    if (password != user.passwordHash) {
      throw Exception("Contraseña incorrecta");
    }

    // Validar rol 
    if (user.rol == null) {
      throw Exception("Usuario sin rol asignado");
    }

    // Retornar usuario 
    return user;
  }
}