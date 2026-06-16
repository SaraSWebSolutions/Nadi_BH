import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/auth_provider.dart';
import 'package:nadi_user_app/services/profile_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/confirm_dialog.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/utils/address_display_helper.dart';
import 'package:nadi_user_app/views/auth/address_screen.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? basicData;
  List addresses = [];
  List familyMembers = [];
  final ImagePicker _pcker = ImagePicker();
  File? profileImage;
  String? profileImageUrl;
  late TextEditingController fullNameController;
  late TextEditingController firstNameController;
  late TextEditingController secondNameController;
  late TextEditingController thirdNameController;
  late TextEditingController fourthNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController buildingController;
  late TextEditingController blockController;
  late TextEditingController floorController;
  late TextEditingController apartmentController;
  late TextEditingController additionalInfoController;
  String? selectedBlock;
  String? selectedBlockId;

  String? selectedRoad;
  String? selectedRoadId;

  List<Map<String, dynamic>> roadsForSelectedBlock = [];
  final ProfileService _profileService = ProfileService();
  final AddressController _addressController = AddressController();
  AddressSource? _addressSource;
  bool _controllersInitialized = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("EDIT PROFILE OPENED");
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    // Read the passed data from GoRouter
    final profileResponse =
        GoRouterState.of(context).extra as Map<String, dynamic>;
    print("PROFILE RESPONSE => $profileResponse");
    print(profileResponse.keys);
    basicData = profileResponse['data'] as Map<String, dynamic>;
    print("BASIC DATA => $basicData");
    addresses = profileResponse['addresses'] as List;
    familyMembers = profileResponse['familyMembers'] as List;
    profileImageUrl = basicData?['basicInfo']?['image'];
    print("RAW IMAGE => $profileImageUrl");
    // print("FULL URL => ${AppConsts.imageBaseUrl}$profileImageUrl");
    // final imageValue = basicData?['basicInfo']?['image'];

    // print("IMAGE VALUE => $imageValue");

    // profileImageUrl = imageValue?.toString();
    //Initialize controllers with existing data
    if (addresses.isNotEmpty) {
      final blockData = addresses[0]['blockId'];
      final roadData = addresses[0]['roadId'];

      if (blockData is Map) {
        selectedBlock = blockData['name']?.toString();
        selectedBlockId = AddressController.sanitizeId(blockData['_id']);
      }

      if (roadData is Map) {
        selectedRoad = roadData['name']?.toString();
        selectedRoadId = AddressController.sanitizeId(roadData['_id']);
      }

      debugPrint("Selected Block => $selectedBlock ($selectedBlockId)");

      debugPrint("Selected Road => $selectedRoad ($selectedRoadId)");
    }
    fullNameController = TextEditingController(
      text: basicData?['basicInfo']['fullName'] ?? '',
    );
    firstNameController = TextEditingController(
      text: basicData?['basicInfo']['fullName'] ?? '',
    );

    secondNameController = TextEditingController(
      text: basicData?['basicInfo']['secondName'] ?? '',
    );

    thirdNameController = TextEditingController(
      text: basicData?['basicInfo']['thirdName'] ?? '',
    );

    fourthNameController = TextEditingController(
      text: basicData?['basicInfo']['fourthName'] ?? '',
    );
    emailController = TextEditingController(
      text: basicData?['basicInfo']['email'] ?? '',
    );
    mobileController = TextEditingController(
      text: basicData?['basicInfo']['mobileNumber']?.toString() ?? "",
    );
    buildingController = TextEditingController(
      text: addresses.isNotEmpty ? addresses[0]['building'] : '',
    );
    blockController = TextEditingController(
      text: addresses.isNotEmpty ? addresses[0]['city'] : '',
    );
    floorController = TextEditingController(
      text: addresses.isNotEmpty ? addresses[0]['floor']?.toString() : '',
    );
    apartmentController = TextEditingController(
      text: addresses.isNotEmpty ? addresses[0]['aptNo']?.toString() : '',
    );
    additionalInfoController = TextEditingController(text: "");

    if (addresses.isNotEmpty) {
      final addressMap = Map<String, dynamic>.from(addresses[0] as Map);
      _addressSource = AddressDisplayHelper.resolveSource(addressMap);
      _addressController.loadAddress(addressMap);
    }
  }

  Future<void> _openAddressEditor() async {
    if (addresses.isEmpty) return;

    final initial = _addressController.toMap();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          isEditMode: false,
          isFromMemberScreen: false,
          initialAddress: initial,
          isEditprofile: true,
          //currentLocation: _addressController.isGeoMode,
          // familyHeaderAddress: _addressSource == AddressSource.familyHeader
          //     ? initial
          //     : null,
          // initialAddress: initial,
        ),
      ),
    );

    if (!mounted || result == null) return;

    _addressController.loadAddress(result);
    _addressSource = _addressController.addressSource;

    setState(() {
      final isGeo = _addressController.isGeoMode;

      if (!isGeo) {
        buildingController.text = _addressController.building.text;
        blockController.text = _addressController.city.text;
        floorController.text = _addressController.floor.text;
        apartmentController.text = _addressController.aptNo.text;

        selectedBlock = _addressController.block;
        selectedBlockId = AddressController.sanitizeId(
          _addressController.blockId,
        );

        selectedRoad = _addressController.road;
        selectedRoadId = AddressController.sanitizeId(
          _addressController.roadId,
        );
      } else {
        // IMPORTANT: clear manual fields to avoid wrong payload
        buildingController.clear();
        blockController.clear();
        floorController.clear();
        apartmentController.clear();

        selectedBlock = null;
        selectedBlockId = null;
        selectedRoad = null;
        selectedRoadId = null;
      }
    });
  }

  Map<String, dynamic> _buildAddressPayload(String propertyType) {
    final isGeo = _addressController.isGeoMode;

    if (isGeo) {
      return {
        "isGeoAddress": true,
        "latitude": _addressController.latitude,
        "longitude": _addressController.longitude,
        "geoAddress": _addressController.geoAddress,
      };
    }

    final payload = <String, dynamic>{
      "isGeoAddress": false,
      "propertyType": propertyType,
      "building": buildingController.text.trim(),
      "city": blockController.text.trim(),
      "floor": floorController.text.trim(),
      "aptNo": apartmentController.text.trim(),

      "blockName": _addressController.customBlockName,
      "roadName": _addressController.customRoadName,
    };

    if (selectedBlockId != null && selectedBlockId!.isNotEmpty) {
      payload["blockId"] = selectedBlockId;
    }

    if (selectedRoadId != null && selectedRoadId!.isNotEmpty) {
      payload["roadId"] = selectedRoadId;
    }

    return payload;
  }

  @override
  void dispose() {
    _addressController.dispose();
    // Dispose controllers
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    buildingController.dispose();
    blockController.dispose();
    floorController.dispose();
    apartmentController.dispose();
    additionalInfoController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    thirdNameController.dispose();
    fourthNameController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _pcker.pickImage(source: source);
    if (image == null) return;
    final file = File(image.path);

    setState(() {
      profileImage = file;
    });
  }

  Future<void> saveProfile() async {
    setState(() => _isLoading = true);

    final userId = await AppPreferences.getUserId();
    final propertyType = addresses.isNotEmpty
        ? addresses[0]['propertyType']
        : "flat";
    // Ensure mobile number is numeric
    final mobileNumber = int.tryParse(mobileController.text.trim());
    if (mobileNumber == null) {
      AppLogger.error(" Invalid mobile number");
      return;
    }
    // if (floorController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text("Floor number is required")));

    //   setState(() => _isLoading = false); // ✅ FIX
    //   return;
    // }
    final addressPayload = _buildAddressPayload(propertyType.toString());
    print("ADDRESS PAYLOAD => $addressPayload");
    // Build payload as Map (not JSON string)
    final Map<String, dynamic> payload = {
      "userId": userId,
      "basicInfo": {
        "fullName": firstNameController.text.trim(),
        "secondName": secondNameController.text.trim(),
        "thirdName": thirdNameController.text.trim(),
        "fourthName": fourthNameController.text.trim(),
        "email": emailController.text.trim(),
        "mobileNumber": mobileNumber,
      },
      "address": _buildAddressPayload(propertyType.toString()),
    };

    // Convert to FormData
    final Map<String, dynamic> formMap = {
      ...payload,
      if (profileImage != null)
        "image": await MultipartFile.fromFile(
          profileImage!.path,
          filename: profileImage!.path.split('/').last,
        ),
    };

    final formData = FormData.fromMap(formMap);

    AppLogger.info(" FormData payload keys: ${formMap.keys}");
    if (profileImage != null) {
      AppLogger.info(" Image Path: ${profileImage!.path}");
    }

    try {
      final response = await _profileService.editProfile(formData: formData);
      print("EDIT PROFILE RESPONSE => $response");
      // Update local cacheprint
      //("Custom Block: ${_addressController.customBlockName.text}");
      final updatedProfile = {
        "data": {
          "basicInfo": {
            "fullName": fullNameController.text.trim(),
            "email": emailController.text.trim(),
            "mobileNumber": mobileNumber,
            "image": response?['data']?['basicInfo']?['image'],
          },
        },
        "addresses": [
          {
            "building": buildingController.text.trim(),
            "city": blockController.text.trim(),
            "floor": floorController.text.trim(),
            "aptNo": apartmentController.text.trim(),

            // "blockId": {"_id": selectedBlockId, "name": selectedBlock},

            // "roadId": {"_id": selectedRoadId, "name": selectedRoad},
            "blockId": {
              "_id": selectedBlockId,
              "name": selectedBlock == "Others"
                  ? _addressController.customBlockName
                  : selectedBlock,
            },

            "roadId": {
              "_id": selectedRoadId,
              "name": selectedRoad == "Others"
                  ? _addressController.customRoadName
                  : selectedRoad,
            },
          },
        ],
        "familyMembers": familyMembers,
      };

      AppLogger.info("Updated Local Profile Cache: $updatedProfile");
      await AppPreferences.saveProfileData(updatedProfile);

      if (mounted) context.pop(true);
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"]?.toString() ??
          AppLocalizations.of(context)!.somethingWentWrong;
      SnackbarHelper.showError(context, message);
    } catch (e, stack) {
      AppLogger.error(stack.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final propertyType =
        (addresses.isNotEmpty ? addresses[0]['addressType'] : "flat")
            .toString()
            .toLowerCase()
            .trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.editProfile,
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
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: profileImage != null
                                    ? FileImage(profileImage!)
                                    : (profileImageUrl != null &&
                                          profileImageUrl!.isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        "${ImageBaseUrl.baseUrl}/$profileImageUrl",
                                      )
                                    : null,
                                child:
                                    profileImage == null &&
                                        (profileImageUrl == null ||
                                            profileImageUrl!.isEmpty)
                                    ? Container(
                                        height: 120,
                                        width: 120,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      )
                                    : null,
                              ),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    pickImage(ImageSource.gallery);
                                  },
                                  child: Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.app_background_clr,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // // Full Name
                        // Text(
                        //   loc.fullName,
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        // // const SizedBox(height: 5),
                        // AppTextField(
                        //   controller: fullNameController,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.allow(
                        //       RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                        //     ),
                        //   ],
                        //   validator: (v) => (v == null || v.trim().isEmpty)
                        //       ? loc.fullNameRequired
                        //       : null,
                        // ),
                        // const SizedBox(height: 6),
                        Text(
                          loc.firstName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        AppTextField(
                          controller: firstNameController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? loc.fullNameRequired
                              : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          loc.secondName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        AppTextField(
                          controller: secondNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          loc.thirdName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        AppTextField(
                          controller: thirdNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          loc.fourthName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        AppTextField(
                          controller: fourthNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        // Email Address
                        Text(
                          loc.emailAddress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AppTextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return loc.emailRequired;
                            }
                            if (!RegExp(
                              r'^[\w.-]+@[\w.-]+\.\w+$',
                            ).hasMatch(v.trim())) {
                              return loc.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),

                        // Phone Number
                        Text(
                          loc.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AppTextField(
                          controller: mobileController,
                          keyboardType: TextInputType.number,
                          prefixText: "+973 ",
                          maxLength: 8,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],

                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return loc.mobileNumberRequired;
                            }

                            if (value.length != 8) {
                              return loc.phoneMustBe8Digits;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          loc.addressTypeLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AppTextField(
                          controller: TextEditingController(
                            text: AddressDisplayHelper.sourceLabel(
                              _addressSource,
                              l10n: loc,
                            ),
                          ),
                          readonly: true,
                          enabled: false,
                        ),
                        const SizedBox(height: 10),
                        if (AddressDisplayHelper.isGeoAddress(
                          _addressController.toMap(),
                        )) ...[
                          Text(
                            loc.fullLocationAddressLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          AppTextField(
                            controller: TextEditingController(
                              text:
                                  _addressController.geoAddress ??
                                  _addressController.fullAddress ??
                                  '',
                            ),
                            readonly: true,
                            enabled: false,
                            minLines: 2,
                            maxLines: 4,
                          ),
                        ] else ...[
                          Text(
                            loc.address,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          AppTextField(
                            controller: TextEditingController(
                              text: AddressDisplayHelper.formatProfileAddress(
                                _addressController.toMap(),
                                // Map<String, dynamic>.from(addresses[0]),
                                l10n: loc,
                              ),
                            ),
                            readonly: true,
                            enabled: false,
                            minLines: 2,
                            maxLines: 5,
                          ),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openAddressEditor,
                            icon: const Icon(Icons.edit_location_alt),
                            label: Text(
                              AddressDisplayHelper.isGeoAddress(
                                    _addressController.toMap(),
                                  )
                                  ? loc.editLocation
                                  : loc.editAddress,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: loc.cancel,
                                onPressed: () {
                                  context.pop();
                                },
                                color: AppColors.btn_primery,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: AppButton(
                                text: loc.save,
                                isLoading: _isLoading,

                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final confirmed = await showConfirmDialog(
                                    context,
                                    title: loc.saveChangesTitle,
                                    message: loc.saveChangesMessage,
                                    confirmText: loc.save,
                                    icon: Icons.save_outlined,
                                  );

                                  if (!confirmed) return;

                                  await saveProfile();
                                },
                                color: AppColors.app_background_clr,
                                width: double.infinity,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
