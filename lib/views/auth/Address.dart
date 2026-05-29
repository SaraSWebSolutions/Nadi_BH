import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/auth_Provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/auth_service.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/inputs/app_dropdown.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';

class Address extends StatefulWidget {
  final String accountType;
  final VoidCallback? onNext;
  final VoidCallback? onChanged;
  final bool family;
  final GlobalKey<FormState> formKey;
  final AddressController controller;
  const Address({
    super.key,
    required this.accountType,
    this.onNext,
    this.family = false,
    required this.formKey,
    required this.controller,
    this.onChanged, // ✅ ADD THIS
  });

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  String selected = "Flat";
  bool _isLoading = false;
  bool _hideBottomButton = false;
  bool get showButton {
    return controller.city.text.isNotEmpty &&
        controller.building.text.isNotEmpty &&
        controller.block != null &&
        controller.road != null;
  }

  // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _adressservice = AuthService();
  AddressController get controller => widget.controller;
  @override
  void _resetAll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clear();

      setState(() {
        selected = "Flat";
        _isLoading = false;
        // _formKey = GlobalKey<FormState>(); // clears validation UI
      });
    });
  }

  Future<void> familyAccount(BuildContext context) async {
    final userId = await AppPreferences.getUserId();

    if (userId == null) {
      AppLogger.info(" USER ID IS NULL");
      return;
    }

    final body = controller.getApiAddressBody(
      userId: userId,
      addressType: selected.toLowerCase(),
    );

    // debugPrint(" API BODY  $body");
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = true);
    });

    try {
      final response = await _adressservice.adressdetails(body: body);
      // API finished
      if (mounted) setState(() => _isLoading = false);

      if (response != null) {
        if (widget.accountType == "Family") {
          widget.onNext?.call();
        } else {
          if (!context.mounted) return;

          /// ✅ CLEAR ALL FIELDS HERE
          controller.city.clear();
          controller.building.clear();
          controller.aptNo.clear();
          controller.floor.clear();

          controller.block = null;
          controller.blockId = null;

          controller.road = null;
          controller.roadId = null;

          controller.roadsForSelectedBlock = [];

          setState(() {
            _hideBottomButton = true;
            // _formKey = GlobalKey<FormState>(); // 🔥 clears validation errors
          });

          _resetAll();

          SnackbarHelper.ShowSuccess(
            context,
            AppLocalizations.of(context)!.accountCreatedSuccessfully,
          );
          //_resetAll();
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) context.push(RouteNames.accountverfy);
          });
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      SnackbarHelper.showError(
        context,
        "${AppLocalizations.of(context)!.submitFailed}: $e",
      );
    }
  }

  void _onAddressChanged() {
    if (_hideBottomButton) {
      setState(() {
        _hideBottomButton = false;
      });
    }

    widget.onChanged?.call();
  }

  Widget buildType(String type, String icon) {
    final bool isSelected = selected == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = type;

            if (type == "Villa") {
              controller.aptNo.clear();
              controller.floor.clear();
            }
          });
        },
        child: Container(
          height: 58, // ✅ fixed height
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.btn_primery
                : Theme.of(context).colorScheme.surface,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: isSelected ? AppColors.btn_primery : Colors.grey.shade300,
            ),
          ),

          child: Center(
            // ✅ IMPORTANT
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX
              children: [
                Image.asset(
                  icon,
                  height: 23,
                  width: 23,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 8),

                Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1, // ✅ FIX TEXT VERTICAL ALIGN
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,

      child: Column(
        children: [
          // AppTextField(
          //   controller: controller.building,
          //   label: l10n.pickLocation,
          // ),
          SizedBox(height: 10),

          // if (widget.accountType == "Family") ...[
          //   AppTextField(label: l10n.enterNumberOfKids),
          //   SizedBox(height: 10),
          //   Row(
          //     children: [
          //       Expanded(child: AppTextField(label: l10n.noOfBoys)),
          //       SizedBox(width: 10),
          //       Expanded(child: AppTextField(label: l10n.noOfGirls)),
          //     ],
          //   ),
          //   SizedBox(height: 17),
          // ],
          SizedBox(height: 15),
          // Image.asset("assets/images/map.png", height: 84),
          // SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildType(l10n.flat, 'assets/icons/Flat.png'),
              buildType(l10n.villa, 'assets/icons/villa.png'),
              // buildType(l10n.office, 'assets/icons/office.png'),
            ],
          ),
          SizedBox(height: 17),
          AppTextField(
            controller: controller.city,
            label: l10n.enterCity,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _onAddressChanged(),
          ),
          SizedBox(height: 17),
          AppTextField(
            controller: controller.building,
            label: l10n.enterBuilding,
            validator: (value) => controller.validateBuilding(value, l10n),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _onAddressChanged(),
          ),
          SizedBox(height: 17),
          if (selected != l10n.villa) ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller.aptNo,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    label: l10n.enterAptNo,
                    onChanged: (_) => _onAddressChanged(),
                    validator: (value) => controller.validateAptNo(value, l10n),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: controller.floor,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _onAddressChanged(),
                    label: l10n.enterFloorNo,
                    validator: (value) => controller.validateFloor(value, l10n),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),
          ],
          Consumer(
            builder: (context, ref, child) {
              final blockAsync = ref.watch(getBlockProvider);

              return blockAsync.when(
                data: (blocks) {
                  if (controller.block != null &&
                      controller.roadsForSelectedBlock.isEmpty) {
                    final selectedBlock = blocks.firstWhere(
                      (b) => b['name'] == controller.block,
                      orElse: () => {},
                    );

                    if (selectedBlock.isNotEmpty) {
                      controller.roadsForSelectedBlock =
                          List<Map<String, dynamic>>.from(
                            selectedBlock['roads'] ?? [],
                          );
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// BLOCK FIRST
                      AppDropdown(
                        label: l10n.selectBlock,
                        items: blocks.map((b) => b['name'] as String).toList(),
                        value: controller.block,
                        onChanged: (val) {
                          _onAddressChanged();
                          setState(() {
                            final block = blocks.firstWhere(
                              (b) => b['name'] == val,
                            );
                            controller.block = block['name'];
                            controller.blockId = block['_id'];
                            controller.road = null;
                            controller.roadId = null;

                            controller.roadsForSelectedBlock =
                                List<Map<String, dynamic>>.from(block['roads']);
                          });
                        },
                        validator: (val) =>
                            val == null ? l10n.pleaseSelectBlock : null,
                      ),

                      SizedBox(height: 15),

                      /// ROAD SECOND
                      AppDropdown(
                        label: l10n.selectRoad,
                        items: controller.roadsForSelectedBlock
                            .map((r) => r['name'] as String)
                            .toList(),
                        value: controller.road,
                        onChanged: (val) {
                          _onAddressChanged();
                          setState(() {
                            final road = controller.roadsForSelectedBlock
                                .firstWhere((r) => r['name'] == val);

                            controller.road = road['name'];
                            controller.roadId = road['_id'];
                          });
                        },
                        validator: (val) =>
                            val == null ? l10n.pleaseSelectRoad : null,
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("${l10n.failedToLoadBlocks}: $e"),
              );
            },
          ),

          SizedBox(height: 20),
          if (!widget.family)
            // if (!widget.family && showButton)
            // if (!_hideBottomButton)
            AppButton(
              text: widget.accountType == "Family"
                  ? l10n.continueBtn
                  : l10n.signIn,
              isLoading: _isLoading,
              onPressed: () {
                final isValid =
                    widget.formKey.currentState?.validate() ?? false;

                if (!isValid) return;

                familyAccount(context);
              },
              color: AppColors.btn_primery,
              width: double.infinity,
            ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
