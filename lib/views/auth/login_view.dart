// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/controllers/login_controller.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/auth_service.dart';
// import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({super.key});

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   final LoginController controller = LoginController();
//   final AuthService _authService = AuthService();
//   // final NotificationService _notificationService = NotificationService();

//   bool isChecked = false;
//   bool _obscure = true;

//   String? emailError;
//   String? passwordError;
//   @override
//   void initState() {
//     super.initState();
//     // START LISTENING FOR PUSH
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   NotificationService.initialize(context);
//     // });
//     _loadRememberMe();
//   }

//   Future<void> _loadRememberMe() async {
//     final remember = await AppPreferences.isRemeberMe();
//     if (remember) {
//       final email = await AppPreferences.getRememberEmail();
//       if (email != null) {
//         controller.email.text = email;
//       }
//       setState(() {
//         isChecked = true;
//       });
//     }
//   }

//   Future<void> login(BuildContext context) async {
//     setState(() {
//       emailError = null;
//       passwordError = null;
//     });

//     final loginData = controller.getLoginData();
//     final fcmToken = await AppPreferences.getfcmToken();
//     print(" fcmToken******************: $fcmToken");
//     try {
//       final response = await _authService.LoginApi(
//         email: loginData.email,
//         password: loginData.password,
//         fcmToken: fcmToken,
//       );
//       AppLogger.warn("loginData: ${response?['data']}");
//       if (response != null && response['token'] != null) {
//         await AppPreferences.saveToken(response['token']);
//         await AppPreferences.setLoggedIn(true);
//         await AppPreferences.saveUserId(response['userId']);
//         await AppPreferences.saveAccountType(response['accountType']);
//         //  REMEMBER ME LOGIC
//         if (isChecked) {
//           await AppPreferences.setRememberMe(true);
//           await AppPreferences.saveRemeberEmail(loginData.email);
//         } else {
//           await AppPreferences.clearRememberMe();
//         }
//         context.go(RouteNames.bottomnav);
//       }
//     } on DioException catch (e) {
//       final message = e.response?.data?['message'] ?? "Invalid credentials";

//       setState(() {
//         if (message.toString().toLowerCase().contains('email')) {
//           emailError = message;
//         } else {
//           passwordError = message;
//         }
//       });
//     } catch (_) {
//       setState(() {
//         passwordError = "Something went wrong";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Stack(
//         children: [
//           // BACKGROUND IMAGE
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/back.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           SafeArea(
//             bottom: false,
//             child: Column(
//               children: [
//                 SizedBox(height: height * 0.07),

//                 /// LOGO
//                 Image.asset("assets/icons/logo.png", height: 170),
//                 SizedBox(height: height * 0.10),

//                 /// FORM
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
//                       child: Column(

//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Welcome!",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 25),
//                           TextFormField(
//                             controller: controller.email,
//                             keyboardType: TextInputType.emailAddress,
//                             decoration: InputDecoration(
//                               labelText: "Email Address",
//                               filled: true,
//                               fillColor: Colors.white,
//                               floatingLabelStyle: TextStyle(
//                                 color: AppColors.btn_primery,
//                               ),
//                               errorText: emailError,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(
//                                   color: AppColors.btn_primery,
//                                   width: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           TextFormField(
//                             controller: controller.password,
//                             obscureText: _obscure,
//                             decoration: InputDecoration(
//                               labelText: "Password",
//                               filled: true,
//                               fillColor: Colors.white,
//                               floatingLabelStyle: const TextStyle(
//                                 color: AppColors.btn_primery,
//                               ),
//                               errorText: passwordError,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: AppColors.btn_primery,
//                                   width: 1.5,
//                                 ),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscure
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                 ),
//                                 onPressed: () {
//                                   setState(() => _obscure = !_obscure);
//                                 },
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 10),

//                           Wrap(
//                             alignment: WrapAlignment.spaceBetween,
//                             runSpacing: 5,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Checkbox(
//                                     value: isChecked,
//                                     activeColor: AppColors.btn_primery,
//                                     onChanged: (v) =>
//                                         setState(() => isChecked = v!),
//                                   ),
//                                   const Text("Remember me"),
//                                 ],
//                               ),
//                               TextButton(
//                                 onPressed: () =>
//                                     context.push(RouteNames.forgotpassword),
//                                 child: const Text(
//                                   "Forgot Password?",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.btn_primery,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: AppButton(
//                                   text: "Sign Up",
//                                   width: 59,
//                                   color: AppColors.button_secondary,
//                                   height: 50,
//                                   onPressed: () =>
//                                       context.push(RouteNames.Account),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: AppButton(
//                                   text: "Sign In",
//                                   width: 59,
//                                   color: const Color(0xFF0D5F48),
//                                   height: 50,
//                                   onPressed: () => login(context),
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 10),
//                           const Center(child: Text("OR")),
//                           const SizedBox(height: 10),
//                           InkWell(
//                             onTap: () {
//                               context.push(RouteNames.phonewithotp);
//                             },
//                             child: Center(
//                               child: Text(
//                                 "Sign In with OTP",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.btn_primery,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/controllers/login_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/views/languagetoggle.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = LoginController();
  final AuthService _authService = AuthService();

  bool isChecked = false;
  bool _obscure = true;
bool _isLoading = false;

  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final remember = await AppPreferences.isRemeberMe();
    if (remember) {
      final email = await AppPreferences.getRememberEmail();
      if (email != null) {
        controller.email.text = email;
      }
      setState(() {
        isChecked = true;
      });
    }
  }
  Future<void> login(BuildContext context) async {
      if (_isLoading) return; // prevent multiple clicks

    final email = controller.email.text.trim();
    final password = controller.password.text.trim();

    // Client-side validation before hitting the API
    setState(() {
  emailError = email.isEmpty
      ? AppLocalizations.of(context)!.emailRequired
      : null;

  passwordError = password.isEmpty
      ? AppLocalizations.of(context)!.passwordRequired
      : null;
});;

    if (emailError != null || passwordError != null) return;
  setState(() => _isLoading = true); // 🔥 START LOADER

    final loginData = controller.getLoginData();
    final fcmToken = await AppPreferences.getfcmToken();
    AppLogger.info("Login Fcm Token ******************* $fcmToken");
    try {
      final response = await _authService.LoginApi(
        email: loginData.email,
        password: loginData.password,
        fcmToken: fcmToken,
      );

      AppLogger.warn("loginData: ${response?['data']}");

      if (response != null && response['token'] != null) {
        await AppPreferences.saveToken(response['token']);
        await AppPreferences.setLoggedIn(true);
        await AppPreferences.saveUserId(response['userId']);
        await AppPreferences.saveAccountType(response['accountType']);

        if (isChecked) {
          await AppPreferences.setRememberMe(true);
          await AppPreferences.saveRemeberEmail(loginData.email);
        } else {
          await AppPreferences.clearRememberMe();
        }

        if (!context.mounted) return;
        context.go(RouteNames.bottomnav);
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Invalid credentials";

      if (message.toString().toLowerCase().contains('disabled')) {
        if (!mounted) return;
        _showAccountDisabledDialog();
      } else if (message.toString().toLowerCase().contains('reject')) {
        if (!mounted) return;
        _showAccountRejectedDialog();
      } else {
        setState(() {
          if (message.toString().toLowerCase().contains('email')) {
            emailError = message;
          } else {
            passwordError = message;
          }
        });
      }
    } catch (_) {
      setState(() {
        passwordError = "Something went wrong";
      });
    }finally {
    if (mounted) setState(() => _isLoading = false); // 🔥 STOP LOADER
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
            Expanded(
              child: Text(
               AppLocalizations.of(context)!.accountDisabled
,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
                AppLocalizations.of(context)!.accountDisabledMsg,

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
                      Icon(Icons.phone, color: AppColors.app_background_clr, size: 20),
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
                      Icon(Icons.email_outlined, color: AppColors.app_background_clr, size: 20),
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
              child:  Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontWeight: FontWeight.w600)),
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
             Expanded(
              child: Text(
                AppLocalizations.of(context)!.accountRejected,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              AppLocalizations.of(context)!.accountRejectedMsg,
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
                      Icon(Icons.phone, color: AppColors.app_background_clr, size: 20),
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
                      Icon(Icons.email_outlined, color: AppColors.app_background_clr, size: 20),
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
              child:  Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // true = Scaffold body shrinks when keyboard opens; scroll view viewport shrinks too,
      // so Flutter's auto-scroll-to-focused-field works correctly.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// LAYER 1 — background image, anchored to top so it crops from bottom (not squishes)
          Positioned.fill(
            child: Image.asset(
              "assets/images/onboarding/1774802367130_PAGE-No3.png",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),


          /// LAYER 2 — scrollable form content
          /// Positioned.fill gives SafeArea a TIGHT height = Stack height (= screen - keyboard).
          /// Without this, SafeArea gets loose constraints → SingleChildScrollView has no bounded
          /// viewport → never scrolls → content clips when keyboard opens.
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                // ClampingScrollPhysics: stops at bounds, no overscroll bounce
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  // minHeight = safe-area height: content fills screen when keyboard closed
                  // (scroll range = 0, so no dragging). When keyboard opens the viewport
                  // shrinks but minHeight stays → content overflows viewport → scrollable.
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.40),
                        // Expanded pushes form to bottom (works with IntrinsicHeight)
                        // const Expanded(child: SizedBox()),

                        /// FORM CONTAINER
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 25,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// TITLE
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context)!.welcome,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 25),

                                /// EMAIL
                                TextFormField(
                                  controller: controller.email,
                                  keyboardType: TextInputType.emailAddress,
                                 decoration: InputDecoration(
  labelText: AppLocalizations.of(context)!.enterEmail,

  filled: true,
  fillColor: Theme.of(context).colorScheme.surface,

  labelStyle: TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),

  floatingLabelStyle: TextStyle(
    color: Theme.of(context).colorScheme.primary,
  ),

  errorText: emailError,

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5,
    ),
  ),
),
                                ),

                                const SizedBox(height: 15),

                                /// PASSWORD
                                TextFormField(
                                  controller: controller.password,
                                  obscureText: _obscure,
                                 decoration: InputDecoration(
  labelText: AppLocalizations.of(context)!.password,

  filled: true,
  fillColor: Theme.of(context).colorScheme.surface,

  labelStyle: TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),

  floatingLabelStyle: TextStyle(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w600,
  ),

  errorText: passwordError,

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5,
    ),
  ),

  suffixIcon: IconButton(
    icon: Icon(
      _obscure
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    onPressed: () {
      setState(() => _obscure = !_obscure);
    },
  ),
),
                                ),

                                const SizedBox(height: 10),

                                /// REMEMBER + FORGOT
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          activeColor: AppColors.btn_primery,
                                          onChanged: (v) =>
                                              setState(() => isChecked = v!),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.rememberMe,
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () => context.push(
                                        RouteNames.forgotpassword,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.forgotPassword,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.app_background_clr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                /// BUTTONS
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: AppLocalizations.of(context)!.signUp,
                                        width: double.infinity,         


                                        color: AppColors.button_secondary,
                                        height: 50,
                                        onPressed: () =>
                                            context.push(RouteNames.Account),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AppButton(
                                        text: AppLocalizations.of(context)!.signIn,
                                        width: double.infinity,
                                                                                  isLoading: _isLoading,

                                        color: AppColors.button_secondary,
                                        height: 50,
                                        onPressed: () => login(context),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.or,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                InkWell(
                                  onTap: () {
                                    context.push(RouteNames.phonewithotp);
                                  },
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.signInWithOtp,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.app_background_clr,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                InkWell(
                                  onTap: () {
                                    context.push(RouteNames.helpSupport);
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.help_outline_rounded,
                                          size: 18,
                                          color: AppColors.app_background_clr,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                        AppLocalizations.of(context)!.helpSupport,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.app_background_clr,
                                            decoration: TextDecoration.underline,
                                            decorationColor:
                                                AppColors.app_background_clr,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
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
             Positioned(
      top: 50,
      right: 20,
      child: LanguageView(),
    ),// closes Positioned.fill
        ],
      ),
    );
  }
}
