import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/theme.dart';
import '../../domain/models/condition.dart';
import '../providers/condition_notifier.dart';

const List<String> _surchargeOptions = [
  '탱크 30%',
  '냉동·냉장 30%',
  '덤프 25%',
  '플렉시백 20%',
  '험로 및 오지 20%',
  '일요일 및 공휴일 20%',
  '심야(22:00~06:00) 20%',
];


class ConditionSurchargePanel extends ConsumerWidget {
  const ConditionSurchargePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Card(
        color: const Color(0xFFFFF6E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '할증 적용',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF7A4B00)),
                      onPressed: () => ref.read(conditionProvider.notifier).state = const Condition(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: _surchargeOptions.map((opt) {
                      final checked = condition.surcharges.contains(opt);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(opt, style: const TextStyle(fontSize: 13)),
                          value: checked,
                          onChanged: (v) {
                            final list = List<String>.from(condition.surcharges);
                            if (v == true) {
                              if (!list.contains(opt)) list.add(opt);
                            } else {
                              list.remove(opt);
                            }
                            ref.read(conditionProvider.notifier).state = condition.copyWith(surcharges: list);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: fieldDecoration(context, hint: '위험물 종류', icon: null),
                      items: ['중량물 할증', '특수 화물'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: fieldDecoration(context, hint: '위험물 할증', icon: null),
                      items: ['중량물 할증', '특수 화물'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            Row(
                children: [
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: fieldDecoration(context, hint: '활대품 할증', icon: null),
                      items: ['중량물 할증', '특수 화물'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: fieldDecoration(context, hint: '배차 취소료', icon: null),
                      items: ['중량물 할증', '특수 화물'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}