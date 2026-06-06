// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/auth_service.dart';
// import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
// import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
// import 'package:pinput/pinput.dart';

// class SignInOtp extends StatefulWidget {
//   const SignInOtp({super.key});

//   @override
//   State<SignInOtp> createState() => _SignInOtpState();
// }

// class _SignInOtpState extends State<SignInOtp> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _otpController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _showOtp = false;
//   bool _isOtpError = false;

//   final defaultPinTheme = PinTheme(
//     width: 50,
//     height: 50,
//     textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: AppColors.btn_primery),
//     ),
//   );

//   final errorPinTheme = PinTheme(
//     width: 50,
//     height: 50,
//     textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.red),
//     ),
//   );

//   Future<void> sendOtp() async {
//     try {
//       final mobileNumber = _phoneController.text;
//       final response = await _authService.OTPwithphone(
//         mobileNumber: mobileNumber,
//       );
//       AppLogger.warn("phone with otp $response");
//       setState(() => _showOtp = true);
//       if (response != null) {
//         setState(() => _showOtp = true);
//         final otp = response['otp'].toString();

//         ///  SHOW SNACKBAR
//         SnackbarHelper.ShowSuccess(context, otp);

//         Future.delayed(const Duration(seconds: 1), () {});
//       }
//     } catch (e) {
//       AppLogger.error("Send otp with phone $e");
//     }
//   }

//   Future<void> OTPphoneverify()async{
//     final otp = _otpController.text.trim();
//     final mobileNumber = _phoneController.text;
//       try{
//     final response = await _authService.OTPphoneverify(
//       otp: otp,
//        mobileNumber: mobileNumber
//        );
//        AppLogger.warn("OTPphoneverify $response");
//        if(response != null){
//            await AppPreferences.saveToken(response['token']);
//            await AppPreferences.saveAccountType(response['accountType']);
//            await AppPreferences.saveUserId(response['userId']);
//             context.go(RouteNames.bottomnav);
//        }

//       }catch(e){
//         AppLogger.error("OTPphoneverify $e");
//       }
//   }

//   @override
//   Widget build(BuildContext context) {
//      final size = MediaQuery.of(context).size;
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/back.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                         SizedBox(height: size.height * 0.03),

//                         /// LOGO (Responsive)
//                         Image.asset(
//                           "assets/images/logo.png",
//                           height: size.height * 0.5,
//                         ),
//                           SizedBox(height: size.height * 0.03),
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 17,
//                       vertical: 17,
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 20),
//                           const Text(
//                             "Sign In with OTP",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                           ),
//                           const SizedBox(height: 20),

//                           // PHONE INPUT
//                           AppTextField(
//                             label: "Enter Phone Number",
//                             keyboardType: TextInputType.phone,
//                             controller: _phoneController,
//                             prefixText: "+973 ",
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "Please enter phone number";
//                               } else if (value.length != 8 ||
//                                   !RegExp(r'^[0-9]+$').hasMatch(value)) {
//                                 return "Phone number must be 8 digits";
//                               }
//                               return null;
//                             },
//                           ),

//                           const SizedBox(height: 20),
//                           if (!_showOtp) ...[
//                             AppButton(
//                               height: 48,
//                               width: double.infinity,
//                               color: AppColors.btn_primery,
//                               text: "Send OTP",
//                               onPressed: () async {
//                                 if (_formKey.currentState!.validate()) {
//                                   await sendOtp();
//                                 }
//                               },
//                             ),
//                           ],

//                           // OTP INPUT
//                           if (_showOtp) ...[
//                             const Text(
//                               "Enter OTP",
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             const SizedBox(height: 15),
//                             Center(
//                               child: Pinput(
//                                 controller: _otpController,
//                                 length: 4,
//                                 defaultPinTheme: defaultPinTheme,
//                                 focusedPinTheme: defaultPinTheme.copyWith(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.green),
//                                   ),
//                                 ),
//                                 submittedPinTheme: defaultPinTheme.copyWith(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.blue),
//                                   ),
//                                 ),
//                                 errorPinTheme: errorPinTheme,
//                                 forceErrorState: _isOtpError,
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) {
//                                   if (_isOtpError)
//                                     setState(() => _isOtpError = false);
//                                 },
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             AppButton(
//                               height: 48,
//                               width: double.infinity,
//                               color: AppColors.btn_primery,
//                               text: "Sign In",
//                               onPressed: () async {
//                                 if (_otpController.text.length == 4) {
//                                   await OTPphoneverify();
//                                 } else {
//                                   setState(() => _isOtpError = true);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text("Enter valid OTP"),
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],

//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/services/MqttNotificationService.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:pinput/pinput.dart';
import 'package:nadi_user_app/controllers/signup_controller.dart';

class SignInOtp extends StatefulWidget {
  const SignInOtp({super.key});

  @override
  State<SignInOtp> createState() => _SignInOtpState();
}

class _SignInOtpState extends State<SignInOtp> {
  final controller = SignupController();

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _showOtp = false;
  bool _isOtpError = false;
  bool _isLoading = false;
  bool _otpSent = false;
  int _secondsRemaining = 30;
  bool _canResendOtp = false;
  String? _otpErrorMessage;
  void _startOtpTimer() {
    _secondsRemaining = 30;
    _canResendOtp = false;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();

        setState(() {
          _canResendOtp = true;
        });
      }
    });
  }

  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    try {
      final mobileNumber = _phoneController.text;
      final fcmToken = await AppPreferences.getfcmToken();
      final response = await _authService.OTPwithphone(
        mobileNumber: mobileNumber,
        fcmToken: fcmToken,
      );
      AppLogger.warn("phone with otp $response");

      if (response != null) {
        if (!mounted) return;
        setState(() {
          _showOtp = true;
          _otpSent = true;
        });
        _startOtpTimer();
        final otp = response['otp'].toString();
        SnackbarHelper.ShowSuccess(context, otp);
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Something went wrong';
      AppLogger.error("Send otp with phone: $message");
      if (!mounted) return;
      if (message.toString().toLowerCase().contains('disabled')) {
        _showAccountDisabledDialog();
      } else if (message.toString().toLowerCase().contains('reject')) {
        _showAccountRejectedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error("Send otp with phone $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> OTPphoneverify() async {
    setState(() => _isLoading = true);

    final otp = _otpController.text.trim();
    final mobileNumber = _phoneController.text;
    try {
      final response = await _authService.OTPphoneverify(
        otp: otp,
        mobileNumber: mobileNumber,
      );
      AppLogger.warn("OTPphoneverify $response");
      await AppPreferences.saveToken(response['token']);
      await AppPreferences.saveAccountType(response['accountType']);
      await AppPreferences.saveUserId(response['userId']);
      await AppPreferences.setLoggedIn(true);
      // Connect MQTT for chat notifications
      final savedUserId = response['userId'];
      if (savedUserId != null) {
        MqttNotificationService.connect(savedUserId);
      }
      if (!context.mounted) return;
      context.go(
        RouteNames.bottomnav,
      ); // ignore: use_build_context_synchronously
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Something went wrong';
      AppLogger.error("OTPphoneverify: $message");
      if (!mounted) return;
      if (message.toString().toLowerCase().contains('disabled')) {
        _showAccountDisabledDialog();
      } else if (message.toString().toLowerCase().contains('reject')) {
        _showAccountRejectedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error("OTPphoneverify $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAccountDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block, color: Colors.red.shade600, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Account Disabled",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your account has been disabled. Please contact our support team for assistance.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.app_background_clr,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "+973 17000000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.app_background_clr,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "support@nadibh.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.app_background_clr,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountRejectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.orange.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Account Rejected",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your account registration has been rejected. Please contact our support team for more information.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.app_background_clr,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "+973 17000000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.app_background_clr,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "support@nadibh.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.app_background_clr,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : AppColors.btn_primery,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.green, width: 1.5),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.red, width: 1.5),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,

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
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: size.height),
                    child: Column(
                      children: [
                        /// TOP SPACE
                        SizedBox(
                          height: isIOS
                              ? size.height * 0.36
                              : size.height * 0.38,
                        ),

                        /// FORM CONTAINER
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight:
                                size.height -
                                (isIOS
                                    ? size.height * 0.36
                                    : size.height * 0.38),
                          ),

                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),

                          padding: EdgeInsets.fromLTRB(
                            17,
                            20,
                            17,
                            MediaQuery.of(context).padding.bottom + 20,
                          ),

                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.signInWithOtp,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// PHONE
                                AppTextField(
                                  label: l10n.enterPhoneNumber,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (_) {
                                    if (_formKey.currentState != null) {
                                      _formKey.currentState!.validate();
                                    }
                                  },
                                  controller: _phoneController,
                                  prefixText: "+973 ",
                                  maxLength: 8,
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  validator: (value) =>
                                      controller.validateMobile(value, l10n),

                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return "Please enter phone number";
                                  //   } else if (value.length != 8 ||
                                  //       !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  //     return "Phone number must be 8 digits";
                                  //   }
                                  //   return null;
                                  // },
                                ),

                                const SizedBox(height: 20),

                                /// SEND OTP
                                AppButton(
                                  height: 48,
                                  width: double.infinity,
                                  isLoading: _isLoading,
                                  color: AppColors.btn_primery,
                                  text: !_showOtp
                                      ? l10n.sendOtp
                                      : _canResendOtp
                                      ? l10n.resendOtp
                                      : "Resend OTP in ${_secondsRemaining}s",
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (!_showOtp) {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await sendOtp();
                                            }
                                            return;
                                          }

                                          if (_canResendOtp) {
                                            await sendOtp();
                                          }
                                        },
                                ),

                                /// OTP SECTION
                                if (_showOtp) ...[
                                  const SizedBox(height: 20),

                                  Text(
                                    l10n.enterOtp,
                                    style: const TextStyle(fontSize: 18),
                                  ),

                                  const SizedBox(height: 15),

                                  Center(
                                    child: Pinput(
                                      controller: _otpController,
                                      length: 4,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: focusedPinTheme,
                                      submittedPinTheme: submittedPinTheme,
                                      errorPinTheme: errorPinTheme,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) {
                                        if (_isOtpError) {
                                          setState(
                                            () => {
                                              _isOtpError = false,
                                              _otpErrorMessage = null,
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  if (_otpErrorMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        _otpErrorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),

                                  AppButton(
                                    height: 48,
                                    width: double.infinity,
                                    color: AppColors.btn_primery,
                                    isLoading: _isLoading,
                                    text: l10n.signIn,
                                    onPressed: () async {
                                      final otp = _otpController.text.trim();

                                      // if (otp.isEmpty) {
                                      //   setState(() => _isOtpError = true);

                                      //   ScaffoldMessenger.of(
                                      //     context,
                                      //   ).showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text("Please enter OTP"),
                                      //       backgroundColor: Colors.red,
                                      //     ),
                                      //   );

                                      //   return;
                                      // }

                                      // if (otp.length != 4) {
                                      //   setState(() => _isOtpError = true);

                                      //   ScaffoldMessenger.of(
                                      //     context,
                                      //   ).showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text(
                                      //         "OTP must be 4 digits",
                                      //       ),
                                      //       backgroundColor: Colors.red,
                                      //     ),
                                      //   );

                                      //   return;
                                      // }
                                      if (otp.isEmpty) {
                                        setState(() {
                                          _isOtpError = true;
                                          _otpErrorMessage =
                                              l10n.pleaseEnterOtp;
                                        });
                                        return;
                                      }

                                      if (otp.length != 4) {
                                        setState(() {
                                          _isOtpError = true;
                                          _otpErrorMessage =
                                              l10n.otpMustBe4Digits;
                                        });
                                        return;
                                      }

                                      await OTPphoneverify();
                                    },
                                  ),
                                ],
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
              alignment: isRTL ? Alignment.topRight : Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(RouteNames.login),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 180, 189, 230),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRTL ? Icons.arrow_back : Icons.arrow_back,
                      color: Colors.white,
                      size: 17,
                    ),
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
