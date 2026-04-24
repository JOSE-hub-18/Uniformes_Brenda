import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DB
import 'data/database/database_helper.dart';

// Screens
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/inventario_screen.dart';
import 'presentation/screens/registrar_prenda_screen.dart';

// Providers
import 'business/providers/auth_provider.dart';
import 'business/providers/inventario_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/registrar_inventario_provider.dart';

// Repositories
import 'data/repositories/inventario_repository.dart';
import 'data/repositories/prenda_repository.dart';
import 'data/repositories/talla_repository.dart';
import 'data/repositories/escuela_repository.dart';

// UseCase
import 'business/usecases/registrar_inventario_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),

        // Provider necesario para dropdowns y escuela
        ChangeNotifierProvider(
          create: (_) => RegistrarInventarioProvider(
            prendaRepository: PrendaRepository(),
            tallaRepository: TallaRepository(),
            escuelaRepository: EscuelaRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uniformes Brenda',
      debugShowCheckedModeBanner: false,

      // Pantalla inicial
      home: const InventarioScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/inventory': (context) => const InventarioScreen(),
      },
    );
  }
}