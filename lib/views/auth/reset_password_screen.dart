import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(
        token: _tokenCtrl.text.trim(),
        newPassword: _passwordCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.passwordResetSuccessful),
            backgroundColor: Colors.green,
          ),
        );
        context.go(RouteNames.login);
      }
    } catch (e) {
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/onboarding/1774802367130_PAGE-No3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Flexible(child: SizedBox(height: MediaQuery.of(context).size.height * 0.35)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.resetPasswordTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.resetPasswordInstructions,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 24),

                          /// Reset token
                          AppTextField(
                            label: loc.resetTokenFromEmail,
                            controller: _tokenCtrl,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return loc.enterResetTokenFromEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          /// New password
                          AppTextField(
                            label: loc.newPassword,
                            controller: _passwordCtrl,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.trim().length < 6) {
                                return loc.passwordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          /// Confirm password
                          AppTextField(
                            label: loc.confirmPasswordLabel,
                            controller: _confirmCtrl,
                            isPassword: true,
                            validator: (v) {
                              if (v != _passwordCtrl.text) {
                                return loc.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : AppButton(
                                  height: 48,
                                  width: double.infinity,
                                  color: AppColors.btn_primery,
                                  text: loc.resetPasswordTitle,
                                  
                                  onPressed: _submit,
                                ),

                          const SizedBox(height: 16),

                          Center(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                loc.back,
                                style: TextStyle(
                                  color: AppColors.btn_primery,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
