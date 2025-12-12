import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        contentPadding ??
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: Colors.blue.shade100, width: 1.w),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: Colors.blue.shade100, width: 1.w),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5.w),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled;
    final mq = MediaQuery.of(context);
    // 폼 전체 컨테이너가 시스템 textScaleFactor의 영향을 받지 않도록 MediaQuery로 감싸기
    return MediaQuery(
      data: mq.copyWith(textScaleFactor: 1.0),
      child: Container(
        height: 50.h,
        // 최소/고정 높
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade100,
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.06),
              blurRadius: 4.r,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // DropdownButtonFormField 내부 레이아웃이 시스템 textScaleFactor에 영향을 받지 않도록 추가 설정
        child: DropdownButtonFormField<String>(
          focusNode: focusNode,
          isExpanded: isExpanded,
          isDense: true,
          itemHeight: math.max(48.h, kMinInteractiveDimension),
          value: items.contains(initialValue)
              ? initialValue
              : (items.isNotEmpty ? items.first : null),
          decoration: _decoration().copyWith(
            fillColor: isDisabled ? Colors.grey.shade100 : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade100,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade300,
                width: 1.5.w,
              ),
            ),
            // 세로 패딩을 줄여서 컨테이너 높이가 시스템 텍스트 스케일에 따라 커지지 않도록 고정
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          dropdownColor: Colors.white,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: MediaQuery(
                    // 드롭다운 오버레이에서도 textScaleFactor 고정
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: Text(
                      e,
                      style:
                          style?.copyWith(color: Colors.black) ??
                          TextStyle(fontSize: 14.sp, color: Colors.black),
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
          style:
              style ??
              TextStyle(
                fontSize: 14.sp,
                color: isDisabled ? Colors.grey : Colors.black,
              ),
          disabledHint: initialValue != null
              ? MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: Text(
                    initialValue!,
                    style: style?.copyWith(color: Colors.grey),
                  ),
                )
              : null,
          icon: icon != null
              ? Icon(icon, size: 20.sp)
              : Icon(Icons.keyboard_arrow_down, size: 20.sp),
        ),
      ),
    );
  }
}
