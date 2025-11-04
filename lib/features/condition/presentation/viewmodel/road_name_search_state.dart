import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:line_all/features/condition/domain/models/road_name_address.dart';

part 'road_name_search_state.freezed.dart';

@freezed
abstract class RoadNameSearchState with _$RoadNameSearchState {
  const factory RoadNameSearchState({
    @Default([]) List<RoadNameAddress> results,
    @Default(false) bool isLoading,
    String? error,
    @Default(0) int totalCount,
    @Default('') String keyword, // 검색
  }) = _RoadNameSearchState;
}
