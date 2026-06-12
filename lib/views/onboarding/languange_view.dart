import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

class LanguangeView extends ConsumerStatefulWidget {
  const LanguangeView({super.key});

  @override
  ConsumerState<LanguangeView> createState() => _LanguangeViewState();
}

class _LanguangeViewState extends ConsumerState<LanguangeView> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    return Scaffold(
      body: Stack(
        children: [
          /// ✅ Background Image (Perfect Fit)
          Positioned.fill(
            child: Image.asset(
              "assets/images/onboarding/1774802367130_PAGE-No2.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          /// ✅ Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Spacer(), // 👈 ensures container stays at bottom

                Expanded(
                  flex: 0, // 👈 prevent unwanted stretching issue
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // 👈 important fix
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.chooseTheLanguage,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppFontSizes.xLarge,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 30),

                          AppButton(
                            text: "عربي",
                            onPressed: () async {
                              ref
                                  .read(languageProvider.notifier)
                                  .changeLanguage('ar');
                              await Future.delayed(const Duration(seconds: 1));
                              if (!context.mounted) return;
                              context.go(RouteNames.welcome);
                            },
                            color: AppColors.btn_primery,
                            width: double.infinity,
                          ),

                          const SizedBox(height: 25),

                          AppButton(
                            text: AppLocalizations.of(context)!.englishLanguage,
                            onPressed: () async {
                              ref
                                  .read(languageProvider.notifier)
                                  .changeLanguage('en');
                              setState(() => _isLoading = true);

                              await Future.delayed(const Duration(seconds: 1));
                              if (!context.mounted) return;
                              context.go(RouteNames.welcome);
                            },
                            color: AppColors.button_secondary,
                            width: double.infinity,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            AppLocalizations.of(context)!
                                .languagePreferenceChangeHint,
                            style: const TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              color: Color(0xFF79747E),
                            ),
                          ),
                        ],
                      ),
                    ),
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
