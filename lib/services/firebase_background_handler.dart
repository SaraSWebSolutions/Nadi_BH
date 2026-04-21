import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.initialize();
  await NotificationService.createChannel();

  final data = message.data;

  // === ADD THIS — let Stream Chat handle its own background pushes ===
  if (data.containsKey('sender') || 
      data.containsKey('channel_id')) {
    return;  // Stream Chat SDK handles this
  }
  // === END ADDED ===

  // ✅ Existing OTP / general notification handling
  final title = message.notification?.title ?? "OTP";
  final body =
      message.notification?.body ?? "Your OTP is ${message.data['otp']}";

  await NotificationService.show(title: title, body: body);
}
