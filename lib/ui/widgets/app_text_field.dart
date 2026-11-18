import 'package:flutter/material.dart';

import '../../models/business_models.dart';
import '../../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.muted, size: 19),
        suffixIcon: suffix,
      ),
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.icon,
    this.validator,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final IconData? icon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.muted, size: 19),
      ),
    );
  }
}

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.validator,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (field) => InkWell(
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: field.value ?? value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selected == null) return;
          field.didChange(selected);
          onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_month_outlined),
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            errorText: field.errorText,
          ),
          child: Text(
            formatDateInput(field.value ?? value),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
