import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';
import '../../data/repositories/local_db_condition_repository.dart';

/// Simple provider for the Condition object. UI can read/write with .state.
final conditionProvider = StateProvider<Condition>((ref) => Condition());

/// Saving flag while persisting state.
final conditionSavingProvider = StateProvider<bool>((ref) => false);

/// 실제 환경에 따라 아래 중 하나를 override 하여 사용
final conditionRepositoryProvider = Provider<ConditionRepository>((ref) {
  // return ConditionApiRepository(); // 실제 API 연동
  return LocalDbConditionRepository(); // 내부DB 저장소(실제 저장)
  // return InMemoryConditionRepository(); // 개발/테스트용 메모리 저장소
});

/// Helper to save current condition using the repository.
final conditionSaveProvider = FutureProvider.family<void, void>((ref, _) async {
  final repo = ref.read(conditionRepositoryProvider);
  final condition = ref.read(conditionProvider); // 현재 상태 읽기
  ref.read(conditionSavingProvider.notifier).state = true; // 저장 중 플래그 설정
  try {
    await repo.saveCondition(condition);
  } finally {
    ref.read(conditionSavingProvider.notifier).state = false;
  }
});
