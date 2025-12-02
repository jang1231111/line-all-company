import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';

class PeriodDropdownRow extends ConsumerWidget {
  final Key? periodKey;
  final Key? typeKey;
  final Key? sectionKey;
  final FocusNode? periodFocusNode;
  final FocusNode? typeFocusNode;
  final FocusNode? sectionFocusNode;

  const PeriodDropdownRow({
    super.key,
    this.periodKey,
    this.typeKey,
    this.sectionKey,
    this.periodFocusNode,
    this.typeFocusNode,
    this.sectionFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF), // 연한 배경으로 가독성 향상
        border: Border.all(color: const Color(0xFFD6E1FF), width: 1.w),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
      child: Column(
        children: [
          // 기간 드롭다운
          DropdownField(
            key: periodKey,
            focusNode: periodFocusNode,
            initialValue: periodOptions
                .firstWhere(
                  (opt) => opt.value == condition.period,
                  orElse: () => periodOptions.first,
                )
                .label,
            items: periodOptions.map((opt) => opt.label).toList(),
            hint: '필수 선택',
            icon: Icons.expand_more,
            style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
            ),
            onChanged: (v) {
              final selected = periodOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => periodOptions.first,
              );
              viewModel.update(condition.copyWith(period: selected.value));
            },
          ),
          SizedBox(height: 8.h),
          // 유형 드롭다운
          DropdownField(
            key: typeKey,
            focusNode: typeFocusNode,
            initialValue: typeOptions
                .firstWhere(
                  (opt) => opt.value == condition.type,
                  orElse: () => typeOptions.first,
                )
                .label,
            items: typeOptions.map((opt) => opt.label).toList(),
            hint: '유형 선택',
            icon: Icons.expand_more,
            style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
            ),
            onChanged: (v) {
              final selected = typeOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => typeOptions.first,
              );
              viewModel.update(condition.copyWith(type: selected.value));
            },
          ),
          SizedBox(height: 8.h),
          // 구간 상세 드롭다운
          DropdownField(
            key: sectionKey,
            focusNode: sectionFocusNode,
            initialValue: sectionOptions
                .firstWhere(
                  (opt) => opt.value == condition.section,
                  orElse: () => sectionOptions.first,
                )
                .label,
            items: sectionOptions.map((opt) => opt.label).toList(),
            hint: '구간 선택',
            icon: Icons.expand_more,
            style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
            ),
            onChanged: (v) {
              final selected = sectionOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => sectionOptions.first,
              );
              viewModel.update(condition.copyWith(section: selected.value));
            },
          ),
        ],
      ),
    );
  }
}
