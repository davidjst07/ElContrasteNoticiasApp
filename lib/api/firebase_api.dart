import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Manejo de notificaciones en base a tipo de datos

  print('Title ${message.notification?.title}');
  print('Body ${message.notification?.body}');
  print('Payload ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Instancia de flutter local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // esta funcion se encarga de inicializar las notificaciones y de obtener el token de firebase
  Future<void> initNotifications() async {
  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
    });
  } catch (e) {
    print('🔥 Error al inicializar Firebase Notifications: $e');
  }
}

  
  // Metodo para mostrar notificaciones locales
  Future<void> _showNotification(RemoteNotification notification) async {
    // Configuracion de la notificacion
    const AndroidNotificationDetails andridDetails = 
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,

    );

    // Detalles de la notificación solo para android
    const NotificationDetails notificationDetails = NotificationDetails(android: andridDetails);

    //Muestra la notificación
    await flutterLocalNotificationsPlugin.show(
      0, 
      notification.title, 
      notification.body, 
      notificationDetails
    );

  }


}
