import '../models/condition.dart';

abstract class ConditionRepository {
  Future<void> saveCondition(Condition condition);
  Future<Condition?> loadLastCondition();
}
