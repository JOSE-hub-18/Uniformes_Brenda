import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [],
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Uniformes Brenda'),
        ),
        body: const Center(
          child: Text('Inicio'),
        ),
      ),
    );
  }
}