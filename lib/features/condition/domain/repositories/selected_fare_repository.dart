import 'package:line_all/features/condition/presentation/models/selected_fare.dart';

abstract class SelectedFareRepository {
  Future<bool> sendSelectedFares({
    required String consignor,
    required String recipient,
    required String recipientEmail,
    required String? recipientPhone,
    required String note,
    required List<SelectedFare> fares,
  });
}
