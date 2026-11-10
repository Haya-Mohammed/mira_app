import 'package:flutter/material.dart';

import 'app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      validator: widget.validator,
      suffixIcon: _obscure
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      onSuffixTap: () => setState(() => _obscure = !_obscure),
    );
  }
}
