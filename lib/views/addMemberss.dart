import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nadi_user_app/services/addAdditionalMember.dart';
import 'package:nadi_user_app/preferences/preferences.dart';

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
  const Addmemberss({super.key});
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
  String? relation;
  String? gender;
  bool _isLoading = false;
  bool _showAddress = false;

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
      "accountTypeId": "693175af976ca992c877f99d",
      "fullName": nameCtrl.text,
      "relation": relation?.toLowerCase(),
      "mobile": mobileCtrl.text,
      "email": emailCtrl.text,
      "password": "123456",
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
      String errorMsg = 'Failed to add member. Please try again.';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.somethingWentWrong}: ${e.toString()}',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: Text(loc.addMember),
        backgroundColor: AppColors.app_background_clr,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FULL NAME
              AppTextField(
                controller: nameCtrl,
                label: loc.memberFullName,
                validator: (v) => v!.isEmpty ? loc.nameValidation : null,
              ),
              const SizedBox(height: 15),

              /// RELATIONSHIP
              AppDropdown(
                label: loc.relationship,
                items: [
                  loc.spouse,
                  loc.father,
                  loc.mother,
                  loc.son,
                  loc.daughter,
                  loc.husband,
                  loc.wife,
                ],
                value: relation,
                onChanged: (val) => setState(() => relation = val),
                validator: (v) => v == null ? loc.selectRelationship : null,
              ),
              const SizedBox(height: 15),

              /// MOBILE
              AppTextField(
                controller: mobileCtrl,
                label: loc.mobileNumber,
                keyboardType: TextInputType.phone,
                prefixText: '+973 ',
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v == null || v.isEmpty ? loc.enterMobile : null,
              ),
              const SizedBox(height: 15),

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
              const SizedBox(height: 15),

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
                  onPressed: () {
                    setState(() {
                      _showAddress = !_showAddress;
                    });
                  },
                  child: Text(
                    _showAddress ? loc.hideAddress : loc.addAddress,
                    style: TextStyle(color: AppColors.btn_primery),
                  ),
                ),
              ),

              /// ✅ ADDRESS (WITH BLOCK + ROAD INSIDE)
              if (_showAddress)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Address(
                    accountType: "Family",
                    family: true,
                    formKey: _addressFormKey,
                    controller: addressController,
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
