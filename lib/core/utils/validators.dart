import 'package:nadi_user_app/l10n/app_localizations.dart';

class Validators {
  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.entertheEmail;
    }

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.enterPassword;
    }

    if (value.length < 6) {
      return l10n.passwordMinLength;
    }

    return null;
  }

  static String? phoneNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.enterPhone;
    }

    if (value.length != 8) {
      return l10n.invalidPhoneLength;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return l10n.onlyDigitsAllowed;
    }

    return null;
  }
}