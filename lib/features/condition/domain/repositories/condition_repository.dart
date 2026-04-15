import 'package:line_all/features/condition/domain/models/fare_result.dart';
import 'package:line_all/features/condition/domain/models/regional_surcharge.dart';

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

  /// 인천/평택 지역별 거리 구간 할증 데이터를 가져옵니다.
  /// [region]: 'incheon' 또는 'pyeongtaek'
  Future<List<RegionalSurcharge>> getRegionalSurcharge({
    required String region,
  });
}
