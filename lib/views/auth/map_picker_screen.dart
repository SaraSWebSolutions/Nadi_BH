import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/models/location_result.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

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
    _loadCurrentLocation();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Select Location",
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

              inputDecoration: const InputDecoration(
                hintText: "Search Address",
                prefixIcon: Icon(Icons.search),
              ),

              debounceTime: 600,

              countries: const ["bh"], // Bahrain only

              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (prediction) async {
                final lat = double.parse(prediction.lat!);
                final lng = double.parse(prediction.lng!);

                selectedLatLng = LatLng(lat, lng);

                selectedPlaceName = prediction.description ?? "";

                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(selectedLatLng!, 17),
                );

                setState(() {});
              },

              itemClick: (prediction) {},
            ),
          ),

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

                // Clear searched location name
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (selectedPlaceName.isNotEmpty) ...[
                Text(
                  selectedPlaceName.isNotEmpty ? selectedPlaceName : address,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),

                // ] else ...[
                //   Text(
                //     address,
                //     style: const TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 16,
                //     ),
                //   ),
                // ],
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmLocation,
                    child: const Text("Confirm Location"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
