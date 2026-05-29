import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

class TermsAndConditions extends ConsumerStatefulWidget {
  const TermsAndConditions({super.key});

  @override
  ConsumerState<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends ConsumerState<TermsAndConditions> {
  bool isChecked = false;
  bool _isLoading = false;
  bool _isFetchingTerms = true;
  String termsContent = "";
  String? errorMessage;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    setState(() {
      _isFetchingTerms = true;
      errorMessage = null;
    });

    try {
      // Use ref.read here to get languageProvider value outside build
      final local = ref.read(languageProvider);
      final lang = local.languageCode;

      final response = await _authService.TermsAndConditionlist(lang);

      final content = response['data']?[0]?['content'];
      if (content == null || content.isEmpty) {
        setState(() {
          errorMessage = "No terms available at the moment.";
        });
      } else {
        setState(() {
          termsContent = content;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load terms. Please try again later.";
      });
    } finally {
      setState(() => _isFetchingTerms = false);
    }
  }

  Future<void> completeRegistration(BuildContext context) async {
    if (!isChecked) return;

    setState(() => _isLoading = true);

    try {
      final userId = await AppPreferences.getUserId();
      final fcmToken = await AppPreferences.getfcmToken();

      await _authService.TermsAndSonditions(
        userId: userId!,
        fcmToken: fcmToken,
      );

      if (!context.mounted) return;
      context.push(RouteNames.opt);
    } catch (e) {
      debugPrint("CompleteRegistration error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          l10n.termsTitle,
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrey),
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),

              child: _isFetchingTerms
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: AppFontSizes.medium,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ourCommitments,
                          style: TextStyle(
                            color: AppColors.app_background_clr,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          termsContent,
                          style: TextStyle(
                            fontSize: AppFontSizes.small,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderGrey.withOpacity(0.5),
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: AppColors.app_background_clr,
                    checkColor: Colors.white,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isChecked = newValue!;
                      });
                    },
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        l10n.agreeTerms,
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AppButton(
              text: l10n.completeRegistration,
              isLoading: _isLoading,
              onPressed: () => completeRegistration(context),

              color: isChecked
                  ? AppColors.btn_primery
                  : AppColors.button_secondary.withOpacity(0.5),

              width: double.infinity,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
