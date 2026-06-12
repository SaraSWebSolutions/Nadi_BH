import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/models/location_result.dart';

enum AddressSource {
  familyHeader,
  currentLocation,
  manual,
}

class AddressController {
  final TextEditingController building = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController aptNo = TextEditingController();
  final TextEditingController floor = TextEditingController();

  String? block;
  String? blockId;
  String? road;
  String? roadId;

  double? latitude;
  double? longitude;
  String? fullAddress;
  AddressSource? addressSource;

  List<Map<String, dynamic>> roadsForSelectedBlock = [];

  static AddressSource? parseSource(dynamic value) {
    switch (value?.toString()) {
      case 'family_header':
      case 'familyHeader':
        return AddressSource.familyHeader;
      case 'current_location':
      case 'currentLocation':
        return AddressSource.currentLocation;
      case 'manual':
        return AddressSource.manual;
      default:
        return null;
    }
  }

  static String sourceToApiValue(AddressSource? source) {
    switch (source) {
      case AddressSource.familyHeader:
        return 'family_header';
      case AddressSource.currentLocation:
        return 'current_location';
      case AddressSource.manual:
        return 'manual';
      default:
        return 'manual';
    }
  }

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

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
    addressSource = null;
    roadsForSelectedBlock.clear();
  }

  void dispose() {
    city.dispose();
    building.dispose();
    aptNo.dispose();
    floor.dispose();
  }

  void loadAddress(Map<String, dynamic> address) {
    city.text = address['city']?.toString() ?? '';
    building.text = address['building']?.toString() ?? '';
    aptNo.text = address['aptNo']?.toString() ?? '';
    floor.text = address['floor']?.toString() ?? '';

    block = address['block'] ?? address['blockName'];
    blockId = _extractId(address['blockId']);
    road = address['road'] ?? address['roadName'];
    roadId = _extractId(address['roadId']);

    latitude = toDouble(address['latitude']);
    longitude = toDouble(address['longitude']);
    fullAddress =
        address['currentLocationAddress']?.toString() ??
        address['fullAddress']?.toString();

    addressSource =
        parseSource(address['addressSource']) ??
        (fullAddress != null &&
                latitude != null &&
                longitude != null &&
                building.text.trim().isEmpty &&
                blockId == null
            ? AddressSource.currentLocation
            : null);

    roadsForSelectedBlock = List<Map<String, dynamic>>.from(
      address['roads'] ?? [],
    );
  }

  String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['_id']?.toString();
    return value.toString();
  }

  void applyFamilyHeader(Map<String, dynamic> address) {
    loadAddress(address);
    addressSource = AddressSource.familyHeader;
  }

  void applyCurrentLocation(LocationResult result) {
    clearManualFields();
    addressSource = AddressSource.currentLocation;
    latitude = result.latitude;
    longitude = result.longitude;
    fullAddress = result.fullAddress;
  }

  void applyManualEntry() {
    clear();
    addressSource = AddressSource.manual;
  }

  void clearManualFields() {
    city.clear();
    building.clear();
    aptNo.clear();
    floor.clear();
    block = null;
    blockId = null;
    road = null;
    roadId = null;
    roadsForSelectedBlock.clear();
  }

  bool get isComplete {
    switch (addressSource) {
      case AddressSource.currentLocation:
        return latitude != null &&
            longitude != null &&
            (fullAddress?.trim().isNotEmpty ?? false);
      case AddressSource.familyHeader:
      case AddressSource.manual:
        return city.text.trim().isNotEmpty &&
            building.text.trim().isNotEmpty &&
            blockId != null &&
            roadId != null;
      default:
        return false;
    }
  }

  bool get isReadOnly => addressSource == AddressSource.familyHeader;

  bool get showsManualForm =>
      addressSource == AddressSource.familyHeader ||
      addressSource == AddressSource.manual;

  bool get showsLocationCard =>
      addressSource == AddressSource.currentLocation &&
      (fullAddress?.trim().isNotEmpty ?? false);

  Map<String, dynamic> toMap({
    String? blockNameOverride,
    String? roadNameOverride,
  }) {
    return {
      'addressSource': sourceToApiValue(addressSource),
      'city': city.text.trim(),
      'building': building.text.trim(),
      'aptNo': aptNo.text.trim(),
      'floor': floor.text.trim(),
      'block': block,
      'blockId': blockId,
      'road': road,
      'roadId': roadId,
      'blockName': blockNameOverride ?? block,
      'roadName': roadNameOverride ?? road,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
      'currentLocationAddress': fullAddress,
      'roads': roadsForSelectedBlock,
    };
  }

  Map<String, dynamic> getOnlyAddressMap({required String addressType}) {
    final map = toMap();
    map['addressType'] = addressType;
    return map;
  }

  Map<String, dynamic> getApiAddressBody({
    required String userId,
    required String addressType,
    String? blockNameOverride,
    String? roadNameOverride,
  }) {
    final address = <String, dynamic>{
      'addressType': addressType,
      'addressSource': sourceToApiValue(addressSource),
    };

    switch (addressSource) {
      case AddressSource.currentLocation:
        address.addAll({
          'currentLocationAddress': fullAddress,
          'latitude': latitude,
          'longitude': longitude,
          'fullAddress': fullAddress,
        });
        break;
      case AddressSource.familyHeader:
      case AddressSource.manual:
        address.addAll({
          'city': city.text.trim(),
          'building': building.text.trim(),
          'aptNo': aptNo.text.trim(),
          'floor': floor.text.trim(),
          'blockId': blockId,
          'roadId': roadId,
          'block': block,
          'road': road,
          'blockName': blockNameOverride ?? block,
          'roadName': roadNameOverride ?? road,
          'latitude': latitude,
          'longitude': longitude,
          'fullAddress': fullAddress,
        });
        break;
      default:
        break;
    }

    return {'userId': userId, 'address': address};
  }

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
