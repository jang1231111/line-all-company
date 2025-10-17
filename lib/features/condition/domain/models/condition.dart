import 'package:freezed_annotation/freezed_annotation.dart';
part 'condition.freezed.dart';
part 'condition.g.dart';

@freezed
abstract class Condition with _$Condition {
  const factory Condition({
    String? period,
    String? type,
    String? section,
    String? searchQuery,
    String? sido,
    String? sigungu,
    String? eupmyeondong,
    String? beopjeongdong,
    @Default([]) List<String> surcharges,
  }) = _Condition;

  factory Condition.fromJson(Map<String, dynamic> json) => _$ConditionFromJson(json);
}
