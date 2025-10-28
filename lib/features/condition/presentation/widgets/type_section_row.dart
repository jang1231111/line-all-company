import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';

class TypeSectionRow extends ConsumerWidget {
  const TypeSectionRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: DropdownField(
            initialValue: condition.type,
            items: typeOptions.map((opt) => opt.label).toList(),
            hint: '유형',
            icon: Icons.category,
            onChanged: (v) {
              final selected = typeOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => typeOptions.first,
              );
              viewModel.update(condition.copyWith(type: selected.value));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownField(
            initialValue: condition.section,
            items: sectionOptions.map((opt) => opt.label).toList(),
            hint: '구간',
            icon: Icons.place,
            onChanged: (v) {
              final selected = sectionOptions.firstWhere(
                (opt) => opt.label == v,
                orElse: () => sectionOptions.first,
              );
              viewModel.update(condition.copyWith(section: selected.value));
            },
          ),
        ),
      ],
    );
  }
}
