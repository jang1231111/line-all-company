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

  /// 선택한 조건(기간, 구간, 상위 지역)에 맞게 시도/시군구/읍면동 동적 목록을 조회합니다.
  /// 정적 에셋 파일 대신 API 서버(`/api/routes`)를 통해 항상 최신 지역 정보를 제공하기 위함입니다.
  /// [mode]: 'sido' | 'sigungu' | 'eupmyeondong'
  Future<List<String>> fetchRegions({
    required String mode,
    required String period,
    required String section,
    String? sido,
    String? sigungu,
  });
}
