import 'package:freezed_annotation/freezed_annotation.dart';

part 'fare_result.freezed.dart';
part 'fare_result.g.dart';

@freezed
abstract class FareResult with _$FareResult {
  const factory FareResult({
    required String section,
    required String sido,
    required String sigungu,
    required String eupmyeondong,
    required int distance,
    required int unnotice,
    required int ft20,
    required int ft40,
  }) = _FareResult;

  factory FareResult.fromJson(Map<String, dynamic> json) =>
      _$FareResultFromJson(json);

  factory FareResult.fromApiJson(Map<String, dynamic> json, String type) {
    final normalized = Map<String, dynamic>.from(json);

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String keyFor(int size) {
      final t = type.toLowerCase();
      switch (t) {
        case 'driver':
          return 'ft${size}_driver';
        case 'transport':
          return 'ft${size}_transport';
        default:
          return 'ft${size}_safe';
      }
    }

    normalized['ft20'] = toInt(json[keyFor(20)]);
    normalized['ft40'] = toInt(json[keyFor(40)]);

    return FareResult.fromJson(normalized);
  }
}
