import 'package:flutter/widgets.dart';
import 'package:nadi_user_app/core/utils/validators.dart';
import 'package:nadi_user_app/models/login_model.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
/// Controller for login page
class LoginController {
  final email = TextEditingController();
  final password = TextEditingController();

  /// Email validation
   String? validateEmail(String? value, AppLocalizations l10n) {
    return Validators.email(value, l10n);
  }

  /// Password validation
  String? validatePassword(String? value, AppLocalizations l10n) {
    return Validators.password(value, l10n);
  }


  LoginModel getLoginData() {
    return LoginModel(
      email: email.text,
      password: password.text,
    );
    
  }
}