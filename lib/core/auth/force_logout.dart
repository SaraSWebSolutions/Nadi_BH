import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/routing/route_names.dart';
import 'package:nadi_user_app/services/MqttNotificationService.dart';

enum ForceLogoutReason { disabled, rejected, unauthorized }

class ForceLogout {
  static bool _inProgress = false;

  static Future<void> trigger(ForceLogoutReason reason) async {
    if (_inProgress) return;
    _inProgress = true;

    try {
      try {
        MqttNotificationService.disconnect();
      } catch (_) {}

      await AppPreferences.clearAll();
      await AppPreferences.setLoggedIn(false);

      final context =
          appRouter.routerDelegate.navigatorKey.currentContext;
      if (context == null) return;

      appRouter.go(RouteNames.login);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = appRouter.routerDelegate.navigatorKey.currentContext;
        if (ctx != null) _showReasonDialog(ctx, reason);
      });
    } finally {
      // Allow a future trigger after the user sees the dialog and taps OK.
      Future.delayed(const Duration(seconds: 2), () => _inProgress = false);
    }
  }

  static void _showReasonDialog(BuildContext context, ForceLogoutReason reason) {
    final isDisabled = reason == ForceLogoutReason.disabled;
    final isRejected = reason == ForceLogoutReason.rejected;

    final title = isDisabled
        ? "Account Disabled"
        : isRejected
            ? "Account Rejected"
            : "Session Ended";
    final message = isDisabled
        ? "Your account has been disabled. Please contact our support team for assistance."
        : isRejected
            ? "Your account has been rejected. Please contact our support team for assistance."
            : "Your session has ended. Please sign in again.";
    final iconData = isDisabled
        ? Icons.block
        : isRejected
            ? Icons.cancel_outlined
            : Icons.lock_outline;
    final iconColor = isDisabled
        ? Colors.red.shade600
        : isRejected
            ? Colors.orange.shade700
            : Colors.blueGrey.shade700;
    final iconBg = isDisabled
        ? Colors.red.shade50
        : isRejected
            ? Colors.orange.shade50
            : Colors.blueGrey.shade50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.app_background_clr,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }
}
