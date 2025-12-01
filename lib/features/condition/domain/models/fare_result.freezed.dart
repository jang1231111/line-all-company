// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fare_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FareResult {

 String get section; String get sido; String get sigungu; String get eupmyeondong; int get distance; int get unnotice; int get ft20; int get ft40;
/// Create a copy of FareResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareResultCopyWith<FareResult> get copyWith => _$FareResultCopyWithImpl<FareResult>(this as FareResult, _$identity);

  /// Serializes this FareResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FareResult&&(identical(other.section, section) || other.section == section)&&(identical(other.sido, sido) || other.sido == sido)&&(identical(other.sigungu, sigungu) || other.sigungu == sigungu)&&(identical(other.eupmyeondong, eupmyeondong) || other.eupmyeondong == eupmyeondong)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.unnotice, unnotice) || other.unnotice == unnotice)&&(identical(other.ft20, ft20) || other.ft20 == ft20)&&(identical(other.ft40, ft40) || other.ft40 == ft40));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,section,sido,sigungu,eupmyeondong,distance,unnotice,ft20,ft40);

@override
String toString() {
  return 'FareResult(section: $section, sido: $sido, sigungu: $sigungu, eupmyeondong: $eupmyeondong, distance: $distance, unnotice: $unnotice, ft20: $ft20, ft40: $ft40)';
}


}

/// @nodoc
abstract mixin class $FareResultCopyWith<$Res>  {
  factory $FareResultCopyWith(FareResult value, $Res Function(FareResult) _then) = _$FareResultCopyWithImpl;
@useResult
$Res call({
 String section, String sido, String sigungu, String eupmyeondong, int distance, int unnotice, int ft20, int ft40
});




}
/// @nodoc
class _$FareResultCopyWithImpl<$Res>
    implements $FareResultCopyWith<$Res> {
  _$FareResultCopyWithImpl(this._self, this._then);

  final FareResult _self;
  final $Res Function(FareResult) _then;

/// Create a copy of FareResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? section = null,Object? sido = null,Object? sigungu = null,Object? eupmyeondong = null,Object? distance = null,Object? unnotice = null,Object? ft20 = null,Object? ft40 = null,}) {
  return _then(_self.copyWith(
section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,sido: null == sido ? _self.sido : sido // ignore: cast_nullable_to_non_nullable
as String,sigungu: null == sigungu ? _self.sigungu : sigungu // ignore: cast_nullable_to_non_nullable
as String,eupmyeondong: null == eupmyeondong ? _self.eupmyeondong : eupmyeondong // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as int,unnotice: null == unnotice ? _self.unnotice : unnotice // ignore: cast_nullable_to_non_nullable
as int,ft20: null == ft20 ? _self.ft20 : ft20 // ignore: cast_nullable_to_non_nullable
as int,ft40: null == ft40 ? _self.ft40 : ft40 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FareResult].
extension FareResultPatterns on FareResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FareResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FareResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FareResult value)  $default,){
final _that = this;
switch (_that) {
case _FareResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FareResult value)?  $default,){
final _that = this;
switch (_that) {
case _FareResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String section,  String sido,  String sigungu,  String eupmyeondong,  int distance,  int unnotice,  int ft20,  int ft40)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FareResult() when $default != null:
return $default(_that.section,_that.sido,_that.sigungu,_that.eupmyeondong,_that.distance,_that.unnotice,_that.ft20,_that.ft40);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String section,  String sido,  String sigungu,  String eupmyeondong,  int distance,  int unnotice,  int ft20,  int ft40)  $default,) {final _that = this;
switch (_that) {
case _FareResult():
return $default(_that.section,_that.sido,_that.sigungu,_that.eupmyeondong,_that.distance,_that.unnotice,_that.ft20,_that.ft40);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String section,  String sido,  String sigungu,  String eupmyeondong,  int distance,  int unnotice,  int ft20,  int ft40)?  $default,) {final _that = this;
switch (_that) {
case _FareResult() when $default != null:
return $default(_that.section,_that.sido,_that.sigungu,_that.eupmyeondong,_that.distance,_that.unnotice,_that.ft20,_that.ft40);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FareResult implements FareResult {
  const _FareResult({required this.section, required this.sido, required this.sigungu, required this.eupmyeondong, required this.distance, required this.unnotice, required this.ft20, required this.ft40});
  factory _FareResult.fromJson(Map<String, dynamic> json) => _$FareResultFromJson(json);

@override final  String section;
@override final  String sido;
@override final  String sigungu;
@override final  String eupmyeondong;
@override final  int distance;
@override final  int unnotice;
@override final  int ft20;
@override final  int ft40;

/// Create a copy of FareResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareResultCopyWith<_FareResult> get copyWith => __$FareResultCopyWithImpl<_FareResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FareResult&&(identical(other.section, section) || other.section == section)&&(identical(other.sido, sido) || other.sido == sido)&&(identical(other.sigungu, sigungu) || other.sigungu == sigungu)&&(identical(other.eupmyeondong, eupmyeondong) || other.eupmyeondong == eupmyeondong)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.unnotice, unnotice) || other.unnotice == unnotice)&&(identical(other.ft20, ft20) || other.ft20 == ft20)&&(identical(other.ft40, ft40) || other.ft40 == ft40));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,section,sido,sigungu,eupmyeondong,distance,unnotice,ft20,ft40);

@override
String toString() {
  return 'FareResult(section: $section, sido: $sido, sigungu: $sigungu, eupmyeondong: $eupmyeondong, distance: $distance, unnotice: $unnotice, ft20: $ft20, ft40: $ft40)';
}


}

/// @nodoc
abstract mixin class _$FareResultCopyWith<$Res> implements $FareResultCopyWith<$Res> {
  factory _$FareResultCopyWith(_FareResult value, $Res Function(_FareResult) _then) = __$FareResultCopyWithImpl;
@override @useResult
$Res call({
 String section, String sido, String sigungu, String eupmyeondong, int distance, int unnotice, int ft20, int ft40
});




}
/// @nodoc
class __$FareResultCopyWithImpl<$Res>
    implements _$FareResultCopyWith<$Res> {
  __$FareResultCopyWithImpl(this._self, this._then);

  final _FareResult _self;
  final $Res Function(_FareResult) _then;

/// Create a copy of FareResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? section = null,Object? sido = null,Object? sigungu = null,Object? eupmyeondong = null,Object? distance = null,Object? unnotice = null,Object? ft20 = null,Object? ft40 = null,}) {
  return _then(_FareResult(
section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,sido: null == sido ? _self.sido : sido // ignore: cast_nullable_to_non_nullable
as String,sigungu: null == sigungu ? _self.sigungu : sigungu // ignore: cast_nullable_to_non_nullable
as String,eupmyeondong: null == eupmyeondong ? _self.eupmyeondong : eupmyeondong // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as int,unnotice: null == unnotice ? _self.unnotice : unnotice // ignore: cast_nullable_to_non_nullable
as int,ft20: null == ft20 ? _self.ft20 : ft20 // ignore: cast_nullable_to_non_nullable
as int,ft40: null == ft40 ? _self.ft40 : ft40 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
