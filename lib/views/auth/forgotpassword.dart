import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> emailVerify() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailCtrl.text.trim();
      AppLogger.warn("Email: $email");

      final response = await _authService.Forgetpassword(email: email);

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? loc.resetEmailSentCheckInbox),
            backgroundColor: AppColors.btn_primery,
            duration: const Duration(seconds: 4),
          ),
        );
        // Go back to login — user will reset password via the link in their email
        context.pop();
      }
    } catch (e) {
      AppLogger.error("$e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final loc = AppLocalizations.of(context)!;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/onboarding/1774802367130_PAGE-No3.png",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          /// CONTENT
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        /// TOP SPACE
                        SizedBox(
                          height: isIOS
                              ? size.height * 0.36
                              : size.height * 0.38,
                        ),

                        /// WHITE CONTAINER
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight:
                                size.height -
                                (isIOS
                                    ? size.height * 0.60
                                    : size.height * 0.40),
                          ),
                          //constraints: BoxConstraints(minHeight: size.height),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                Text(
                                  loc.forgotPassword,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                AppTextField(
                                  label: loc.enterEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailCtrl,
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

                                const SizedBox(height: 30),

                                AppButton(
                                  height: 48,
                                  width: double.infinity,
                                  color: AppColors.btn_primery,
                                  text: loc.sendEmail,
                                  isLoading: _isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      emailVerify();
                                    }
                                  },
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// BACK BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  GoRouter.of(context).go('/login');
                },
                child: Container(
                  margin: const EdgeInsets.all(12),
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRTL ? Icons.arrow_forward : Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
