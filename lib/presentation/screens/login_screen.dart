import 'package:flutter/material.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../business/usecases/login_usecase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usuarioRepo = UsuarioRepository();
  final _loginUseCase = LoginUseCase();

  bool _cargando = false;
  bool _verPassword = false;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
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
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuarios = await _usuarioRepo.obtenerTodos();
      final user = await _loginUseCase.execute(
        usuarios,
        _usuarioController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      }
    } catch (e) {
      setState(() {
        _error = 'Usuario o contraseña incorrectos';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logounifomes.png',
                      width: 200,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 52),

                  // Campo usuario
                  const Text(
                    'Usuario',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _usuarioController,
                    hint: 'Ingrese su usuario',
                    icono: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  // Campo contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _passwordController,
                    hint: 'Ingrese su contraseña',
                    icono: Icons.lock_outline,
                    esPassword: true,
                    verPassword: _verPassword,
                    onTogglePassword: () =>
                        setState(() => _verPassword = !_verPassword),
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Botón entrar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1452BD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _cargando
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Campo de texto reutilizable ---
class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool esPassword;
  final bool verPassword;
  final VoidCallback? onTogglePassword;

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
      obscureText: esPassword && !verPassword,
      style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFACACAC), fontSize: 14),
        prefixIcon: const Icon(Icons.person_outline,
            color: Color(0xFF1452BD), size: 20),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1452BD), width: 1.5),
        ),
      ),
    );
  }
}