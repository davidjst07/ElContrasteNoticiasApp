import 'package:elcontraste_push/api/firebase_api.dart';
import 'package:elcontraste_push/screens/screen_news.dart';
import 'package:elcontraste_push/screens/screen_welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Contraste Noticias APP',
      theme: ThemeData(
        // Define el tema global de la aplicación
        primaryColor: const Color(0xFF0B375E), // Color principal
        scaffoldBackgroundColor: Colors.white, // Fondo de las pantallas
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B375E), // Color de los botones
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
          ),
        ),
        textTheme: const TextTheme(
          // Estilo de texto para títulos
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          // Estilo de texto para botones
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      routes: {
        '/': (context) => const ScreenWelcome(),
        '/news': (context) => const NoticiasPage(),
      },
      initialRoute: '/screen_welcome',
    );
  }
}

class PaginaPrincipal extends StatelessWidget {
  const PaginaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ScreenWelcome(),
    );
  }
}