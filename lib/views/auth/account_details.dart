// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/auth_service.dart';
// import 'package:nadi_user_app/widgets/app_back.dart';
// import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

// class AccountDetails extends StatefulWidget {
//   const AccountDetails({super.key});

//   @override
//   State<AccountDetails> createState() => _AccountDetailsState();
// }

// class _AccountDetailsState extends State<AccountDetails> {
//   final AuthService _authService = AuthService();
//   @override
//   void initState() {
//     super.initState();
//     // _loadAccoundtype();
//   }

//   // Future<void> _loadAccoundtype() async {
//   //   await _authService.acountype();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             height: MediaQuery.of(context).size.height * 0.55, // control height
//             child: Image.asset(
//               "assets/images/accounttype.png",
//               fit: BoxFit.cover,
//             ),
//           ),

//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: AppCircleIconButton(
//                 icon: Icons.arrow_back,
//                 onPressed: () => context.pop(),
//               ),
//             ),
//           ),

//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.50,
//               width: double.infinity,
//               padding: const EdgeInsets.all(30),

//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(50),
//                   topRight: Radius.circular(50),
//                 ),
//               ),

//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Account Type",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//                   ),

//                   const SizedBox(height: 25),
//                   // In your AccountDetails widget
//                   AppButton(
//                     text: "Individual Account",
//                     icon: Image.asset("assets/icons/person.png", height: 40),
//                     color: AppColors.btn_primery,
//                     width: double.infinity,
//                     onPressed: () async {
//                       final res = await _authService.selectAccount(
//                         accountTypeId: "693175af976ca992c877f99d", // INDIVIDUAL
//                       );

//                       if (res) {
//                         context.pushNamed(
//                           RouteNames.stepper,
//                           extra: "Individual",
//                         );
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 8),

//                   Text(
//                     "Manage your services and profile independently.",
//                     style: TextStyle(
//                       fontSize: AppFontSizes.small,
//                       color: AppColors.borderGrey,
//                     ),
//                   ),

//                   const SizedBox(height: 27),
//                   AppButton(
//                     text: "Family Account",
//                     icon: Image.asset("assets/icons/persons.png", height: 40),
//                     color: AppColors.btn_primery,
//                     width: double.infinity,
//                     onPressed: () async {
//                       final res = await _authService.selectAccount(
//                         accountTypeId: "693175a0976ca992c877f99b", // FAMILY
//                       );

//                       if (res) {
//                         context.pushNamed(RouteNames.stepper, extra: "Family");
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 8),

//                   Text(
//                     "Register and manage services for multiple family members.",
//                     style: TextStyle(
//                       fontSize: AppFontSizes.small,
//                       color: AppColors.borderGrey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/account_types_provider.dart';
import 'package:nadi_user_app/providers/account_types_providers.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

// class AccountDetails extends ConsumerStatefulWidget {
//   const AccountDetails({super.key});

//   @override
//   ConsumerState<AccountDetails> createState() => _AccountDetailsState();
// }

// class _AccountDetailsState extends ConsumerState<AccountDetails>
//     with SingleTickerProviderStateMixin {
//   final AuthService _authService = AuthService();
//   late final AnimationController _controller;
//   late final Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

//     _controller.forward(); // start animation
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final availabilityAsync = ref.watch(accountTypeAvailabilityProvider);
//     final availability = availabilityAsync.maybeWhen(
//       data: (value) => value,
//       orElse: () => const AccountTypeAvailability(
//         individualEnabled: true,
//         familyEnabled: true,
//       ),
//     );
//     final showIndividual = availability.individualEnabled;
//     final showFamily = availability.familyEnabled;

//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             height: MediaQuery.of(context).size.height * 0.99,
//             child: Image.asset("assets/images/onboarding/1774802367130_PAGE-No3.png", fit: BoxFit.cover),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: AppCircleIconButton(
//                 icon: Icons.arrow_back,
//                 onPressed: () => context.pop(),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.60,
//               width: double.infinity,
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 // color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(50),
//                   topRight: Radius.circular(50),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.accountTypeTitle,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//                   ),
//                   const SizedBox(height: 25),

//                   if (showIndividual) ...[
//                     // Animated Individual Account Button
//                     ScaleTransition(
//                       scale: _animation,
//                       child: AppButton(
//                         text: AppLocalizations.of(context)!.individualAccount,
//                         icon: Image.asset("assets/icons/person.png", height: 40),
//                         color: AppColors.btn_primery,
//                         width: double.infinity,
//                         onPressed: () async {
//                           final res = await _authService.selectAccount(
//                             accountTypeId: individualAccountTypeId,
//                           );

//                           if (res) {
//                             if (!context.mounted) return;
//                             context.pushNamed(
//                               RouteNames.stepper,
//                               extra: "Individual",
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       AppLocalizations.of(context)!.individualAccountDesc,
//                       style: TextStyle(
//                         fontSize: AppFontSizes.small,
//                         color: AppColors.borderGrey,
//                       ),
//                     ),
//                     const SizedBox(height: 27),
//                   ],

//                   if (showFamily) ...[
//                     // Animated Family Account Button
//                     ScaleTransition(
//                       scale: _animation,
//                       child: AppButton(
//                         text: AppLocalizations.of(context)!.familyAccount,
//                         icon: Image.asset("assets/icons/persons.png", height: 40),
//                         color: AppColors.btn_primery,
//                         width: double.infinity,
//                         onPressed: () async {
//                           final res = await _authService.selectAccount(
//                             accountTypeId: familyAccountTypeId,
//                           );

//                           if (res) {
//                             if (!context.mounted) return;
//                             context.pushNamed(
//                               RouteNames.stepper,
//                               extra: "Family",
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       AppLocalizations.of(context)!.familyAccountDesc,
//                       style: TextStyle(
//                         fontSize: AppFontSizes.small,
//                         color: AppColors.borderGrey,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class AccountDetails extends ConsumerStatefulWidget {
  const AccountDetails({super.key});

  @override
  ConsumerState<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends ConsumerState<AccountDetails>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isNavigating = false;
  String? _loadingAccountId;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    /// ✅ FORCE REFRESH
    Future.microtask(() {
      ref.invalidate(accountTypesProvider);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isIndividual(String type) => type == "IA";
  bool isFamily(String type) => type == "FA";

  @override
  Widget build(BuildContext context) {
    final accountTypesAsync = ref.watch(accountTypesProvider);
    final availabilityAsync = ref.watch(accountTypeAvailabilityProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final availability = availabilityAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const AccountTypeAvailability(
        individualEnabled: true,
        familyEnabled: true,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.99,
            child: Image.asset(
              "assets/images/onboarding/1774802367130_PAGE-No3.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppCircleIconButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              width: double.infinity,
              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),

              child: accountTypesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Center(
                  child: Text(
                    e.toString(),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),

                data: (response) {
                  final list = response.data;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.accountTypeTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),

                        const SizedBox(height: 25),

                        ...list.map((item) {
                          final individual = isIndividual(item.type);
                          final family = isFamily(item.type);

                          if ((individual && !availability.individualEnabled) ||
                              (family && !availability.familyEnabled)) {
                            return const SizedBox();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaleTransition(
                                scale: _animation,
                                child: AppButton(
                                  isLoading: _loadingAccountId == item.id,

                                  text: isArabic ? item.nameAr : item.nameEn,
                                  icon: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: Image.asset(
                                        individual
                                            ? "assets/icons/person.png"
                                            : "assets/icons/persons.png",
                                        width: individual ? 23 : 38,
                                        height: individual ? 23 : 38,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  color: AppColors.btn_primery,
                                  width: double.infinity,
                                  onPressed: _loadingAccountId == item.id
                                      ? null
                                      : () async {
                                          setState(() {
                                            _loadingAccountId = item.id;
                                          });

                                          try {
                                            final res = await _authService
                                                .selectAccount(
                                                  accountTypeId: item.id,
                                                );

                                            if (!mounted) return;

                                            if (res) {
                                              context.pushNamed(
                                                RouteNames.stepper,
                                                extra: item.type == 'IA'
                                                    ? "Individual"
                                                    : "Family",
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(e.toString());
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _loadingAccountId = null;
                                              });
                                            }
                                          }
                                        },
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                individual
                                    ? AppLocalizations.of(
                                        context,
                                      )!.individualAccountDesc
                                    : AppLocalizations.of(
                                        context,
                                      )!.familyAccountDesc,

                                style: TextStyle(
                                  fontSize: AppFontSizes.small,

                                  /// ✅ FIXED FOR DARK MODE
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),

                              const SizedBox(height: 27),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
