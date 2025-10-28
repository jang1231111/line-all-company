import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';
import '../providers/condition_provider.dart';
import '../data/surcharge_calculator.dart';

class ConditionViewModel extends StateNotifier<Condition> {
  final ConditionRepository repository;
  ConditionViewModel(this.repository) : super(const Condition());

  void update(Condition condition) {
    state = condition;
  }

  Future<void> search() async {
    await repository.search();
  }

  /// 할증 관련 값이 바뀔 때 호출
  void updateSurcharge() {
    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: state.surcharges,
      dangerType: state.dangerType,
      weightType: state.weightType,
      specialType: state.specialType,
      cancellationFee: state.cancellationFee,
    );
    state = state.copyWith(surchargeResult: surchargeResult);
  }
}

final conditionViewModelProvider =
    StateNotifierProvider<ConditionViewModel, Condition>((ref) {
      final repo = ref.watch(conditionRepositoryProvider);
      return ConditionViewModel(repo);
    });
