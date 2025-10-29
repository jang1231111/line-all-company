// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FareResult _$FareResultFromJson(Map<String, dynamic> json) => _FareResult(
  section: json['section'] as String,
  sido: json['sido'] as String,
  sigungu: json['sigungu'] as String,
  eupmyeondong: json['eupmyeondong'] as String,
  distance: (json['distance'] as num).toInt(),
  unnotice: (json['unnotice'] as num).toInt(),
  ft20Safe: (json['ft20_safe'] as num).toInt(),
  ft40Safe: (json['ft40_safe'] as num).toInt(),
);

Map<String, dynamic> _$FareResultToJson(_FareResult instance) =>
    <String, dynamic>{
      'section': instance.section,
      'sido': instance.sido,
      'sigungu': instance.sigungu,
      'eupmyeondong': instance.eupmyeondong,
      'distance': instance.distance,
      'unnotice': instance.unnotice,
      'ft20_safe': instance.ft20Safe,
      'ft40_safe': instance.ft40Safe,
    };
