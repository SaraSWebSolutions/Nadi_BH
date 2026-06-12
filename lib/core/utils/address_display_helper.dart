import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class AddressDisplayHelper {
  static String sourceLabel(
    AddressSource? source, {
    required AppLocalizations l10n,
  }) {
    switch (source) {
      case AddressSource.familyHeader:
        return l10n.familyHeaderAddressLabel;
      case AddressSource.currentLocation:
        return l10n.currentLocationLabel;
      case AddressSource.manual:
        return l10n.manualAddressLabel;
      default:
        return l10n.genericAddressLabel;
    }
  }

  static bool isGeoAddress(Map<String, dynamic> address) {
    return AddressController.isGeoAddressMap(address);
  }

  static AddressSource? resolveSource(Map<String, dynamic> address) {
    final explicit = AddressController.parseSource(address['addressSource']);
    if (explicit != null) return explicit;
    return _inferLegacySource(address);
  }

  static AddressSource? _inferLegacySource(Map<String, dynamic> address) {
    if (AddressController.parseIsGeoAddress(address['isGeoAddress'])) {
      return AddressSource.currentLocation;
    }

    final hasLocation =
        address['latitude'] != null &&
        address['longitude'] != null &&
        ((address['geoAddress'] ??
                    address['currentLocationAddress'] ??
                    address['fullAddress'] ??
                    '')
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

  static String formatProfileAddress(
    Map<String, dynamic> address, {
    required AppLocalizations l10n,
  }) {
    if (isGeoAddress(address)) {
      return (address['geoAddress'] ??
              address['currentLocationAddress'] ??
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
      add(l10n.cityWithValue(address['city'].toString()));
    }

    add(l10n.buildingWithValue(address['building']?.toString() ?? ''));

    if ((address['aptNo'] ?? '').toString().isNotEmpty) {
      add(l10n.apartmentWithValue(address['aptNo'].toString()));
    }

    if ((address['floor'] ?? '').toString().isNotEmpty) {
      add(l10n.floorWithValue(address['floor'].toString()));
    }

    if (address['blockId'] is Map) {
      add(
        l10n.blockWithValue(
          (address['blockId']['name'] ?? '').toString(),
        ),
      );
    } else {
      add(
        l10n.blockWithValue(
          (address['blockName'] ?? address['block'] ?? '').toString(),
        ),
      );
    }

    if (address['roadId'] is Map) {
      add(
        l10n.roadWithValue(
          (address['roadId']['name'] ?? '').toString(),
        ),
      );
    } else {
      add(
        l10n.roadWithValue(
          (address['roadName'] ?? address['road'] ?? '').toString(),
        ),
      );
    }

    add('${address['additionalInfo'] ?? ''}');

    return parts.where((e) => e.trim().isNotEmpty).join(', ');
  }
}
