import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/address_api_repository.dart';
import 'road_name_search_state.dart';

class RoadNameSearchViewModel extends StateNotifier<RoadNameSearchState> {
  final AddressApiRepository repository;
  RoadNameSearchViewModel(this.repository) : super(const RoadNameSearchState());

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  Future<void> search(String keyword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await repository.searchJuso(keyword);
      state = state.copyWith(
        results: results,
        isLoading: false,
        totalCount: results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
