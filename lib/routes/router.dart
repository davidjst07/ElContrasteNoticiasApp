import 'package:flutter/material.dart';
import 'package:ElContrasteApp/screens/screen_welcome.dart';
import 'package:ElContrasteApp/screens/screen_news.dart';
import 'package:ElContrasteApp/screens/screen_radio.dart';

class AppRouter {
  // Método que se encarga de generar las rutas de la aplicación
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const ScreenWelcome());
      case '/news':
        return MaterialPageRoute(builder: (_) => const NoticiasPage());
      case '/radio':
        return MaterialPageRoute(builder: (_) => const RadioPage());
      default:
        // Devuelve null para rutas desconocidas
        return null;
    }
  }
}