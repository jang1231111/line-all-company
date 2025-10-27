import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/action_buttons.dart';
import 'package:line_all/features/condition/presentation/widgets/header.dart';
import 'package:line_all/features/condition/presentation/widgets/period_dropdown_row.dart';
import 'package:line_all/features/condition/presentation/widgets/region_selectors.dart';
import 'package:line_all/features/condition/presentation/widgets/search_box.dart';
import 'package:line_all/features/condition/presentation/widgets/type_section_row.dart';

import '../../domain/models/condition.dart';
import '../data/region_loader.dart';
import '../viewmodel/condition_viewmodel.dart';

final regionHierarchyProvider = FutureProvider<RegionHierarchy>((ref) async {
  return await loadRegionHierarchy();
});

class ConditionFormWidget extends ConsumerStatefulWidget {
  const ConditionFormWidget({super.key});

  @override
  ConsumerState<ConditionFormWidget> createState() =>
      _ConditionFormWidgetState();
}

class _ConditionFormWidgetState extends ConsumerState<ConditionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _periodController;

  @override
  void initState() {
    super.initState();
    final condition = ref.read(conditionViewModelProvider);
    _periodController = TextEditingController(text: condition.period ?? '');
  }

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    final saving = false;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFFEAF5FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(
                        title: '운임 계산 조건 설정',
                        onReset: () {
                          viewModel.update(const Condition());
                          _periodController.clear();
                        },
                      ),
                      const SizedBox(height: 14),
                      // Period
                      PeriodDropdownRow(),
                      const SizedBox(height: 12),
                      const TypeSectionRow(),
                      const SizedBox(height: 12),
                      SearchBox(
                        initialValue: condition.searchQuery ?? '',
                        onChanged: (v) => viewModel.update(
                          condition.copyWith(searchQuery: v),
                        ),
                        onSearch: () {},
                      ),
                      const SizedBox(height: 12),
                      const RegionSelectors(),
                      const SizedBox(height: 12),
                      ActionButtons(
                        saving: saving,
                        onSave: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            //     await viewModel.save();
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            // const SnackBar(content: Text('저장되었습니다')),
                            //     );
                          }
                        },
                        onReset: () {
                          viewModel.update(const Condition());
                          _periodController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
