import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/routing/app_router.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ GoRouter instance for navigation on notification tap
  static GoRouter? _router;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// ✅ Handle notification tap — navigate to correct screen
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    // === ADD THIS ===
    if (payload != null && payload.startsWith('chat:')) {
      final channelId = payload.replaceFirst('chat:', '');
      if (channelId.isNotEmpty) {
        // Navigate using existing GoRouter - fallback to bottomnav since ChatDetails requires extra arguments
        _router?.go(RouteNames.bottomnav);
      }
      return;
    }
    // === END ADDED ===
  }

  static Future<void> createChannel() async {
    const AndroidNotificationChannel otpChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for OTP notifications',
      importance: Importance.high,
    );

    /// ✅ Separate channel for chat messages
    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_messages_channel',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(otpChannel);
    await androidPlugin?.createNotificationChannel(chatChannel);
  }

  /// ✅ Show a local notification with optional payload and channel
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
