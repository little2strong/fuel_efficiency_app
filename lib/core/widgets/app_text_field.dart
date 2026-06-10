import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Labeled text field with a consistent header label above the input, matching
/// the form style throughout the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.suffixText,
    this.keyboardType,
    this.validator,
    this.numeric = false,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefix;
  final String? suffixText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool numeric;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : keyboardType,
          inputFormatters: numeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : null,
          validator: validator,
          maxLines: maxLines,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }
}
