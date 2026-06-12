import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/models/location_result.dart';

enum AddressSource { familyHeader, currentLocation, manual }

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
  bool isGeoAddress = false;
  String? geoAddress;
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
    if (value == null || value == '') return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool parseIsGeoAddress(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  static bool toBool(dynamic value) => parseIsGeoAddress(value);

  /// Never send empty string ObjectIds to the backend.
  static String? sanitizeId(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return sanitizeId(value['_id']);
    }
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  bool get isGeoMode =>
      isGeoAddress &&
      (addressSource == AddressSource.currentLocation ||
          addressSource == AddressSource.familyHeader);

  bool get isManualMode =>
      addressSource == AddressSource.manual ||
      (addressSource == AddressSource.familyHeader && !isGeoAddress);

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
    isGeoAddress = false;
    geoAddress = null;
    addressSource = null;
    roadsForSelectedBlock.clear();
  }

  void dispose() {
    city.dispose();
    building.dispose();
    aptNo.dispose();
    floor.dispose();
  }

  void _clearManualFields() {
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

  void loadAddress(Map<String, dynamic> address) {
    isGeoAddress = parseIsGeoAddress(address['isGeoAddress']);
    geoAddress =
        address['geoAddress']?.toString() ??
        address['currentLocationAddress']?.toString() ??
        address['fullAddress']?.toString();
    fullAddress = geoAddress;

    latitude = toDouble(address['latitude']);
    longitude = toDouble(address['longitude']);

    addressSource = parseSource(address['addressSource']);
    if (addressSource == null) {
      if (isGeoAddress) {
        addressSource = AddressSource.currentLocation;
      } else if ((address['building'] ?? '').toString().trim().isNotEmpty) {
        addressSource = AddressSource.manual;
      }
    }

    if (isGeoMode) {
      _clearManualFields();
      return;
    }

    city.text = address['city']?.toString() ?? '';
    building.text = address['building']?.toString() ?? '';
    aptNo.text = address['aptNo']?.toString() ?? '';
    floor.text = address['floor']?.toString() ?? '';
    block = address['block'] ?? address['blockName'];
    blockId = sanitizeId(address['blockId']);
    road = address['road'] ?? address['roadName'];
    roadId = sanitizeId(address['roadId']);

    roadsForSelectedBlock = List<Map<String, dynamic>>.from(
      address['roads'] ?? [],
    );
  }

  void applyFamilyHeader(Map<String, dynamic> address) {
    loadAddress(address);
    addressSource = AddressSource.familyHeader;

    if (isGeoAddress) {
      _clearManualFields();
    }
  }

  void applyCurrentLocation(LocationResult result) {
    addressSource = AddressSource.currentLocation;
    latitude = result.latitude;
    longitude = result.longitude;
    fullAddress = result.fullAddress;
    geoAddress = result.fullAddress;
    isGeoAddress = true;
    _clearManualFields();
  }

  void applyManualEntry() {
    clear();
    addressSource = AddressSource.manual;
    isGeoAddress = false;
    geoAddress = null;
    latitude = null;
    longitude = null;
  }

  bool get isComplete {
    if (isGeoMode) {
      return latitude != null &&
          longitude != null &&
          isGeoAddress &&
          (geoAddress?.trim().isNotEmpty ?? false);
    }

    if (isManualMode) {
      return city.text.trim().isNotEmpty &&
          building.text.trim().isNotEmpty &&
          sanitizeId(blockId) != null &&
          sanitizeId(roadId) != null;
    }

    return false;
  }

  bool get isReadOnly => addressSource == AddressSource.familyHeader;

  bool get showsManualForm => isManualMode && addressSource != null;

  bool get showsLocationCard => isGeoMode && (geoAddress?.trim().isNotEmpty ?? false);

  Map<String, dynamic> buildAddressPayload({
    required String addressType,
    String? blockNameOverride,
    String? roadNameOverride,
  }) {
    final sanitizedBlockId = sanitizeId(blockId);
    final sanitizedRoadId = sanitizeId(roadId);
    final resolvedBlockName = blockNameOverride ?? block;
    final resolvedRoadName = roadNameOverride ?? road;

    final payload = <String, dynamic>{
      'addressType': addressType,
      'addressSource': sourceToApiValue(addressSource),
      'latitude': latitude,
      'longitude': longitude,
      'isGeoAddress': isGeoAddress,
      'geoAddress': isGeoAddress ? (geoAddress ?? '') : '',
      'fullAddress': fullAddress ?? geoAddress ?? '',
      'currentLocationAddress': isGeoAddress ? (geoAddress ?? '') : '',
    };

    if (isGeoMode) {
      payload.addAll({
        'blockId': null,
        'roadId': null,
        'city': '',
        'building': '',
        'aptNo': '',
        'floor': '',
        'block': null,
        'road': null,
        'blockName': null,
        'roadName': null,
      });
      return payload;
    }

    payload.addAll({
      'city': city.text.trim(),
      'building': building.text.trim(),
      'aptNo': aptNo.text.trim(),
      'floor': floor.text.trim(),
      'block': block,
      'blockId': sanitizedBlockId,
      'road': road,
      'roadId': sanitizedRoadId,
      'blockName': resolvedBlockName,
      'roadName': resolvedRoadName,
    });

    return payload;
  }

  Map<String, dynamic> toMap({
    String? blockNameOverride,
    String? roadNameOverride,
  }) {
    final payload = buildAddressPayload(
      addressType: 'flat',
      blockNameOverride: blockNameOverride,
      roadNameOverride: roadNameOverride,
    );
    payload['roads'] = roadsForSelectedBlock;
    return payload;
  }

  Map<String, dynamic> getOnlyAddressMap({required String addressType}) {
    return buildAddressPayload(addressType: addressType);
  }

  Map<String, dynamic> getApiAddressBody({
    required String userId,
    required String addressType,
    String? blockNameOverride,
    String? roadNameOverride,
  }) {
    return {
      'userId': userId,
      'address': buildAddressPayload(
        addressType: addressType,
        blockNameOverride: blockNameOverride,
        roadNameOverride: roadNameOverride,
      ),
    };
  }

  static Map<String, dynamic> mapToApiAddress(
    Map<String, dynamic> address, {
    String addressType = 'home',
  }) {
    final controller = AddressController();
    controller.loadAddress(address);
    return controller.buildAddressPayload(addressType: addressType);
  }

  static bool isGeoAddressMap(Map<String, dynamic> address) {
    if (parseIsGeoAddress(address['isGeoAddress'])) return true;
    final source = parseSource(address['addressSource']);
    return source == AddressSource.currentLocation;
  }

  static bool isAddressDataComplete(Map<String, dynamic> address) {
    if (isGeoAddressMap(address)) {
      return toDouble(address['latitude']) != null &&
          toDouble(address['longitude']) != null &&
          (address['geoAddress'] ??
                  address['currentLocationAddress'] ??
                  address['fullAddress'] ??
                  '')
              .toString()
              .trim()
              .isNotEmpty;
    }

    final blockId = sanitizeId(address['blockId']);
    final roadId = sanitizeId(address['roadId']);

    return (address['building'] ?? '').toString().trim().isNotEmpty &&
        blockId != null &&
        roadId != null;
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
