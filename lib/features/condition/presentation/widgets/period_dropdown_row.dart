import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/data/condition_optilons.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';

class PeriodDropdownRow extends ConsumerWidget {
  const PeriodDropdownRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    return DropdownField(
      initialValue: periodOptions
          .firstWhere(
            (opt) => opt.value == condition.period,
            orElse: () => periodOptions.first,
          )
          .label,
      items: periodOptions.map((opt) => opt.label).toList(),
      hint: '기간',
      icon: Icons.calendar_today,
      onChanged: (v) {
        final selected = periodOptions.firstWhere(
          (opt) => opt.label == v,
          orElse: () => periodOptions.first,
        );
        viewModel.update(condition.copyWith(period: selected.value));
      },
    );
  }
}
