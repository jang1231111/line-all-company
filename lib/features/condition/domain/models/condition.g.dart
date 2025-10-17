// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Condition _$ConditionFromJson(Map<String, dynamic> json) => _Condition(
  period: json['period'] as String?,
  type: json['type'] as String?,
  section: json['section'] as String?,
  searchQuery: json['searchQuery'] as String?,
  sido: json['sido'] as String?,
  sigungu: json['sigungu'] as String?,
  eupmyeondong: json['eupmyeondong'] as String?,
  beopjeongdong: json['beopjeongdong'] as String?,
  surcharges:
      (json['surcharges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ConditionToJson(_Condition instance) =>
    <String, dynamic>{
      'period': instance.period,
      'type': instance.type,
      'section': instance.section,
      'searchQuery': instance.searchQuery,
      'sido': instance.sido,
      'sigungu': instance.sigungu,
      'eupmyeondong': instance.eupmyeondong,
      'beopjeongdong': instance.beopjeongdong,
      'surcharges': instance.surcharges,
    };
