import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/widgets/app_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.focusNode,
    this.helperText,
    this.hintText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixTooltip,
    this.onSuffixTap,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
  });

  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? helperText;
  final String? hintText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? suffixTooltip;
  final VoidCallback? onSuffixTap;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    Widget field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorText: (errorText?.isNotEmpty ?? false) ? errorText : null,
        constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.base,
          vertical: spacing.base,
        ),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                icon: Icon(suffixIcon),
                tooltip: suffixTooltip,
                onPressed: enabled ? onSuffixTap : null,
              ),
      ),
    );

    if (label == null) return field;

    field = Semantics(label: label, child: field);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: AppFieldLabel(label!)),
        SizedBox(height: spacing.xs),
        field,
      ],
    );
  }
}
