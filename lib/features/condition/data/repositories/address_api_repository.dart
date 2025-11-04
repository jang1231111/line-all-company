import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../domain/models/road_name_address.dart';

class AddressApiRepository {
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
            compact: false,
            maxWidth: 70,
          ),
        );

  Future<List<RoadNameAddress>> searchJuso(String keyword) async {
    try {
      final response = await _dio.get(
        '/api/juso',
        queryParameters: {
          'keyword': keyword,
          'addInfoYn': 'Y',
          'countPerPage': 100,
        },
      );
      if (response.statusCode == 200) {
        final results = response.data['results'];
        final jusoList = results?['juso'] as List<dynamic>? ?? [];
        return jusoList.map((item) => RoadNameAddress.fromJson(item)).toList();
      } else {
        throw Exception(
          '주소 API 오류: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('주소 API 오류: ${e.message}');
    }
  }
}
