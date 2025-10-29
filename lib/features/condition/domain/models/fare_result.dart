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
    @JsonKey(name: 'ft20_safe') required int ft20Safe,
    @JsonKey(name: 'ft40_safe') required int ft40Safe,
  }) = _FareResult;

  factory FareResult.fromJson(Map<String, dynamic> json) =>
      _$FareResultFromJson(json);
}
