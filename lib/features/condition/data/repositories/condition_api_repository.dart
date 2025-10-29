import 'package:dio/dio.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';
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
            maxWidth: 100, // 한 줄 최대 길이
          ),
        );

  @override
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
  }) async {
    final queryParameters = {
      if (period != null && period.isNotEmpty) 'period': period,
      'type': 'safe', // 타입 Safe(안전 위탁 운임) 고정
      if (section != null && section.isNotEmpty) 'section': section,
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
          return data.map((item) => FareResult.fromJson(item)).toList();
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
}
