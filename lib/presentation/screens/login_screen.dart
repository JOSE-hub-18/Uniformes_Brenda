import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Paquete para manejar estados globales
import '../../business/providers/auth_provider.dart'; // El provider que creamos


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controladores para obtener el texto de los campos
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Booleano para mostrar/ocultar contraseña
  bool _verPassword = false;

  // Variables para las animaciones de entrada
  late AnimationController _animController;
  late Animation<double> _fadeAnim; // Opacidad
  late Animation<Offset> _slideAnim; // Desplazamiento

  @override
  void initState() {
    super.initState();
    // Configurar animaciones de entrada (fade + slide)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward(); // Iniciar animación
  }

  @override
  void dispose() {
    // Limpiar recursos para evitar memory leaks
    _animController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método que se ejecuta al presionar "Entrar"
  Future<void> _handleLogin() async {
    // Obtener el AuthProvider sin escuchar cambios (listen: false)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Llamar al método login del provider y esperar respuesta
    final exito = await authProvider.login(
      _usuarioController.text.trim(),
      _passwordController.text,
    );

    // Verificar que el widget aún existe antes de continuar
    if (!mounted) return;

    // Si el login fue exitoso, navegar a la pantalla home
    if (exito) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: authProvider.usuarioActual,
      );
    }
    // Si falló, el error ya está en authProvider.error y se muestra automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: SafeArea(
        // Animaciones de entrada
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              // Consumer escucha cambios en AuthProvider y reconstruye cuando hay notifyListeners()
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logounifomes.png',
                          width: 260,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 52),

                      // Etiqueta del campo usuario
                      const Text(
                        'Usuario',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Campo de texto para usuario
                      _Campo(
                        controller: _usuarioController,
                        hint: 'Ingrese su usuario',
                        icono: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      // Etiqueta del campo contraseña
                      const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Campo de texto para contraseña (con toggle de visibilidad)
                      _Campo(
                        controller: _passwordController,
                        hint: 'Ingrese su contraseña',
                        icono: Icons.lock_outline,
                        esPassword: true,
                        verPassword: _verPassword,
                        onTogglePassword: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),

                      // Mostrar mensaje de error si existe
                      if (authProvider.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          authProvider.error!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Botón de login
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          // Si está cargando, desactivar botón
                          onPressed: authProvider.cargando ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1452BD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          // Si está cargando, mostrar spinner; si no, mostrar texto
                          child: authProvider.cargando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget reutilizable para campos de texto
class _Campo extends StatelessWidget {
  final TextEditingController controller; // Controlador del texto
  final String hint; // Texto placeholder
  final IconData icono; // Icono prefijo
  final bool esPassword; // Si es campo de contraseña
  final bool verPassword; // Si la contraseña está visible
  final VoidCallback? onTogglePassword; // Función para mostrar/ocultar contraseña

  const _Campo({
    required this.controller,
    required this.hint,
    required this.icono,
    this.esPassword = false,
    this.verPassword = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // Ocultar texto solo si es password Y verPassword es false
      obscureText: esPassword && !verPassword,
      style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFACACAC), fontSize: 14),
        // Icono al inicio del campo
        prefixIcon: Icon(icono, color: Color(0xFF1452BD), size: 20),
        // Icono de ojo solo si es campo de contraseña
        suffixIcon: esPassword
            ? IconButton(
                icon: Icon(
                  verPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF1452BD),
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        // Bordes del campo
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Borde cuando el campo tiene foco
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1452BD), width: 1.5),
        ),
      ),
    );
  }
}