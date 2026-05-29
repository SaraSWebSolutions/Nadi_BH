import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      isExpanded: true,
      isDense: true,

      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.2,
      ),

      icon: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),

      dropdownColor: Theme.of(context).colorScheme.surface,

      decoration: InputDecoration(
        labelText: label,

        helperText: " ",

        errorMaxLines: 3,

        errorStyle: const TextStyle(
          fontSize: 12,
          height: 1.3,
          color: Colors.red,
        ),

        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,

        // ✅ PERFECT ALIGNMENT
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        labelStyle: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),

        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),

      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              e,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),

      onChanged: onChanged,

      validator: validator,
    );
  }
}
