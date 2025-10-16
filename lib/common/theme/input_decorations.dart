import 'package:flutter/material.dart';

InputDecoration fieldDecoration(
  BuildContext context, {
  required String hint,
  IconData? icon,
}) {
  final theme = Theme.of(context).inputDecorationTheme;
  return const InputDecoration()
      .applyDefaults(theme)
      .copyWith(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: theme.prefixIconColor ?? Colors.blueGrey)
            : null,
      );
}