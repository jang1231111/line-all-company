import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/viewmodel/selected_fare_viewmodel.dart';
import '../data/selected_fare_local_data_source.dart';
import 'package:line_all/features/condition/data/repositories/selected_fare_repository_impl.dart';

final selectedFareProvider =
    StateNotifierProvider<SelectedFareViewModel, List<SelectedFare>>(
      (ref) => SelectedFareViewModel(
        SelectedFareLocalDataSource(),
        SelectedFareRepositoryImpl(),
      ),
    );
