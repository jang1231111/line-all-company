import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/fare_result.dart';

class FareResultViewModel extends StateNotifier<AsyncValue<List<FareResult>>> {
  FareResultViewModel() : super(const AsyncValue.data([]));

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setResults(List<FareResult> results) {
    state = AsyncValue.data(results);
  }

  void setError(Object error, [StackTrace? stackTrace]) {
    state = AsyncValue.error(error, stackTrace!);
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
