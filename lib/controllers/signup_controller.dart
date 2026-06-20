import 'package:flutter/material.dart';
import 'package:nadi_user_app/models/SignupModel.dart';

import 'package:nadi_user_app/core/utils/validators.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class SignupController {
  // Text controllers
  final name = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final firstName = TextEditingController();
  final secondName = TextEditingController();
  final thirdName = TextEditingController();
  final fourthName = TextEditingController();

  // Address controllers
  final doorNo = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final pincode = TextEditingController();

  // Account Type
  String accountType = "Individual"; // default

  // Gender
  String? gender;

  // Form key
  final formKey = GlobalKey<FormState>();

  // MODEL OBJECT TO STORE FINAL SUBMITTED DATA
  SignupModel? signupData;

  // Validators
  String? validateName(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) {
      return l10n.enterfirstname;
    }
    return null;
  }
  // String? validateMobile(String? v, AppLocalizations l10n) {
  //   if (v == null || v.trim().isEmpty) {
  //     return l10n.enterMobile;
  //   }

  //   if (!RegExp(r'^[0-9]{8}$').hasMatch(v)) {
  //     return l10n.mobileMustBe8Digits;
  //   }

  //   if (RegExp(r'^(\d)\1{7}$').hasMatch(v)) {
  //     return "Please enter a valid mobile number";
  //   }

  //   if (!RegExp(r'^[367]\d{7}$').hasMatch(v)) {
  //     return "Please enter a valid Bahrain mobile number";
  //   }

  //   return null;
  // }
  String? validateMobile(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.enterMobile;
    if (v.length != 8) return l10n.mobileMustBe8Digits;
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return l10n.onlyDigitsAllowed;
    if (v == '00000000') return l10n.invalidMobileNumber;
    return null;
  }

  String? validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return l10n.enterEmail;
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return l10n.enterValidEmail;
    }

    return null;
  }

  /// Password validation
  String? validatePassword(String? value, AppLocalizations l10n) {
    return Validators.password(value, l10n);
  }

  String? validateConfirmPassword(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) {
      return l10n.enterConfirmPassword;
    }
    if (v != password.text) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  String? validateGender(String? v, AppLocalizations l10n) {
    return v == null ? l10n.selectGender : null;
  }

  // Save all the data into a model
  void saveToModel() {
    signupData = SignupModel(
      accountType: accountType,
      firstName: firstName.text.trim(),
      secondName: secondName.text.trim(),
      thirdName: thirdName.text.trim(),
      fourthName: fourthName.text.trim(),
      mobileNumber: mobile.text.trim(),
      email: email.text.trim(),
      gender: gender?.toLowerCase() ?? "",
      password: password.text.trim(),
    );
  }
}
