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
      initialValue: value,
      decoration: InputDecoration(
  labelText: label,

  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

  // ✅ Dynamic label color
  labelStyle: TextStyle(
    fontSize: 14,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),

  floatingLabelStyle: TextStyle(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w600,
  ),

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
      width: 1.2,
    ),
  ),

  // ✅ VERY IMPORTANT (fix background issue)
  filled: true,
  fillColor: Theme.of(context).colorScheme.surface,
),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface, // ✅ FIX
    )),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
