import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';

class ConditionApiRepository implements ConditionRepository {
  static const String baseUrl = 'http://1.234.83.203:3006';
  static const String apiKey = 'MyNameIsKingDyung';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'x-api-key': apiKey},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ))
    ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: false, // 줄바꿈 포함
      maxWidth: 120,  // 한 줄 최대 길이
    ));

  @override
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
  }) async {
    final queryParameters = {
      if (period != null && period.isNotEmpty) 'period': period,
      if (section != null && section.isNotEmpty) 'section': section,
      if (sido != null && sido.isNotEmpty) 'sido': sido,
      if (sigungu != null && sigungu.isNotEmpty) 'sigungu': sigungu,
      if (eupmyeondong != null && eupmyeondong.isNotEmpty)
        'eupmyeondong': eupmyeondong,
      if (dong != null && dong.isNotEmpty) 'dong': dong,
      if (destinationSearch != null && destinationSearch.isNotEmpty)
        'destinationSearch': destinationSearch,
      if (type != null && type.isNotEmpty) 'type': type,
      if (unnotice != null) 'unnotice': unnotice.toString(),
      if (mode != null && mode.isNotEmpty) 'mode': mode,
    };

    try {
      final response = await _dio.get(
        '/api/routes',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw Exception('API 오류: ${response.statusCode} ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio 오류: ${e.message}');
    }
  }
}
