import 'package:flutter/material.dart';
import 'package:nadi_user_app/controllers/address_controller.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/views/auth/Address.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

class AddressScreen extends StatefulWidget {
  final bool isFromMemberScreen;
  final bool isEditMode;
  final Map<String, dynamic>? familyHeaderAddress;
  final Map<String, dynamic>? initialAddress;
  final bool isEditprofile;
  const AddressScreen({
    super.key,
    this.isFromMemberScreen = false,
    this.isEditMode = false,
    this.familyHeaderAddress,
    this.initialAddress,
    this.isEditprofile = true,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AddressController _controller = AddressController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          l10n.address,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),

        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: AppCircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Address(
          accountType: 'Family',
          family: true,
          formKey: _formKey,
          isprofile: false,
          isEditprofile: widget.isEditprofile,
          controller: _controller,
          isFromMemberScreen: widget.isFromMemberScreen,
          isEditMode: widget.isEditMode,
          familyHeaderAddress: widget.familyHeaderAddress,
          initialAddress: widget.initialAddress,
          onNext: (address) {
            Navigator.pop(context, address ?? _controller.toMap());
          },
        ),
      ),
    );
  }
}
