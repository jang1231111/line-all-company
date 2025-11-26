import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final FocusNode? focusNode;
  final String? initialValue;
  final List<String> items;
  final String hint;
  final IconData? icon;
  final ValueChanged<String?>? onChanged;
  final bool isExpanded;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool enabled;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  const DropdownField({
    super.key,
    this.focusNode,
    required this.items,
    required this.hint,
    this.initialValue,
    this.icon,
    this.onChanged,
    this.isExpanded = true,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.style,
    this.hintStyle,
    this.contentPadding,
  });

  InputDecoration _decoration() => InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled;
    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        focusNode: focusNode,
        isExpanded: isExpanded,
        value: items.contains(initialValue) ? initialValue : items.first,
        decoration: _decoration().copyWith(
          fillColor: isDisabled ? Colors.grey.shade100 : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade100,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade300,
              width: 1.5,
            ),
          ),
          contentPadding:
              contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        dropdownColor: Colors.white, // 드롭다운 목록 배경색 명확히 지정
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: style?.copyWith(color: Colors.black) ??
                      TextStyle(
                        fontSize: 14,
                        color: Colors.black, // 목록은 항상 검정색으로!
                      ),
                ),
              ),
            )
            .toList(),
        onChanged: enabled
            ? (v) {
                final selected = items.firstWhere(
                  (opt) => opt == v,
                  orElse: () => items.first,
                );
                onChanged?.call(selected);
              }
            : null,
        validator: validator,
        onSaved: onSaved,
        style: style ??
            TextStyle(
              fontSize: 14,
              color: isDisabled ? Colors.grey : Colors.black,
            ),
        disabledHint: initialValue != null
            ? Text(initialValue!, style: style?.copyWith(color: Colors.grey))
            : null,
        icon: icon != null ? Icon(icon) : const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}
