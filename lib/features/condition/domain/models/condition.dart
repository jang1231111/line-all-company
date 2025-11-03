import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:line_all/features/condition/presentation/data/surcharge_calculator.dart';
part 'condition.freezed.dart';

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
    String? mode,
    @Default([]) List<String> surcharges, // 체크박스 id 리스트
    String? dangerType, // 위험물 드롭다운 value
    String? weightType, // 중량물 드롭다운 value
    String? specialType, // 활대품 드롭다운 value
    String? cancellationFee, // 취소료 드롭다운 value
    @Default(SurchargeResult()) SurchargeResult surchargeResult, // 기본값 적용
  }) = _Condition;
}
