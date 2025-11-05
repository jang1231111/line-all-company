// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_fare.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectedFare _$SelectedFareFromJson(Map<String, dynamic> json) =>
    _SelectedFare(
      row: FareResult.fromJson(json['row'] as Map<String, dynamic>),
      type: $enumDecode(_$FareTypeEnumMap, json['type']),
      rate: (json['rate'] as num).toDouble(),
      price: (json['price'] as num).toInt(),
      surchargeLabels: (json['surchargeLabels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SelectedFareToJson(_SelectedFare instance) =>
    <String, dynamic>{
      'row': instance.row,
      'type': _$FareTypeEnumMap[instance.type]!,
      'rate': instance.rate,
      'price': instance.price,
      'surchargeLabels': instance.surchargeLabels,
    };

const _$FareTypeEnumMap = {FareType.ft20: 'ft20', FareType.ft40: 'ft40'};
