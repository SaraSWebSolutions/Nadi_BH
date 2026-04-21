import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

import 'package:nadi_user_app/providers/active_chat_provider.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/providers/fetchpointsnodification.dart';
import 'package:nadi_user_app/providers/theme_provider.dart';
import 'package:flutter/services.dart';
import 'package:nadi_user_app/routing/route_names.dart';
import 'package:nadi_user_app/services/AppListener.dart';
import 'package:nadi_user_app/services/notification_service.dart';
import 'package:nadi_user_app/services/MqttNotificationService.dart';
import 'package:nadi_user_app/services/Stream_Chat_Service.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final container = ProviderContainer();

Future<int> getBadgeCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('badge_count') ?? 0;
}

Future<void> saveBadgeCount(int count) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('badge_count', count);
}

Future<void> updateBadge(int count) async {
  try {
    await AppBadgePlus.updateBadge(count); // ✅ handles 0 also
  } catch (e) {
    debugPrint("❌ Badge not supported: $e");
  }
}
///  STEP 1: ADD THIS HERE (TOP LEVEL, NOT INSIDE CLASS)
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data.containsKey('sender') || 
      message.data.containsKey('channel_id')) {
    return;  // Stream Chat SDK handles this
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// FIREBASE INIT
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// LOCAL NOTIFICATION INIT
  await NotificationService.initialize();
  await NotificationService.createChannel();

  /// BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  /// REQUEST PERMISSION (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  /// ✅ CRITICAL: Tell iOS to show notification banner+sound+badge even
  /// when the app is in the foreground. Without this, iOS only plays the
  /// sound but does NOT display the notification alert.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  /// VERY IMPORTANT FOR IOS TOKEN
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  // final userId = await AppPreferences.getUserId();
  // if(userId != null){
  //       await StreamChatService().connectUser(userId);
  // }

  /// GET FCM TOKEN
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM TOKEN = $token");
  } catch (e) {
    print("⚠️ FCM not available on simulator: $e");
  }

  /// TOKEN REFRESH LISTENER
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("🔥 NEW FCM TOKEN = $newToken");
  });

  /// Hive init
  await Hive.initFlutter();
  await Hive.openBox("aboutBox");
  await Hive.openBox("blockbox");
  await Hive.openBox("servicesBox");

  /// FOREGROUND MESSAGE
 FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  final data = message.data;

  // ✅ Handle Stream Chat push notifications
  if (data.containsKey('sender') ||
      data.containsKey('channel_id') ||
      (data.containsKey('type') && data['type'] == 'message.new')) {

    final senderName = data['sender_name'] ??
        data['sender'] ??
        message.notification?.title ??
        'New Message';

    final messageText = data['message_text'] ??
        message.notification?.body ??
        'You have a new message';

    final channelId = data['channel_id'] ?? data['cid'] ?? '';

    final activeChannel = container.read(activeChatChannelProvider);

    // ❌ If user is inside same chat → NO badge increment
    if (activeChannel != null &&
        activeChannel.isNotEmpty &&
        channelId.isNotEmpty &&
        channelId == activeChannel) {
      debugPrint('🔇 FCM: Suppressed — user is viewing this chat');
      return;
    }

    // ✅ 🔥 BADGE INCREMENT
    int currentCount = await getBadgeCount();
    currentCount++;
    await saveBadgeCount(currentCount);
    await updateBadge(currentCount);

    debugPrint('🔔 FCM: Chat notification: $senderName');

    NotificationService.show(
      title: senderName,
      body: messageText,
      payload: 'chat:$channelId',
      channelId: 'chat_messages_channel',
      channelName: 'Chat Messages',
    );
    return;
  }

  // ✅ 🔥 BADGE INCREMENT (GENERAL)
  int currentCount = await getBadgeCount();
  currentCount++;
  await saveBadgeCount(currentCount);
  await updateBadge(currentCount);

  NotificationService.show(
    title: message.notification?.title ?? 'OTP',
    body: message.notification?.body ??
        'Your OTP is ${message.data['otp']}',
  );

  container.invalidate(fetchpointsnodification);
});
  // ✅ Wire GoRouter to NotificationService for tap-to-navigate
  NotificationService.setRouter(appRouter);

  // Init MQTT and connect if already logged in
  MqttNotificationService.init(container);
  final userId = await AppPreferences.getUserId();
  if (userId != null) {
    MqttNotificationService.connect(userId);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppListener(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    return MaterialApp.router(
      routerConfig: appRouter,

      debugShowCheckedModeBanner: false,

      // StreamChat must wrap the entire app so StreamChannel/StreamMessageListView
      // can find it via context anywhere in the widget tree
      builder: (context, child) {
        return StreamChat(
          client: StreamChatService().client,
          child: child!,
        );
      },

      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      themeMode: themeMode,
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background_clr,
        primaryColor: AppColors.btn_primery,
        colorScheme: const ColorScheme.light(
          primary: AppColors.btn_primery,
          secondary: AppColors.button_secondary,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF2D2D2D)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btn_primery,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.btn_primery.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.btn_primery, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Poppins',
        primaryColor: AppColors.btn_primery,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.btn_primery,
          secondary: AppColors.button_secondary,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF1E1E1E),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btn_primery,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black45,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.btn_primery, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeProvider);
//     final locale = ref.watch(languageProvider);
//     final StreamChatClient client = StreamChatService().client;

//     return MaterialApp.router(
//       routerConfig: appRouter,
//       debugShowCheckedModeBanner: false,

//       locale: locale,
//       supportedLocales: AppLocalizations.supportedLocales,
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],

//       themeMode: themeMode,

//       theme: ThemeData(
//         fontFamily: 'Poppins',
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: AppColors.background_clr,
//         colorScheme: const ColorScheme.light(
//           primary: AppColors.btn_primery,
//           secondary: AppColors.button_secondary,
//           surface: Colors.white,
//           onSurface: Colors.black,
//         ),
//       ),

//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: Colors.black,
//         fontFamily: 'Poppins',
//         colorScheme: const ColorScheme.dark(
//           primary: AppColors.btn_primery,
//           secondary: AppColors.button_secondary,
//           surface: Color.fromARGB(255, 56, 56, 56),
//           onSurface: Color.fromARGB(255, 53, 53, 53),
//         ),
//       ),

//       builder: (context, child) {
//         return StreamChat(
//               client: StreamChatService().client,
//           child: child!,
//         );
//       },
//     );
//   }
// }