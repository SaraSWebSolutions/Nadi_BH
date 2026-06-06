// import 'package:flutter/material.dart';
// import 'package:nadi_user_app/l10n/app_localizations.dart';

// class AddressController {
//   TextEditingController building = TextEditingController();
//   TextEditingController city = TextEditingController();
//   TextEditingController aptNo = TextEditingController();
//   TextEditingController floor = TextEditingController();
//   String? block;
//   String? blockId;

//   String? road;
//   String? roadId;

//   List<Map<String, dynamic>> roadsForSelectedBlock = [];

//   /// For debugging / local use
//   Map<String, dynamic> getAddressData() {
//     return {
//       "roadId": roadId,
//       "roadName": road,
//       "blockId": blockId,
//       "blockName": block,
//       "city": city.text,
//       "building": building.text,
//       "aptNo": aptNo.text,
//       "floor": floor.text,
//     };
//   }

//   void clear() {
//     city.clear();
//     floor.clear();
//     building.clear();
//     aptNo.clear();

//     // ✅ reset dropdown values
//     block = null;
//     blockId = null;

//     road = null;
//     roadId = null;

//     // ✅ clear dependent dropdown list
//     roadsForSelectedBlock = [];
//   }

//   void loadAddress(Map<String, dynamic> address) {
//     city.text = address["city"] ?? "";
//     building.text = address["building"] ?? "";
//     aptNo.text = address["aptNo"] ?? "";
//     floor.text = address["floor"] ?? "";

//     blockId = address["blockId"];
//     roadId = address["roadId"];

//     /// OPTIONAL
//     block = address["block"];
//     road = address["road"];
//   }

//   Map<String, dynamic> getOnlyAddressMap({required String addressType}) {
//     return {
//       "city": city.text,
//       "addressType": addressType,
//       "floor": floor.text,
//       "building": building.text,
//       "aptNo": aptNo.text,
//       "roadId": roadId,
//       "road": road,
//       "blockId": blockId,
//       "block": block, // ✅ ADD THIS
//     };
//   }

//   Map<String, dynamic> getApiAddressBody({
//     required String userId,
//     required String addressType, // flat / villa / office
//   }) {
//     return {
//       "userId": userId,
//       "address": {
//         "addressType": addressType,
//         "city": city.text,
//         "building": building.text,
//         "aptNo": aptNo.text,
//         "floor": floor.text,
//         "roadId": roadId,
//         "blockId": blockId,
//       },
//     };
//   }

//   // Validators
//   String? validateBuilding(String? val, AppLocalizations l10n) =>
//       (val == null || val.isEmpty) ? l10n.enteryour_build : null;

//   String? validateAptNo(String? val, AppLocalizations l10n) =>
//       (val == null || val.isEmpty) ? l10n.enteraptno : null;

//   String? validateFloor(String? val, AppLocalizations l10n) =>
//       (val == null || val.isEmpty) ? l10n.enterFloorno : null;
// }

import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class AddressController {
  // Text Fields
  final TextEditingController building = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController aptNo = TextEditingController();
  final TextEditingController floor = TextEditingController();

  // Dropdown Values
  String? block;
  String? blockId;

  String? road;
  String? roadId;

  // Location Data
  double? latitude;
  double? longitude;

  String? fullAddress;

  // Roads
  List<Map<String, dynamic>> roadsForSelectedBlock = [];

  /// =========================
  /// CLEAR (ONLY ONE VERSION)
  /// =========================
  void clear() {
    city.clear();
    building.clear();
    aptNo.clear();
    floor.clear();

    block = null;
    blockId = null;

    road = null;
    roadId = null;

    latitude = null;
    longitude = null;

    fullAddress = null;

    roadsForSelectedBlock.clear();
  }

  /// =========================
  /// DISPOSE
  /// =========================
  void dispose() {
    city.dispose();
    building.dispose();
    aptNo.dispose();
    floor.dispose();
  }

  /// =========================
  /// LOAD ADDRESS
  /// =========================
  void loadAddress(Map<String, dynamic> address) {
    city.text = address["city"] ?? "";
    building.text = address["building"] ?? "";
    aptNo.text = address["aptNo"] ?? "";
    floor.text = address["floor"] ?? "";

    block = address["block"];
    blockId = address["blockId"];

    road = address["road"];
    roadId = address["roadId"];

    latitude = address["latitude"];
    longitude = address["longitude"];

    fullAddress = address["fullAddress"];
  }

  Map<String, dynamic> getOnlyAddressMap({required String addressType}) {
    return {
      "addressType": addressType,

      "city": city.text.trim(),
      "building": building.text.trim(),
      "aptNo": aptNo.text.trim().isEmpty ? null : aptNo.text.trim(),
      "floor": floor.text.trim().isEmpty ? null : floor.text.trim(),

      "block": block,
      "blockId": blockId,

      "road": road,
      "roadId": roadId,

      "latitude": latitude,
      "longitude": longitude,

      "fullAddress": fullAddress,
    };
  }

  /// =========================
  /// API BODY
  /// =========================
  Map<String, dynamic> getApiAddressBody({
    required String userId,
    required String addressType,
  }) {
    return {
      "userId": userId,
      "address": {
        "addressType": addressType,
        "city": city.text.trim(),
        "building": building.text.trim(),
        "aptNo": aptNo.text.trim(),
        "floor": floor.text.trim(),
        "blockId": blockId,
        "roadId": roadId,
        "block": block,
        "road": road,
        "latitude": latitude,
        "longitude": longitude,
        "fullAddress": fullAddress,
      },
    };
  }

  /// =========================
  /// VALIDATORS
  /// =========================
  String? validateBuilding(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enteryour_build;
    }
    return null;
  }

  String? validateAptNo(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enteraptno;
    }
    return null;
  }

  String? validateFloor(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enterFloorno;
    }
    return null;
  }
}
