import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class AppDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final DateTime? firstDate;
  final Function(DateTime)? onDateSelected;

  const AppDatePicker({
    super.key,
    required this.controller,
    this.label,
    this.firstDate,
    this.onDateSelected,
  });

  Future<void> _pickDate(BuildContext context) async {
    DateTime today = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: firstDate ?? today,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = DateFormat("dd/MM/yyyy", "en_US").format(pickedDate);

      if (onDateSelected != null) {
        onDateSelected!(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(context),
      decoration: InputDecoration(
        labelText: label ?? l10n.selectDate,
          floatingLabelStyle: const TextStyle(color: AppColors.btn_primery),
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
                                 focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(color:AppColors.btn_primery ,width: 1.5)
        ),
      ),
    );
  }
}
