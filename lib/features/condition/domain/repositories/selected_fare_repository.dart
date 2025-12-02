import 'package:line_all/features/condition/presentation/models/selected_fare.dart';

abstract class SelectedFareRepository {
  Future<bool> sendSelectedFares({
    required String consignor,
    required String email,
    required List<SelectedFare> fares,
  });
}
