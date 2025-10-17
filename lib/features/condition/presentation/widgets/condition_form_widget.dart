import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/theme.dart';
import '../../../../common/widgets/dropdown_field.dart';
import '../../domain/models/condition.dart';
import '../viewmodel/condition_viewmodel.dart';

class ConditionFormWidget extends ConsumerStatefulWidget {
  const ConditionFormWidget({super.key});

  @override
  ConsumerState<ConditionFormWidget> createState() => _ConditionFormWidgetState();
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
                      _Header(
                        title: '운임 계산 조건 설정',
                        onReset: () {
                          viewModel.update(const Condition());
                          _periodController.clear();
                        },
                      ),
                      const SizedBox(height: 14),
                      // Period
                      TextFormField(
                        controller: _periodController,
                        decoration: fieldDecoration(
                          context,
                          hint: '기간',
                          icon: Icons.calendar_today,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return '기간을 입력하세요';
                          }
                          if (v.length < 2) {
                            return '기간이 너무 짧습니다';
                          }
                          return null;
                        },
                        onChanged: (v) => viewModel.update(condition.copyWith(period: v)),
                      ),
                      const SizedBox(height: 12),
                      const _TypeSectionRow(),
                      const SizedBox(height: 12),
                      _SearchBox(
                        initialValue: condition.searchQuery ?? '',
                        onChanged: (v) => viewModel.update(condition.copyWith(searchQuery: v)),
                        onSearch: () {},
                      ),
                      const SizedBox(height: 12),
                      const _RegionSelectors(),
                      const SizedBox(height: 12),
                      _ActionButtons(
                        saving: saving,
                        onSave: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await viewModel.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('저장되었습니다')),
                            );
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

// add private widgets near bottom of file:
class _SearchBox extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  const _SearchBox({
    required this.initialValue,
    required this.onChanged,
    required this.onSearch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
        color: const Color(0xFFDFF0FF),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF154E9C)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              decoration: const InputDecoration(
                hintText: '예: 강남구, 역삼동, 역삼1동, ...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.black54),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: onSearch,
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool saving;
  final Future<void> Function() onSave;
  final VoidCallback onReset;
  const _ActionButtons({
    required this.saving,
    required this.onSave,
    required this.onReset,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontSize: 14),
          ),
          onPressed: saving ? null : () => onSave(),
          icon: const Icon(Icons.save),
          label: Text(saving ? '저장 중...' : '저장'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF154E9C),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontSize: 14),
          ),
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('초기화'),
        ),
      ],
    );
  }
}

// new extracted header widget
class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onReset;
  const _Header({required this.title, required this.onReset, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF154E9C),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.refresh,
              size: 18,
              color: Color(0xFF154E9C),
            ),
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}

// extracted type & section row
class _TypeSectionRow extends ConsumerWidget {
  const _TypeSectionRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: DropdownField(
            value: condition.type,
            items: ['안전운송운임', '안전위탁운임', '기타'],
            hint: '유형',
            icon: Icons.category,
            onChanged: (v) => viewModel.update(condition.copyWith(type: v)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownField(
            value: condition.section,
            items: ['인천항기점(왕복)', '서울-부산', '기타'],
            hint: '구간',
            icon: Icons.place,
            onChanged: (v) => viewModel.update(condition.copyWith(section: v)),
          ),
        ),
      ],
    );
  }
}

// extracted region selector rows
class _RegionSelectors extends ConsumerWidget {
  const _RegionSelectors({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownField(
                value: condition.sido,
                items: ['전체', '서울특별시', '인천광역시', '부산광역시'],
                hint: '시도',
                icon: Icons.map,
                onChanged: (v) => viewModel.update(condition.copyWith(sido: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownField(
                value: condition.sigungu,
                items: ['전체', '강남구', '서구', '남구'],
                hint: '시군구',
                icon: Icons.location_city,
                onChanged: (v) => viewModel.update(condition.copyWith(sigungu: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownField(
                value: condition.eupmyeondong,
                items: ['전체', '역삼동', '연수동'],
                hint: '읍면동',
                icon: Icons.home_work,
                onChanged: (v) => viewModel.update(condition.copyWith(eupmyeondong: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownField(
                value: condition.beopjeongdong,
                items: ['전체', '역삼1동', '역삼2동'],
                hint: '법정동',
                icon: Icons.account_balance,
                onChanged: (v) => viewModel.update(condition.copyWith(beopjeongdong: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
