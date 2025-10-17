// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'condition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Condition {

 String? get period; String? get type; String? get section; String? get searchQuery; String? get sido; String? get sigungu; String? get eupmyeondong; String? get beopjeongdong; List<String> get surcharges;
/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionCopyWith<Condition> get copyWith => _$ConditionCopyWithImpl<Condition>(this as Condition, _$identity);

  /// Serializes this Condition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Condition&&(identical(other.period, period) || other.period == period)&&(identical(other.type, type) || other.type == type)&&(identical(other.section, section) || other.section == section)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sido, sido) || other.sido == sido)&&(identical(other.sigungu, sigungu) || other.sigungu == sigungu)&&(identical(other.eupmyeondong, eupmyeondong) || other.eupmyeondong == eupmyeondong)&&(identical(other.beopjeongdong, beopjeongdong) || other.beopjeongdong == beopjeongdong)&&const DeepCollectionEquality().equals(other.surcharges, surcharges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,type,section,searchQuery,sido,sigungu,eupmyeondong,beopjeongdong,const DeepCollectionEquality().hash(surcharges));

@override
String toString() {
  return 'Condition(period: $period, type: $type, section: $section, searchQuery: $searchQuery, sido: $sido, sigungu: $sigungu, eupmyeondong: $eupmyeondong, beopjeongdong: $beopjeongdong, surcharges: $surcharges)';
}


}

/// @nodoc
abstract mixin class $ConditionCopyWith<$Res>  {
  factory $ConditionCopyWith(Condition value, $Res Function(Condition) _then) = _$ConditionCopyWithImpl;
@useResult
$Res call({
 String? period, String? type, String? section, String? searchQuery, String? sido, String? sigungu, String? eupmyeondong, String? beopjeongdong, List<String> surcharges
});




}
/// @nodoc
class _$ConditionCopyWithImpl<$Res>
    implements $ConditionCopyWith<$Res> {
  _$ConditionCopyWithImpl(this._self, this._then);

  final Condition _self;
  final $Res Function(Condition) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = freezed,Object? type = freezed,Object? section = freezed,Object? searchQuery = freezed,Object? sido = freezed,Object? sigungu = freezed,Object? eupmyeondong = freezed,Object? beopjeongdong = freezed,Object? surcharges = null,}) {
  return _then(_self.copyWith(
period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sido: freezed == sido ? _self.sido : sido // ignore: cast_nullable_to_non_nullable
as String?,sigungu: freezed == sigungu ? _self.sigungu : sigungu // ignore: cast_nullable_to_non_nullable
as String?,eupmyeondong: freezed == eupmyeondong ? _self.eupmyeondong : eupmyeondong // ignore: cast_nullable_to_non_nullable
as String?,beopjeongdong: freezed == beopjeongdong ? _self.beopjeongdong : beopjeongdong // ignore: cast_nullable_to_non_nullable
as String?,surcharges: null == surcharges ? _self.surcharges : surcharges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Condition].
extension ConditionPatterns on Condition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Condition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Condition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Condition value)  $default,){
final _that = this;
switch (_that) {
case _Condition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Condition value)?  $default,){
final _that = this;
switch (_that) {
case _Condition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? period,  String? type,  String? section,  String? searchQuery,  String? sido,  String? sigungu,  String? eupmyeondong,  String? beopjeongdong,  List<String> surcharges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Condition() when $default != null:
return $default(_that.period,_that.type,_that.section,_that.searchQuery,_that.sido,_that.sigungu,_that.eupmyeondong,_that.beopjeongdong,_that.surcharges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? period,  String? type,  String? section,  String? searchQuery,  String? sido,  String? sigungu,  String? eupmyeondong,  String? beopjeongdong,  List<String> surcharges)  $default,) {final _that = this;
switch (_that) {
case _Condition():
return $default(_that.period,_that.type,_that.section,_that.searchQuery,_that.sido,_that.sigungu,_that.eupmyeondong,_that.beopjeongdong,_that.surcharges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? period,  String? type,  String? section,  String? searchQuery,  String? sido,  String? sigungu,  String? eupmyeondong,  String? beopjeongdong,  List<String> surcharges)?  $default,) {final _that = this;
switch (_that) {
case _Condition() when $default != null:
return $default(_that.period,_that.type,_that.section,_that.searchQuery,_that.sido,_that.sigungu,_that.eupmyeondong,_that.beopjeongdong,_that.surcharges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Condition implements Condition {
  const _Condition({this.period, this.type, this.section, this.searchQuery, this.sido, this.sigungu, this.eupmyeondong, this.beopjeongdong, final  List<String> surcharges = const []}): _surcharges = surcharges;
  factory _Condition.fromJson(Map<String, dynamic> json) => _$ConditionFromJson(json);

@override final  String? period;
@override final  String? type;
@override final  String? section;
@override final  String? searchQuery;
@override final  String? sido;
@override final  String? sigungu;
@override final  String? eupmyeondong;
@override final  String? beopjeongdong;
 final  List<String> _surcharges;
@override@JsonKey() List<String> get surcharges {
  if (_surcharges is EqualUnmodifiableListView) return _surcharges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surcharges);
}


/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionCopyWith<_Condition> get copyWith => __$ConditionCopyWithImpl<_Condition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Condition&&(identical(other.period, period) || other.period == period)&&(identical(other.type, type) || other.type == type)&&(identical(other.section, section) || other.section == section)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sido, sido) || other.sido == sido)&&(identical(other.sigungu, sigungu) || other.sigungu == sigungu)&&(identical(other.eupmyeondong, eupmyeondong) || other.eupmyeondong == eupmyeondong)&&(identical(other.beopjeongdong, beopjeongdong) || other.beopjeongdong == beopjeongdong)&&const DeepCollectionEquality().equals(other._surcharges, _surcharges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,type,section,searchQuery,sido,sigungu,eupmyeondong,beopjeongdong,const DeepCollectionEquality().hash(_surcharges));

@override
String toString() {
  return 'Condition(period: $period, type: $type, section: $section, searchQuery: $searchQuery, sido: $sido, sigungu: $sigungu, eupmyeondong: $eupmyeondong, beopjeongdong: $beopjeongdong, surcharges: $surcharges)';
}


}

/// @nodoc
abstract mixin class _$ConditionCopyWith<$Res> implements $ConditionCopyWith<$Res> {
  factory _$ConditionCopyWith(_Condition value, $Res Function(_Condition) _then) = __$ConditionCopyWithImpl;
@override @useResult
$Res call({
 String? period, String? type, String? section, String? searchQuery, String? sido, String? sigungu, String? eupmyeondong, String? beopjeongdong, List<String> surcharges
});




}
/// @nodoc
class __$ConditionCopyWithImpl<$Res>
    implements _$ConditionCopyWith<$Res> {
  __$ConditionCopyWithImpl(this._self, this._then);

  final _Condition _self;
  final $Res Function(_Condition) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = freezed,Object? type = freezed,Object? section = freezed,Object? searchQuery = freezed,Object? sido = freezed,Object? sigungu = freezed,Object? eupmyeondong = freezed,Object? beopjeongdong = freezed,Object? surcharges = null,}) {
  return _then(_Condition(
period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sido: freezed == sido ? _self.sido : sido // ignore: cast_nullable_to_non_nullable
as String?,sigungu: freezed == sigungu ? _self.sigungu : sigungu // ignore: cast_nullable_to_non_nullable
as String?,eupmyeondong: freezed == eupmyeondong ? _self.eupmyeondong : eupmyeondong // ignore: cast_nullable_to_non_nullable
as String?,beopjeongdong: freezed == beopjeongdong ? _self.beopjeongdong : beopjeongdong // ignore: cast_nullable_to_non_nullable
as String?,surcharges: null == surcharges ? _self._surcharges : surcharges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
