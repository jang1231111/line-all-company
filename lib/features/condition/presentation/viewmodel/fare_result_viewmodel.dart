import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/fare_result.dart';

class FareResultViewModel extends StateNotifier<List<FareResult>> {
  FareResultViewModel() : super([]);

  void setResults(List<FareResult> results) {
    state = results;
  }

  void clear() {
    state = [];
  }
}
