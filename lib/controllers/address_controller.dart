import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class AddressController {
  TextEditingController building = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController aptNo = TextEditingController();
  TextEditingController floor = TextEditingController();
String? block;
String? blockId;

String? road;
String? roadId;

List<Map<String, dynamic>> roadsForSelectedBlock = [];

  /// For debugging / local use
  Map<String, dynamic> getAddressData() {
    return {
      "roadId": roadId,
      "roadName": road,
      "blockId": blockId,
      "blockName": block,
      "city": city.text,
      "building": building.text,
      "aptNo": aptNo.text,
      "floor": floor.text,
    };
  }
  void clear() {
  city.clear();
  floor.clear();
  building.clear();
  aptNo.clear();

  // ✅ reset dropdown values
  block = null;
  blockId = null;

  road = null;
  roadId = null;

  // ✅ clear dependent dropdown list
  roadsForSelectedBlock = [];
}
  Map<String, dynamic> getOnlyAddressMap({
    required String addressType,
  }) {
    return {
      "city": city.text,
      "addressType": addressType,
      "floor": floor.text,
      "building": building.text,
      "aptNo": aptNo.text,
      "roadId": roadId,
      "blockId": blockId,
    };
  }

  Map<String, dynamic> getApiAddressBody({
    required String userId,
    required String addressType, // flat / villa / office
  }) {
    return {
      "userId": userId,
      "address": {
        "addressType": addressType,
        "city": city.text,
        "building": building.text,
        "aptNo": aptNo.text,
        "floor": floor.text,
        "roadId": roadId,
        "blockId": blockId,
      }
    };
  }

  // Validators
  String? validateBuilding(String? val, AppLocalizations l10n) =>
      (val == null || val.isEmpty) ? l10n.requiredField : null;

  String? validateAptNo(String? val, AppLocalizations l10n) =>
      (val == null || val.isEmpty) ? l10n.requiredField : null;

  String? validateFloor(String? val, AppLocalizations l10n) =>
      (val == null || val.isEmpty) ? l10n.requiredField : null;
}
