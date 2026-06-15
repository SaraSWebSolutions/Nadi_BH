import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/address_display_helper.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/models/location_result.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/auth_Provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/views/auth/map_picker_screen.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Address extends StatefulWidget {
  final String accountType;
  final Function(Map<String, dynamic>? address)? onNext;
  final VoidCallback? onChanged;
  final bool family;
  final GlobalKey<FormState> formKey;
  final AddressController controller;
  final bool isFromMemberScreen;
  final bool isEditMode;
  final Map<String, dynamic>? familyHeaderAddress;
  final Map<String, dynamic>? initialAddress;
  final bool isprofile;
  const Address({
    super.key,
    required this.accountType,
    this.onNext,
    this.family = false,
    required this.formKey,
    required this.controller,
    this.onChanged,
    this.isFromMemberScreen = false,
    this.isEditMode = false,
    this.familyHeaderAddress,
    this.initialAddress,
    required this.isprofile,
  });

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final TextEditingController otherBlockController = TextEditingController();

  final TextEditingController otherRoadController = TextEditingController();
  String selected = "Flat";
  bool _isLoading = false;
  bool _hideBottomButton = false;
  bool get showButton {
    return controller.city.text.isNotEmpty &&
        controller.building.text.isNotEmpty &&
        controller.block != null &&
        controller.road != null;
  }

  bool _isLocationLoading = false;
  bool isOtherBlockSelected = false;
  bool isOtherRoadSelected = false;
  String? otherBlockError;
  String? otherRoadError;
  // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _adressservice = AuthService();
  AddressController get controller => widget.controller;

  // @override
  // void initState() {
  //   super.initState();
  //   final initial = widget.initialAddress;
  //   if (initial != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (!mounted) return;
  //       controller.loadAddress(initial);
  //       if (controller.addressSource == null) {
  //         controller.addressSource =
  //             AddressDisplayHelper.resolveSource(initial) ??
  //             AddressSource.manual;
  //       }
  //       setState(() {});
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();

    final initial = widget.initialAddress;

    print("INITIAL ADDRESS => $initial");

    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        controller.loadAddress(initial);

        print("LAT => ${controller.latitude}");
        print("LNG => ${controller.longitude}");
        print("SOURCE => ${controller.addressSource}");

        setState(() {});
      });
    }
  }

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

  @override
  void dispose() {
    otherBlockController.dispose();
    otherRoadController.dispose();
    super.dispose();
  }

  Future<void> familyAccount(BuildContext context) async {
    final userId = await AppPreferences.getUserId();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      otherBlockError = null;
      otherRoadError = null;
    });

    if (!controller.isGeoMode) {
      if (isOtherBlockSelected && otherBlockController.text.trim().isEmpty) {
        setState(() {
          otherBlockError = l10n.pleaseEnterBlock;
        });
        return;
      }

      if (isOtherRoadSelected && otherRoadController.text.trim().isEmpty) {
        setState(() {
          otherRoadError = l10n.pleaseEnterRoad;
        });
        return;
      }
    }

    if (userId == null) {
      AppLogger.info(" USER ID IS NULL");
      return;
    }

    if (!controller.isComplete) {
      SnackbarHelper.showError(context, l10n.addAddressError);
      return;
    }

    final body = controller.getApiAddressBody(
      userId: userId,
      addressType: selected.toLowerCase(),
      blockNameOverride: isOtherBlockSelected
          ? otherBlockController.text.trim()
          : controller.block,
      roadNameOverride: isOtherRoadSelected
          ? otherRoadController.text.trim()
          : controller.road,
    );
    debugPrint(" API BODY  $body");
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = true);
    });

    try {
      final response = await _adressservice.adressdetails(body: body);

      // stop loading
      if (mounted) setState(() => _isLoading = false);

      if (response == null) return;

      final addressData = response["data"]; // ✅ IMPORTANT FIX

      if (widget.accountType == "Family") {
        fillAddressFromApi(addressData);
        widget.onNext?.call(addressData); // ✅ PASS ADDRESS
        return;
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
        otherBlockController.clear();
        otherRoadController.clear();

        setState(() {
          isOtherBlockSelected = false;
          isOtherRoadSelected = false;

          otherBlockError = null;
          otherRoadError = null;
        });

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

  Future<void> _openMapPicker() async {
    debugPrint("STEP 1");
    debugPrint(
      "OPENING MAP => lat=${controller.latitude}, lng=${controller.longitude}",
    );
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    final l10n = AppLocalizations.of(context)!;

    if (!serviceEnabled) {
      SnackbarHelper.showError(context, l10n.pleaseEnableLocationService);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      SnackbarHelper.showError(context, l10n.locationPermissionDenied);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      SnackbarHelper.showError(
        context,
        l10n.locationPermissionPermanentlyDenied,
      );

      await Geolocator.openAppSettings();
      return;
    }

    try {
      setState(() => _isLocationLoading = true);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapPickerScreen(
            latitude: controller.latitude,
            longitude: controller.longitude,
            savedAddress: controller.geoAddress,
          ),
        ),
      );

      if (result is LocationResult) {
        await _applyCurrentLocation(result);
      }
    } catch (e) {
      debugPrint("MAP ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  Future<void> _applyCurrentLocation(LocationResult result) async {
    if (!mounted) return;
    setState(() {
      controller.applyCurrentLocation(result);
    });
  }

  void fillAddressFromApi(Map<String, dynamic> data) {
    setState(() {
      controller.loadAddress(Map<String, dynamic>.from(data));
    });
  }

  void _resetLocalAddressState() {
    otherBlockController.clear();
    otherRoadController.clear();
    isOtherBlockSelected = false;
    isOtherRoadSelected = false;
    otherBlockError = null;
    otherRoadError = null;
  }

  Future<void> _fillAddressFromFamilyHeader() async {
    final address = widget.familyHeaderAddress;
    if (address == null) return;

    setState(() {
      controller.applyFamilyHeader(address);
      _resetLocalAddressState();
    });

    if (controller.isGeoMode || !mounted) return;

    final ref = ProviderScope.containerOf(context);
    final blocks = await ref.read(getBlockProvider.future);
    final blockName = controller.block;
    if (blockName == null) return;

    Map<String, dynamic>? matchedBlock;
    try {
      matchedBlock = blocks.firstWhere((b) => b['name'] == blockName);
    } catch (_) {
      matchedBlock = null;
    }

    if (!mounted || matchedBlock == null) return;

    final resolvedBlock = matchedBlock;

    setState(() {
      controller.blockId ??= AddressController.sanitizeId(resolvedBlock['_id']);
      controller.roadsForSelectedBlock = List<Map<String, dynamic>>.from(
        resolvedBlock['roads'] ?? [],
      );

      final roadName = controller.road;
      if (roadName != null) {
        final matchedRoad = controller.roadsForSelectedBlock.where(
          (r) => r['name'] == roadName,
        );
        if (matchedRoad.isNotEmpty) {
          controller.roadId ??= AddressController.sanitizeId(
            matchedRoad.first['_id'],
          );
        }
      }
    });
  }

  Future<void> _onSelectSource(AddressSource source) async {
    switch (source) {
      case AddressSource.familyHeader:
        await _fillAddressFromFamilyHeader();
        break;
      case AddressSource.currentLocation:
        controller.addressSource = AddressSource.currentLocation;
        await _openMapPicker();
        break;
      case AddressSource.manual:
        setState(() {
          controller.applyManualEntry();
          _resetLocalAddressState();
        });
        break;
    }
  }

  bool _validateManualForm() {
    final l10n = AppLocalizations.of(context)!;

    if (controller.isGeoMode) return true;

    setState(() {
      otherBlockError = null;
      otherRoadError = null;
    });

    if (isOtherBlockSelected && otherBlockController.text.trim().isEmpty) {
      setState(() => otherBlockError = l10n.pleaseEnterBlock);
      return false;
    }

    if (isOtherRoadSelected && otherRoadController.text.trim().isEmpty) {
      setState(() => otherRoadError = l10n.pleaseEnterRoad);
      return false;
    }

    final hasValidBlock =
        AddressController.sanitizeId(controller.blockId) != null ||
        (isOtherBlockSelected && otherBlockController.text.trim().isNotEmpty);

    final hasValidRoad =
        AddressController.sanitizeId(controller.roadId) != null ||
        (isOtherRoadSelected && otherRoadController.text.trim().isNotEmpty);

    if (!hasValidBlock) {
      SnackbarHelper.showError(context, l10n.pleaseSelectBlock);
      return false;
    }

    if (!hasValidRoad) {
      SnackbarHelper.showError(context, l10n.pleaseSelectRoad);
      return false;
    }

    return widget.formKey.currentState?.validate() ?? false;
  }

  void _handleContinue() {
    final l10n = AppLocalizations.of(context)!;

    if (controller.addressSource == null) {
      SnackbarHelper.showError(context, l10n.addAddressError);
      return;
    }

    if (!_validateManualForm() || !controller.isComplete) {
      if (!controller.isComplete) {
        SnackbarHelper.showError(context, l10n.addAddressError);
      }
      return;
    }

    widget.onNext?.call(
      controller.toMap(
        blockNameOverride: isOtherBlockSelected
            ? otherBlockController.text.trim()
            : controller.block,
        roadNameOverride: isOtherRoadSelected
            ? otherRoadController.text.trim()
            : controller.road,
      ),
    );
  }

  // Legacy GPS helper removed — map picker is the single current-location entry point.

  Widget buildType(String type, String icon) {
    final bool isSelected = selected == type;

    return Expanded(
      child: GestureDetector(
        onTap: controller.isReadOnly
            ? null
            : () {
                setState(() {
                  selected = type;

                  if (type == "Villa") {
                    controller.aptNo.clear();
                    controller.floor.clear();
                  }
                });
              },
        child: Container(
          height: 58,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    height: 1,
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

  Widget _buildModeOptionCard({
    required String title,
    required IconData icon,
    required AddressSource source,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected
            ? AppColors.btn_primery.withOpacity(0.08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLocationLoading ? null : () => _onSelectSource(source),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.btn_primery
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.btn_primery
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.btn_primery
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_isLocationLoading &&
                    source == AddressSource.currentLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressModeOptions() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (widget.isFromMemberScreen)
          _buildModeOptionCard(
            title: l10n.useFamilyHeaderAddress,
            icon: Icons.home_outlined,
            source: AddressSource.familyHeader,
            isSelected: controller.addressSource == AddressSource.familyHeader,
          ),
        _buildModeOptionCard(
          title: l10n.useCurrentLocation,
          icon: Icons.my_location,
          source: AddressSource.currentLocation,
          isSelected: controller.addressSource == AddressSource.currentLocation,
        ),
        _buildModeOptionCard(
          title: l10n.enterManually,
          icon: Icons.edit_location_alt,
          source: AddressSource.manual,
          isSelected: controller.addressSource == AddressSource.manual,
        ),
      ],
    );
  }

  Widget _buildManualAddressForm() {
    final l10n = AppLocalizations.of(context)!;
    final fieldsEnabled = !controller.isReadOnly;

    return Column(
      children: [
        const SizedBox(height: 17),

        AppTextField(
          controller: controller.city,
          label: l10n.enterCity,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          readonly: controller.isReadOnly,
          enabled: fieldsEnabled,
          onChanged: (_) => _onAddressChanged(),
        ),

        const SizedBox(height: 17),

        AppTextField(
          controller: controller.building,
          label: l10n.enterBuilding,
          validator: (value) => controller.validateBuilding(value, l10n),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          readonly: controller.isReadOnly,
          enabled: fieldsEnabled,
          onChanged: (_) => _onAddressChanged(),
        ),

        const SizedBox(height: 17),

        if (selected != l10n.villa) ...[
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.aptNo,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  label: l10n.enterAptNo,
                  readonly: controller.isReadOnly,
                  enabled: fieldsEnabled,
                  onChanged: (_) => _onAddressChanged(),
                  validator: (value) => controller.validateAptNo(value, l10n),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: controller.floor,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  readonly: controller.isReadOnly,
                  enabled: fieldsEnabled,
                  onChanged: (_) => _onAddressChanged(),
                  label: l10n.enterFloorNo,
                  validator: (value) => controller.validateFloor(value, l10n),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
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
                final matchedBlock = blocks
                    .where(
                      (b) =>
                          b['name'].toString() == controller.block?.toString(),
                    )
                    .toList();

                final blockValue = matchedBlock.isNotEmpty
                    ? matchedBlock.first['name']
                    : null;
                final matchedRoad = controller.roadsForSelectedBlock
                    .where(
                      (r) =>
                          r['name'].toString() == controller.road?.toString(),
                    )
                    .toList();

                final roadValue = matchedRoad.isNotEmpty
                    ? matchedRoad.first['name']
                    : null;
                return Column(
                  children: [
                    AppDropdown(
                      label: l10n.selectBlock,
                      enabled: fieldsEnabled,
                      items: [
                        ...blocks.map((b) => b['name'] as String),
                        if (!controller.isReadOnly) l10n.others,
                      ],

                      value: blockValue,
                      // onChanged: (val) {
                      //   _onAddressChanged();

                      //   setState(() {
                      //     final block = blocks.firstWhere(
                      //       (b) => b['name'] == val,
                      //     );

                      //     controller.block = block['name'];
                      //     controller.blockId = block['_id'];

                      //     controller.road = null;
                      //     controller.roadId = null;

                      //     controller.roadsForSelectedBlock =
                      //         List<Map<String, dynamic>>.from(block['roads']);
                      //   });
                      // },
                      onChanged: (val) {
                        _onAddressChanged();

                        if (val == l10n.others) {
                          setState(() {
                            isOtherBlockSelected = true;

                            controller.block = null;
                            controller.blockId = null;

                            controller.road = null;
                            controller.roadId = null;

                            controller.roadsForSelectedBlock.clear();
                          });

                          return;
                        }

                        setState(() {
                          isOtherBlockSelected = false;

                          final block = blocks.firstWhere(
                            (b) => b['name'] == val,
                          );

                          controller.block = block['name'];
                          controller.blockId = AddressController.sanitizeId(
                            block['_id'],
                          );

                          controller.road = null;
                          controller.roadId = null;

                          controller.roadsForSelectedBlock =
                              List<Map<String, dynamic>>.from(block['roads']);
                        });
                      },
                      validator: (val) =>
                          val == null ? l10n.pleaseSelectBlock : null,
                    ),

                    const SizedBox(height: 15),
                    if (isOtherBlockSelected) ...[
                      AppTextField(
                        controller: otherBlockController,
                        label: l10n.enterBlockName,
                        keyboardType: TextInputType.number,
                        readonly: controller.isReadOnly,
                        enabled: fieldsEnabled,
                        validator: (value) {
                          if (isOtherBlockSelected &&
                              (value == null || value.trim().isEmpty)) {
                            return l10n.pleaseEnterBlockName;
                          }
                          return null;
                        },
                        onChanged: (_) {
                          if (otherBlockError != null) {
                            setState(() => otherBlockError = null);
                          }
                        },
                      ),

                      if (otherBlockError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              otherBlockError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 15),
                    // if (!isOtherBlockSelected)
                    AppDropdown(
                      label: l10n.selectRoad,
                      enabled: fieldsEnabled,
                      items: [
                        ...controller.roadsForSelectedBlock.map(
                          (r) => r['name'] as String,
                        ),
                        if (!controller.isReadOnly) l10n.others,
                      ],
                      value: roadValue,
                      // onChanged: (val) {
                      //   _onAddressChanged();

                      //   setState(() {
                      //     final road = controller.roadsForSelectedBlock
                      //         .firstWhere((r) => r['name'] == val);

                      //     controller.road = road['name'];
                      //     controller.roadId = road['_id'];
                      //   });
                      // },
                      onChanged: (val) {
                        _onAddressChanged();

                        if (val == l10n.others) {
                          setState(() {
                            isOtherRoadSelected = true;

                            controller.road = null;
                            controller.roadId = null;
                          });
                          return;
                        }

                        setState(() {
                          isOtherRoadSelected = false;

                          final road = controller.roadsForSelectedBlock
                              .firstWhere((r) => r['name'] == val);

                          controller.road = road['name'];
                          controller.roadId = AddressController.sanitizeId(
                            road['_id'],
                          );
                        });
                      },
                      validator: (val) =>
                          val == null ? l10n.pleaseSelectRoad : null,
                    ),
                    const SizedBox(height: 15),

                    if (isOtherRoadSelected) ...[
                      AppTextField(
                        controller: otherRoadController,
                        label: l10n.enterRoadName,
                        keyboardType: TextInputType.number,
                        readonly: controller.isReadOnly,
                        enabled: fieldsEnabled,
                        validator: (value) {
                          if (isOtherRoadSelected &&
                              (value == null || value.trim().isEmpty)) {
                            return l10n.pleaseEnterRoadName;
                          }
                          return null;
                        },
                        onChanged: (_) {
                          if (otherRoadError != null) {
                            setState(() => otherRoadError = null);
                          }
                        },
                      ),

                      if (otherRoadError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              otherRoadError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrentLocationView() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectedAddressLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            controller.geoAddress ?? controller.fullAddress ?? '',
            style: const TextStyle(fontSize: 15),
          ),
          if (!controller.isReadOnly) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLocationLoading ? null : _openMapPicker,
              icon: const Icon(Icons.edit_location_alt),
              label: Text(l10n.editLocation),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canContinue =>
      controller.addressSource != null && controller.isComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
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
              if (controller.showsManualForm) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildType(l10n.flat, 'assets/icons/Flat.png'),
                    buildType(l10n.villa, 'assets/icons/villa.png'),
                  ],
                ),
                const SizedBox(height: 17),
              ],
              if (!widget.isEditMode || controller.addressSource == null)
                _buildAddressModeOptions(),

              const SizedBox(height: 20),

              if (controller.showsLocationCard) _buildCurrentLocationView(),

              if (controller.showsManualForm) _buildManualAddressForm(),
              SizedBox(height: 17),

              // AppTextField(
              //   controller: controller.city,
              //   label: l10n.enterCity,
              //   keyboardType: TextInputType.streetAddress,
              //   textInputAction: TextInputAction.next,
              //   onChanged: (_) => _onAddressChanged(),
              // ),
              // SizedBox(height: 17),
              // AppTextField(
              //   controller: controller.building,
              //   label: l10n.enterBuilding,
              //   validator: (value) => controller.validateBuilding(value, l10n),
              //   keyboardType: TextInputType.text,
              //   textInputAction: TextInputAction.next,
              //   onChanged: (_) => _onAddressChanged(),
              // ),
              // SizedBox(height: 17),
              // if (selected != l10n.villa) ...[
              //   Row(
              //     children: [
              //       Expanded(
              //         child: AppTextField(
              //           controller: controller.aptNo,
              //           keyboardType: TextInputType.number,
              //           textInputAction: TextInputAction.next,
              //           label: l10n.enterAptNo,
              //           onChanged: (_) => _onAddressChanged(),
              //           validator: (value) =>
              //               controller.validateAptNo(value, l10n),
              //         ),
              //       ),
              //       SizedBox(width: 10),
              //       Expanded(
              //         child: AppTextField(
              //           controller: controller.floor,
              //           keyboardType: TextInputType.number,
              //           textInputAction: TextInputAction.done,
              //           onChanged: (_) => _onAddressChanged(),
              //           label: l10n.enterFloorNo,
              //           validator: (value) =>
              //               controller.validateFloor(value, l10n),
              //         ),
              //       ),
              //     ],
              //   ),
              //   SizedBox(height: 17),
              // ],
              // Consumer(
              //   builder: (context, ref, child) {
              //     final blockAsync = ref.watch(getBlockProvider);

              //     return blockAsync.when(
              //       data: (blocks) {
              //         if (controller.block != null &&
              //             controller.roadsForSelectedBlock.isEmpty) {
              //           final selectedBlock = blocks.firstWhere(
              //             (b) => b['name'] == controller.block,
              //             orElse: () => {},
              //           );

              //           if (selectedBlock.isNotEmpty) {
              //             controller.roadsForSelectedBlock =
              //                 List<Map<String, dynamic>>.from(
              //                   selectedBlock['roads'] ?? [],
              //                 );
              //           }
              //         }
              //         return Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             /// BLOCK FIRST
              //             AppDropdown(
              //               label: l10n.selectBlock,
              //               items: blocks
              //                   .map((b) => b['name'] as String)
              //                   .toList(),
              //               value:
              //                   blocks.any((b) => b['name'] == controller.block)
              //                   ? controller.block
              //                   : null,
              //               onChanged: (val) {
              //                 _onAddressChanged();
              //                 setState(() {
              //                   final block = blocks.firstWhere(
              //                     (b) => b['name'] == val,
              //                   );
              //                   controller.block = block['name'];
              //                   controller.blockId = block['_id'];
              //                   controller.road = null;
              //                   controller.roadId = null;

              //                   controller.roadsForSelectedBlock =
              //                       List<Map<String, dynamic>>.from(
              //                         block['roads'],
              //                       );
              //                 });
              //               },
              //               validator: (val) =>
              //                   val == null ? l10n.pleaseSelectBlock : null,
              //             ),

              //             SizedBox(height: 15),

              //             /// ROAD SECOND
              //             AppDropdown(
              //               label: l10n.selectRoad,
              //               items: controller.roadsForSelectedBlock
              //                   .map((r) => r['name'] as String)
              //                   .toList(),
              //               value:
              //                   controller.roadsForSelectedBlock.any(
              //                     (r) => r['name'] == controller.road,
              //                   )
              //                   ? controller.road
              //                   : null,
              //               onChanged: (val) {
              //                 _onAddressChanged();
              //                 setState(() {
              //                   final road = controller.roadsForSelectedBlock
              //                       .firstWhere((r) => r['name'] == val);

              //                   controller.road = road['name'];
              //                   controller.roadId = road['_id'];
              //                 });
              //               },
              //               validator: (val) =>
              //                   val == null ? l10n.pleaseSelectRoad : null,
              //             ),
              //           ],
              //         );
              //       },
              //       loading: () => const CircularProgressIndicator(),
              //       error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
              //     );
              //   },
              // ),
              if (!widget.isprofile && widget.family && _canContinue)
                AppButton(
                  text: l10n.continueBtn,
                  isLoading: _isLoading,
                  onPressed: _handleContinue,
                  color: AppColors.btn_primery,
                  width: double.infinity,
                ),
              if (!widget.isprofile && !widget.family && _canContinue)
                AppButton(
                  text: widget.accountType == "Family"
                      ? l10n.continueBtn
                      : l10n.continueBtn,
                  isLoading: _isLoading,
                  onPressed: () {
                    if (!_validateManualForm() || !controller.isComplete) {
                      if (!controller.isComplete) {
                        SnackbarHelper.showError(context, l10n.addAddressError);
                      }
                      return;
                    }
                    familyAccount(context);
                  },
                  color: AppColors.btn_primery,
                  width: double.infinity,
                ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
