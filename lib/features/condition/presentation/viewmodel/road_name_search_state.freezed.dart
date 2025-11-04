// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'road_name_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoadNameSearchState {

 List<RoadNameAddress> get results; bool get isLoading; String? get error; int get totalCount; String get keyword;
/// Create a copy of RoadNameSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoadNameSearchStateCopyWith<RoadNameSearchState> get copyWith => _$RoadNameSearchStateCopyWithImpl<RoadNameSearchState>(this as RoadNameSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoadNameSearchState&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.keyword, keyword) || other.keyword == keyword));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),isLoading,error,totalCount,keyword);

@override
String toString() {
  return 'RoadNameSearchState(results: $results, isLoading: $isLoading, error: $error, totalCount: $totalCount, keyword: $keyword)';
}


}

/// @nodoc
abstract mixin class $RoadNameSearchStateCopyWith<$Res>  {
  factory $RoadNameSearchStateCopyWith(RoadNameSearchState value, $Res Function(RoadNameSearchState) _then) = _$RoadNameSearchStateCopyWithImpl;
@useResult
$Res call({
 List<RoadNameAddress> results, bool isLoading, String? error, int totalCount, String keyword
});




}
/// @nodoc
class _$RoadNameSearchStateCopyWithImpl<$Res>
    implements $RoadNameSearchStateCopyWith<$Res> {
  _$RoadNameSearchStateCopyWithImpl(this._self, this._then);

  final RoadNameSearchState _self;
  final $Res Function(RoadNameSearchState) _then;

/// Create a copy of RoadNameSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? isLoading = null,Object? error = freezed,Object? totalCount = null,Object? keyword = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<RoadNameAddress>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoadNameSearchState].
extension RoadNameSearchStatePatterns on RoadNameSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoadNameSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoadNameSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoadNameSearchState value)  $default,){
final _that = this;
switch (_that) {
case _RoadNameSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoadNameSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _RoadNameSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RoadNameAddress> results,  bool isLoading,  String? error,  int totalCount,  String keyword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoadNameSearchState() when $default != null:
return $default(_that.results,_that.isLoading,_that.error,_that.totalCount,_that.keyword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RoadNameAddress> results,  bool isLoading,  String? error,  int totalCount,  String keyword)  $default,) {final _that = this;
switch (_that) {
case _RoadNameSearchState():
return $default(_that.results,_that.isLoading,_that.error,_that.totalCount,_that.keyword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RoadNameAddress> results,  bool isLoading,  String? error,  int totalCount,  String keyword)?  $default,) {final _that = this;
switch (_that) {
case _RoadNameSearchState() when $default != null:
return $default(_that.results,_that.isLoading,_that.error,_that.totalCount,_that.keyword);case _:
  return null;

}
}

}

/// @nodoc


class _RoadNameSearchState implements RoadNameSearchState {
  const _RoadNameSearchState({final  List<RoadNameAddress> results = const [], this.isLoading = false, this.error, this.totalCount = 0, this.keyword = ''}): _results = results;
  

 final  List<RoadNameAddress> _results;
@override@JsonKey() List<RoadNameAddress> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  String keyword;

/// Create a copy of RoadNameSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoadNameSearchStateCopyWith<_RoadNameSearchState> get copyWith => __$RoadNameSearchStateCopyWithImpl<_RoadNameSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoadNameSearchState&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.keyword, keyword) || other.keyword == keyword));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),isLoading,error,totalCount,keyword);

@override
String toString() {
  return 'RoadNameSearchState(results: $results, isLoading: $isLoading, error: $error, totalCount: $totalCount, keyword: $keyword)';
}


}

/// @nodoc
abstract mixin class _$RoadNameSearchStateCopyWith<$Res> implements $RoadNameSearchStateCopyWith<$Res> {
  factory _$RoadNameSearchStateCopyWith(_RoadNameSearchState value, $Res Function(_RoadNameSearchState) _then) = __$RoadNameSearchStateCopyWithImpl;
@override @useResult
$Res call({
 List<RoadNameAddress> results, bool isLoading, String? error, int totalCount, String keyword
});




}
/// @nodoc
class __$RoadNameSearchStateCopyWithImpl<$Res>
    implements _$RoadNameSearchStateCopyWith<$Res> {
  __$RoadNameSearchStateCopyWithImpl(this._self, this._then);

  final _RoadNameSearchState _self;
  final $Res Function(_RoadNameSearchState) _then;

/// Create a copy of RoadNameSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? isLoading = null,Object? error = freezed,Object? totalCount = null,Object? keyword = null,}) {
  return _then(_RoadNameSearchState(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<RoadNameAddress>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
