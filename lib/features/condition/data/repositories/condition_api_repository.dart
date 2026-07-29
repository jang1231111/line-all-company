import 'package:dio/dio.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';
import 'package:line_all/features/condition/domain/models/regional_surcharge.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart'; // kPeriod2026Apr
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';

class ConditionApiRepository implements ConditionRepository {
  static const String baseUrl = 'http://1.234.83.203:3006';
  static const String apiKey = 'MyNameIsKingDyung';

  final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'x-api-key': apiKey},
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
            responseType: ResponseType.json,
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseHeader: false,
            responseBody: true,
            error: true,
            compact: false, // 줄바꿈 포함
            maxWidth: 70, // 한 줄 최대 길이
          ),
        );

  @override
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
  }) async {
    // API에는 항상 순수 기간 값으로 전달
    // 4월 운영지침 내부 구분자('-apr')를 제거
    final apiPeriod = period.replaceAll(kPeriod2026Apr.substring(kPeriod2026Feb.length), '');
    final queryParameters = {
      'period': apiPeriod,
      'type': type,
      'section': section,
      if (sido != null && sido.isNotEmpty) 'sido': sido,
      if (sigungu != null && sigungu.isNotEmpty) 'sigungu': sigungu,
      if (eupmyeondong != null && eupmyeondong.isNotEmpty)
        'eupmyeondong': eupmyeondong,
      if (dong != null && dong.isNotEmpty) 'dong': dong,
      if (destinationSearch != null && destinationSearch.isNotEmpty)
        'destinationSearch': destinationSearch,
      if (unnotice != null) 'unnotice': unnotice.toString(),
      if (mode != null && mode.isNotEmpty) 'mode': mode,
    };
    try {
      final response = await _dio.get(
        '/api/routes',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        // 여기서 타입 캐스팅
        final data = response.data['data'];
        if (data is List) {
          return data
              .map(
                (item) => FareResult.fromApiJson(
                  Map<String, dynamic>.from(item as Map<String, dynamic>),
                  type,
                ),
              )
              .toList();
        } else {
          throw Exception('API 데이터 형식 오류');
        }
      } else {
        throw Exception(
          'API 오류: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Dio 오류: ${e.message}');
    }
  }

  @override
  Future<List<FareResult>> searchByRoadName({
    required String period,
    required String type,
    required String section,
    required String sido,
    required String sigungu,
    String? eupmyeondong,
    String? destinationSearch,
    String? dong,
  }) async {
    // API에는 항상 순수 기간 값으로 전달
    final apiPeriod = period.replaceAll(kPeriod2026Apr.substring(kPeriod2026Feb.length), '');
    final queryParameters = {
      'period': apiPeriod,
      'type': type,
      'section': section,
      'sido': sido,
      'sigungu': sigungu,
      if (eupmyeondong != null) 'eupmyeondong': eupmyeondong,
      if (destinationSearch != null) 'destinationSearch': destinationSearch,
      if (dong != null) 'dong': dong,
    };
    try {
      final response = await _dio.get(
        '/api/routes',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map(
                (item) => FareResult.fromApiJson(
                  Map<String, dynamic>.from(item as Map<String, dynamic>),
                  type,
                ),
              )
              .toList();
        } else {
          throw Exception('API 데이터 형식 오류');
        }
      } else {
        throw Exception(
          'API 오류: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Dio 오류: ${e.message}');
    }
  }

  /// [GET] /api/regional-surcharge
  /// 인천/평택 지역별 거리 구간 할증 데이터를 가져옵니다.
  /// 앱 시작 시 캐싱되어 재사용됩니다.
  @override
  Future<List<RegionalSurcharge>> getRegionalSurcharge({
    required String region,
  }) async {
    try {
      final response = await _dio.get(
        '/api/regional-surcharge',
        queryParameters: {'region': region},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map(
                (item) => RegionalSurcharge.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();
        } else {
          throw Exception('API 데이터 형식 오류');
        }
      } else {
        throw Exception(
          'API 오류: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Dio 오류: ${e.message}');
    }
  }

  /// /api/routes 엔드포인트를 호출하여 mode('sido', 'sigungu', 'eupmyeondong')별 지역 목록을 가져옵니다.
  /// 서버에서 반환한 응답 데이터를 파싱하고 중복을 제거 및 정렬하여 드롭다운 항목으로 제공합니다.
  @override
  Future<List<String>> fetchRegions({
    required String mode,
    required String period,
    required String section,
    String? sido,
    String? sigungu,
  }) async {
    final queryParameters = {
      'mode': mode,
      'period': period,
      'section': section,
      'type': 'safe',
      if (sido != null && sido.isNotEmpty) 'sido': sido,
      if (sigungu != null && sigungu.isNotEmpty) 'sigungu': sigungu,
    };
    try {
      final response = await _dio.get(
        '/api/routes',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          final List<String> list = [];
          for (final item in data) {
            if (item is String) {
              if (item.isNotEmpty) list.add(item);
            } else if (item is Map<String, dynamic>) {
              final val = item[mode] ??
                  item['sido'] ??
                  item['sigungu'] ??
                  item['eupmyeondong'] ??
                  item['name'];
              if (val != null && val.toString().isNotEmpty) {
                list.add(val.toString());
              }
            }
          }
          return list.toSet().toList()..sort();
        }
        return [];
      } else {
        throw Exception(
          'API 오류: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Dio 오류: ${e.message}');
    }
  }
}
