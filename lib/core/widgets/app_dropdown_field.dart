import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/theme/sizes.dart';
import 'package:booking_app/core/widgets/app_field_label.dart';
import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.errorText,
    this.validator,
    this.enabled = true,
    this.hintText,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final spacing = context.spacing;
    final hintStyle = context.theme.inputDecorationTheme.hintStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: AppFieldLabel(label)),
        SizedBox(height: spacing.xs),
        Semantics(
          label: label,
          child: DropdownButtonFormField<T>(
            key: ValueKey(value),
            initialValue: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconEnabledColor: c.textSecondary,
            iconDisabledColor: c.disabledText,
            style: context.textTheme.bodyLarge,
            validator: validator,
            decoration: InputDecoration(
              errorText: (errorText?.isNotEmpty ?? false) ? errorText : null,
              constraints: const BoxConstraints(
                minHeight: AppSizes.touchTargetMin,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
            ),
            hint: hintText == null ? null : Text(hintText!, style: hintStyle),
            disabledHint: value == null
                ? null
                : Text(
                    itemLabel(value as T),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: c.disabledText,
                    ),
                  ),
            items: [
              for (final item in items)
                DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
