import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/database_helper.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'business/providers/auth_provider.dart';
import 'business/providers/inventario_provider.dart';
import 'presentation/screens/inventario_screen.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/screens/administrar_prenda_screen.dart'; // Ajusta tu ruta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  runApp(
    // MultiProvider envuelve la app para proporcionar acceso global a los providers
    MultiProvider(
      providers: [
        // Provider de autenticación - maneja login, logout y estado del usuario
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => InventarioProvider()),

        ChangeNotifierProvider(create: (_) => HomeProvider()),

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
      home: const AdministrarPrendaScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/inventory': (context) => const InventarioScreen(),
      },
      
    );
  }
}