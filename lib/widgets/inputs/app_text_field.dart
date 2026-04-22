import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool readonly;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool filled;
  final Color? fillColor;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.prefixText,
    this.validator,
    this.readonly = false,
    this.enabled = true,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.inputFormatters,
    this.filled = false,
    this.fillColor,
        this.focusNode, // ✅ add here
          this.textStyle, // 👈 ADD THIS


  });
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}
class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
   return TextFormField(
  readOnly: widget.readonly,
  enabled: widget.enabled,
  controller: widget.controller,
  obscureText: widget.isPassword ? _obscure : false,
  keyboardType: widget.keyboardType,
  validator: widget.validator,
  minLines: widget.minLines,
  maxLines: widget.maxLines ?? 1,
  maxLength: widget.maxLength,
  maxLengthEnforcement: MaxLengthEnforcement.enforced,
  inputFormatters: widget.inputFormatters,
  focusNode: widget.focusNode,

  style: widget.textStyle ??
      TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
      ),

  buildCounter: widget.maxLength != null
      ? (_, {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink()
      : null,

  decoration: InputDecoration(
    labelText: widget.label,
    prefixText: widget.prefixText,

    labelStyle: TextStyle(
      fontSize: 15,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w400,
    ),

    floatingLabelStyle: TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    ),

    filled: true,

    fillColor: !widget.enabled
        ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4)
        : (widget.filled
            ? (widget.fillColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest)
            : Theme.of(context).colorScheme.surface),

    prefixIcon: widget.prefixIcon != null
        ? Icon(
            widget.prefixIcon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          )
        : null,

    suffixIcon: widget.isPassword
        ? IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
            onPressed: () {
              setState(() => _obscure = !_obscure);
            },
          )
        : null,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),

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
  ),
);
  }
}
