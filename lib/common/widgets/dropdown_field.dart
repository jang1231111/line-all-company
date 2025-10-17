import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final IconData? icon;
  final ValueChanged<String?>? onChanged;
  final bool isExpanded;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool enabled;
  final TextStyle? style;

  const DropdownField({
    super.key,
    required this.items,
    required this.hint,
    this.value,
    this.icon,
    this.onChanged,
    this.isExpanded = true,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.style,
  });

  InputDecoration _decoration() => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.blueGrey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: isExpanded,
      value: value,
      decoration: _decoration(),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: style))).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      onSaved: onSaved,
      style: style,
      disabledHint: value != null ? Text(value!, style: style?.copyWith(color: Colors.grey)) : null,
    );
  }
}