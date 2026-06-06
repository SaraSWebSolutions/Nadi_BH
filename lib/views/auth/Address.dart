import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/auth_Provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

class Address extends StatefulWidget {
  final String accountType;
  final VoidCallback? onNext;
  final VoidCallback? onChanged;
  final bool family;
  final GlobalKey<FormState> formKey;
  final AddressController controller;
  const Address({
    super.key,
    required this.accountType,
    this.onNext,
    this.family = false,
    required this.formKey,
    required this.controller,
    this.onChanged, // ✅ ADD THIS
  });

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  String selected = "Flat";
  bool _isLoading = false;
  bool _hideBottomButton = false;
  bool get showButton {
    return controller.city.text.isNotEmpty &&
        controller.building.text.isNotEmpty &&
        controller.block != null &&
        controller.road != null;
  }

  // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _adressservice = AuthService();
  AddressController get controller => widget.controller;
  @override
  void _resetAll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clear();

      setState(() {
        selected = "Flat";
        _isLoading = false;
        // _formKey = GlobalKey<FormState>(); // clears validation UI
      });
    });
  }

  Future<void> familyAccount(BuildContext context) async {
    final userId = await AppPreferences.getUserId();

    if (userId == null) {
      AppLogger.info(" USER ID IS NULL");
      return;
    }

    final body = controller.getApiAddressBody(
      userId: userId,
      addressType: selected.toLowerCase(),
    );

    // debugPrint(" API BODY  $body");
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = true);
    });

    try {
      final response = await _adressservice.adressdetails(body: body);
      // API finished
      if (mounted) setState(() => _isLoading = false);

      if (response != null) {
        if (widget.accountType == "Family") {
          widget.onNext?.call();
        } else {
          if (!context.mounted) return;

          /// ✅ CLEAR ALL FIELDS HERE
          controller.city.clear();
          controller.building.clear();
          controller.aptNo.clear();
          controller.floor.clear();

          controller.block = null;
          controller.blockId = null;

          controller.road = null;
          controller.roadId = null;

          controller.roadsForSelectedBlock = [];

          setState(() {
            _hideBottomButton = true;
            // _formKey = GlobalKey<FormState>(); // 🔥 clears validation errors
          });

          _resetAll();

          SnackbarHelper.ShowSuccess(
            context,
            AppLocalizations.of(context)!.accountCreatedSuccessfully,
          );
          //_resetAll();
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) context.push(RouteNames.accountverfy);
          });
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      SnackbarHelper.showError(
        context,
        "${AppLocalizations.of(context)!.submitFailed}: $e",
      );
    }
  }

  void _onAddressChanged() {
    if (_hideBottomButton) {
      setState(() {
        _hideBottomButton = false;
      });
    }

    widget.onChanged?.call();
  }

  Widget buildType(String type, String icon) {
    final bool isSelected = selected == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = type;

            if (type == "Villa") {
              controller.aptNo.clear();
              controller.floor.clear();
            }
          });
        },
        child: Container(
          height: 58, // ✅ fixed height
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.btn_primery
                : Theme.of(context).colorScheme.surface,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: isSelected ? AppColors.btn_primery : Colors.grey.shade300,
            ),
          ),

          child: Center(
            // ✅ IMPORTANT
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX
              children: [
                Image.asset(
                  icon,
                  height: 23,
                  width: 23,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 8),

                Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1, // ✅ FIX TEXT VERTICAL ALIGN
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,

      child: Column(
        children: [
          // AppTextField(
          //   controller: controller.building,
          //   label: l10n.pickLocation,
          // ),
          SizedBox(height: 10),

          // if (widget.accountType == "Family") ...[
          //   AppTextField(label: l10n.enterNumberOfKids),
          //   SizedBox(height: 10),
          //   Row(
          //     children: [
          //       Expanded(child: AppTextField(label: l10n.noOfBoys)),
          //       SizedBox(width: 10),
          //       Expanded(child: AppTextField(label: l10n.noOfGirls)),
          //     ],
          //   ),
          //   SizedBox(height: 17),
          // ],
          SizedBox(height: 15),
          // Image.asset("assets/images/map.png", height: 84),
          // SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildType(l10n.flat, 'assets/icons/Flat.png'),
              buildType(l10n.villa, 'assets/icons/villa.png'),
              // buildType(l10n.office, 'assets/icons/office.png'),
            ],
          ),
          SizedBox(height: 17),
          AppTextField(
            controller: controller.city,
            label: l10n.enterCity,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _onAddressChanged(),
          ),
          SizedBox(height: 17),
          AppTextField(
            controller: controller.building,
            label: l10n.enterBuilding,
            validator: (value) => controller.validateBuilding(value, l10n),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _onAddressChanged(),
          ),
          SizedBox(height: 17),
          if (selected != l10n.villa) ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller.aptNo,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    label: l10n.enterAptNo,
                    onChanged: (_) => _onAddressChanged(),
                    validator: (value) => controller.validateAptNo(value, l10n),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: controller.floor,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _onAddressChanged(),
                    label: l10n.enterFloorNo,
                    validator: (value) => controller.validateFloor(value, l10n),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),
          ],
          Consumer(
            builder: (context, ref, child) {
              final blockAsync = ref.watch(getBlockProvider);

              return blockAsync.when(
                data: (blocks) {
                  if (controller.block != null &&
                      controller.roadsForSelectedBlock.isEmpty) {
                    final selectedBlock = blocks.firstWhere(
                      (b) => b['name'] == controller.block,
                      orElse: () => {},
                    );

                    if (selectedBlock.isNotEmpty) {
                      controller.roadsForSelectedBlock =
                          List<Map<String, dynamic>>.from(
                            selectedBlock['roads'] ?? [],
                          );
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// BLOCK FIRST
                      AppDropdown(
                        label: l10n.selectBlock,
                        items: blocks.map((b) => b['name'] as String).toList(),
                        value: controller.block,
                        onChanged: (val) {
                          _onAddressChanged();
                          setState(() {
                            final block = blocks.firstWhere(
                              (b) => b['name'] == val,
                            );
                            controller.block = block['name'];
                            controller.blockId = block['_id'];
                            controller.road = null;
                            controller.roadId = null;

                            controller.roadsForSelectedBlock =
                                List<Map<String, dynamic>>.from(block['roads']);
                          });
                        },
                        validator: (val) =>
                            val == null ? l10n.pleaseSelectBlock : null,
                      ),

                      SizedBox(height: 15),

                      /// ROAD SECOND
                      AppDropdown(
                        label: l10n.selectRoad,
                        items: controller.roadsForSelectedBlock
                            .map((r) => r['name'] as String)
                            .toList(),
                        value: controller.road,
                        onChanged: (val) {
                          _onAddressChanged();
                          setState(() {
                            final road = controller.roadsForSelectedBlock
                                .firstWhere((r) => r['name'] == val);

                            controller.road = road['name'];
                            controller.roadId = road['_id'];
                          });
                        },
                        validator: (val) =>
                            val == null ? l10n.pleaseSelectRoad : null,
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
              );
            },
          ),

          SizedBox(height: 20),
          if (!widget.family)
            // if (!widget.family && showButton)
            // if (!_hideBottomButton)
            AppButton(
              text: widget.accountType == "Family"
                  ? l10n.continueBtn
                  : l10n.signIn,
              isLoading: _isLoading,
              onPressed: () {
                final isValid =
                    widget.formKey.currentState?.validate() ?? false;

                if (!isValid) return;

                familyAccount(context);
              },
              color: AppColors.btn_primery,
              width: double.infinity,
            ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/controllers/address_controller.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
// import 'package:nadi_user_app/l10n/app_localizations.dart';
// import 'package:nadi_user_app/models/location_result.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/providers/auth_Provider.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/auth_service.dart';
// import 'package:nadi_user_app/views/auth/map_picker_screen.dart';
// import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
// import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
// import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class Address extends StatefulWidget {
//   final String accountType;
//   final VoidCallback? onNext;
//   final VoidCallback? onChanged;
//   final bool family;
//   final GlobalKey<FormState> formKey;
//   final AddressController controller;

//   const Address({
//     super.key,
//     required this.accountType,
//     this.onNext,
//     this.family = false,
//     required this.formKey,
//     required this.controller,
//     this.onChanged, // ✅ ADD THIS
//   });

//   @override
//   State<Address> createState() => _AddressState();
// }

// class _AddressState extends State<Address> {
//   final TextEditingController otherBlockController = TextEditingController();

//   final TextEditingController otherRoadController = TextEditingController();
//   String selected = "Flat";
//   bool _isLoading = false;
//   bool _hideBottomButton = false;
//   bool get showButton {
//     return controller.city.text.isNotEmpty &&
//         controller.building.text.isNotEmpty &&
//         controller.block != null &&
//         controller.road != null;
//   }

//   bool _isSubmitting = false;
//   bool _isLocationLoading = false;
//   bool _showManualForm = false;
//   bool _locationDetected = false;
//   bool _locationModeSelected = false; // NEW
//   bool isOtherBlockSelected = false;
//   bool isOtherRoadSelected = false;
//   String _detectedAddress = "";
//   String? otherBlockError;
//   String? otherRoadError;
//   // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final AuthService _adressservice = AuthService();
//   AddressController get controller => widget.controller;
//   @override
//   void _resetAll() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.clear();

//       setState(() {
//         selected = "Flat";
//         _isLoading = false;
//         // _formKey = GlobalKey<FormState>(); // clears validation UI
//       });
//     });
//   }

//   @override
//   void dispose() {
//     otherBlockController.dispose();
//     otherRoadController.dispose();
//     super.dispose();
//   }

//   Future<void> familyAccount(BuildContext context) async {
//     final userId = await AppPreferences.getUserId();
//     final l10n = AppLocalizations.of(context)!;

//     setState(() {
//       otherBlockError = null;
//       otherRoadError = null;
//     });

//     if (isOtherBlockSelected && otherBlockController.text.trim().isEmpty) {
//       setState(() {
//         otherBlockError = l10n.pleaseEnterBlock;
//       });
//       return;
//     }

//     if (isOtherRoadSelected && otherRoadController.text.trim().isEmpty) {
//       setState(() {
//         otherRoadError = l10n.pleaseEnterRoad;
//       });
//       return;
//     }
//     if (userId == null) {
//       AppLogger.info(" USER ID IS NULL");
//       return;
//     }

//     final body = controller.getApiAddressBody(
//       userId: userId,
//       addressType: selected.toLowerCase(),
//     );

//     body['address']['blockName'] =
//         (isOtherBlockSelected
//             ? otherBlockController.text.trim()
//             : controller.block) ??
//         '';

//     body['address']['roadName'] =
//         (isOtherRoadSelected
//             ? otherRoadController.text.trim()
//             : controller.road) ??
//         '';
//     body['address']['latitude'] = controller.latitude; // double
//     body['address']['longitude'] = controller.longitude; //
//     debugPrint(" API BODY  $body");
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted) setState(() => _isLoading = true);
//     });

//     try {
//       final response = await _adressservice.adressdetails(body: body);
//       // API finished
//       if (mounted) setState(() => _isLoading = false);

//       if (response != null) {
//         if (widget.accountType == "Family") {
//           widget.onNext?.call();
//         } else {
//           if (!context.mounted) return;

//           /// ✅ CLEAR ALL FIELDS HERE
//           controller.city.clear();
//           controller.building.clear();
//           controller.aptNo.clear();
//           controller.floor.clear();

//           controller.block = null;
//           controller.blockId = null;

//           controller.road = null;
//           controller.roadId = null;

//           controller.roadsForSelectedBlock = [];
//           otherBlockController.clear();
//           otherRoadController.clear();

//           setState(() {
//             isOtherBlockSelected = false;
//             isOtherRoadSelected = false;

//             otherBlockError = null;
//             otherRoadError = null;
//           });

//           setState(() {
//             _hideBottomButton = true;
//             // _formKey = GlobalKey<FormState>(); // 🔥 clears validation errors
//           });

//           _resetAll();

//           SnackbarHelper.ShowSuccess(
//             context,
//             AppLocalizations.of(context)!.accountCreatedSuccessfully,
//           );
//           //_resetAll();
//           Future.delayed(const Duration(seconds: 1), () {
//             if (context.mounted) context.push(RouteNames.accountverfy);
//           });
//         }
//       }
//     } catch (e) {
//       if (!context.mounted) return;
//       setState(() => _isLoading = false);
//       SnackbarHelper.showError(
//         context,
//         "${AppLocalizations.of(context)!.submitFailed}: $e",
//       );
//     }
//   }

//   void _onAddressChanged() {
//     if (_hideBottomButton) {
//       setState(() {
//         _hideBottomButton = false;
//       });
//     }

//     widget.onChanged?.call();
//   }

//   Future<void> _openMapPicker() async {
//     setState(() {
//       _isLocationLoading = true;
//       _locationModeSelected = true;
//       _showManualForm = false; // hide manual instantly
//     });

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const MapPickerScreen()),
//     );

//     if (!mounted) return;

//     setState(() {
//       _isLocationLoading = false;
//     });

//     if (result == null) {
//       // user cancelled → allow manual again
//       setState(() {
//         _locationModeSelected = false;
//       });
//       return;
//     }

//     if (result is LocationResult) {
//       await _applyLocation(result);
//     }
//   }

//   Future<void> _applyLocation(LocationResult result) async {
//     final ref = ProviderScope.containerOf(context);

//     final blocks = await ref.read(getBlockProvider.future);

//     setState(() {
//       _locationDetected = true;
//       _detectedAddress = result.fullAddress;

//       controller.city.text = result.city;

//       // Save coordinates
//       controller.latitude = result.latitude;
//       controller.longitude = result.longitude;

//       if (controller.building.text.isEmpty && result.building.isNotEmpty) {
//         controller.building.text = result.building;
//       }
//     });

//     final matchedBlock = blocks.firstWhere(
//       (b) => b['name'].toString().toLowerCase() == result.block.toLowerCase(),
//       orElse: () => {},
//     );
//     debugPrint("============== LOCATION ==============");
//     debugPrint("City   : ${result.city}");
//     debugPrint("Block  : ${result.block}");
//     debugPrint("Road   : ${result.road}");

//     debugPrint("============== BLOCKS ==============");
//     for (final block in blocks) {
//       debugPrint("Block Name: ${block['name']}");
//     }
//     if (matchedBlock.isNotEmpty) {
//       controller.block = matchedBlock['name'];
//       controller.blockId = matchedBlock['_id'];

//       controller.roadsForSelectedBlock = List<Map<String, dynamic>>.from(
//         matchedBlock['roads'] ?? [],
//       );

//       final matchedRoad = controller.roadsForSelectedBlock.where(
//         (road) =>
//             road['name'].toString().toLowerCase() == result.road.toLowerCase(),
//       );
//       debugPrint("Matched Block = ${matchedBlock['name']}");
//       if (matchedRoad.isNotEmpty) {
//         final road = matchedRoad.first;

//         controller.road = road['name'];
//         controller.roadId = road['_id'];
//       }
//     }

//     setState(() {});
//   }

//   Future<void> _useMyLocation() async {
//     try {
//       setState(() => _isLocationLoading = true);

//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         SnackbarHelper.showError(context, "Enable location services");
//         return;
//       }

//       var permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         SnackbarHelper.showError(context, "Location permission denied");
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       final place = placemarks.first;

//       debugPrint("========== FULL PLACEMARK ==========");
//       debugPrint(place.toString());

//       debugPrint("Name               : ${place.name}");
//       debugPrint("Street             : ${place.street}");
//       debugPrint("Thoroughfare       : ${place.thoroughfare}");
//       debugPrint("SubThoroughfare    : ${place.subThoroughfare}");
//       debugPrint("Locality           : ${place.locality}");
//       debugPrint("SubLocality        : ${place.subLocality}");
//       debugPrint("AdministrativeArea : ${place.administrativeArea}");
//       debugPrint("SubAdminArea       : ${place.subAdministrativeArea}");
//       debugPrint("PostalCode         : ${place.postalCode}");
//       debugPrint("Country            : ${place.country}");

//       final fullAddress = [
//         place.name,
//         place.street,
//         place.subLocality,
//         place.locality,
//         place.administrativeArea,
//       ].where((e) => e != null && e.isNotEmpty).join(", ");

//       setState(() {
//         _locationDetected = true;
//         _detectedAddress = fullAddress;

//         controller.city.text = place.locality ?? "";

//         controller.block = null;
//         controller.blockId = null;

//         controller.road = null;
//         controller.roadId = null;

//         controller.roadsForSelectedBlock.clear();
//       });

//       SnackbarHelper.ShowSuccess(context, "Location detected successfully");
//       // setState(() {
//       //   controller.city.text = place.locality ?? "";
//       //   controller.block = place.subLocality ?? "";
//       //   controller.road = place.thoroughfare ?? "";
//       // });
//       // setState(() {
//       //   controller.city.text = place.locality ?? "";

//       //   // Don't directly assign dropdown values
//       //   controller.block = null;
//       //   controller.road = null;

//       //   controller.blockId = null;
//       //   controller.roadId = null;

//       //   controller.roadsForSelectedBlock.clear();
//       // });
//       // SnackbarHelper.ShowSuccess(context, "Location detected successfully");
//     } catch (e) {
//       SnackbarHelper.showError(context, "Failed to fetch location");
//     } finally {
//       if (mounted) setState(() => _isLocationLoading = false);
//     }
//   }

//   Widget buildType(String type, String icon) {
//     final bool isSelected = selected == type;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selected = type;

//             if (type == "Villa") {
//               controller.aptNo.clear();
//               controller.floor.clear();
//             }
//           });
//         },
//         child: Container(
//           height: 58, // ✅ fixed height
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppColors.btn_primery
//                 : Theme.of(context).colorScheme.surface,

//             borderRadius: BorderRadius.circular(14),

//             border: Border.all(
//               color: isSelected ? AppColors.btn_primery : Colors.grey.shade300,
//             ),
//           ),

//           child: Center(
//             // ✅ IMPORTANT
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX
//               children: [
//                 Image.asset(
//                   icon,
//                   height: 23,
//                   width: 23,
//                   color: isSelected
//                       ? Colors.white
//                       : Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),

//                 const SizedBox(width: 8),

//                 Text(
//                   type,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     height: 1, // ✅ FIX TEXT VERTICAL ALIGN
//                     color: isSelected
//                         ? Colors.white
//                         : Theme.of(context).colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAddressSelection() {
//     return Column(
//       children: [
//         AppButton(
//           text: _isLocationLoading
//               ? "Detecting Location..."
//               : "Use Current Location",
//           icon: const Icon(Icons.my_location, color: Colors.white),
//           width: double.infinity,
//           isLoading: _isLocationLoading,
//           color: AppColors.btn_primery,
//           // onPressed: _isLocationLoading ? null : _useMyLocation,
//           onPressed: _openMapPicker,
//         ),

//         const SizedBox(height: 12),

//         OutlinedButton.icon(
//           onPressed: _locationModeSelected
//               ? null
//               : () {
//                   setState(() {
//                     _showManualForm = true;
//                   });
//                 },
//           icon: const Icon(Icons.edit_location_alt),
//           label: const Text("Enter Address Manually"),
//         ),
//       ],
//     );
//   }

//   Widget _buildManualAddressForm() {
//     final l10n = AppLocalizations.of(context)!;

//     return Column(
//       children: [
//         const SizedBox(height: 17),

//         AppTextField(
//           controller: controller.city,
//           label: l10n.enterCity,
//           keyboardType: TextInputType.streetAddress,
//           textInputAction: TextInputAction.next,
//           onChanged: (_) => _onAddressChanged(),
//         ),

//         const SizedBox(height: 17),

//         AppTextField(
//           controller: controller.building,
//           label: l10n.enterBuilding,
//           validator: (value) => controller.validateBuilding(value, l10n),
//           keyboardType: TextInputType.text,
//           textInputAction: TextInputAction.next,
//           onChanged: (_) => _onAddressChanged(),
//         ),

//         const SizedBox(height: 17),

//         if (selected != l10n.villa) ...[
//           Row(
//             children: [
//               Expanded(
//                 child: AppTextField(
//                   controller: controller.aptNo,
//                   keyboardType: TextInputType.number,
//                   textInputAction: TextInputAction.next,
//                   label: l10n.enterAptNo,
//                   onChanged: (_) => _onAddressChanged(),
//                   validator: (value) => controller.validateAptNo(value, l10n),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: AppTextField(
//                   controller: controller.floor,
//                   keyboardType: TextInputType.number,
//                   textInputAction: TextInputAction.done,
//                   onChanged: (_) => _onAddressChanged(),
//                   label: l10n.enterFloorNo,
//                   validator: (value) => controller.validateFloor(value, l10n),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 17),
//         ],

//         Consumer(
//           builder: (context, ref, child) {
//             final blockAsync = ref.watch(getBlockProvider);

//             return blockAsync.when(
//               data: (blocks) {
//                 if (controller.block != null &&
//                     controller.roadsForSelectedBlock.isEmpty) {
//                   final selectedBlock = blocks.firstWhere(
//                     (b) => b['name'] == controller.block,
//                     orElse: () => {},
//                   );

//                   if (selectedBlock.isNotEmpty) {
//                     controller.roadsForSelectedBlock =
//                         List<Map<String, dynamic>>.from(
//                           selectedBlock['roads'] ?? [],
//                         );
//                   }
//                 }

//                 return Column(
//                   children: [
//                     AppDropdown(
//                       label: l10n.selectBlock,
//                       items: [
//                         ...blocks.map((b) => b['name'] as String),
//                         "Others",
//                       ],
//                       value: blocks.any((b) => b['name'] == controller.block)
//                           ? controller.block
//                           : null,
//                       // onChanged: (val) {
//                       //   _onAddressChanged();

//                       //   setState(() {
//                       //     final block = blocks.firstWhere(
//                       //       (b) => b['name'] == val,
//                       //     );

//                       //     controller.block = block['name'];
//                       //     controller.blockId = block['_id'];

//                       //     controller.road = null;
//                       //     controller.roadId = null;

//                       //     controller.roadsForSelectedBlock =
//                       //         List<Map<String, dynamic>>.from(block['roads']);
//                       //   });
//                       // },
//                       onChanged: (val) {
//                         _onAddressChanged();

//                         if (val == "Others") {
//                           setState(() {
//                             isOtherBlockSelected = true;

//                             controller.block = null;
//                             controller.blockId = null;

//                             controller.road = null;
//                             controller.roadId = null;

//                             controller.roadsForSelectedBlock.clear();
//                           });

//                           return;
//                         }

//                         setState(() {
//                           isOtherBlockSelected = false;

//                           final block = blocks.firstWhere(
//                             (b) => b['name'] == val,
//                           );

//                           controller.block = block['name'];
//                           controller.blockId = block['_id'];

//                           controller.road = null;
//                           controller.roadId = null;

//                           controller.roadsForSelectedBlock =
//                               List<Map<String, dynamic>>.from(block['roads']);
//                         });
//                       },
//                       validator: (val) =>
//                           val == null ? l10n.pleaseSelectBlock : null,
//                     ),

//                     const SizedBox(height: 15),
//                     if (isOtherBlockSelected) ...[
//                       AppTextField(
//                         controller: otherBlockController,
//                         label: "Enter Block Name",
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (isOtherBlockSelected &&
//                               (value == null || value.trim().isEmpty)) {
//                             return "Please enter block name";
//                           }
//                           return null;
//                         },
//                         onChanged: (_) {
//                           if (otherBlockError != null) {
//                             setState(() => otherBlockError = null);
//                           }
//                         },
//                       ),

//                       if (otherBlockError != null)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 12, top: 4),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               otherBlockError!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                     const SizedBox(height: 15),
//                     // if (!isOtherBlockSelected)
//                     AppDropdown(
//                       label: l10n.selectRoad,
//                       items: [
//                         ...controller.roadsForSelectedBlock.map(
//                           (r) => r['name'] as String,
//                         ),
//                         "Others",
//                       ],
//                       value:
//                           controller.roadsForSelectedBlock.any(
//                             (r) => r['name'] == controller.road,
//                           )
//                           ? controller.road
//                           : null,
//                       // onChanged: (val) {
//                       //   _onAddressChanged();

//                       //   setState(() {
//                       //     final road = controller.roadsForSelectedBlock
//                       //         .firstWhere((r) => r['name'] == val);

//                       //     controller.road = road['name'];
//                       //     controller.roadId = road['_id'];
//                       //   });
//                       // },
//                       onChanged: (val) {
//                         _onAddressChanged();

//                         if (val == "Others") {
//                           setState(() {
//                             isOtherRoadSelected = true;

//                             controller.road = null;
//                             controller.roadId = null;
//                           });
//                           return;
//                         }

//                         setState(() {
//                           isOtherRoadSelected = false;

//                           final road = controller.roadsForSelectedBlock
//                               .firstWhere((r) => r['name'] == val);

//                           controller.road = road['name'];
//                           controller.roadId = road['_id'];
//                         });
//                       },
//                       validator: (val) =>
//                           val == null ? l10n.pleaseSelectRoad : null,
//                     ),
//                     const SizedBox(height: 15),

//                     if (isOtherRoadSelected) ...[
//                       AppTextField(
//                         controller: otherRoadController,
//                         label: "Enter Road Name",
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (isOtherRoadSelected &&
//                               (value == null || value.trim().isEmpty)) {
//                             return "Please enter road name";
//                           }
//                           return null;
//                         },
//                         onChanged: (_) {
//                           if (otherRoadError != null) {
//                             setState(() => otherRoadError = null);
//                           }
//                         },
//                       ),

//                       if (otherRoadError != null)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 12, top: 4),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               otherRoadError!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ],
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDetectedLocationCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.location_on, color: Colors.green),
//               SizedBox(width: 8),
//               Text(
//                 "Detected Location",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           Text(_detectedAddress),

//           const SizedBox(height: 10),

//           // TextButton(
//           //   onPressed: () {
//           //     setState(() {
//           //       _showManualForm = true;
//           //     });
//           //   },
//           //   child: const Text("Adjust Address"),
//           // ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     return Form(
//       key: widget.formKey,
//       autovalidateMode: AutovalidateMode.disabled,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 20),
//           child: Column(
//             children: [
//               // AppTextField(
//               //   controller: controller.building,
//               //   label: l10n.pickLocation,
//               // ),
//               SizedBox(height: 10),

//               // if (widget.accountType == "Family") ...[
//               //   AppTextField(label: l10n.enterNumberOfKids),
//               //   SizedBox(height: 10),
//               //   Row(
//               //     children: [
//               //       Expanded(child: AppTextField(label: l10n.noOfBoys)),
//               //       SizedBox(width: 10),
//               //       Expanded(child: AppTextField(label: l10n.noOfGirls)),
//               //     ],
//               //   ),
//               //   SizedBox(height: 17),
//               // ],
//               SizedBox(height: 15),
//               // Image.asset("assets/images/map.png", height: 84),
//               // SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   buildType(l10n.flat, 'assets/icons/Flat.png'),
//                   buildType(l10n.villa, 'assets/icons/villa.png'),
//                   // buildType(l10n.office, 'assets/icons/office.png'),
//                 ],
//               ),
//               SizedBox(height: 17),
//               _buildAddressSelection(),

//               const SizedBox(height: 20),

//               if (_locationDetected) _buildDetectedLocationCard(),

//               if (_showManualForm || _locationDetected)
//                 _buildManualAddressForm(),
//               SizedBox(height: 17),

//               // AppTextField(
//               //   controller: controller.city,
//               //   label: l10n.enterCity,
//               //   keyboardType: TextInputType.streetAddress,
//               //   textInputAction: TextInputAction.next,
//               //   onChanged: (_) => _onAddressChanged(),
//               // ),
//               // SizedBox(height: 17),
//               // AppTextField(
//               //   controller: controller.building,
//               //   label: l10n.enterBuilding,
//               //   validator: (value) => controller.validateBuilding(value, l10n),
//               //   keyboardType: TextInputType.text,
//               //   textInputAction: TextInputAction.next,
//               //   onChanged: (_) => _onAddressChanged(),
//               // ),
//               // SizedBox(height: 17),
//               // if (selected != l10n.villa) ...[
//               //   Row(
//               //     children: [
//               //       Expanded(
//               //         child: AppTextField(
//               //           controller: controller.aptNo,
//               //           keyboardType: TextInputType.number,
//               //           textInputAction: TextInputAction.next,
//               //           label: l10n.enterAptNo,
//               //           onChanged: (_) => _onAddressChanged(),
//               //           validator: (value) =>
//               //               controller.validateAptNo(value, l10n),
//               //         ),
//               //       ),
//               //       SizedBox(width: 10),
//               //       Expanded(
//               //         child: AppTextField(
//               //           controller: controller.floor,
//               //           keyboardType: TextInputType.number,
//               //           textInputAction: TextInputAction.done,
//               //           onChanged: (_) => _onAddressChanged(),
//               //           label: l10n.enterFloorNo,
//               //           validator: (value) =>
//               //               controller.validateFloor(value, l10n),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               //   SizedBox(height: 17),
//               // ],
//               // Consumer(
//               //   builder: (context, ref, child) {
//               //     final blockAsync = ref.watch(getBlockProvider);

//               //     return blockAsync.when(
//               //       data: (blocks) {
//               //         if (controller.block != null &&
//               //             controller.roadsForSelectedBlock.isEmpty) {
//               //           final selectedBlock = blocks.firstWhere(
//               //             (b) => b['name'] == controller.block,
//               //             orElse: () => {},
//               //           );

//               //           if (selectedBlock.isNotEmpty) {
//               //             controller.roadsForSelectedBlock =
//               //                 List<Map<String, dynamic>>.from(
//               //                   selectedBlock['roads'] ?? [],
//               //                 );
//               //           }
//               //         }
//               //         return Column(
//               //           crossAxisAlignment: CrossAxisAlignment.start,
//               //           children: [
//               //             /// BLOCK FIRST
//               //             AppDropdown(
//               //               label: l10n.selectBlock,
//               //               items: blocks
//               //                   .map((b) => b['name'] as String)
//               //                   .toList(),
//               //               value:
//               //                   blocks.any((b) => b['name'] == controller.block)
//               //                   ? controller.block
//               //                   : null,
//               //               onChanged: (val) {
//               //                 _onAddressChanged();
//               //                 setState(() {
//               //                   final block = blocks.firstWhere(
//               //                     (b) => b['name'] == val,
//               //                   );
//               //                   controller.block = block['name'];
//               //                   controller.blockId = block['_id'];
//               //                   controller.road = null;
//               //                   controller.roadId = null;

//               //                   controller.roadsForSelectedBlock =
//               //                       List<Map<String, dynamic>>.from(
//               //                         block['roads'],
//               //                       );
//               //                 });
//               //               },
//               //               validator: (val) =>
//               //                   val == null ? l10n.pleaseSelectBlock : null,
//               //             ),

//               //             SizedBox(height: 15),

//               //             /// ROAD SECOND
//               //             AppDropdown(
//               //               label: l10n.selectRoad,
//               //               items: controller.roadsForSelectedBlock
//               //                   .map((r) => r['name'] as String)
//               //                   .toList(),
//               //               value:
//               //                   controller.roadsForSelectedBlock.any(
//               //                     (r) => r['name'] == controller.road,
//               //                   )
//               //                   ? controller.road
//               //                   : null,
//               //               onChanged: (val) {
//               //                 _onAddressChanged();
//               //                 setState(() {
//               //                   final road = controller.roadsForSelectedBlock
//               //                       .firstWhere((r) => r['name'] == val);

//               //                   controller.road = road['name'];
//               //                   controller.roadId = road['_id'];
//               //                 });
//               //               },
//               //               validator: (val) =>
//               //                   val == null ? l10n.pleaseSelectRoad : null,
//               //             ),
//               //           ],
//               //         );
//               //       },
//               //       loading: () => const CircularProgressIndicator(),
//               //       error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
//               //     );
//               //   },
//               // ),

//               // SizedBox(height: 20),
//               if (!widget.family)
//                 // if (!widget.family && showButton)
//                 // if (!_hideBottomButton)
//                 AppButton(
//                   text: widget.accountType == "Family"
//                       ? l10n.continueBtn
//                       : l10n.signIn,
//                   isLoading: _isLoading,
//                   onPressed: () {
//                     final isValid =
//                         widget.formKey.currentState?.validate() ?? false;

//                     if (!isValid) return;

//                     familyAccount(context);
//                   },
//                   color: AppColors.btn_primery,
//                   width: double.infinity,
//                 ),

//               SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
