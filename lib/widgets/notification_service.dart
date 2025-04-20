import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isPlaying = false; // Estado de reproducción

  Future<void> init() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'radio_channel',
      'Radio Notifications',
      description: 'Notificaciones para controlar la radio',
      importance: Importance.high,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        final actionId = details.actionId; // Obtén el ID de la acción
        final payload = details.payload; // Obtén el payload de la notificación
        
        print('Action ID recibido: $actionId'); // Depuración
        print('Payload recibido: $payload'); // Depuración
        
        if (actionId == 'play_pause' || payload == 'play_pause') {
          _isPlaying = !_isPlaying;
          await showNotificationWithControls(_isPlaying);
        } else if (actionId == 'stop' || payload == 'stop') {
          _isPlaying = false;
          await cancelAllNotifications();
        }
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotificationWithControls(bool isPlaying) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'radio_channel',
      'Radio Notifications',
      channelDescription: 'Notificaciones para controlar la radio',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      //largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      actions: [
        AndroidNotificationAction(
          'play_pause',
          isPlaying ? '⏸️ Pausar' : '▶️ Reproducir',
          showsUserInterface: true, // Asegura que el botón sea interactivo
        ),
        const AndroidNotificationAction(
          'stop',
          '⏹️ Detener',
          showsUserInterface: true, // Asegura que el botón sea interactivo
        ),
      ],
      ongoing: true,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Emisora Contraste',
      isPlaying ? '🎶 Reproduciendo en vivo' : '⏸️ Pausado',
      platformChannelSpecifics,
      payload: isPlaying ? 'pause' : 'play',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
