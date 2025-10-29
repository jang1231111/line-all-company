import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';
import '../data/surcharge_calculator.dart';
import '../providers/fare_result_provider.dart'; // 추가

class ConditionViewModel extends StateNotifier<Condition> {
  ConditionViewModel(this._repository, this._ref) : super(const Condition());

  final ConditionRepository _repository;
  final Ref _ref;
  void update(Condition condition) {
    state = condition;
  }

  Future<void> search() async {
    final results = await _repository.search(
      period: state.period,
      section: state.section,
      sido: state.sido,
      sigungu: state.sigungu,
      eupmyeondong: state.eupmyeondong,
      type: state.type,
    );
    // 결과를 FareResultViewModel에 저장
    _ref.read(fareResultViewModelProvider.notifier).setResults(results);
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
