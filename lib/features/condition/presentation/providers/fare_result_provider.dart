import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../viewmodel/fare_result_viewmodel.dart';
import '../../domain/models/fare_result.dart';

final fareResultViewModelProvider =
    StateNotifierProvider<FareResultViewModel, AsyncValue<List<FareResult>>>(
      (ref) => FareResultViewModel(),
    );
