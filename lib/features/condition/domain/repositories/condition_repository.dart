import '../models/condition.dart';

abstract class ConditionRepository {
    Future<List<dynamic>> search({
    String? period,
    String? section,
    String? sido,
    String? sigungu,
    String? eupmyeondong,
    String? dong,
    String? destinationSearch,
    String? type,
    int? unnotice,
    String? mode,
  });
  // Future<void> saveCondition(Condition condition);
  // Future<Condition?> loadLastCondition();
}
