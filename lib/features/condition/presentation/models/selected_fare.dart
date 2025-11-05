import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';

part 'selected_fare.freezed.dart';
part 'selected_fare.g.dart'; // json serialization part 추가

enum FareType { ft20, ft40 }

@freezed
abstract class SelectedFare with _$SelectedFare {
  const factory SelectedFare({
    required FareResult row,
    required FareType type,
    required double rate,
    required int price,
    required List<String> surchargeLabels,
  }) = _SelectedFare;

  factory SelectedFare.fromJson(Map<String, dynamic> json) =>
      _$SelectedFareFromJson(json);
}

// FareType enum에 json serialization 지원
extension FareTypeExtension on FareType {
  String toJson() => toString().split('.').last;
  static FareType fromJson(String value) =>
      FareType.values.firstWhere((e) => e.toString().split('.').last == value);
}
