import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/confirm_dialog.dart';
import 'package:nadi_user_app/widgets/id_card.dart';

class UploadIdView extends StatefulWidget {
  const UploadIdView({super.key});

  @override
  State<UploadIdView> createState() => _UploadIdViewState();
}

class _UploadIdViewState extends State<UploadIdView> {
  File? frontImage;
  File? backImage;
  final AuthService _authService = AuthService();
  final ImagePicker picker = ImagePicker();
  bool _isLoading = false;

  Future<void> pickImage(bool isFront, ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      if (isFront) {
        frontImage = File(image.path);
      } else {
        backImage = File(image.path);
      }
    });
  }

  Future<bool> _confirmExit() async {
    final loc = AppLocalizations.of(context)!;
    return await showConfirmDialog(
      context,
      title: loc.discardSignUpTitle,
      message: loc.discardSignUpMessage,
      confirmText: loc.discard,
      icon: Icons.warning_amber_rounded,
      destructive: true,
    );
  }

  Future<void> _handleBack() async {
    final ok = await _confirmExit();
    if (ok && context.mounted) {
      context.push(RouteNames.Account);
    }
  }

  Future<void> UploadIDproof(BuildContext context) async {
    if (frontImage == null || backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.uploadIdError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await AppPreferences.getUserId();
      if (userId == null) throw Exception("User not found");

      final response = await _authService.uploadIdProof(
        frontImage: frontImage!,
        backImage: backImage!,
        userId: userId,
      );

      if (response != null) {
        if (!context.mounted) return;
        context.push(RouteNames.Terms);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: AppColors.app_background_clr,
          elevation: 0,
          centerTitle: true,

          title: Text(
            AppLocalizations.of(context)!.signUp,
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
                    onPressed: () => _handleBack(),
                  ),
                ),
              ),
            ),
          ),
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // const Divider(height: 1),
            SizedBox(height: 5),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.uploadIdTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Skip Button
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              context.push(RouteNames.Terms);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.app_background_clr
                                      .withOpacity(0.4),
                                ),
                                color: AppColors.app_background_clr.withOpacity(
                                  0.08,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.skip,
                                    style: TextStyle(
                                      color: AppColors.app_background_clr,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: AppColors.app_background_clr,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      IdCardSection(
                        title: AppLocalizations.of(context)!.uploadIdFrontTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.uploadIdSubtitle,
                        previewImage: frontImage,
                        onTakePhoto: () {
                          print("Take photo clicked");
                          pickImage(true, ImageSource.camera);
                        },
                        onUploadGallery: () {
                          print("Upload gallery clicked");
                          pickImage(true, ImageSource.gallery);
                        },
                      ),
                      const SizedBox(height: 20),
                      IdCardSection(
                        title: AppLocalizations.of(context)!.uploadIdBackTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.uploadIdSubtitle,
                        previewImage: backImage,
                        onTakePhoto: () {
                          print("Take photo clicked");
                          pickImage(false, ImageSource.camera);
                        },
                        onUploadGallery: () {
                          pickImage(false, ImageSource.gallery);
                          print("Upload gallery clicked");
                        },
                      ),
                      SizedBox(height: 20),
                      AppButton(
                        text: AppLocalizations.of(context)!.continueButton,
                        isLoading: _isLoading,
                        onPressed: () {
                          UploadIDproof(context);
                        },
                        color: AppColors.btn_primery,
                        width: double.infinity,
                      ),
                      SizedBox(height: 20),
                    ],
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
