import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';

class ConditionApiRepository implements ConditionRepository {
  @override
  Future<void> saveCondition(Condition condition) async {
    // TODO: 실제 API 연동 구현 (예시)
    await Future.delayed(const Duration(milliseconds: 300));
    // throw UnimplementedError();
  }

  @override
  Future<Condition?> loadLastCondition() async {
    // TODO: 실제 API 연동 구현 (예시)
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }
}
