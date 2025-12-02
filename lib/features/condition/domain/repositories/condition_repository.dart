import 'package:line_all/features/condition/domain/models/fare_result.dart';

abstract class ConditionRepository {
  Future<List<FareResult>> searchByRegion({
    required String period,
    required String type,
    required String section,
    String? sido,
    String? sigungu,
    String? eupmyeondong,
    String? dong,
    String? destinationSearch,
    int? unnotice,
    String? mode,
  });

  Future<List<FareResult>> searchByRoadName({
    required String period,
    required String type,
    required String section,
    required String sido,
    required String sigungu,
    String? eupmyeondong,
    String? destinationSearch,
    String? dong,
  });
}
