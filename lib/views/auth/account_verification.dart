import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

class AccountVerification extends StatefulWidget {
  const AccountVerification({super.key});

  @override
  State<AccountVerification> createState() => _AccountVerificationState();
}

class _AccountVerificationState extends State<AccountVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            Container(
              height: 177,
              width: 177,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.app_background_clr,
              ),
              child: const Icon(
                Icons.perm_identity,
                size: 90,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              AppLocalizations.of(context)!.accountVerificationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.xLarge,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.accountVerificationDesc1,
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        height: 1.7,
                      ),
                    ),

                    Text(
                      AppLocalizations.of(context)!.accountVerificationDesc2,
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        height: 1.7,
                      ),
                    ),

                    Text(
                      AppLocalizations.of(context)!.accountVerificationDesc1,
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppLocalizations.of(context)!.accountVerificationDesc2,
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        height: 1.7,
                        color: AppColors.app_background_clr,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            AppButton(
              text: AppLocalizations.of(context)!.continueButton,
              onPressed: () {
                context.push(RouteNames.uploadcard);
              },
              color: AppColors.btn_primery,
              width: double.infinity,
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
