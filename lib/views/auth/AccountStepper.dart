import 'package:flutter/material.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/views/auth/AccountFormView.dart';
import 'package:nadi_user_app/views/auth/AddMember.dart';
import 'package:nadi_user_app/views/auth/Address.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/confirm_dialog.dart';

class AccountStepper extends StatefulWidget {
  final String accountType; // "Individual" or "Family"

  const AccountStepper({super.key, required this.accountType});

  @override
  State<AccountStepper> createState() => _AccountStepperState();
}

class _AccountStepperState extends State<AccountStepper> {
  int _currentStep = 0;
  final AuthService _authService = AuthService();
  final _formKeyIndividual = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();
  final _formKeyAddMember = GlobalKey<FormState>();
  final addressController = AddressController();

  String _localizedAccountType(AppLocalizations loc) {
    switch (widget.accountType) {
      case "Family":
        return loc.family;
      case "Individual":
        return loc.individual;
      default:
        return widget.accountType;
    }
  }

  Future<void> _discardSignup() async {
    debugPrint("===== _discardSignup CALLED =====");

    try {
      final userId = await AppPreferences.getUserId();

      debugPrint("Retrieved UserId: $userId");

      if (userId == null) {
        debugPrint("User ID is NULL");
        return;
      }

      debugPrint("Calling discard API...");

      await _authService.discardAccount(userId);

      debugPrint("Account discarded successfully");
    } catch (e, stackTrace) {
      debugPrint("Discard failed: $e");
      debugPrint(stackTrace.toString());
    }
  }

  Widget _buildStep() {
    final loc = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case 0:
        return AccountFormView(
          key: const ValueKey(0),
          accountType: widget.accountType,
          formKey: _formKeyIndividual,
          onNext: () {
            if (_formKeyIndividual.currentState!.validate()) {
              setState(() => _currentStep = 1);
            }
          },
        );

      case 1:
        return Address(
          key: const ValueKey(1),
          accountType: widget.accountType,
          formKey: _formKeyAddress,
          controller: addressController,
          onNext: () {
            if (_formKeyAddress.currentState!.validate()) {
              setState(() {
                if (widget.accountType == "Family") {
                  _currentStep = 2;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.accountCreatedSuccessfully)),
                  );
                }
              });
            }
          },
        );

      case 2:
        return Addmember(
          key: const ValueKey(2),
          accountType: widget.accountType,
          formKey: _formKeyAddMember,
          onNext: () {
            if (_formKeyAddMember.currentState!.validate()) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.completedExclamation)));
            }
          },
        );

      default:
        return const SizedBox();
    }
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    List<String> stepTitles = widget.accountType == "Family"
        ? [loc.family, loc.address, loc.member]
        : [loc.account, loc.address];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldExit = await _confirmExit();

        if (!shouldExit) return;
        debugPrint("BACK BUTTON PRESSED");

        await _discardSignup();

        if (!mounted) return;
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            loc.accountTypeStepperTitle(_localizedAccountType(loc)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.app_background_clr,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,

          leadingWidth: 56,

          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 38,
                height: 38,
                child: FittedBox(
                  child: AppCircleIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () async {
                      debugPrint("APP BAR BACK CLICKED");

                      final navigator = Navigator.of(context);

                      final shouldExit = await _confirmExit();

                      debugPrint("shouldExit = $shouldExit");

                      if (!shouldExit) return;

                      await _discardSignup();

                      navigator.pop();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        body: Column(
          children: [
            // CUSTOM STEPPER
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 5,
                left: 20,
                right: 20,
              ),
              child: CustomStepper(
                currentStep: _currentStep,
                titles: stepTitles,
              ),
            ),

            const SizedBox(height: 10),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 3,
                ),

                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(1, 0), //  Right to Left
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(position: slide, child: child);
                  },
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//   CUSTOM STEPPER UI

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<String> titles;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(titles.length * 2 - 1, (index) {
        if (index.isEven) {
          int stepIndex = index ~/ 2;

          bool isActive = stepIndex == currentStep;
          bool isCompleted = stepIndex < currentStep;

          return Column(
            children: [
              // ---------- CIRCLE ----------
              CircleAvatar(
                radius: 10,
                backgroundColor: isActive || isCompleted
                    ? AppColors.app_background_clr
                    : Colors.grey.shade400,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        "${stepIndex + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 5),

              // ---------- LABEL ----------
              Text(
                titles[stepIndex],
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? AppColors.app_background_clr
                      : Colors.grey.shade500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        } else {
          int leftStep = index ~/ 2;

          bool isLeftCompleted = leftStep < currentStep;

          return Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                height: 2,
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isLeftCompleted
                    ? AppColors.app_background_clr
                    : Colors.grey.shade300,
              ),
            ),
          );
        }
      }),
    );
  }
}
