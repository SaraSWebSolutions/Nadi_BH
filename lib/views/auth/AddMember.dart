// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:mannai_user_app/controllers/address_controller.dart';
// // import 'package:mannai_user_app/controllers/family_member_controller.dart';

// // import 'package:mannai_user_app/core/constants/app_consts.dart';
// // import 'package:mannai_user_app/core/utils/logger.dart';
// // import 'package:mannai_user_app/routing/app_router.dart';
// // import 'package:mannai_user_app/services/auth_service.dart';
// // import 'package:mannai_user_app/views/auth/individual/Address.dart';

// // import 'package:mannai_user_app/widgets/buttons/primary_button.dart';
// // import 'package:mannai_user_app/widgets/inputs/app_dropdown.dart';
// // import 'package:mannai_user_app/widgets/inputs/app_text_field.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class Addmember extends StatefulWidget {
// //   final String accountType;
// //   final VoidCallback onNext;
// //   final GlobalKey<FormState> formKey;

// //   const Addmember({
// //     super.key,
// //     required this.accountType,
// //     required this.onNext,
// //     required this.formKey,
// //   });

// //   @override
// //   State<Addmember> createState() => _AddmemberState();
// // }

// // class _AddmemberState extends State<Addmember> {
// //   bool _isAddress = false;
// //   final controller = FamilyMemberController();
// //   final addressController = AddressController();
// //   final AuthService _authService = AuthService();
// //   final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
// // int _totalMembers = 0;
// // int _currentMemberIndex = 1;
// // List<Map<String, dynamic>> _members = [];
// // bool _isLoading = false;

// //   @override
// //   Widget build(BuildContext context) {
// // bool _isLoading = false; // add this in your State class

// // Future<void> AccountCreated(BuildContext context) async {
// //   final memberValid = widget.formKey.currentState?.validate() ?? false;
// //   if (!memberValid) {
// //     debugPrint("MEMBER FORM INVALID");
// //     return;
// //   }

// //   if (_isAddress) {
// //     final addressValid = _addressFormKey.currentState?.validate() ?? false;
// //     debugPrint("ADDRESS VALID = $addressValid");
// //     if (!addressValid) {
// //       debugPrint("ADDRESS FORM INVALID");
// //       return;
// //     }
// //   }

// //   debugPrint("ALL VALID — CONTINUING");

// //   final prefs = await SharedPreferences.getInstance();
// //   final userId = prefs.getString("userId");

// //   debugPrint("USER ID = $userId");

// //   if (userId == null) {
// //     debugPrint("USER ID NULL");
// //     return;
// //   }

// //   final addressMap = addressController.getOnlyAddressMap(
// //     addressType: "flat",
// //   );

// //   final body = controller.getApiFamilyMemberBody(
// //     userId: userId,
// //     address: addressMap,
// //   );

// //   debugPrint("FINAL BODY  ${jsonEncode(body)}");

// //   if (mounted) setState(() => _isLoading = true);

// //   try {
// //     final response = await _authService.memberdetails(body: body);

// //     // API finished, stop loader
// //     if (mounted) setState(() => _isLoading = false);

// //     ScaffoldMessenger.of(context)
// //       ..hideCurrentSnackBar()
// //       ..showSnackBar(
// //         SnackBar(
// //           content: const Text(
// //             "Account created successfully",
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           backgroundColor: AppColors.button_secondary,
// //           duration: const Duration(seconds: 2),
// //         ),
// //       );

// //     // small delay so user can see snackbar
// //     Future.delayed(const Duration(seconds: 1), () {
// //       context.push(RouteNames.accountverfy);
// //     });

// //     AppLogger.debug("RESPONSE 👉 ${jsonEncode(response)}");
// //   } catch (e) {
// //     if (mounted) setState(() => _isLoading = false); // stop loader on error
// //     debugPrint("Address submit failed  $e");
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(SnackBar(content: Text("Submit failed: $e")));
// //   }
// // }

// //     return Form(
// //       key: widget.formKey,
// //       child: Column(
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,

// //               children: [
// //                 Text(
// //                   "Add ${widget.accountType} Member",
// //                   style: const TextStyle(
// //                     fontSize: 22,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 15),
// //                 AppTextField(
// //                   controller: controller.familyCount,
// //                   label: "Enter Family Count*",
// //                   validator: (value) => controller.validatefamilycount(value),
// //                 ),
// //                 const SizedBox(height: 15),

// //                 AppTextField(
// //                   controller: controller.fullName,
// //                   label: "Member Full Name*",
// //                   validator: (value) => controller.validatefullname(value),
// //                 ),

// //                 const SizedBox(height: 15),
// //                 AppDropdown(
// //                   label: "Relationship*",
// //                   items: ["Father", "Mother", "Son", "Daughter", "Spouse"],
// //                   value: controller.relation,
// //                   onChanged: (val) {
// //                     setState(() {
// //                       controller.relation = val;
// //                     });
// //                   },
// //                   validator: (val) =>
// //                       val == null ? "Please select relationship" : null,
// //                 ),

// //                 const SizedBox(height: 15),

// //                 AppTextField(
// //                   controller: controller.mobile,
// //                   label: "Mobile Number*",
// //                   validator: (value) => controller.validatemobilenumber(value),
// //                 ),

// //                 const SizedBox(height: 15),
// //                       AppTextField(
// //                   controller: controller.password,
// //                   label: "Password*",
// //                   validator: (value) => controller.validatepassword(value),
// //                 ),

// //                 const SizedBox(height: 15),

// //                 AppTextField(
// //                   controller: controller.email,
// //                   label: "Email Adress*",
// //                   validator: (value) => controller.validateemail(value),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 AppDropdown(
// //                   label: "Gender*",
// //                   items: ["Male", "Female", "Oter"],
// //                   value: controller.gender,
// //                   onChanged: (val) {
// //                     setState(() {
// //                       controller.gender = val;
// //                     });
// //                   },
// //                   validator: (val) =>
// //                       val == null ? "Please select relationship" : null,
// //                 ),

// //                 const SizedBox(height: 20),

// //                 if (_isAddress)
// //                   Column(
// //                     children: [
// //                       const SizedBox(height: 20),
// //                       Address(
// //                         accountType: "Family",
// //                         family: true,
// //                         formKey: _addressFormKey,
// //                         controller: addressController, //  pass controller
// //                       ),
// //                     ],
// //                   ),
// //                 const SizedBox(height: 20),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   height: 47,
// //                   child: OutlinedButton(
// //                     style: OutlinedButton.styleFrom(
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _isAddress = !_isAddress;
// //                       });
// //                     },
// //                     child: Text(
// //                       _isAddress ? "Hide Address" : "Add Address",
// //                       style: TextStyle(color: AppColors.btn_primery),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 20),

// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 20),
// //           AppButton(
// //             text: "Sign Up",
// //             isLoading: _isLoading,
// //             onPressed: () {
// //               AccountCreated(context);
// //             },

// //             color: AppColors.btn_primery,
// //             width: double.infinity,
// //             height: 47,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nadi_user_app/controllers/address_controller.dart';
// import 'package:nadi_user_app/controllers/family_member_controller.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/utils/logger.dart';
// import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
// import 'package:nadi_user_app/l10n/app_localizations.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/routing/app_router.dart';
// import 'package:nadi_user_app/services/auth_service.dart';
// import 'package:nadi_user_app/views/auth/Address.dart';
// import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
// import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
// import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

// class FamilyMemberData {
//   final String fullName;
//   final String mobile;
//   final String email;
//   final String relation;
//   final String gender;
//   final Map<String, dynamic>? address;

//   FamilyMemberData({
//     required this.fullName,
//     required this.mobile,
//     required this.email,
//     required this.relation,
//     required this.gender,
//     this.address,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "full_name": fullName,
//       "mobile": mobile,
//       "email": email,
//       "relation": relation,
//       "gender": gender,
//       "address": address,
//     };
//   }
// }

// class Addmember extends StatefulWidget {
//   final String accountType;
//   final VoidCallback onNext;
//   final GlobalKey<FormState> formKey;

//   const Addmember({
//     super.key,
//     required this.accountType,
//     required this.onNext,
//     required this.formKey,
//   });

//   @override
//   State<Addmember> createState() => _AddmemberState();
// }

// class _AddmemberState extends State<Addmember> {
//   final controller = FamilyMemberController();
//   final addressController = AddressController();
//   final AuthService _authService = AuthService();
//   bool _isAddress = false;
//   int? _editingIndex;
//   // bool _isFamilyCountLocked = false;
//   // bool _hideBottomButton = false;
//   final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _nameFocus = FocusNode();
//   bool _isLoading = false;
//   final Map<String, String> genderMap = {'male': 'Male', 'female': 'Female'};
//   int _totalMembers = 0;
//   int _currentMemberIndex = 1;
//   List<FamilyMemberData> savedMembers = [];
//   String _localizedAccountType(AppLocalizations l10n) {
//     switch (widget.accountType) {
//       case "Family":
//         return l10n.family;
//       case "Individual":
//         return l10n.individual;
//       default:
//         return widget.accountType;
//     }
//   }

//   void _loadMemberForEdit(int index) {
//     final member = savedMembers[index];

//     _editingIndex = index;

//     controller.fullName.text = member.fullName;
//     controller.mobile.text = member.mobile;
//     controller.email.text = member.email;
//     controller.relation = member.relation;
//     controller.gender = member.gender;

//     _isAddress = member.address != null;

//     if (member.address != null) {
//       addressController.loadAddress(member.address!);
//     } else {
//       addressController.clear();
//     }

//     setState(() {}); // ✅ IMPORTANT FIX
//   }

//   void _handleMemberCountChange(int count) {
//     if (count <= 0) return;

//     FocusScope.of(context).unfocus();

//     setState(() {
//       _totalMembers = count;

//       /// REMOVE EXTRA MEMBERS
//       if (savedMembers.isNotEmpty && savedMembers.length >= count) {
//         savedMembers = savedMembers.sublist(0, count);
//       }

//       /// CASE 1:
//       /// USER REDUCED COUNT
//       /// AND SAVED MEMBERS == TOTAL COUNT
//       /// SHOW LAST SAVED MEMBER
//       if (savedMembers.length == count) {
//         final lastMember = savedMembers.last;

//         controller.fullName.text = lastMember.fullName;
//         controller.mobile.text = lastMember.mobile;
//         controller.email.text = lastMember.email;

//         controller.relation = lastMember.relation;
//         controller.gender = lastMember.gender;

//         if (lastMember.address != null) {
//           addressController.loadAddress(lastMember.address!);
//           _isAddress = true;
//         } else {
//           addressController.clear();
//           _isAddress = false;
//         }

//         _currentMemberIndex = count;
//       } else {
//         _currentMemberIndex = (savedMembers.length + 1).clamp(1, count);

//         if (_editingIndex == null) {
//           _clearCurrentEditingForm();
//         }
//       }

//       controller.familyCount.text = count.toString();
//     });
//   }

//   @override
//   void dispose() {
//     controller.familyCount.dispose();
//     controller.fullName.dispose();
//     controller.mobile.dispose();
//     controller.email.dispose();
//     controller.password.dispose();

//     _scrollController.dispose();
//     _nameFocus.dispose(); // ✅ important
//     super.dispose();
//   }

//   void _resetForm() {
//     savedMembers.clear();
//     controller.familyCount.clear();
//     controller.fullName.clear();
//     controller.mobile.clear();
//     controller.email.clear();
//     controller.password.clear();

//     controller.gender = null;
//     controller.relation = null;

//     _totalMembers = 0;
//     _currentMemberIndex = 1;

//     // _isFamilyCountLocked = false;
//     //_hideBottomButton = false;
//     _isAddress = false;

//     addressController.clear();
//   }
//   // void updateMemberCount(int count) {
//   //   setState(() {
//   //     if (count > members.length) {
//   //       for (int i = members.length; i < count; i++) {
//   //         members.add(FamilyMemberData());
//   //       }
//   //     } else if (count < members.length) {
//   //       members.removeRange(count, members.length);
//   //     }

//   //     _totalMembers = count;
//   //   });
//   // }
//   // Future<void> _addMember() async {
//   //   final l10n = AppLocalizations.of(context)!;
//   //   final memberValid = widget.formKey.currentState?.validate() ?? false;
//   //   final isMemberValid = widget.formKey.currentState?.validate() ?? false;

//   //   /// 1️⃣ FIRST: Validate MEMBER fields
//   //   if (!isMemberValid) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text(l10n.pleaseFillMemberDetails),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //   if (!_isAddress) {
//   //     SnackbarHelper.showError(context, l10n.addAddressError);
//   //     return;
//   //   }

//   //   final addressValid = _addressFormKey.currentState?.validate() ?? false;

//   //   if (!memberValid || !addressValid) return;

//   //   // final prefs = await SharedPreferences.getInstance();
//   //   // final userId = prefs.getString("userId");
//   //   final userId = await AppPreferences.getUserId();
//   //   if (userId == null) return;

//   //   final body = controller.getApiFamilyMemberBody(
//   //     userId: userId,
//   //     address: _isAddress
//   //         ? addressController.getOnlyAddressMap(addressType: "flat")
//   //         : null,
//   //   );

//   //   AppLogger.success("body : $body");
//   //   setState(() => _isLoading = true);

//   //   try {
//   //     final response = await _authService.memberdetails(body: body);
//   //     setState(() {
//   //       _isLoading = false;
//   //       // _isFamilyCountLocked = true;
//   //     });
//   //     AppLogger.debug("Member added  ${jsonEncode(response)}");
//   //     savedMembers.add(
//   //       FamilyMemberData()
//   //         ..fullName.text = controller.fullName.text
//   //         ..mobile.text = controller.mobile.text
//   //         ..email.text = controller.email.text
//   //         ..relation = controller.relation
//   //         ..gender = controller.gender,
//   //     );
//   //     // Clear form for next member
//   //     controller.fullName.clear();
//   //     controller.mobile.clear();
//   //     controller.email.clear();
//   //     controller.password.clear();
//   //     controller.relation = null;
//   //     controller.gender = null;
//   //     if (_isAddress) addressController.clear();

//   //     // If last member
//   //     if (savedMembers.length >= _totalMembers) {
//   //       if (!context.mounted) return;
//   //       // setState(() {
//   //       //   _hideBottomButton = true;
//   //       // });

//   //       // ignore: use_build_context_synchronously
//   //       SnackbarHelper.ShowSuccess(context, l10n.allMembersAdded);
//   //       _resetForm();

//   //       // Delay slightly so user sees the snackbar
//   //       Future.delayed(const Duration(seconds: 1), () {
//   //         if (context.mounted)
//   //           context.push(
//   //             RouteNames.accountverfy,
//   //           ); // ignore: use_build_context_synchronously
//   //       });
//   //     } else {
//   //       // Increment member index for next member
//   //       setState(() {
//   //         _currentMemberIndex++;
//   //       });

//   //       FocusScope.of(context).unfocus();

//   //       WidgetsBinding.instance.addPostFrameCallback((_) {
//   //         if (_scrollController.hasClients) {
//   //           _scrollController.jumpTo(0); // faster than animate
//   //         }

//   //         // ✅ THIS IS THE FIX
//   //         _nameFocus.requestFocus();
//   //       });
//   //     }
//   //   } on DioException catch (e) {
//   //     if (!mounted) return;
//   //     setState(() => _isLoading = false);
//   //     String errorMsg = l10n.failedToAddMemberTryAgain;
//   //     if (e.response?.data != null) {
//   //       final data = e.response!.data;
//   //       if (data is Map) {
//   //         errorMsg =
//   //             data['message'] ?? data['error'] ?? data['msg'] ?? errorMsg;
//   //         if (data['errors'] != null && data['errors'] is Map) {
//   //           final errors = data['errors'] as Map;
//   //           final fieldErrors = errors.values
//   //               .map((v) => v is List ? v.first : v.toString())
//   //               .join(', ');
//   //           if (fieldErrors.isNotEmpty) errorMsg = fieldErrors;
//   //         }
//   //       } else if (data is String) {
//   //         errorMsg = data;
//   //       }
//   //     } else if (e.type == DioExceptionType.connectionTimeout ||
//   //         e.type == DioExceptionType.receiveTimeout) {
//   //       errorMsg = l10n.connectionTimeoutTryAgain;
//   //     } else if (e.type == DioExceptionType.connectionError) {
//   //       errorMsg = l10n.noInternetTryAgain;
//   //     }
//   //     SnackbarHelper.showError(context, errorMsg);
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     setState(() => _isLoading = false);
//   //     SnackbarHelper.showError(
//   //       context,
//   //       '${l10n.somethingWentWrong}: ${e.toString()}',
//   //     );
//   //   }
//   // }
//   Future<void> _addMember() async {
//     final l10n = AppLocalizations.of(context)!;

//     /// IMPORTANT FIX
//     /// If all required members already added,
//     /// directly submit without validating current empty form
//     if (savedMembers.length >= _totalMembers) {
//       await _submitAllMembers();
//       return;
//     }

//     final isMemberValid = widget.formKey.currentState?.validate() ?? false;

//     if (!isMemberValid) {
//       SnackbarHelper.showError(context, l10n.pleaseFillMemberDetails);
//       return;
//     }

//     if (!_isAddress) {
//       SnackbarHelper.showError(context, l10n.addAddressError);
//       return;
//     }

//     final addressValid = _addressFormKey.currentState?.validate() ?? false;

//     if (!addressValid) return;

//     /// SAVE MEMBER
//     final newMember = FamilyMemberData(
//       fullName: controller.fullName.text.trim(),
//       mobile: controller.mobile.text.trim(),
//       email: controller.email.text.trim(),
//       relation: controller.relation ?? "",
//       gender: controller.gender ?? "",
//       address: addressController.getOnlyAddressMap(addressType: "flat"),
//     );

//     if (_editingIndex != null) {
//       // ✅ UPDATE EXISTING MEMBER
//       savedMembers[_editingIndex!] = newMember;
//       _editingIndex = null;
//     } else {
//       // ✅ ADD NEW MEMBER
//       savedMembers.add(newMember);
//     }

//     AppLogger.success("Saved Members Count => ${savedMembers.length}");

//     /// IF LAST MEMBER
//     if (savedMembers.length >= _totalMembers) {
//       await _submitAllMembers();
//       return;
//     }

//     /// NEXT MEMBER
//     setState(() {
//       _currentMemberIndex = savedMembers.length + 1;
//     });

//     _clearCurrentEditingForm();
//   }

//   void _syncEditingToSaved() {
//     if (_editingIndex == null) return;

//     savedMembers[_editingIndex!] = FamilyMemberData(
//       fullName: controller.fullName.text.trim(),
//       mobile: controller.mobile.text.trim(),
//       email: controller.email.text.trim(),
//       relation: controller.relation ?? "",
//       gender: controller.gender ?? "",
//       address: addressController.getOnlyAddressMap(addressType: "flat"),
//     );
//   }

//   Future<void> _submitAllMembers() async {
//     if (_editingIndex != null) {
//       _syncEditingToSaved();
//       _editingIndex = null;
//     }
//     final l10n = AppLocalizations.of(context)!;

//     final userId = await AppPreferences.getUserId();

//     AppLogger.success("USER ID => $userId");

//     if (userId == null || userId.isEmpty) {
//       SnackbarHelper.showError(
//         context,
//         "User ID not found. Please login again.",
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final body = {
//         "userId": userId,
//         "members": savedMembers.map((e) => e.toJson()).toList(),
//       };

//       AppLogger.success("FINAL API BODY => ${jsonEncode(body)}");

//       final response = await _authService.memberdetails(body: body);

//       AppLogger.success("FINAL RESPONSE => ${jsonEncode(response)}");

//       if (!mounted) return;

//       setState(() => _isLoading = false);

//       SnackbarHelper.ShowSuccess(context, l10n.allMembersAdded);

//       _resetForm();

//       Future.delayed(const Duration(seconds: 1), () {
//         if (context.mounted) {
//           context.push(RouteNames.accountverfy);
//         }
//       });
//     } on DioException catch (e) {
//       if (!mounted) return;

//       setState(() => _isLoading = false);

//       String errorMsg = l10n.failedToAddMemberTryAgain;

//       if (e.response?.data != null) {
//         final data = e.response!.data;

//         if (data is Map) {
//           errorMsg = data['message'] ?? data['error'] ?? errorMsg;
//         }
//       }

//       SnackbarHelper.showError(context, errorMsg);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() => _isLoading = false);

//       SnackbarHelper.showError(context, e.toString());
//     }
//   }

//   void _clearCurrentEditingForm() {
//     controller.fullName.clear();
//     controller.mobile.clear();
//     controller.email.clear();
//     controller.password.clear();

//     controller.gender = null;
//     controller.relation = null;

//     addressController.clear();
//     _editingIndex = null; // ✅ VERY IMPORTANT

//     setState(() {});

//     FocusScope.of(context).unfocus();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(0);
//       }

//       _nameFocus.requestFocus();
//     });
//   }

//   // remove keyboard focus

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     return Form(
//       key: widget.formKey,
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Text(
//                   //   "Add ${widget.accountType} Member",
//                   //   style: const TextStyle(
//                   //     fontSize: 22,
//                   //     fontWeight: FontWeight.w600,
//                   //   ),
//                   // ),
//                   const SizedBox(height: 15),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(18),
//                             border: Border.all(
//                               color: AppColors.btn_primery.withOpacity(.12),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(.04),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.groups_rounded,
//                                     color: AppColors.btn_primery,
//                                     size: 22,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     l10n.enterFamilyCount,
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               const SizedBox(height: 16),

//                               Row(
//                                 children: [
//                                   /// MINUS BUTTON
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(14),
//                                     onTap: () {
//                                       int current =
//                                           int.tryParse(
//                                             controller.familyCount.text,
//                                           ) ??
//                                           0;

//                                       if (current > 1) {
//                                         _handleMemberCountChange(current - 1);
//                                       }
//                                     },
//                                     child: Container(
//                                       width: 48,
//                                       height: 48,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(14),
//                                         color: Colors.grey.shade100,
//                                       ),
//                                       child: const Icon(Icons.remove),
//                                     ),
//                                   ),

//                                   const SizedBox(width: 14),

//                                   /// COUNT VIEW
//                                   Expanded(
//                                     child: Container(
//                                       height: 52,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(14),
//                                         border: Border.all(
//                                           color: AppColors.btn_primery
//                                               .withOpacity(.15),
//                                         ),
//                                       ),
//                                       child: TextFormField(
//                                         controller: controller.familyCount,
//                                         keyboardType: TextInputType.number,
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                         decoration: const InputDecoration(
//                                           border: InputBorder.none,
//                                           counterText: "",
//                                         ),
//                                         maxLength: 2,
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter
//                                               .digitsOnly,
//                                         ],
//                                         validator: (value) => controller
//                                             .validatefamilycount(value, l10n),
//                                         onChanged: (val) {
//                                           final count = int.tryParse(val);

//                                           if (count != null && count > 0) {
//                                             _handleMemberCountChange(count);
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),

//                                   const SizedBox(width: 14),

//                                   /// PLUS BUTTON
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(14),
//                                     onTap: () {
//                                       int current =
//                                           int.tryParse(
//                                             controller.familyCount.text,
//                                           ) ??
//                                           0;

//                                       _handleMemberCountChange(current + 1);
//                                     },
//                                     child: Container(
//                                       width: 48,
//                                       height: 48,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(14),
//                                         color: AppColors.btn_primery,
//                                       ),
//                                       child: const Icon(
//                                         Icons.add,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               if (_totalMembers > 0) ...[
//                                 const SizedBox(height: 14),

//                                 /// PROGRESS
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: LinearProgressIndicator(
//                                     value: _currentMemberIndex / _totalMembers,
//                                     minHeight: 8,
//                                     backgroundColor: Colors.grey.shade200,
//                                     valueColor: AlwaysStoppedAnimation(
//                                       AppColors.btn_primery,
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 10),

//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       "Member $_currentMemberIndex of $_totalMembers",
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.grey.shade700,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),

//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 5,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.btn_primery
//                                             .withOpacity(.08),
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       child: Text(
//                                         "${savedMembers.length} Added",
//                                         style: TextStyle(
//                                           color: AppColors.btn_primery,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // const SizedBox(height: 10),
//                   // if (_totalMembers > 0)
//                   //   Text(
//                   //     l10n.addMemberTitle(
//                   //       _localizedAccountType(l10n),
//                   //       _currentMemberIndex.toString(),
//                   //       _totalMembers.toString(),
//                   //     ),
//                   //     style: const TextStyle(
//                   //       fontSize: 12,
//                   //       // fontWeight: FontWeight.w400,
//                   //     ),
//                   //   ),
//                   const SizedBox(height: 15),

//                   AppTextField(
//                     controller: controller.fullName,
//                     onChanged: (_) => _syncEditingToSaved(),
//                     label: l10n.memberFullName,
//                     focusNode: _nameFocus, // ✅ add this
//                     keyboardType: TextInputType.name,
//                     textInputAction: TextInputAction.next,
//                     validator: (value) =>
//                         controller.validatefullname(value, l10n),
//                   ),
//                   const SizedBox(height: 15),

//                   AppDropdown(
//                     label: l10n.relationship,
//                     items: [
//                       l10n.father,
//                       l10n.mother,
//                       l10n.son,
//                       l10n.daughter,
//                       l10n.husband,
//                       l10n.wife,
//                       l10n.addOther,
//                     ],
//                     value: controller.relation,
//                     onChanged: (val) => {
//                       setState(() => controller.relation = val),
//                       _syncEditingToSaved(),
//                     },
//                     validator: (val) =>
//                         val == null ? l10n.selectRelationship : null,
//                   ),

//                   const SizedBox(height: 15),

//                   // Mobile
//                   AppTextField(
//                     controller: controller.mobile,
//                     keyboardType: TextInputType.phone,
//                     textInputAction: TextInputAction.next,
//                     onChanged: (_) => _syncEditingToSaved(),
//                     label: l10n.mobileNumber,
//                     prefixText: "+973 ",
//                     maxLength: 8,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     validator: (value) =>
//                         controller.validatemobilenumber(value, l10n),
//                   ),

//                   const SizedBox(height: 15),

//                   // AppTextField(
//                   //   controller: controller.password,

//                   //   label: "Password*",
//                   //   validator: (value) => controller.validatepassword(value),
//                   // ),
//                   // const SizedBox(height: 15),
//                   AppTextField(
//                     controller: controller.email,
//                     onChanged: (_) => _syncEditingToSaved(),
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.done,
//                     label: '${l10n.emailAddress}*',
//                     validator: (value) => controller.validateemail(value, l10n),
//                   ),
//                   const SizedBox(height: 15),
//                   AppDropdown(
//                     label: l10n.gender,
//                     items: [l10n.male, l10n.female],
//                     value: controller.gender,
//                     onChanged: (val) => setState(() => controller.gender = val),
//                     validator: (val) => val == null ? l10n.selectGender : null,
//                   ),

//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 47,
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isAddress = !_isAddress;
//                         });
//                       },
//                       child: Text(
//                         _isAddress ? l10n.hideAddress : l10n.addAddress,
//                         style: TextStyle(color: AppColors.btn_primery),
//                       ),
//                     ),
//                   ),

//                   if (_isAddress)
//                     Column(
//                       children: [
//                         const SizedBox(height: 20),
//                         Address(
//                           accountType: "Family",
//                           family: true,
//                           formKey: _addressFormKey,
//                           controller: addressController, //  pass controller
//                           onChanged: _syncEditingToSaved, // ✅ IMPORTANT
//                         ),
//                       ],
//                     ),

//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),

//             // if (!_hideBottomButton)
//             AppButton(
//               text: savedMembers.length + 1 >= _totalMembers
//                   ? l10n.finish
//                   : l10n.addMember,
//               isLoading: _isLoading,
//               onPressed: _addMember,
//               color: AppColors.btn_primery,
//               width: double.infinity,
//               height: 47,
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/controllers/family_member_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/views/auth/Address.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

class FamilyMemberData {
  final String fullName;
  final String mobile;
  final String email;
  final String relation;
  final String gender;
  final Map<String, dynamic>? address;

  FamilyMemberData({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.relation,
    required this.gender,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "mobile": mobile,
      "email": email,
      "relation": relation,
      "gender": gender,
      "address": address,
    };
  }
}

class Addmember extends StatefulWidget {
  final String accountType;
  final VoidCallback onNext;
  final GlobalKey<FormState> formKey;

  const Addmember({
    super.key,
    required this.accountType,
    required this.onNext,
    required this.formKey,
  });

  @override
  State<Addmember> createState() => _AddmemberState();
}

class _AddmemberState extends State<Addmember> {
  final controller = FamilyMemberController();
  final addressController = AddressController();
  final AuthService _authService = AuthService();
  bool _isAddress = false;
  int? _editingIndex;
  // bool _isFamilyCountLocked = false;
  // bool _hideBottomButton = false;
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _nameFocus = FocusNode();
  bool _isLoading = false;
  final Map<String, String> genderMap = {'male': 'Male', 'female': 'Female'};
  int _totalMembers = 0;
  int _currentMemberIndex = 1;
  List<Map<String, dynamic>> familyMembers = [];
  int? editingIndex;
  int currentIndex = 0;
  bool _showFamilyCountError = false;

  bool _isFamilyCountEditable = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  String? selectedGender;
  String? selectedRelationship;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _localizedAccountType(AppLocalizations l10n) {
    switch (widget.accountType) {
      case "Family":
        return l10n.family;
      case "Individual":
        return l10n.individual;
      default:
        return widget.accountType;
    }
  }

  void loadMember(int index) {
    currentIndex = index;

    final member = familyMembers[index];

    controller.fullName.text = member["fullName"] ?? "";

    controller.mobile.text = member["mobile"] ?? "";

    controller.email.text = member["email"] ?? "";

    controller.relation =
        member["relation"] == null ||
            member["relation"].toString().trim().isEmpty
        ? null
        : member["relation"];

    controller.gender =
        member["gender"] == null || member["gender"].toString().trim().isEmpty
        ? null
        : member["gender"];

    final address = member["address"] ?? {};

    addressController.city.text = address["city"] ?? "";

    addressController.building.text = address["building"] ?? "";

    addressController.aptNo.text = address["aptNo"] ?? "";

    addressController.floor.text = address["floor"] ?? "";

    addressController.block = address["block"];

    addressController.blockId = address["blockId"];

    addressController.road = address["road"];

    addressController.roadId = address["roadId"];

    setState(() {});
  }

  void nextMember() {
    updateCurrentMember();

    if (currentIndex < _totalMembers - 1) {
      loadMember(currentIndex + 1);

      setState(() {
        _currentMemberIndex = currentIndex + 1;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }

        FocusScope.of(context).unfocus();
        _nameFocus.requestFocus();
      });
    }
  }

  void previousMember() {
    updateCurrentMember();

    if (currentIndex > 0) {
      loadMember(currentIndex - 1);
    }
  }

  void addMember() {
    if (!formKey.currentState!.validate()) return;

    final member = {
      "fullName": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "gender": selectedGender,
      "relationship": selectedRelationship,

      /// ADDRESS OBJECT
      "address": {
        "city": addressController.city.text.trim(),
        "building": addressController.building.text.trim(),
        "aptNo": addressController.aptNo.text.trim(),
        "floor": addressController.floor.text.trim(),
        "block": addressController.block,
        "blockId": addressController.blockId,
        "road": addressController.road,
        "roadId": addressController.roadId,
        "addressType": addressController.getOnlyAddressMap(addressType: "flat"),
      },
    };

    familyMembers.add(member);

    clearForm();

    setState(() {});
  }

  void clearForm() {
    nameController.clear();
    mobileController.clear();

    selectedGender = null;
    selectedRelationship = null;

    formKey.currentState?.reset();

    setState(() {});
  }

  void updateCurrentMember() {
    if (familyMembers.isEmpty) return;

    familyMembers[currentIndex] = {
      "fullName": controller.fullName.text.trim(),

      "mobile": controller.mobile.text.trim(),

      "email": controller.email.text.trim(),

      "relation": controller.relation,

      "gender": controller.gender,

      "address": {
        "city": addressController.city.text.trim(),

        "building": addressController.building.text.trim(),

        "aptNo": addressController.aptNo.text.trim(),

        "floor": addressController.floor.text.trim(),

        "block": addressController.block,

        "blockId": addressController.blockId,

        "road": addressController.road,

        "roadId": addressController.roadId,

        "addressType": "flat",
      },
    };
  }

  // void _handleMemberCountChange(int count) {
  //   if (count <= 0) return;

  //   updateCurrentMember();

  //   final oldLength = familyMembers.length;

  //   setState(() {
  //     _totalMembers = count;

  //     // ADD MEMBERS
  //     while (familyMembers.length < count) {
  //       familyMembers.add({
  //         "fullName": "",
  //         "mobile": "",
  //         "email": "",
  //         "relation": null,
  //         "gender": null,
  //         "address": {},
  //       });
  //     }

  //     // REMOVE MEMBERS
  //     if (familyMembers.length > count) {
  //       familyMembers.removeRange(count, familyMembers.length);
  //     }

  //     // PLUS button -> open newly added member
  //     if (count > oldLength) {
  //       currentIndex = count - 1;
  //     }

  //     // MINUS button -> stay in valid range
  //     if (currentIndex >= count) {
  //       currentIndex = count - 1;
  //     }

  //     _currentMemberIndex = currentIndex + 1;
  //   });

  //   loadMember(currentIndex);

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _nameFocus.requestFocus();
  //   });
  // }
  void _handleMemberCountChange(int count) {
    if (count <= 0) return;

    updateCurrentMember();

    setState(() {
      _totalMembers = count;

      while (familyMembers.length < count) {
        familyMembers.add({
          "fullName": "",
          "mobile": "",
          "email": "",
          "relation": null,
          "gender": null,
          "address": {},
        });
      }

      if (familyMembers.length > count) {
        familyMembers.removeRange(count, familyMembers.length);
      }

      if (currentIndex >= count) {
        currentIndex = count - 1;
      }

      _currentMemberIndex = currentIndex + 1;
    });

    if (familyMembers.isNotEmpty) {
      loadMember(currentIndex);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.familyCount.dispose();
    controller.fullName.dispose();
    controller.mobile.dispose();
    controller.email.dispose();
    controller.password.dispose();

    _scrollController.dispose();
    _nameFocus.dispose(); // ✅ important
    super.dispose();
  }

  void _resetForm() {
    controller.familyCount.clear();
    controller.fullName.clear();
    controller.mobile.clear();
    controller.email.clear();
    controller.password.clear();

    controller.gender = null;
    controller.relation = null;

    _totalMembers = 0;
    _currentMemberIndex = 1;
    currentIndex = 0;

    familyMembers.clear(); // ✅ IMPORTANT FIX

    _isAddress = false;

    addressController.clear();

    setState(() {}); // ✅ IMPORTANT FIX
  }
  // void updateMemberCount(int count) {
  //   setState(() {
  //     if (count > members.length) {
  //       for (int i = members.length; i < count; i++) {
  //         members.add(FamilyMemberData());
  //       }
  //     } else if (count < members.length) {
  //       members.removeRange(count, members.length);
  //     }

  //     _totalMembers = count;
  //   });
  // }
  // Future<void> _addMember() async {
  //   final l10n = AppLocalizations.of(context)!;
  //   final memberValid = widget.formKey.currentState?.validate() ?? false;
  // final isMemberValid = widget.formKey.currentState?.validate() ?? false;

  //   /// 1️⃣ FIRST: Validate MEMBER fields
  //   if (!isMemberValid) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(l10n.pleaseFillMemberDetails),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //   if (!_isAddress) {
  //     SnackbarHelper.showError(context, l10n.addAddressError);
  //     return;
  //   }

  //   final addressValid = _addressFormKey.currentState?.validate() ?? false;

  //   if (!memberValid || !addressValid) return;

  //   // final prefs = await SharedPreferences.getInstance();
  //   // final userId = prefs.getString("userId");
  //   final userId = await AppPreferences.getUserId();
  //   if (userId == null) return;

  //   final body = controller.getApiFamilyMemberBody(
  //     userId: userId,
  //     address: _isAddress
  //         ? addressController.getOnlyAddressMap(addressType: "flat")
  //         : null,
  //   );

  //   AppLogger.success("body : $body");
  //   setState(() => _isLoading = true);

  //   try {
  //     final response = await _authService.memberdetails(body: body);
  //     setState(() {
  //       _isLoading = false;
  //       // _isFamilyCountLocked = true;
  //     });
  //     AppLogger.debug("Member added  ${jsonEncode(response)}");
  //     savedMembers.add(
  //       FamilyMemberData()
  //         ..fullName.text = controller.fullName.text
  //         ..mobile.text = controller.mobile.text
  //         ..email.text = controller.email.text
  //         ..relation = controller.relation
  //         ..gender = controller.gender,
  //     );
  //     // Clear form for next member
  //     controller.fullName.clear();
  //     controller.mobile.clear();
  //     controller.email.clear();
  //     controller.password.clear();
  //     controller.relation = null;
  //     controller.gender = null;
  //     if (_isAddress) addressController.clear();

  //     // If last member
  //     if (savedMembers.length >= _totalMembers) {
  //       if (!context.mounted) return;
  //       // setState(() {
  //       //   _hideBottomButton = true;
  //       // });

  //       // ignore: use_build_context_synchronously
  //       SnackbarHelper.ShowSuccess(context, l10n.allMembersAdded);
  //       _resetForm();

  //       // Delay slightly so user sees the snackbar
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (context.mounted)
  //           context.push(
  //             RouteNames.accountverfy,
  //           ); // ignore: use_build_context_synchronously
  //       });
  //     } else {
  //       // Increment member index for next member
  //       setState(() {
  //         _currentMemberIndex++;
  //       });

  //       FocusScope.of(context).unfocus();

  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_scrollController.hasClients) {
  //           _scrollController.jumpTo(0); // faster than animate
  //         }

  //         // ✅ THIS IS THE FIX
  //         _nameFocus.requestFocus();
  //       });
  //     }
  //   } on DioException catch (e) {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //     String errorMsg = l10n.failedToAddMemberTryAgain;
  //     if (e.response?.data != null) {
  //       final data = e.response!.data;
  //       if (data is Map) {
  //         errorMsg =
  //             data['message'] ?? data['error'] ?? data['msg'] ?? errorMsg;
  //         if (data['errors'] != null && data['errors'] is Map) {
  //           final errors = data['errors'] as Map;
  //           final fieldErrors = errors.values
  //               .map((v) => v is List ? v.first : v.toString())
  //               .join(', ');
  //           if (fieldErrors.isNotEmpty) errorMsg = fieldErrors;
  //         }
  //       } else if (data is String) {
  //         errorMsg = data;
  //       }
  //     } else if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout) {
  //       errorMsg = l10n.connectionTimeoutTryAgain;
  //     } else if (e.type == DioExceptionType.connectionError) {
  //       errorMsg = l10n.noInternetTryAgain;
  //     }
  //     SnackbarHelper.showError(context, errorMsg);
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //     SnackbarHelper.showError(
  //       context,
  //       '${l10n.somethingWentWrong}: ${e.toString()}',
  //     );
  //   }
  // }

  Future<void> _addMember() async {
    final l10n = AppLocalizations.of(context)!;

    /// IMPORTANT FIX
    /// If all required members already added,
    /// directly submit without validating current empty form
    // if (savedMembers.length >= _totalMembers) {
    //   await _submitAllMembers();
    //   return;
    // }
    final isMemberValid = widget.formKey.currentState?.validate() ?? false;

    if (!isMemberValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillMemberDetails),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_isAddress) {
      SnackbarHelper.showError(context, l10n.addAddressError);
      return;
    }

    // final isMemberValid = widget.formKey.currentState?.validate() ?? false;

    if (!isMemberValid) {
      SnackbarHelper.showError(context, l10n.pleaseFillMemberDetails);
      return;
    }

    if (!_isAddress) {
      SnackbarHelper.showError(context, l10n.addAddressError);
      return;
    }

    final addressValid = _addressFormKey.currentState?.validate() ?? false;

    if (!addressValid) return;

    /// SAVE MEMBER
    final newMember = FamilyMemberData(
      fullName: controller.fullName.text.trim(),
      mobile: controller.mobile.text.trim(),
      email: controller.email.text.trim(),
      relation: controller.relation ?? "",
      gender: controller.gender ?? "",
      address: addressController.getOnlyAddressMap(addressType: "flat"),
    );

    // _saveOrUpdateMember(newMember);

    // AppLogger.success("Saved Members Count => ${savedMembers.length}");

    // /// IF LAST MEMBER
    // if (savedMembers.length >= _totalMembers) {
    //   await _submitAllMembers();
    //   return;
    // }

    // /// NEXT MEMBER
    // setState(() {
    //   _currentMemberIndex = savedMembers.length + 1;
    // });

    _clearCurrentEditingForm();
  }

  // void _syncEditingToSaved() {
  //   if (_editingIndex == null) return;

  //   savedMembers[_editingIndex!] = FamilyMemberData(
  //     fullName: controller.fullName.text.trim(),
  //     mobile: controller.mobile.text.trim(),
  //     email: controller.email.text.trim(),
  //     relation: controller.relation ?? "",
  //     gender: controller.gender ?? "",
  //     address: addressController.getOnlyAddressMap(addressType: "flat"),
  //   );
  // }
  bool isMemberComplete(Map<String, dynamic> member) {
    final address = member["address"];

    return (member["fullName"] ?? "").toString().trim().isNotEmpty &&
        (member["mobile"] ?? "").toString().trim().isNotEmpty &&
        (member["email"] ?? "").toString().trim().isNotEmpty &&
        member["relation"] != null &&
        member["gender"] != null &&
        address != null &&
        (address["building"] ?? "").toString().trim().isNotEmpty &&
        address["blockId"] != null &&
        address["roadId"] != null;
  }

  Future<void> _submitAllMembers() async {
    updateCurrentMember();

    final l10n = AppLocalizations.of(context)!;

    final userId = await AppPreferences.getUserId();

    if (userId == null || userId.isEmpty) {
      SnackbarHelper.showError(context, "User ID not found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final validMembers = familyMembers.where(isMemberComplete).toList();
      final body = {
        "userId": userId,
        "familyCount": validMembers.length.toString(),
        "familyMembers": validMembers.map((member) {
          return {
            "fullName": member["fullName"],
            "relation": member["relation"]?.toString().toLowerCase(),
            "mobile": int.tryParse(member["mobile"].toString()) ?? 0,
            "email": member["email"],
            "gender": member["gender"]?.toString().toLowerCase(),
            "address": {
              "addressType": "home",
              "city": member["address"]["city"],
              "building": member["address"]["building"],
              "floor": member["address"]["floor"],
              "aptNo": member["address"]["aptNo"],
              "roadId": member["address"]["roadId"],
              "blockId": member["address"]["blockId"],
            },
          };
        }).toList(),
      };
      AppLogger.success("FINAL BODY => ${jsonEncode(body)}");

      final response = await _authService.memberdetails(body: body);

      AppLogger.success("RESPONSE => ${jsonEncode(response)}");

      if (!mounted) return;

      setState(() => _isLoading = false);

      SnackbarHelper.ShowSuccess(context, l10n.allMembersAdded);
      _resetForm();
      context.push(RouteNames.accountverfy);
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      SnackbarHelper.showError(
        context,
        e.response?.data["message"] ?? "Something went wrong",
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      SnackbarHelper.showError(context, e.toString());
    }
  }

  void _clearCurrentEditingForm() {
    controller.fullName.clear();
    controller.mobile.clear();
    controller.email.clear();
    controller.password.clear();

    controller.gender = null;
    controller.relation = null;

    addressController.clear();
    _editingIndex = null; // ✅ VERY IMPORTANT

    setState(() {});

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      _nameFocus.requestFocus();
    });
  }

  // remove keyboard focus
  int get completedMembers {
    return familyMembers.where(isMemberComplete).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completed = completedMembers;
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Add ${widget.accountType} Member",
                  //   style: const TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.btn_primery.withOpacity(.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.groups_rounded,
                                    color: AppColors.btn_primery,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.enterFamilyCount,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  /// MINUS BUTTON
                                  InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      int current =
                                          int.tryParse(
                                            controller.familyCount.text,
                                          ) ??
                                          0;

                                      if (current > 1) {
                                        final newCount = current - 1;

                                        controller.familyCount.text = newCount
                                            .toString();

                                        _handleMemberCountChange(newCount);
                                      }
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.grey.shade100,
                                      ),
                                      child: const Icon(Icons.remove),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  /// COUNT VIEW
                                  Expanded(
                                    child: Container(
                                      height: 52,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.btn_primery
                                              .withOpacity(.15),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: controller.familyCount,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          counterText: "",
                                        ),
                                        maxLength: 2,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        onChanged: (val) {
                                          updateCurrentMember();

                                          /// Allow temporary empty state while editing
                                          if (val.isEmpty) {
                                            return;
                                          }

                                          final current =
                                              familyMembers.isNotEmpty
                                              ? familyMembers[currentIndex]
                                              : null;

                                          /// Don't allow count change if current member incomplete
                                          if (current != null &&
                                              !isMemberComplete(current)) {
                                            final previousValue = _totalMembers
                                                .toString();

                                            controller
                                                .familyCount
                                                .value = TextEditingValue(
                                              text: previousValue,
                                              selection:
                                                  TextSelection.collapsed(
                                                    offset:
                                                        previousValue.length,
                                                  ),
                                            );

                                            FocusScope.of(context).unfocus();

                                            SnackbarHelper.showError(
                                              context,
                                              "Please fill current member first",
                                            );

                                            return;
                                          }

                                          final count = int.tryParse(val);

                                          if (count == null) {
                                            return;
                                          }

                                          /// Prevent 0
                                          if (count <= 0) {
                                            controller
                                                .familyCount
                                                .value = TextEditingValue(
                                              text: _totalMembers.toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                    offset: _totalMembers
                                                        .toString()
                                                        .length,
                                                  ),
                                            );

                                            SnackbarHelper.showError(
                                              context,
                                              "Family count must be greater than 0",
                                            );

                                            return;
                                          }

                                          /// Limit to 10
                                          if (count >= 10) {
                                            controller.familyCount.value =
                                                const TextEditingValue(
                                                  text: "10",
                                                  selection:
                                                      TextSelection.collapsed(
                                                        offset: 2,
                                                      ),
                                                );

                                            SnackbarHelper.showError(
                                              context,
                                              "Maximum family count is 10",
                                            );

                                            _handleMemberCountChange(10);

                                            return;
                                          }

                                          setState(() {
                                            _showFamilyCountError = false;
                                          });
                                          final previousCount = _totalMembers;

                                          _handleMemberCountChange(count);

                                          /// User increased count
                                          if (count > previousCount) {
                                            /// Find first incomplete member
                                            final nextIndex = familyMembers
                                                .indexWhere(
                                                  (m) => !isMemberComplete(m),
                                                );

                                            if (nextIndex != -1) {
                                              currentIndex = nextIndex;

                                              loadMember(nextIndex);

                                              setState(() {
                                                _currentMemberIndex =
                                                    nextIndex + 1;
                                              });

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    _nameFocus.requestFocus();
                                                  });
                                            }

                                            return;
                                          }
                                          // final previousCount = _totalMembers;

                                          // /// User is increasing count
                                          // if (count > previousCount) {
                                          //   /// Allow only next member creation
                                          //   final newCount = previousCount + 1;

                                          //   controller.familyCount.value =
                                          //       TextEditingValue(
                                          //         text: newCount.toString(),
                                          //         selection:
                                          //             TextSelection.collapsed(
                                          //               offset: newCount
                                          //                   .toString()
                                          //                   .length,
                                          //             ),
                                          //       );

                                          //   _handleMemberCountChange(newCount);

                                          //   currentIndex = newCount - 1;

                                          //   loadMember(currentIndex);

                                          //   setState(() {
                                          //     _currentMemberIndex =
                                          //         currentIndex + 1;
                                          //   });

                                          //   WidgetsBinding.instance
                                          //       .addPostFrameCallback((_) {
                                          //         _nameFocus.requestFocus();
                                          //       });

                                          //   return;
                                          // }

                                          // /// User decreased count
                                          // _handleMemberCountChange(count);

                                          // if (familyMembers.isNotEmpty) {
                                          //   currentIndex = currentIndex.clamp(
                                          //     0,
                                          //     familyMembers.length - 1,
                                          //   );

                                          //   loadMember(currentIndex);

                                          //   setState(() {
                                          //     _currentMemberIndex =
                                          //         currentIndex + 1;
                                          //   });
                                          // }
                                        },
                                      ),

                                      // TextFormField(
                                      //   // readOnly:
                                      //   //     familyMembers.isNotEmpty &&
                                      //   //     !isMemberComplete(
                                      //   //       familyMembers[currentIndex],
                                      //   //     ),
                                      //   controller: controller.familyCount,
                                      //   keyboardType: TextInputType.number,
                                      //   textAlign: TextAlign.center,
                                      //   style: const TextStyle(
                                      //     fontSize: 22,
                                      //     fontWeight: FontWeight.w700,
                                      //   ),
                                      //   decoration: const InputDecoration(
                                      //     border: InputBorder.none,
                                      //     counterText: "",
                                      //   ),
                                      //   maxLength: 2,
                                      //   inputFormatters: [
                                      //     FilteringTextInputFormatter
                                      //         .digitsOnly,
                                      //   ],
                                      //   onChanged: (val) {
                                      //     updateCurrentMember();

                                      //     final current =
                                      //         familyMembers.isNotEmpty
                                      //         ? familyMembers[currentIndex]
                                      //         : null;

                                      //     /// Block editing if current member incomplete
                                      //     if (current != null &&
                                      //         !isMemberComplete(current)) {
                                      //       final previousValue = _totalMembers
                                      //           .toString();

                                      //       controller
                                      //           .familyCount
                                      //           .value = TextEditingValue(
                                      //         text: previousValue,
                                      //         selection:
                                      //             TextSelection.collapsed(
                                      //               offset:
                                      //                   previousValue.length,
                                      //             ),
                                      //       );

                                      //       FocusScope.of(context).unfocus();

                                      //       SnackbarHelper.showError(
                                      //         context,
                                      //         "Please fill current member first",
                                      //       );

                                      //       return;
                                      //     }

                                      //     final count = int.tryParse(val);

                                      //     if (count == null || count <= 0) {
                                      //       controller
                                      //           .familyCount
                                      //           .value = TextEditingValue(
                                      //         text: _totalMembers.toString(),
                                      //         selection:
                                      //             TextSelection.collapsed(
                                      //               offset: _totalMembers
                                      //                   .toString()
                                      //                   .length,
                                      //             ),
                                      //       );
                                      //       return;
                                      //     }

                                      //     setState(() {
                                      //       _showFamilyCountError = false;
                                      //     });

                                      //     _handleMemberCountChange(count);
                                      //   },
                                      //   // onChanged: (val) {
                                      //   //   updateCurrentMember();

                                      //   //   final count = int.tryParse(val);

                                      //   //   if (count != null &&
                                      //   //       count > _totalMembers) {
                                      //   //     final current =
                                      //   //         familyMembers.isNotEmpty
                                      //   //         ? familyMembers[currentIndex]
                                      //   //         : null;

                                      //   //     if (current != null &&
                                      //   //         !isMemberComplete(current)) {
                                      //   //       controller.familyCount.text =
                                      //   //           _totalMembers.toString();

                                      //   //       controller.familyCount.selection =
                                      //   //           TextSelection.fromPosition(
                                      //   //             TextPosition(
                                      //   //               offset: controller
                                      //   //                   .familyCount
                                      //   //                   .text
                                      //   //                   .length,
                                      //   //             ),
                                      //   //           );

                                      //   //       FocusScope.of(context).unfocus();

                                      //   //       SnackbarHelper.showError(
                                      //   //         context,
                                      //   //         "Please fill current member first",
                                      //   //       );

                                      //   //       return;
                                      //   //     }
                                      //   //   }

                                      //   //   if (count == null || count <= 0) {
                                      //   //     controller.familyCount.clear();

                                      //   //     setState(() {
                                      //   //       _totalMembers = 0;
                                      //   //     });

                                      //   //     return;
                                      //   //   }

                                      //   //   setState(() {
                                      //   //     _showFamilyCountError = false;
                                      //   //   });

                                      //   //   _handleMemberCountChange(count);
                                      //   // },

                                      //   // validator: (value) => controller
                                      //   //     .validatefamilycount(value, l10n),
                                      //   // onChanged: (val) {
                                      //   //   final count = int.tryParse(val);

                                      //   //   /// Prevent 0
                                      //   //   if (count == null || count <= 0) {
                                      //   //     controller.familyCount.clear();

                                      //   //     setState(() {
                                      //   //       _totalMembers = 0;
                                      //   //     });

                                      //   //     return;
                                      //   //   }

                                      //   //   /// VALID
                                      //   //   setState(() {
                                      //   //     _showFamilyCountError = false;
                                      //   //   });
                                      //   //   _handleMemberCountChange(count);
                                      //   // },
                                      // ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  /// PLUS BUTTON
                                  InkWell(
                                    borderRadius: BorderRadius.circular(14),

                                    /// PLUS
                                    onTap: () {
                                      final current = familyMembers.isNotEmpty
                                          ? familyMembers[currentIndex]
                                          : null;

                                      /// 1. If current form is empty → DO NOT MOVE
                                      if (current != null &&
                                          !isMemberComplete(current)) {
                                        SnackbarHelper.showError(
                                          context,
                                          "Please fill current member first",
                                        );
                                        return;
                                      }

                                      /// 2. Save current before moving
                                      updateCurrentMember();

                                      /// 3. Increase count
                                      final currentCount =
                                          int.tryParse(
                                            controller.familyCount.text.trim(),
                                          ) ??
                                          0;

                                      final newCount = currentCount + 1;

                                      controller.familyCount.text = newCount
                                          .toString();

                                      _handleMemberCountChange(newCount);

                                      /// 4. Move to new form only if needed
                                      if (familyMembers.length < newCount) {
                                        familyMembers.add({
                                          "fullName": "",
                                          "mobile": "",
                                          "email": "",
                                          "relation": null,
                                          "gender": null,
                                          "address": {},
                                        });
                                      }

                                      currentIndex = newCount - 1;
                                      loadMember(currentIndex);

                                      setState(() {
                                        _currentMemberIndex = currentIndex + 1;
                                      });
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: AppColors.btn_primery,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_showFamilyCountError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 4,
                                  ),
                                  child: Text(
                                    l10n.enterFamilyCount,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (_totalMembers > 0) ...[
                                const SizedBox(height: 14),

                                /// PROGRESS
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: _totalMembers == 0
                                        ? 0
                                        : (completedMembers / _totalMembers),
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.btn_primery,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.member} ${currentIndex + 1} "
                                      "${AppLocalizations.of(context)!.ofText} $_totalMembers",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.btn_primery
                                            .withOpacity(.08),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        "${familyMembers.where((e) => (e["fullName"] ?? "").toString().trim().isNotEmpty).length} "
                                        "${AppLocalizations.of(context)!.added}",
                                        style: TextStyle(
                                          color: AppColors.btn_primery,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  // if (_totalMembers > 0)
                  //   Text(
                  //     l10n.addMemberTitle(
                  //       _localizedAccountType(l10n),
                  //       _currentMemberIndex.toString(),
                  //       _totalMembers.toString(),
                  //     ),
                  //     style: const TextStyle(
                  //       fontSize: 12,
                  //       // fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  const SizedBox(height: 15),

                  AppTextField(
                    controller: controller.fullName,
                    onChanged: (_) {
                      updateCurrentMember();
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\u0600-\u06FF ]'),
                      ),
                    ],
                    // onChanged: (_) => _syncEditingToSaved(),
                    label: l10n.memberFullName,
                    focusNode: _nameFocus, // ✅ add this
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        controller.validatefullname(value, l10n),
                  ),
                  const SizedBox(height: 15),

                  AppDropdown(
                    label: l10n.relationship,
                    items: [
                      l10n.father,
                      l10n.mother,
                      l10n.son,
                      l10n.daughter,
                      l10n.husband,
                      l10n.wife,
                      l10n.addOther,
                    ],
                    value: controller.relation,
                    onChanged: (val) {
                      controller.relation = val;

                      updateCurrentMember();

                      setState(() {});
                    },
                    validator: (val) =>
                        val == null ? l10n.selectRelationship : null,
                  ),

                  const SizedBox(height: 15),

                  // Mobile
                  AppTextField(
                    controller: controller.mobile,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      updateCurrentMember();
                    },
                    // onChanged: (_) => _syncEditingToSaved(),
                    label: l10n.mobileNumber,
                    prefixText: "+973 ",
                    maxLength: 8,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        controller.validatemobilenumber(value, l10n),
                  ),

                  const SizedBox(height: 15),

                  // AppTextField(
                  //   controller: controller.password,

                  //   label: "Password*",
                  //   validator: (value) => controller.validatepassword(value),
                  // ),
                  // const SizedBox(height: 15),
                  AppTextField(
                    controller: controller.email,
                    onChanged: (_) {
                      updateCurrentMember();
                    },
                    // onChanged: (_) => _syncEditingToSaved(),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    label: '${l10n.emailAddress}*',
                    validator: (value) => controller.validateemail(value, l10n),
                  ),
                  const SizedBox(height: 15),
                  AppDropdown(
                    label: l10n.gender,
                    items: [l10n.male, l10n.female],
                    value: controller.gender,
                    onChanged: (val) {
                      controller.gender = val;

                      updateCurrentMember();

                      setState(() {});
                    },
                    validator: (val) => val == null ? l10n.selectGender : null,
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isAddress = !_isAddress;
                        });
                      },
                      child: Text(
                        _isAddress ? l10n.hideAddress : l10n.addAddress,
                        style: TextStyle(color: AppColors.btn_primery),
                      ),
                    ),
                  ),

                  if (_isAddress)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Address(
                          accountType: "Family",
                          family: true,
                          formKey: _addressFormKey,
                          controller: addressController, //  pass controller
                          // onChanged: _syncEditingToSaved, // ✅ IMPORTANT
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            // if (!_hideBottomButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: AppButton(
                text: currentIndex + 1 == _totalMembers
                    ? l10n.finish
                    : l10n.next,

                isLoading: _isLoading,

                // onPressed: () async {
                //   final isFamilyCountEmpty = controller.familyCount.text
                //       .trim()
                //       .isEmpty;

                //   setState(() {
                //     _showFamilyCountError = isFamilyCountEmpty;
                //   });

                //   // Member form validation
                //   final isMemberValid =
                //       widget.formKey.currentState?.validate() ?? false;

                //   if (!isMemberValid) {
                //     return; // field errors will show below fields
                //   }

                //   // Address must be expanded
                //   if (!_isAddress) {
                //     SnackbarHelper.showError(context, l10n.addAddressError);
                //     return;
                //   }

                //   // Address validation
                //   final isAddressValid =
                //       _addressFormKey.currentState?.validate() ?? false;

                //   if (!isAddressValid) {
                //     return; // address field errors show below fields
                //   }

                //   if (isFamilyCountEmpty) {
                //     return;
                //   }

                //   /// Save current member + address locally
                //   updateCurrentMember();

                //   final completed = completedMembers;

                //   if (completed >= _totalMembers) {
                //     await _submitAllMembers();
                //     return;
                //   }

                //   /// Load next member
                //   final nextIndex = familyMembers.indexWhere(
                //     (m) => !isMemberComplete(m),
                //   );

                //   if (nextIndex != -1) {
                //     loadMember(nextIndex);

                //     setState(() {
                //       currentIndex = nextIndex;
                //       _currentMemberIndex = nextIndex + 1;
                //     });

                //     WidgetsBinding.instance.addPostFrameCallback((_) {
                //       _nameFocus.requestFocus();
                //     });
                //   }
                // },
                onPressed: () async {
                  final l10n = AppLocalizations.of(context)!;

                  final isCountEmpty = controller.familyCount.text
                      .trim()
                      .isEmpty;
                  if (isCountEmpty) {
                    setState(() => _showFamilyCountError = true);
                    return;
                  }

                  final isMemberValid =
                      widget.formKey.currentState?.validate() ?? false;

                  if (!isMemberValid) return;

                  if (!_isAddress) {
                    SnackbarHelper.showError(context, l10n.addAddressError);
                    return;
                  }

                  final isAddressValid =
                      _addressFormKey.currentState?.validate() ?? false;

                  if (!isAddressValid) return;

                  /// 1. SAVE CURRENT FORM LOCALLY
                  updateCurrentMember();

                  /// 2. CHECK IF CURRENT MEMBER IS COMPLETE
                  final current = familyMembers[currentIndex];

                  final isComplete = isMemberComplete(current);

                  /// ❌ IF NOT COMPLETE → DO NOT MOVE
                  if (!isComplete) {
                    SnackbarHelper.showError(
                      context,
                      "Please complete current member before continuing",
                    );
                    return;
                  }

                  /// 3. IF LAST MEMBER → CALL API
                  final completed = completedMembers;

                  if (completed >= _totalMembers) {
                    await _submitAllMembers();
                    return;
                  }

                  /// 4. MOVE TO NEXT EMPTY MEMBER
                  final nextIndex = familyMembers.indexWhere(
                    (m) => !isMemberComplete(m),
                  );

                  if (nextIndex != -1) {
                    loadMember(nextIndex);

                    setState(() {
                      currentIndex = nextIndex;
                      _currentMemberIndex = nextIndex + 1;
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _nameFocus.requestFocus();
                    });
                  }
                },
                color: AppColors.btn_primery,
                width: double.infinity,
                //height: 58,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
