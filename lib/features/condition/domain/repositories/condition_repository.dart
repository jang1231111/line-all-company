import 'package:line_all/features/condition/domain/models/fare_result.dart';

abstract class ConditionRepository {
  Future<List<FareResult>> search({
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
}
