// import 'package:flutter/material.dart';

// import 'package:nadi_user_app/views/screens/chats_view.dart';
// import 'package:nadi_user_app/views/screens/my_service_request.dart';
// import 'package:nadi_user_app/views/screens/myprofile.dart';
// import 'package:nadi_user_app/views/screens/settings_view.dart';
// import 'package:nadi_user_app/widgets/HomeTabNavigator .dart';

// class BottomNav extends StatefulWidget {
//   const BottomNav({super.key});

//   @override
//   State<BottomNav> createState() => _BottomNavState();
// }

// class _BottomNavState extends State<BottomNav> {
//   int _selectedIndex = 0;
//   DateTime? lastBackPressed;

//   final homeNavigatorKey = GlobalKey<NavigatorState>();
//   late final List<Widget Function()> screens;

//   @override
//   void initState() {
//     super.initState();
//     screens = [
//       () => HomeTabNavigator(
//         navigatorKey: homeNavigatorKey,
//         onTabChange: changeTab,
//       ),
//       () => MyServiceRequest(),
//       () => ChatsView(),
//       () => Myprofile(),
//       () => SettingsView(),
//     ];
//   }

//   void changeTab(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   /// BACK BUTTON HANDLER
//   Future<bool> _onWillPop() async {
//     if (_selectedIndex != 0) {
//       setState(() => _selectedIndex = 0);
//       return false;
//     }

//     if (homeNavigatorKey.currentState != null &&
//         homeNavigatorKey.currentState!.canPop()) {
//       homeNavigatorKey.currentState!.pop();
//       return false;
//     }

//     DateTime now = DateTime.now();
//     if (lastBackPressed == null ||
//         now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
//       lastBackPressed = now;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Tap again to exit"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return false;
//     }

//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         body: SafeArea(
//           bottom: true,
//           top: false,
//           child: screens[_selectedIndex](),
//         ),
//         bottomNavigationBar: _buildBottomNav(),
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       height: 85,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? const Color.fromARGB(255, 223, 219, 219).withOpacity(0.6)
//                 : Colors.black12,
//             blurRadius: isDark ? 12 : 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) => setState(() => _selectedIndex = index),
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           selectedItemColor: const Color(0xFF0F7757),
//           unselectedItemColor: Colors.grey,
//           selectedLabelStyle: const TextStyle(fontSize: 12),
//           unselectedLabelStyle: const TextStyle(fontSize: 12),
//           showUnselectedLabels: true,
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 28),
//               activeIcon: Icon(Icons.home, size: 28),
//               label: "Home",
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(
//                 AssetImage("assets/icons/services.png"),
//                 size: 28,
//               ),
//               label: "My Request",
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/icons/chat.png"), size: 28),
//               label: "Live Chat",
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/icons/profile.png"), size: 28),
//               label: "Profile",
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/icons/setting.png"), size: 28),
//               label: "Settings",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/stream_unread_provider.dart';
import 'package:nadi_user_app/views/screens/chats_view.dart';
import 'package:nadi_user_app/views/screens/my_service_request.dart';
import 'package:nadi_user_app/views/screens/myprofile.dart';
import 'package:nadi_user_app/views/screens/settings_view.dart';
import 'package:nadi_user_app/widgets/HomeTabNavigator%20.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/services/Stream_Chat_Service.dart';

class BottomNav extends ConsumerStatefulWidget {
  const BottomNav({super.key});

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  int _selectedIndex = 0;
  DateTime? lastBackPressed;

  final homeNavigatorKey = GlobalKey<NavigatorState>();
  late final List<Widget Function()> screens;

  @override
  void initState() {
    super.initState();
    _initStreamChat();
    screens = [
      () => HomeTabNavigator(
        navigatorKey: homeNavigatorKey,
        onTabChange: changeTab,
      ),
      () => const MyServiceRequest(),
      () => const ChatsView(),
      () => const Myprofile(),
      () => const SettingsView(),
    ];
  }

  Future<void> _initStreamChat() async {
    try {
      final userId = await AppPreferences.getUserId();
      if (userId != null && userId.isNotEmpty) {
        await StreamChatService().connectUserIfNeeded(userId);
      }
    } catch (e) {
      debugPrint("❌ Stream Chat Init Failed in BottomNav: $e");
    }
  }

  void changeTab(int index) {
    setState(() => _selectedIndex = index);
  }

  /// BACK BUTTON HANDLER
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    if (homeNavigatorKey.currentState != null &&
        homeNavigatorKey.currentState!.canPop()) {
      homeNavigatorKey.currentState!.pop();
      return false;
    }

    DateTime now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.tapAgainToExit),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        // ⭐ SafeArea applied properly
        body: SafeArea(
          top: false,
          bottom: true,
          child: screens[_selectedIndex](),
        ),

        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  /// Badge-wrapped icon for the Live Chat tab
  Widget _chatIconWithBadge(int totalUnread, {bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.chat_bubble : Icons.chat_bubble_outline,
          size: 28,
          color: active ? AppColors.app_background_clr : Colors.grey,
        ),
        if (totalUnread > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  totalUnread > 99 ? '99+' : '$totalUnread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Total unread across all chats — drives the tab badge
    final unreadMap = ref
        .watch(streamUnreadCountsProvider)
        .maybeWhen(data: (data) => data, orElse: () => {});

    // USE THIS

    final totalUnread = unreadMap.values.fold<int>(
      0,
      (sum, c) => sum + (c as int),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color.fromARGB(255, 223, 219, 219).withOpacity(0.6)
                : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.app_background_clr,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, size: 28),
              activeIcon: const Icon(Icons.home, size: 28),
              label: loc.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined, size: 28),
              activeIcon: const Icon(Icons.assignment, size: 28),
              label: loc.navMyRequest,
            ),
            // Live Chat with unread badge
            BottomNavigationBarItem(
              icon: _chatIconWithBadge(totalUnread, active: false),
              activeIcon: _chatIconWithBadge(totalUnread, active: true),
              label: loc.navLiveChat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline, size: 28),
              activeIcon: const Icon(Icons.person, size: 28),
              label: loc.navProfile,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined, size: 28),
              activeIcon: const Icon(Icons.settings, size: 28),
              label: loc.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
