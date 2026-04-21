import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/views/languagetoggle.dart';
import 'package:nadi_user_app/views/logoanimation.dart';
import 'package:nadi_user_app/views/onboarding/BottomCurveClipper.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF6374AE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/onboarding/1774802367129_PAGE-No1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    height: size.height * 0.35,
                    width: double.infinity,
                  ),
                  Positioned(top: 50, right: 20, child: const LanguageView()),
                  Positioned(
                    top: size.height * 0.20,
                    child: Text(
                      AppLocalizations.of(context)!.welcome,
                      style: const TextStyle(
                        fontSize: 35,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Image.asset("assets/images/logo.png", width: size.width * 0.65, height: size.width * 0.65, fit: BoxFit.contain),
              const SizedBox(height: 15),

              Image.asset("assets/icons/nadhil.png", height: 65),

              const SizedBox(height: 40),

              const LogoAnimation(),

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: AppButton(
                  text: AppLocalizations.of(context)!.getStarted,
                  onPressed: () {
                    context.go(RouteNames.about);
                  },
                  color: AppColors.btn_primery,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
