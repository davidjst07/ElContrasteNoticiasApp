import 'package:ElContrasteApp/api/firebase_api.dart';
import 'package:ElContrasteApp/widgets/audio_handler.dart';
import 'package:ElContrasteApp/widgets/bottom_navigation.dart';
import 'package:ElContrasteApp/widgets/notification_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Firebase.initializeApp();
  await initializeDateFormatting('es');

  // Configuración de AudioService
  await _initializeAudioService();

  runApp(const MyApp());

  Future.delayed(Duration.zero, () async {
    await FirebaseApi().initNotifications();
    await NotificationService().init();
    FlutterNativeSplash.remove();
  });
}

// Función para inicializar el servicio de audio
Future<void> _initializeAudioService() async {
  try {
    if (!(await AudioService.running)) {
      await AudioService.init(
        builder: () => RadioAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.elcontraste.radio',
          androidNotificationChannelName: 'El Contraste Radio',
          androidNotificationOngoing: true,
          // Removido resumeOnClick ya que no es un parámetro válido
        ),
      );
    }
  } catch (e) {
    debugPrint('Error al inicializar AudioService: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El Contraste Noticias APP',
      theme: ThemeData(
        primaryColor: const Color(0xFF0B375E),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B375E),
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const ScreenWelcome(),
    );
  }
}

class ScreenWelcome extends StatefulWidget {
  const ScreenWelcome({super.key});

  @override
  _ScreenWelcome createState() => _ScreenWelcome();
}

class _ScreenWelcome extends State<ScreenWelcome> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
      );
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 20, 99, 168),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Iniciar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}