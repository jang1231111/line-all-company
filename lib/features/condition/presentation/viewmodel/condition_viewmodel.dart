
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';
import '../providers/condition_notifier.dart';


class ConditionViewModel extends StateNotifier<Condition> {
  final ConditionRepository repository;
  ConditionViewModel(this.repository) : super(const Condition());

  void update(Condition condition) {
    state = condition;
  }

  Future<void> save() async {
    await repository.saveCondition(state);
  }
}

final conditionViewModelProvider = StateNotifierProvider<ConditionViewModel, Condition>((ref) {
  final repo = ref.watch(conditionRepositoryProvider);
  return ConditionViewModel(repo);
});
