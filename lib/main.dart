import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/database_helper.dart';
import 'presentation/screens/login_screen.dart';
import 'business/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  runApp(
    // MultiProvider envuelve la app para proporcionar acceso global a los providers
    MultiProvider(
      providers: [
        // Provider de autenticación - maneja login, logout y estado del usuario
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const Scaffold(
          body: Center(child: Text('home — próximamente')),
        ),
      },
    );
  }
}