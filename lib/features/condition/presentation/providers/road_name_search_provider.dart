import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/data/repositories/address_api_repository.dart';
import 'package:line_all/features/condition/presentation/viewmodel/road_name_search_viewmodel.dart';

import '../viewmodel/road_name_search_state.dart';

final roadNameSearchViewModelProvider =
    StateNotifierProvider<RoadNameSearchViewModel, RoadNameSearchState>(
      (ref) =>
          RoadNameSearchViewModel(ref.watch(roadNameSearchRepositoryProvider)),
    );

final roadNameSearchRepositoryProvider = Provider<AddressApiRepository>((ref) {
  return AddressApiRepository();
});
