// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/network/dio_client.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:nadi_user_app/providers/profile_provider.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/widgets/app_back.dart';
// import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

// class Myprofile extends ConsumerWidget {
//   const Myprofile({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final profileAsyncValue = ref.watch(profileprovider);

//     return Scaffold(
//       backgroundColor: AppColors.background_clr,
//       body: profileAsyncValue.when(
//         data: (profileResponse) {
//           if (profileResponse == null) {
//             AppLogger.error("Profile response is null");
//             return const Center(child: Text("No profile data"));
//           }

//           final basicData =
//               profileResponse['data'] as Map<String, dynamic>? ?? {};
//           final addresses = profileResponse['addresses'] as List? ?? [];
//           final familyMembers = profileResponse['familyMembers'] as List? ?? [];

//           String safeString(dynamic value) => value?.toString() ?? "";

//           final nameCtrl = TextEditingController(
//             text: safeString(basicData['basicInfo']?['fullName']),
//           );
//           final emailCtrl = TextEditingController(
//             text: safeString(basicData['basicInfo']?['email']),
//           );
//           final phoneCtrl = TextEditingController(
//             text: safeString(basicData['basicInfo']?['mobileNumber']),
//           );
//           final addressCtrl = TextEditingController(
//             text: addresses.isNotEmpty ? safeString(addresses[0]['city']) : "",
//           );

//           return Column(
//             children: [
//               // Header
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       const Color.fromRGBO(76, 149, 129, 1),
//                       const Color.fromRGBO(117, 192, 172, 1),
//                     ],
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(51),
//                     bottomRight: Radius.circular(51),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         AppCircleIconButton(
//                           icon: Icons.arrow_back,
//                           onPressed: () => context.push(RouteNames.bottomnav),
//                           color: const Color.fromRGBO(183, 213, 205, 1),
//                         ),
//                         const Text(
//                           "Profile Details",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Text(""),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                     Container(
//                       height: 62,
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         color: const Color.fromRGBO(13, 95, 72, 1),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               basicData['basicInfo']?['image'] == null ||
//                                       basicData['basicInfo']!['image']
//                                           .toString()
//                                           .isEmpty
//                                   ? const CircleAvatar(
//                                       radius: 22,
//                                       backgroundColor: Colors.blue,
//                                       child: Icon(
//                                         Icons.person,
//                                         color: Colors.white,
//                                         size: 20,
//                                       ),
//                                     )
//                                   : CircleAvatar(
//                                       radius: 22,
//                                       backgroundColor: Colors.transparent,
//                                       backgroundImage: CachedNetworkImageProvider(
//                                         "${ImageBaseUrl.baseUrl}/${basicData['basicInfo']!['image']}",
//                                       ),
//                                     ),
//                               const SizedBox(width: 12),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Welcome",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   Text(
//                                     nameCtrl.text.isNotEmpty
//                                         ? nameCtrl.text
//                                         : "Loading...",
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           InkWell(
//                             onTap: () async {
//                               final profileDataForEdit = {
//                                 "data": basicData,
//                                 "addresses": addresses,
//                                 "familyMembers": familyMembers,
//                               };

//                               final result = await context.push<bool>(
//                                 RouteNames.editprfoile,
//                                 extra: profileDataForEdit,
//                               );

//                               if (result == true) {
//                                 ref.refresh(profileprovider);
//                               }
//                             },
//                             child: Container(
//                               height: 38,
//                               width: 38,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white,
//                               ),
//                               child: const Icon(
//                                 Icons.edit_outlined,
//                                 color: AppColors.button_secondary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Body
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 15,
//                       vertical: 25,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Full Name",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         AppTextField(
//                           controller: nameCtrl,
//                           readonly: true,
//                           enabled: false,
//                         ),
//                         const SizedBox(height: 15),
//                         const Text(
//                           "Email Address",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         AppTextField(
//                           controller: emailCtrl,
//                           readonly: true,
//                           enabled: false,
//                         ),
//                         const SizedBox(height: 15),
//                         const Text(
//                           "Phone Number",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         AppTextField(
//                           controller: phoneCtrl,
//                           readonly: true,
//                           enabled: false,
//                         ),
//                         const SizedBox(height: 15),
//                         const Text(
//                           "Address",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         AppTextField(
//                           minLines: 3,
//                           maxLines: 5,
//                           controller: addressCtrl,
//                           readonly: true,
//                           enabled: false,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading: () => const SizedBox(),
//         error: (err, stack) {
//           AppLogger.error("Riverpod profileprovider error: $err");
//           return const Center(child: Text("Error loading profile"));
//         },
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/family_members_manage_provider.dart';
import 'package:nadi_user_app/providers/profile_provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/confirm_dialog.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';

class Myprofile extends ConsumerWidget {
  const Myprofile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(profileprovider);
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileAsyncValue.when(
        data: (profileResponse) {
          if (profileResponse == null) {
            AppLogger.error("Profile response is null");
            return Center(child: Text(loc.noProfileData));
          }
          final basicData =
              profileResponse['data'] as Map<String, dynamic>? ?? {};
          final addresses = profileResponse['addresses'] as List? ?? [];
          final familyMembers = profileResponse['familyMembers'] as List? ?? [];
          String safeString(dynamic value) => value?.toString() ?? "";
          final nameCtrl = TextEditingController(
            text: safeString(basicData['basicInfo']?['fullName']),
          );
          final emailCtrl = TextEditingController(
            text: safeString(basicData['basicInfo']?['email']),
          );
          final phoneCtrl = TextEditingController(
            text: safeString(basicData['basicInfo']?['mobileNumber']),
          );
          String buildFullAddress(Map addr) {
            final parts = <String>[];
            void add(String? label, dynamic value) {
              final v = safeString(value).trim();
              if (v.isEmpty) return;
              parts.add(label == null ? v : "$label $v");
            }

            add(null, addr['building']);
            add(loc.block, addr['block']);
            add(null, addr['city']);
            add(loc.floor, addr['floor']);
            add(loc.apartment, addr['aptNo']);
            add(null, addr['additionalInfo']);
            return parts.join(", ");
          }

          final addressCtrl = TextEditingController(
            text: addresses.isNotEmpty
                ? buildFullAddress(addresses[0] as Map)
                : "",
          );
          final familyCount = basicData['familyCount'] ?? 0;
          final accountTypeId = basicData['accountTypeId'] ?? "";
          final showAddMember = accountTypeId == "693175a0976ca992c877f99b";
          return Column(
            children: [
              // Header
              Container(
                height: 180, // slightly reduced height
                width: double.infinity,
                padding: const EdgeInsets.only(top: 35, left: 15, right: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.app_background_clr,
                      Color.fromARGB(255, 193, 201, 234),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(51),
                    bottomRight: Radius.circular(51),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppCircleIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () => context.push(RouteNames.bottomnav),
                          color: const Color.fromARGB(255, 193, 201, 234),
                        ),
                        Text(
                          loc.profileDetails,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 38), // to balance space
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 58, // reduced height
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.app_background_clr,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              basicData['basicInfo']?['image'] == null ||
                                      basicData['basicInfo']!['image']
                                          .toString()
                                          .isEmpty
                                  ? const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.blue,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: CachedNetworkImageProvider(
                                        "${ImageBaseUrl.baseUrl}/${basicData['basicInfo']!['image']}",
                                      ),
                                    ),
                              const SizedBox(width: 10), // reduced
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.welcome,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    nameCtrl.text.isNotEmpty
                                        ? nameCtrl.text
                                        : loc.loading,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              final profileDataForEdit = {
                                "data": basicData,
                                "addresses": addresses,
                                "familyMembers": familyMembers,
                              };
                              final result = await context.push<bool>(
                                RouteNames.editprfoile,
                                extra: profileDataForEdit,
                              );
                              if (result == true) {
                                ref.refresh(profileprovider);
                              }
                            },
                            child: Container(
                              height: 36, // reduced size
                              width: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.button_secondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(profileprovider); // reload profile
                    ref.invalidate(familyMembersVerifiedProvider);
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ), // reduced vertical padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showAddMember) ...[
                            const SizedBox(height: 20),
                            const _FamilyMembersListSection(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await context.push(
                                    RouteNames.addMember,
                                  );

                                  // refresh family members + profile
                                  if (result == true && context.mounted) {
                                    ref.invalidate(
                                      familyMembersVerifiedProvider,
                                    );
                                    ref.invalidate(profileprovider);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.app_background_clr,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  loc.addMember,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Text(
                            loc.fullName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4), // reduced
                          AppTextField(
                            controller: nameCtrl,
                            readonly: true,
                            enabled: false,
                            textStyle: TextStyle(
                              // color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10), // reduced
                          Text(
                            loc.emailAddress,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppTextField(
                            controller: emailCtrl,
                            readonly: true,
                            enabled: false,
                            textStyle: TextStyle(
                              // color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${loc.phoneNumber}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppTextField(
                            prefixText: "+973 ",
                            controller: phoneCtrl,
                            readonly: true,
                            enabled: false,
                            textStyle: TextStyle(
                              // color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loc.address,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppTextField(
                            minLines: 3,
                            maxLines: 5,
                            controller: addressCtrl,
                            readonly: true,
                            enabled: false,
                            textStyle: TextStyle(
                              // color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          AppLogger.error("Riverpod profileprovider error: $err");
          return Center(child: Text(loc.errorLoadingProfile));
        },
      ),
    );
  }
}

String _memberStatus(Map member) {
  final verification = (member['accountVerification'] ?? '')
      .toString()
      .toLowerCase();
  final rawStatus = member['accountStatus'];
  final bool isActive;
  if (rawStatus is bool) {
    isActive = rawStatus;
  } else {
    final s = rawStatus?.toString().toLowerCase() ?? '';
    isActive = s == 'true' || s == 'active';
  }

  if (verification == 'rejected') return 'Rejected';
  if (verification == 'verified' && isActive) return 'Active';
  return 'Pending';
}

Widget _statusCountPill({
  required String label,
  required int count,
  required Color color,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          "$label: $count",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _FamilyMembersListSection extends ConsumerWidget {
  const _FamilyMembersListSection();

  Widget _header(BuildContext context, int count) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.familyMembers,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.app_background_clr.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.app_background_clr,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!; // ✅ ADD THIS

    final membersAsync = ref.watch(familyMembersVerifiedProvider);
    return membersAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 0),
          _infoBox(
            child: const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 0),
          _infoBox(
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.errorLoadingProfile,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(familyMembersListProvider),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ],
      ),
      data: (members) {
        if (members.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, 0),
              _infoBox(
                child: Row(
                  children: [
                    Icon(Icons.group_outlined, color: Colors.grey.shade500),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.noFamilyMembers,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        int active = 0;
        int pending = 0;
        int rejected = 0;
        for (final m in members) {
          final status = _memberStatus(m);
          final loc = AppLocalizations.of(context)!;

          switch (status) {
            case 'Rejected':
              rejected++;
              break;
            case 'Pending':
              pending++;
              break;
            default:
              active++;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, members.length),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusCountPill(
                  label: loc.active,
                  count: active,
                  color: Colors.green.shade700,
                  bg: Colors.green.shade50,
                ),
                _statusCountPill(
                  label: loc.pending,
                  count: pending,
                  color: Colors.orange.shade800,
                  bg: Colors.orange.shade50,
                ),
                _statusCountPill(
                  label: loc.rejected,
                  count: rejected,
                  color: Colors.red.shade700,
                  bg: Colors.red.shade50,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...members.map(
              (m) => _FamilyMemberTile(
                member: m,
                onRemoved: () {
                  ref.invalidate(familyMembersVerifiedProvider);
                  ref.invalidate(profileprovider);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FamilyMemberTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> member;
  final VoidCallback onRemoved;

  const _FamilyMemberTile({required this.member, required this.onRemoved});

  @override
  ConsumerState<_FamilyMemberTile> createState() => _FamilyMemberTileState();
}

class _FamilyMemberTileState extends ConsumerState<_FamilyMemberTile> {
  bool _removing = false;

  ({String label, Color color, Color bg}) _statusBadge(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final status = _memberStatus(widget.member);
    switch (status) {
      case 'Rejected':
        return (
          label: loc.rejected,
          color: Colors.red.shade700,
          bg: Colors.red.shade50,
        );
      case 'Pending':
        return (
          label: loc.pending,
          color: Colors.orange.shade800,
          bg: Colors.orange.shade50,
        );
      default:
        return (
          label: loc.active,
          color: Colors.green.shade700,
          bg: Colors.green.shade50,
        );
    }
  }

  Future<void> _remove() async {
    final memberId = widget.member['_id']?.toString();
    final loc = AppLocalizations.of(context)!;
    if (memberId == null || memberId.isEmpty) return;

    final name =
        widget.member['basicInfo']?['fullName']?.toString() ?? loc.thisMember;
    final confirmed = await showConfirmDialog(
      context,
      title: loc.removeMemberTitle,
      message: loc.removeMemberMessage,
      confirmText: loc.remove,
      icon: Icons.person_remove_alt_1_rounded,
      destructive: true,
    );
    if (!confirmed) return;
    if (!mounted) return;

    setState(() => _removing = true);
    try {
      await ref
          .read(familyMembersManageServiceProvider)
          .removeFamilyMember(memberId);
      if (!mounted) return;
      SnackbarHelper.ShowSuccess(context, loc.memberRemoved(name));
      ref.invalidate(familyMembersVerifiedProvider);
      ref.invalidate(profileprovider);

      widget.onRemoved();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final basic = widget.member['basicInfo'] as Map? ?? {};
    final name = basic['fullName']?.toString() ?? '';
    final phone = basic['mobileNumber']?.toString() ?? '';
    final image = basic['image']?.toString() ?? '';
    final relation = widget.member['relation']?.toString();
    final badge = _statusBadge(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: image.isNotEmpty
                ? CachedNetworkImageProvider("${ImageBaseUrl.baseUrl}/$image")
                : null,
            child: image.isEmpty
                ? Icon(Icons.person, color: Colors.grey.shade500)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name.isEmpty ? '-' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badge.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: badge.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (relation != null && relation.isNotEmpty) relation,
                    if (phone.isNotEmpty) phone,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _removing
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: loc.remove,
                  onPressed: _remove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
