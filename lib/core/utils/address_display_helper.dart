import 'package:nadi_user_app/controllers/address_controller.dart';

class AddressDisplayHelper {
  static String sourceLabel(AddressSource? source) {
    switch (source) {
      case AddressSource.familyHeader:
        return 'Family Header Address';
      case AddressSource.currentLocation:
        return 'Current Location';
      case AddressSource.manual:
        return 'Manual Address';
      default:
        return 'Address';
    }
  }

  static AddressSource? resolveSource(Map<String, dynamic> address) {
    return AddressController.parseSource(address['addressSource']) ??
        _inferLegacySource(address);
  }

  static AddressSource? _inferLegacySource(Map<String, dynamic> address) {
    final hasLocation =
        address['latitude'] != null &&
        address['longitude'] != null &&
        ((address['currentLocationAddress'] ?? address['fullAddress'] ?? '')
                .toString()
                .trim()
                .isNotEmpty);

    final hasManual =
        (address['building'] ?? '').toString().trim().isNotEmpty &&
        (address['blockId'] != null || address['blockName'] != null);

    if (hasLocation && !hasManual) {
      return AddressSource.currentLocation;
    }
    if (hasManual) {
      return AddressSource.manual;
    }
    return null;
  }

  static String formatProfileAddress(Map<String, dynamic> address) {
    final source = resolveSource(address);

    if (source == AddressSource.currentLocation) {
      return (address['currentLocationAddress'] ??
              address['fullAddress'] ??
              '')
          .toString()
          .trim();
    }

    final parts = <String>[];

    void add(String value) {
      if (value.trim().isNotEmpty) parts.add(value.trim());
    }

    if ((address['city'] ?? '').toString().isNotEmpty) {
      add('City ${address['city']}');
    }

    add('Building ${address['building'] ?? ''}');

    if ((address['aptNo'] ?? '').toString().isNotEmpty) {
      add('Apartment ${address['aptNo']}');
    }

    if ((address['floor'] ?? '').toString().isNotEmpty) {
      add('Floor ${address['floor']}');
    }

    if (address['blockId'] is Map) {
      add('Block ${address['blockId']['name'] ?? ''}');
    } else {
      add('Block ${address['blockName'] ?? address['block'] ?? ''}');
    }

    if (address['roadId'] is Map) {
      add('Road ${address['roadId']['name'] ?? ''}');
    } else {
      add('Road ${address['roadName'] ?? address['road'] ?? ''}');
    }

    add('${address['additionalInfo'] ?? ''}');

    return parts.where((e) => e.trim().isNotEmpty).join(', ');
  }
}
