// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:video_player/video_player.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:nadi_user_app/core/network/dio_client.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/onbording_service.dart';

// class CustomSplashScreen extends StatefulWidget {
//   const CustomSplashScreen({super.key});

//   @override
//   State<CustomSplashScreen> createState() => _CustomSplashScreenState();
// }

// class _CustomSplashScreenState extends State<CustomSplashScreen>
//     with SingleTickerProviderStateMixin {
//   final OnbordingService _onbordingService = OnbordingService();

//   String? imageUrl;
//   String? videoUrl;
//   VideoPlayerController? _videoController;

//   bool isLoading = true;

//   // 🔹 Animation
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     AppLogger.success("🚀 Splash initState()");

//     // 🔹 Zoom / flash animation
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 2.05).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _initNotifications();
//     _loadSplashMedia();
//   }

//   // LOAD IMAGE / VIDEO FROM BACKEND

//   Future<void> _loadSplashMedia() async {

//     try {
//       final response = await _onbordingService.loading();
//       AppLogger.success("✅ API Response: ${jsonEncode(response)}");

//       if (response == null ||
//           response['data'] == null ||
//           response['data'].isEmpty) {
//         _startNavigation();
//         return;
//       }

//       final item = response['data'][0];
//       final image = item['image'];
//       final video = item['video'];

//       // VIDEO
//       if (video != null && video.toString().isNotEmpty) {
//         videoUrl = "${ImageBaseUrl.baseUrl}/$video";

//         _videoController = VideoPlayerController.networkUrl(
//           Uri.parse(videoUrl!),
//         );

//         await _videoController!.initialize();
//         _videoController!
//           ..setLooping(true)
//           ..play();
//       }
//       // IMAGE
//       else if (image != null && image.toString().isNotEmpty) {
//         imageUrl = "${ImageBaseUrl.baseUrl}/$image";
//       }

//       setState(() => isLoading = false);
//       _startNavigation();
//     } catch (e) {
//       AppLogger.error("❌ Splash error: $e");
//       _startNavigation();
//     }
//   }

//   // FIREBASE NOTIFICATIONS

//   Future<void> _initNotifications() async {
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     final token = await FirebaseMessaging.instance.getToken();
//     if (token != null) {
//       await AppPreferences.savefcmToken(token);
//     }
//   }

//   // NAVIGATION

//   void _startNavigation() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (!mounted) return;
//       _decideNavigation();
//     });
//   }

//   Future<void> _decideNavigation() async {
//     final isLoggedIn = await AppPreferences.isLoggedIn();
//     final hasSeenAbout = await AppPreferences.hasSeenAbout();
//     final token = await AppPreferences.getToken();

//     if (!mounted) return;

//     if (!hasSeenAbout) {
//       context.go(RouteNames.language);
//     } else if (isLoggedIn && token.isNotEmpty) {
//       context.go(RouteNames.bottomnav);
//     } else {
//       context.go(RouteNames.login);
//     }
//   }

//   // MEDIA UI WITH ANIMATION

//   Widget _buildMedia() {
//     Widget child;

//     if (_videoController != null && _videoController!.value.isInitialized) {
//       child = AspectRatio(
//         aspectRatio: _videoController!.value.aspectRatio,
//         child: VideoPlayer(_videoController!),
//       );
//     } else if (imageUrl != null) {
//       child = Image.network(
//         imageUrl!,
//         width: 180,
//         height: 180,
//         fit: BoxFit.contain,
//       );
//     } else {
//       child = Image.asset('assets/icons/logo.png', width: 150, height: 150);
//     }

//     // 🔹 Zoom / flash animation wrapper
//     return ScaleTransition(scale: _scaleAnimation, child: child);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D5F48),
//       body: Center(child: isLoading ? const SizedBox() : _buildMedia()),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/onbording_service.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:go_router/go_router.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  final OnbordingService _onbordingService = OnbordingService();

  String? imageUrl;
  String? videoUrl;
  VideoPlayerController? _videoController;

  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    AppLogger.success("🚀 Splash initState()");

    _setupAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([_initNotifications(), _loadSplashMedia()]);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // ================= ANIMATION =================
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.repeat();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_hasNavigated) _decideNavigation();
    });
  }

  // ================= LOAD MEDIA =================
  Future<void> _loadSplashMedia() async {
    try {
      final response = await _onbordingService.loading().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );

      if (response == null ||
          response['data'] == null ||
          response['data'].isEmpty) {
        return;
      }

      final item = response['data'][0];
      final image = item['image'];
      final video = item['video'];

      if (video != null && video.toString().isNotEmpty) {
        videoUrl = "${ImageBaseUrl.baseUrl}/$video";

        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl!),
        );

        await _videoController!.initialize().timeout(
          const Duration(seconds: 3),
          onTimeout: () {},
        );

        _videoController!
          ..setLooping(true)
          ..play();
      } else if (image != null && image.toString().isNotEmpty) {
        imageUrl = "${ImageBaseUrl.baseUrl}/$image";
      }

      if (mounted) setState(() {});
    } catch (e) {
      AppLogger.error("❌ Splash error: $e");
    }
  }

  // ================= FCM =================
  Future<void> _initNotifications() async {
    try {
      await Future(() async {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        AppLogger.success("Permission: ${settings.authorizationStatus}");

        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
          await AppPreferences.savefcmToken(token);
        });

        final token = await FirebaseMessaging.instance.getToken();

        if (token != null) {
          await AppPreferences.savefcmToken(token);
        }
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      AppLogger.error("FCM init error: $e");
    }
  }

  // ================= NAVIGATION =================
  Future<void> _decideNavigation() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final isLoggedIn = await AppPreferences.isLoggedIn();
    final hasSeenAbout = await AppPreferences.hasSeenAbout();
    final token = await AppPreferences.getToken();

    if (!mounted) return;

    if (!hasSeenAbout) {
      context.go(RouteNames.language);
    } else if (token != null && token.isNotEmpty) {
      context.go(RouteNames.bottomnav);
    } else {
      context.go(RouteNames.login);
    }
  }

  // ================= UI =================
  Widget _buildSplashUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔄 ROTATING LOGO (FIXED SIZE = NO JUMP)
        SizedBox(
          width: 300,
          height: 300,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Center(
              child: Image.asset(
                'assets/logo/logo.png',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),

        const SizedBox(height: 50),

        // 📊 PROGRESS BAR
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ================= VIDEO / IMAGE =================
  Widget _buildMedia() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }

    if (imageUrl != null) {
      return _buildSplashUI();
    }

    return _buildSplashUI();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6374AE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/onboarding/1774802367129_PAGE-No1.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: isLoading ? const SizedBox() : _buildMedia()),
      ),
    );
  }
}
