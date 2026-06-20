import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/utils/validators.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class FamilyMemberController {
  final familyCount = TextEditingController();
  final fullName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String? relation;
  String? gender;

  //Validation

  String? validatefamilycount(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.enterFamilyCount;
    }
    return null;
  }

  String? validatepassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.enterPassword;
    }
    return null;
  }

  String? validatefullname(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.enter_memberFullName;
    }
    return null;
  }

  String? validatemobilenumber(String? value, AppLocalizations l10n) {
    return Validators.phoneNumber(value, l10n);
  }

  String? validateemail(String? value, AppLocalizations l10n) {
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
  // String? validateemail(String? value, AppLocalizations l10n) {
  //   return Validators.email(value, l10n);
  // }

  Map<String, dynamic> getApiFamilyMemberBody({
    required String userId,
    required Map<String, dynamic>? address,
  }) {
    return {
      "userId": userId,
      "familyCount": familyCount.text,
      "fullName": fullName.text,
      "relation": relation?.toLowerCase(),
      "mobile": mobile.text,
      "email": email.text,
      "password": password.text,
      "gender": gender?.toLowerCase(),
      "address": address,
    };
  }
}
