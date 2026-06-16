import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nadi_user_app/services/addAdditionalMember.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/views/auth/Address.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/providers/profile_provider.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class Addmemberss extends ConsumerStatefulWidget {
  final String accountTypeId;
  final Map<String, dynamic>? familyHeadAddress;

  const Addmemberss({
    super.key,
    required this.accountTypeId,
    this.familyHeadAddress,
  });

  @override
  ConsumerState<Addmemberss> createState() => _AddmemberssState();
}

class _AddmemberssState extends ConsumerState<Addmemberss> {
  final _formKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final AddAdditionalMember _authService = AddAdditionalMember();
  final AddressController addressController = AddressController();
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool _highlightAddress = false;
  final GlobalKey _addressSectionKey = GlobalKey();

  String? relation;
  String? gender;
  bool _isLoading = false;
  bool _showAddress = false;
  @override
  void initState() {
    super.initState();

    try {
      print("familyHeadAddress => ${widget.familyHeadAddress}");

      if (widget.familyHeadAddress != null) {
        addressController.loadAddress(widget.familyHeadAddress!);

        addressController.addressSource = AddressSource.familyHeader;

        _showAddress = true;
      }
    } catch (e, s) {
      print("INIT ERROR => $e");
      print(s);
    }
  }

  // ADD MEMBER API
  Future<void> _addMember() async {
    final loc = AppLocalizations.of(context)!;
    final isValid = _formKey.currentState!.validate();
    final isMemberValid = _formKey.currentState!.validate();

    /// 1️⃣ FIRST: Validate MEMBER fields
    if (!isMemberValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseFillMemberDetails),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_showAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.addAddressError,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isAddressValid = _addressFormKey.currentState!.validate();
    if (!isValid || !isAddressValid) return;

    final userId = await AppPreferences.getUserId();
    if (userId == null) return;
    // BUILD BODY (CORRECT FORMAT)
    final body = {
      "userId": userId,
      // "accountTypeId": widget.accountTypeId,
      "fullName": nameCtrl.text,
      "relation": relation?.toLowerCase(),
      "mobile": mobileCtrl.text,
      "email": emailCtrl.text,
      // "password": "123456",
      "gender": gender?.toLowerCase(),
      if (_showAddress)
        "address": {
          "city": addressController.city.text,
          "addressType": "flat",
          "floor": addressController.floor.text,
          "building": addressController.building.text,
          "aptNo": addressController.aptNo.text,
          "roadId": addressController.roadId,
          "blockId": addressController.blockId,
        },
    };

    setState(() => _isLoading = true);

    try {
      final response = await AddAdditionalMember().addAdditionalMember(
        body: body,
      );
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.memberAddedSuccessfully,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh profile data natively
      ref.invalidate(profileprovider);

      if (mounted) {
        GoRouter.of(context).pop(true);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMsg = AppLocalizations.of(context)!.failedToAddMemberTryAgain;
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMsg =
              data['message'] ?? data['error'] ?? data['msg'] ?? errorMsg;
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final fieldErrors = errors.values
                .map((v) => v is List ? v.first : v.toString())
                .join(', ');
            if (fieldErrors.isNotEmpty) errorMsg = fieldErrors;
          }
        } else if (data is String) {
          errorMsg = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = loc.connectionTimeoutTryAgain;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = loc.noInternetTryAgain;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String errorMsg = e.toString();

      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddressSection() async {
    setState(() {
      _showAddress = true;
      _highlightAddress = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final context = _addressSectionKey.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _highlightAddress = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.addMember,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// FULL NAME
              AppTextField(
                controller: nameCtrl,
                label: loc.memberFullName,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                  ),
                ],
                validator: (v) => v!.isEmpty ? loc.enter_memberFullName : null,
              ),
              const SizedBox(height: 10),

              /// RELATIONSHIP
              AppDropdown(
                label: loc.relationship,
                items: [
                  // loc.spouse,
                  // loc.father,
                  // loc.mother,
                  // loc.son,
                  // loc.daughter,
                  // loc.husband,
                  // loc.wife,
                  loc.father,
                  loc.mother,
                  loc.son,
                  loc.daughter,
                  loc.husband,
                  loc.wife,
                  loc.addOther,
                ],
                value: relation,
                onChanged: (val) => setState(() => relation = val),
                validator: (v) => v == null ? loc.selectRelationship : null,
              ),
              const SizedBox(height: 10),

              /// MOBILE
              AppTextField(
                controller: mobileCtrl,
                label: loc.mobileNumber,
                keyboardType: TextInputType.phone,
                prefixText: '+973 ',
                maxLength: 8,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8), // 🔥 MUST ADD
                ],
                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return loc.enterMobile;
                  }

                  if (v.trim().length != 8) {
                    return loc.mobileNumberMustBe8Digits;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),

              /// EMAIL
              AppTextField(
                controller: emailCtrl,
                label: "${loc.emailAddress} *",
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return loc.enterEmail;
                  }

                  final emailRegex = RegExp(
                    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                  );

                  if (!emailRegex.hasMatch(v.trim())) {
                    return loc.enterValidEmail;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),

              /// GENDER
              AppDropdown(
                label: loc.gender,
                items: [loc.male, loc.female],
                value: gender,
                onChanged: (val) => setState(() => gender = val),
                validator: (v) => v == null ? loc.selectGender : null,
              ),

              const SizedBox(height: 20),

              /// ADDRESS TOGGLE BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (!_showAddress) {
                      _showAddressSection();
                    } else {
                      setState(() {
                        _showAddress = false;
                      });
                    }
                  },
                  child: Text(
                    _showAddress ? loc.hideAddress : loc.addAddress,
                    style: TextStyle(color: AppColors.btn_primery),
                  ),
                ),
              ),

              /// ✅ ADDRESS (WITH BLOCK + ROAD INSIDE)
              if (_showAddress)
                AnimatedContainer(
                  key: _addressSectionKey,
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _highlightAddress
                          ? AppColors.button_secondary
                          : Colors.transparent,
                      width: 2,
                    ),
                    color: _highlightAddress
                        ? AppColors.button_secondary.withOpacity(.08)
                        : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Address(
                        isFromMemberScreen: true,
                        familyHeaderAddress: widget.familyHeadAddress,
                        accountType: "Family",
                        isEditprofile: false,
                        family: true,
                        isprofile: true,
                        formKey: _addressFormKey,
                        controller: addressController,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              /// SUBMIT BUTTON
              AppButton(
                text: loc.addMember,
                isLoading: _isLoading,
                onPressed: _addMember,
                color: AppColors.btn_primery,
                width: double.infinity,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
