import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/viewmodel/selected_fare_viewmodel.dart';

final selectedFareProvider =
    StateNotifierProvider<SelectedFareViewModel, List<SelectedFare>>(
      (ref) => SelectedFareViewModel(),
    );
