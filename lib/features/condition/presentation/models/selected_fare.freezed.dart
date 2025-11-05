// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_fare.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectedFare {

 FareResult get row; FareType get type; double get rate; int get price; List<String> get surchargeLabels;
/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectedFareCopyWith<SelectedFare> get copyWith => _$SelectedFareCopyWithImpl<SelectedFare>(this as SelectedFare, _$identity);

  /// Serializes this SelectedFare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectedFare&&(identical(other.row, row) || other.row == row)&&(identical(other.type, type) || other.type == type)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.surchargeLabels, surchargeLabels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,row,type,rate,price,const DeepCollectionEquality().hash(surchargeLabels));

@override
String toString() {
  return 'SelectedFare(row: $row, type: $type, rate: $rate, price: $price, surchargeLabels: $surchargeLabels)';
}


}

/// @nodoc
abstract mixin class $SelectedFareCopyWith<$Res>  {
  factory $SelectedFareCopyWith(SelectedFare value, $Res Function(SelectedFare) _then) = _$SelectedFareCopyWithImpl;
@useResult
$Res call({
 FareResult row, FareType type, double rate, int price, List<String> surchargeLabels
});


$FareResultCopyWith<$Res> get row;

}
/// @nodoc
class _$SelectedFareCopyWithImpl<$Res>
    implements $SelectedFareCopyWith<$Res> {
  _$SelectedFareCopyWithImpl(this._self, this._then);

  final SelectedFare _self;
  final $Res Function(SelectedFare) _then;

/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? row = null,Object? type = null,Object? rate = null,Object? price = null,Object? surchargeLabels = null,}) {
  return _then(_self.copyWith(
row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as FareResult,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FareType,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,surchargeLabels: null == surchargeLabels ? _self.surchargeLabels : surchargeLabels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FareResultCopyWith<$Res> get row {
  
  return $FareResultCopyWith<$Res>(_self.row, (value) {
    return _then(_self.copyWith(row: value));
  });
}
}


/// Adds pattern-matching-related methods to [SelectedFare].
extension SelectedFarePatterns on SelectedFare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectedFare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectedFare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectedFare value)  $default,){
final _that = this;
switch (_that) {
case _SelectedFare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectedFare value)?  $default,){
final _that = this;
switch (_that) {
case _SelectedFare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FareResult row,  FareType type,  double rate,  int price,  List<String> surchargeLabels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectedFare() when $default != null:
return $default(_that.row,_that.type,_that.rate,_that.price,_that.surchargeLabels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FareResult row,  FareType type,  double rate,  int price,  List<String> surchargeLabels)  $default,) {final _that = this;
switch (_that) {
case _SelectedFare():
return $default(_that.row,_that.type,_that.rate,_that.price,_that.surchargeLabels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FareResult row,  FareType type,  double rate,  int price,  List<String> surchargeLabels)?  $default,) {final _that = this;
switch (_that) {
case _SelectedFare() when $default != null:
return $default(_that.row,_that.type,_that.rate,_that.price,_that.surchargeLabels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectedFare implements SelectedFare {
  const _SelectedFare({required this.row, required this.type, required this.rate, required this.price, required final  List<String> surchargeLabels}): _surchargeLabels = surchargeLabels;
  factory _SelectedFare.fromJson(Map<String, dynamic> json) => _$SelectedFareFromJson(json);

@override final  FareResult row;
@override final  FareType type;
@override final  double rate;
@override final  int price;
 final  List<String> _surchargeLabels;
@override List<String> get surchargeLabels {
  if (_surchargeLabels is EqualUnmodifiableListView) return _surchargeLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surchargeLabels);
}


/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectedFareCopyWith<_SelectedFare> get copyWith => __$SelectedFareCopyWithImpl<_SelectedFare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectedFareToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedFare&&(identical(other.row, row) || other.row == row)&&(identical(other.type, type) || other.type == type)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._surchargeLabels, _surchargeLabels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,row,type,rate,price,const DeepCollectionEquality().hash(_surchargeLabels));

@override
String toString() {
  return 'SelectedFare(row: $row, type: $type, rate: $rate, price: $price, surchargeLabels: $surchargeLabels)';
}


}

/// @nodoc
abstract mixin class _$SelectedFareCopyWith<$Res> implements $SelectedFareCopyWith<$Res> {
  factory _$SelectedFareCopyWith(_SelectedFare value, $Res Function(_SelectedFare) _then) = __$SelectedFareCopyWithImpl;
@override @useResult
$Res call({
 FareResult row, FareType type, double rate, int price, List<String> surchargeLabels
});


@override $FareResultCopyWith<$Res> get row;

}
/// @nodoc
class __$SelectedFareCopyWithImpl<$Res>
    implements _$SelectedFareCopyWith<$Res> {
  __$SelectedFareCopyWithImpl(this._self, this._then);

  final _SelectedFare _self;
  final $Res Function(_SelectedFare) _then;

/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? row = null,Object? type = null,Object? rate = null,Object? price = null,Object? surchargeLabels = null,}) {
  return _then(_SelectedFare(
row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as FareResult,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FareType,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,surchargeLabels: null == surchargeLabels ? _self._surchargeLabels : surchargeLabels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SelectedFare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FareResultCopyWith<$Res> get row {
  
  return $FareResultCopyWith<$Res>(_self.row, (value) {
    return _then(_self.copyWith(row: value));
  });
}
}

// dart format on
