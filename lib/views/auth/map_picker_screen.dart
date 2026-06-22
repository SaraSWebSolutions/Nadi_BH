import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/models/location_result.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

class MapPickerScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? savedAddress;
  const MapPickerScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.savedAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? mapController;

  LatLng? selectedLatLng;

  String address = "";
  String selectedPlaceName = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.latitude != null && widget.longitude != null) {
      selectedLatLng = LatLng(widget.latitude!, widget.longitude!);

      address = widget.savedAddress ?? "";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      _loadCurrentLocation();
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      selectedLatLng = LatLng(position.latitude, position.longitude);

      await _reverseGeocode();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Location Error: $e");

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _reverseGeocode() async {
    final placemarks = await placemarkFromCoordinates(
      selectedLatLng!.latitude,
      selectedLatLng!.longitude,
    );

    if (placemarks.isEmpty) return;

    final place = placemarks.first;

    final parts = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((e) => e != null && e.toString().trim().isNotEmpty);

    address = parts.join(", ");
  }

  //   Future<void> _reverseGeocode() async {
  //     final placemarks = await placemarkFromCoordinates(
  //       selectedLatLng!.latitude,
  //       selectedLatLng!.longitude,
  //     );

  //     if (placemarks.isEmpty) return;

  //     final place = placemarks.first;

  //     final building = place.name ?? "";
  //     final road = place.street ?? "";
  //     final block = place.subLocality ?? "";
  //     final city = place.locality ?? "";

  //     address =
  //         '''
  // Building: $building
  // Road: $road
  // Block: $block
  // City: $city
  // ''';

  //     debugPrint("Building: $building");
  //     debugPrint("Road: $road");
  //     debugPrint("Block: $block");
  //     debugPrint("City: $city");
  //   }

  Future<void> _confirmLocation() async {
    final placemarks = await placemarkFromCoordinates(
      selectedLatLng!.latitude,
      selectedLatLng!.longitude,
    );

    final place = placemarks.first;

    Navigator.pop(
      context,
      LocationResult(
        latitude: selectedLatLng!.latitude,
        longitude: selectedLatLng!.longitude,
        fullAddress: selectedPlaceName.isNotEmpty ? selectedPlaceName : address,
        city: place.locality ?? "",
        block: place.subLocality ?? "",
        road: place.street ?? "",
        building: place.name ?? "",
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.selectLocation,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),

        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: AppCircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: "AIzaSyAX0FMPV_cS4VOBRoJTKgw3SttVjKBeu6I",

              inputDecoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,

                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),

                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),

              debounceTime: 600,
              countries: const ["bh"],
              isLatLngRequired: true,

              getPlaceDetailWithLatLng: (prediction) async {
                final lat = double.parse(prediction.lat!);
                final lng = double.parse(prediction.lng!);

                selectedLatLng = LatLng(lat, lng);
                selectedPlaceName = prediction.description ?? "";

                await _reverseGeocode();

                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(selectedLatLng!, 17),
                );

                setState(() {});
              },

              itemClick: (prediction) {},
            ),
          ), // <-- Padding closed here

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLatLng!,
                zoom: 16,
              ),
              myLocationEnabled: true,
              onMapCreated: (controller) {
                mapController = controller;
              },
              onTap: (latLng) async {
                selectedLatLng = latLng;
                selectedPlaceName = "";

                await _reverseGeocode();

                setState(() {});
              },
              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: selectedLatLng!,
                ),
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPlaceName.isNotEmpty ? selectedPlaceName : address,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmLocation,
                    child: Text(AppLocalizations.of(context)!.confirmLocation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      //       body: Column(
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.all(16),
      //             child: GooglePlaceAutoCompleteTextField(
      //   textEditingController: _searchController,
      //               googleAPIKey: "AIzaSyAX0FMPV_cS4VOBRoJTKgw3SttVjKBeu6I",

      //   inputDecoration: InputDecoration(
      //     isDense: true,
      //     contentPadding: const EdgeInsets.symmetric(
      //       vertical: 14,
      //       horizontal: 12,
      //     ),

      //     filled: true,
      //     fillColor: theme.colorScheme.surface,

      //     // hintText: AppLocalizations.of(context)!.searchLocation,
      //     hintStyle: TextStyle(
      //       color: theme.colorScheme.onSurfaceVariant,
      //     ),

      //     prefixIcon: Icon(
      //       Icons.search,
      //       color: theme.colorScheme.onSurfaceVariant,
      //     ),

      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: BorderSide(
      //         color: theme.colorScheme.outline,
      //       ),
      //     ),

      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: BorderSide(
      //         color: theme.colorScheme.outline,
      //       ),
      //     ),

      //     focusedBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: BorderSide(
      //         color: theme.colorScheme.primary,
      //         width: 1.5,
      //       ),
      //     ),
      //   ),

      //   debounceTime: 600,
      //   countries: const ["bh"],
      //   isLatLngRequired: true,

      //   getPlaceDetailWithLatLng: (prediction) async {
      //     final lat = double.parse(prediction.lat!);
      //     final lng = double.parse(prediction.lng!);

      //     selectedLatLng = LatLng(lat, lng);
      //     selectedPlaceName = prediction.description ?? "";

      //     await _reverseGeocode();

      //     mapController?.animateCamera(
      //       CameraUpdate.newLatLngZoom(selectedLatLng!, 17),
      //     );

      //     setState(() {});
      //   },
      //   itemClick: (prediction) {},
      // ),

      //           Expanded(
      //             child: GoogleMap(
      //               initialCameraPosition: CameraPosition(
      //                 target: selectedLatLng!,
      //                 zoom: 16,
      //               ),
      //               myLocationEnabled: true,
      //               onMapCreated: (controller) {
      //                 mapController = controller;
      //               },
      //               onTap: (latLng) async {
      //                 selectedLatLng = latLng;

      //                 // Clear searched location name
      //                 selectedPlaceName = "";

      //                 await _reverseGeocode();

      //                 setState(() {});
      //               },
      //               markers: {
      //                 Marker(
      //                   markerId: const MarkerId("selected"),
      //                   position: selectedLatLng!,
      //                 ),
      //               },
      //             ),
      //           ),

      //           Container(
      //             padding: const EdgeInsets.all(16),
      //              decoration: BoxDecoration(
      //     color: Theme.of(context).colorScheme.surface,
      //     border: Border(
      //       top: BorderSide(
      //         color: Theme.of(context).colorScheme.outline,
      //       ),
      //     ),
      //   ),
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 // if (selectedPlaceName.isNotEmpty) ...[
      //                 Text(
      //                   selectedPlaceName.isNotEmpty ? selectedPlaceName : address,
      //                   style:  TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 16,
      //                               color: Theme.of(context).colorScheme.onSurface,

      //                   ),
      //                 ),
      //                 const SizedBox(height: 4),

      //                 // ] else ...[
      //                 //   Text(
      //                 //     address,
      //                 //     style: const TextStyle(
      //                 //       fontWeight: FontWeight.bold,
      //                 //       fontSize: 16,
      //                 //     ),
      //                 //   ),
      //                 // ],
      //                 const SizedBox(height: 16),

      //                 SizedBox(
      //                   width: double.infinity,
      //                   child: ElevatedButton(
      //                     onPressed: _confirmLocation,
      //                     child: Text(AppLocalizations.of(context)!.confirmLocation),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           ),
      //         ],
      //       ),
    );
  }
}
