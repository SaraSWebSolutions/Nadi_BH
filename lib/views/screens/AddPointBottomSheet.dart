import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/services/points_request.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

enum RecipientType { admin, friend }

class AddPointBottomSheetContent extends StatefulWidget {
  final String accountType;
  const AddPointBottomSheetContent({super.key, required this.accountType});

  @override
  State<AddPointBottomSheetContent> createState() =>
      _AddPointBottomSheetContentState();
}

class _AddPointBottomSheetContentState
    extends State<AddPointBottomSheetContent> {
  RecipientType _selectedType = RecipientType.admin;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final PointsRequest _pointsRequest = PointsRequest();

  // Family member state
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isFetchingMembers = false;
  Map<String, dynamic>? _selectedMember;

  @override
  void dispose() {
    _pointsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    if (_familyMembers.isNotEmpty) return;
    setState(() => _isFetchingMembers = true);
    try {
      final members = await _pointsRequest.fetchFamilyMembers();
      setState(() {
        _familyMembers = members;
        _isFetchingMembers = false;
      });
    } catch (e) {
      setState(() => _isFetchingMembers = false);
      if (mounted) SnackbarHelper.showError(context, e.toString());
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final points = _pointsController.text.trim();
    final reason = _notesController.text.trim();

    if (_selectedType == RecipientType.admin) {
      setState(() => isLoading = true);
      try {
        await _pointsRequest.sendtoadmin(points: points);
        if (!mounted) return;
        setState(() => isLoading = false);
        SnackbarHelper.ShowSuccess(
          context,
          AppLocalizations.of(context)!.pointsRequestSuccess,
        );
        Navigator.pop(context);
      } catch (e) {
        AppLogger.error("API ERROR: $e");
        if (!mounted) return;
        setState(() => isLoading = false);
        SnackbarHelper.showError(context, e.toString());
      }
    } else {
      final mobile =
          _selectedMember?['basicInfo']?['mobileNumber']?.toString() ?? "";
      setState(() => isLoading = true);
      try {
        await _pointsRequest.sendtofriend(
          mobileNumber: mobile,
          points: points,
          reason: reason,
        );
        if (!mounted) return;
        setState(() => isLoading = false);
        SnackbarHelper.ShowSuccess(
          context,
          AppLocalizations.of(context)!.pointsRequestSuccess,
        );
        Navigator.pop(context);
      } catch (e) {
        AppLogger.error("API ERROR: $e");
        if (!mounted) return;
        setState(() => isLoading = false);
        SnackbarHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.75,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              /// Drag handle
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Title
              Text(
                t.requestToPoints,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              /// RADIO BUTTON ROW
              Row(
                children: [
                  Expanded(
                    child: ListTileTheme(
                      horizontalTitleGap: 0,
                      dense: true,
                      child: RadioListTile<RecipientType>(
                        contentPadding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        title: Text(
                          t.admin,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        value: RecipientType.admin,
                        activeColor: AppColors.app_background_clr,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            _selectedMember = null;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTileTheme(
                      horizontalTitleGap: 0,
                      dense: true,
                      child: RadioListTile<RecipientType>(
                        contentPadding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        title: Text(
                          t.family,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        value: RecipientType.friend,
                        activeColor: AppColors.app_background_clr,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                          _loadFamilyMembers();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    /// Family member selector (only when Friend is selected)
                    if (_selectedType == RecipientType.friend) ...[
                      if (_isFetchingMembers)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedMember,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: t.selectFamilyMember,
                            floatingLabelStyle: const TextStyle(
                                color: AppColors.app_background_clr),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.app_background_clr),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.red),
                            ),
                          ),
                          hint: _familyMembers.isEmpty
                              ? Text(t.noFamilyMembersFound)
                              : Text(t.chooseMember),
                          items: _familyMembers.map((member) {
                            final name =
                                member['basicInfo']?['fullName'] ?? "Unknown";
                            final relation = member['relation'] ?? "";
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: member,
                              child: Text(
                                relation.isNotEmpty
                                    ? "$name ($relation)"
                                    : name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _familyMembers.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _selectedMember = value);
                                },
                          validator: (_) {
                            if (_familyMembers.isEmpty) return null;
                            if (_selectedMember == null) {
                              return t.pleaseSelectFamilyMember;
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 15),
                    ],

                    /// Points
                    reuseTextField(
                      controller: _pointsController,
                      hintText: t.enterPoints,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.pointsRequired;
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return t.enterValidPoints;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t.positiveIntegerHint,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 25),

                    /// Notes
                    Text(
                      t.notesOptional,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    reuseTextField(
                      hintText: t.notesHint,
                      controller: _notesController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: t.cancel,
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      color: Colors.grey.shade400,
                      width: 150,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: t.submit,
                      isLoading: isLoading,
                      onPressed: _handleSubmit,
                      color: const Color.fromRGBO(213, 155, 8, 1),
                      height: 48,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget reuseTextField({
    TextEditingController? controller,
    required String hintText,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: hintText,
        prefixText: prefix,
        floatingLabelStyle: const TextStyle(color: AppColors.app_background_clr),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade200 : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.app_background_clr),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
