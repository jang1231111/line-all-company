import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';

import '../../data/repositories/condition_api_repository.dart';
import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';

final conditionViewModelProvider =
    StateNotifierProvider<ConditionViewModel, Condition>(
      (ref) => ConditionViewModel(ref.watch(conditionRepositoryProvider), ref),
    );

// 실제 환경에 따라 아래 중 하나를 override 하여 사용
final conditionRepositoryProvider = Provider<ConditionRepository>((ref) {
  return ConditionApiRepository(); // 실제 API 연동
  // return LocalDbConditionRepository(); // 내부DB 저장소(실제 저장)
  // return InMemoryConditionRepository(); // 개발/테스트용 메모리 저장소
});
