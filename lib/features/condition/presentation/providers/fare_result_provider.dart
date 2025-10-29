import 'package:flutter_riverpod/legacy.dart';
import '../viewmodel/fare_result_viewmodel.dart';
import '../../domain/models/fare_result.dart';

final fareResultViewModelProvider =
    StateNotifierProvider<FareResultViewModel, List<FareResult>>(
      (ref) => FareResultViewModel(),
    );
