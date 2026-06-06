import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/fetchpointsnodification.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'package:nadi_user_app/providers/profile_provider.dart';
import 'package:nadi_user_app/providers/serviceProvider.dart';
import 'package:nadi_user_app/providers/theme_provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/account_delete.dart';
import 'package:nadi_user_app/services/lockout_service.dart';
import 'package:nadi_user_app/services/MqttNotificationService.dart';
import 'package:nadi_user_app/services/notification_toggle_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/confirm_dialog.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool isToggleOn = true; // default — overwritten immediately from cache
  bool isLoadingToggle = true;
  final LockoutService _lockoutService = LockoutService();
  final NotificationToggleService _notificationService =
      NotificationToggleService();
  // Reusable theme selector
  Widget themeOption(String type) {
    final currentTheme = ref.watch(themeProvider);

    bool isActive = false;

    if (type == "Light" && currentTheme == ThemeMode.light) {
      isActive = true;
    } else if (type == "Dark" && currentTheme == ThemeMode.dark) {
      isActive = true;
    } else if (type == "System" && currentTheme == ThemeMode.system) {
      isActive = true;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.app_background_clr : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget settingItem({
    required String text,
    required Image icon,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 166, 176, 219),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: icon,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String selectedLanguage = "ENG";

  Widget languageOption(String value) {
    final locale = ref.watch(languageProvider);

    bool isActive =
        (value == "ENG" && locale.languageCode == 'en') ||
        (value == "BH" && locale.languageCode == 'ar');

    return GestureDetector(
      onTap: () {
        if (value == "ENG") {
          ref.read(languageProvider.notifier).changeLanguage('en');
        } else if (value == "BH") {
          ref.read(languageProvider.notifier).changeLanguage('ar');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.app_background_clr : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCachedThenSync();
  }

  Future<void> _loadCachedThenSync() async {
    // 1. Load cached value instantly — no flicker
    final cached = await AppPreferences.getNotificationToggle();
    if (!mounted) return;
    setState(() {
      isToggleOn = cached;
      isLoadingToggle = false;
    });

    // 2. Silently sync from API in background
    try {
      final status = await _notificationService.fetchCheckStatus();
      if (!mounted) return;
      if (status != cached) {
        setState(() => isToggleOn = status);
        await AppPreferences.saveNotificationToggle(status);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ ADD THIS
    Future<void> logout(BuildContext context) async {
      try {
        /// 1. Get stored FCM token (NOT fresh one)
        final fcmToken = await AppPreferences.getfcmToken();

        /// 2. Call backend logout / lockout API first
        await _lockoutService.fetchLockout(fcmToken);

        /// 3. Disconnect services safely
        MqttNotificationService.disconnect();

        /// 4. Clear local storage
        await AppPreferences.clearAll();

        /// 5. Invalidate providers
        ref.invalidate(profileprovider);
        ref.invalidate(serviceListProvider);
        ref.invalidate(fetchpointsnodification);

        /// 6. Navigate safely
        if (context.mounted) {
          context.go(RouteNames.login);
        }
      } catch (e) {
        /// FORCE LOGOUT (fallback)
        await AppPreferences.clearAll();

        ref.invalidate(profileprovider);
        ref.invalidate(serviceListProvider);
        ref.invalidate(fetchpointsnodification);

        if (context.mounted) {
          context.go(RouteNames.login);
        }
      }
    }

    final AccountDelete accountDelete = AccountDelete();

    List<dynamic> deleteReasons = [];
    String? selectedReasonId;
    bool isLoadingReasons = false;

    Future<void> showDeleteAccountDialog(BuildContext context) async {
      setState(() {
        isLoadingReasons = true;
      });

      try {
        final locale = ref.read(languageProvider);
        final lang = locale.languageCode;

        final response = await accountDelete.fetchdeletereson(lang);

        deleteReasons = response["data"] ?? [];
      } catch (e) {
        debugPrint("Error loading reasons: $e");
      }

      setState(() {
        isLoadingReasons = false;
      });

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(l10n.deleteAccountTitle),
                content: SizedBox(
                  width: double.maxFinite,
                  child: isLoadingReasons
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.deleteAccountDescription),

                            const SizedBox(height: 15),

                            /// ✅ RADIO LIST FROM API
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: deleteReasons.length,
                                itemBuilder: (context, index) {
                                  final item = deleteReasons[index];

                                  return RadioListTile<String>(
                                    value: item["_id"],
                                    groupValue: selectedReasonId,
                                    title: Text(item["reason"]),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedReasonId = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              l10n.cancel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              if (selectedReasonId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.pleaseSelectReason),
                                  ),
                                );
                                return;
                              }

                              await accountDelete.fetchdeleteaccount(
                                reasonId: selectedReasonId!,
                              );

                              await AppPreferences.clearAll();
                              await AppPreferences.setLoggedIn(false);

                              if (context.mounted) {
                                context.go(RouteNames.login);
                              }
                            },
                            child: Text(
                              l10n.delete,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // actions: [
                //   TextButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     child: Text(l10n.cancel),
                //   ),
                //   TextButton(
                //     onPressed: () async {
                //       if (selectedReasonId == null) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(content: Text(l10n.pleaseSelectReason)),
                //         );
                //         return;
                //       }
                //       await accountDelete.fetchdeleteaccount(
                //         reasonId: selectedReasonId!,
                //       );
                //       await AppPreferences.clearAll();
                //       await AppPreferences.setLoggedIn(false);
                //       if (context.mounted) context.go(RouteNames.splash);
                //     },
                //     child: Text(
                //       l10n.delete,
                //       style: TextStyle(color: Colors.red),
                //     ),
                //   ),
                // ],
              );
            },
          );
        },
      );
    }

    Future<void> notificationToggle() async {
      final newValue = !isToggleOn;

      setState(() {
        isToggleOn = newValue;
      });
      AppLogger.info("notificationToggle $newValue");
      await AppPreferences.saveNotificationToggle(newValue);
      try {
        await _notificationService.updateNotificationStatus(newValue);

        // Optional: handle FCM topic
        // if (newValue) {
        //   await FirebaseMessaging.instance.subscribeToTopic("all");
        // } else {
        //   await FirebaseMessaging.instance.unsubscribeFromTopic("all");
        // }
      } catch (e) {
        // API failed — revert toggle and cache
        if (mounted) setState(() => isToggleOn = !newValue);
        await AppPreferences.saveNotificationToggle(!newValue);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.notificationUpdateFailed,
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),

        leadingWidth: 60,

        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                // child: AppCircleIconButton(
                //   icon: Icons.arrow_back,
                //   onPressed: () => context.pop(),
                // ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    settingItem(
                      text: AppLocalizations.of(context)!.aboutApp,
                      icon: Image.asset("assets/icons/i.png"),
                      onTap: () {
                        context.push(RouteNames.aboutscreen);
                      },
                    ),
                    const SizedBox(height: 15),
                    settingItem(
                      text: AppLocalizations.of(context)!.helpSupport,
                      icon: Image.asset("assets/icons/help.png"),
                      onTap: () {
                        context.push(RouteNames.helpSupport);
                      },
                    ),

                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 166, 176, 219),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset("assets/icons/noti.png"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              AppLocalizations.of(context)!.notification,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: notificationToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 45,
                            height: 25,
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isToggleOn
                                  ? AppColors.app_background_clr
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: isToggleOn
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // settingItem(
                    //   text: "Change Language",
                    //   icon: Image.asset("assets/icons/global.png"),
                    //   onTap: () {},
                    // ),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 166, 176, 219),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset("assets/icons/global.png"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.changeLanguage,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromARGB(255, 166, 176, 219),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              languageOption("BH"),
                              languageOption("ENG"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    settingItem(
                      text: AppLocalizations.of(context)!.history,
                      icon: Image.asset("assets/icons/menu.png"),
                      onTap: () {
                        context.push(RouteNames.viewalllogs);
                      },
                    ),
                    const SizedBox(height: 15),
                    settingItem(
                      text: AppLocalizations.of(context)!.privacyPolicy,

                      icon: Image.asset("assets/icons/policy.png"),
                      onTap: () {
                        context.push(RouteNames.privacyPolicy);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 166, 176, 219),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset("assets/icons/idea.png"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.theme,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromARGB(255, 166, 176, 219),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(themeProvider.notifier)
                                      .changeTheme(ThemeMode.light);
                                },
                                child: themeOption("Light"),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(themeProvider.notifier)
                                      .changeTheme(ThemeMode.dark);
                                },
                                child: themeOption("Dark"),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(themeProvider.notifier)
                                      .changeTheme(ThemeMode.system);
                                },
                                child: themeOption("System"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: settingItem(
                  text: AppLocalizations.of(context)!.logout,
                  icon: Image.asset("assets/icons/logout.png"),
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: l10n.logoutTitle,
                      message: l10n.logoutMessage,
                      confirmText: l10n.logout,
                      icon: Icons.logout_rounded,
                      destructive: true,
                    );
                    if (!context.mounted) return;
                    if (confirmed) logout(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: settingItem(
                  text: AppLocalizations.of(context)!.accountDelete,
                  icon: Image.asset("assets/icons/accout_delete.png"),
                  onTap: () {
                    showDeleteAccountDialog(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// Replace Container background -  color: Theme.of(context).colorScheme.surface, // ✅ surface adapts to light/dark
// Use theme for Text -    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  //   fontWeight: FontWeight.w600,
                                                    //   fontSize: 20,
                                                                 // ),
// textTheme.titleLarge automatically adapts to light / dark mode text color

