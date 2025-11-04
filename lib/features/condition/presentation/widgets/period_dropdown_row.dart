import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';

class PeriodDropdownRow extends ConsumerWidget {
  final FocusNode? periodFocusNode;
  final FocusNode? typeFocusNode;
  final FocusNode? sectionFocusNode;
  final Key? typeKey;
  final Key? sectionKey;
  final bool error;

  const PeriodDropdownRow({
    super.key,
    this.periodFocusNode,
    this.typeFocusNode,
    this.sectionFocusNode,
    this.typeKey,
    this.sectionKey,
    this.error = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: error ? Colors.red : const Color(0xFFB4C8F7),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        children: [
          // 기간 드롭다운
          DropdownField(
            focusNode: periodFocusNode,
            initialValue: periodOptions
                .firstWhere(
                  (opt) => opt.value == condition.period,
                  orElse: () => periodOptions.first,
                )
                .label,
            items: periodOptions.map((opt) => opt.label).toList(),
            hint: '필수 선택',
            icon: null,
            onChanged: (v) {
              final selected = periodOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => periodOptions.first,
              );
              viewModel.update(condition.copyWith(period: selected.value));
            },
          ),
          const SizedBox(height: 10),
          // 유형 드롭다운
          // DropdownField(
          //   key: typeKey,
          //   focusNode: typeFocusNode,
          //   initialValue: typeOptions
          //       .firstWhere(
          //         (opt) => opt.value == condition.type,
          //         orElse: () => typeOptions.first,
          //       )
          //       .label,
          //   items: typeOptions.map((opt) => opt.label).toList(),
          //   hint: '유형 선택',
          //   icon: null,
          //   onChanged: (v) {
          //     final selected = typeOptions.firstWhere(
          //       (opt) => opt.label == v,
          //       orElse: () => typeOptions.first,
          //     );
          //     viewModel.update(condition.copyWith(type: selected.value));
          //   },
          // ),
          // const SizedBox(height: 10),
          // 구간 드롭다운
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
            icon: null,
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
