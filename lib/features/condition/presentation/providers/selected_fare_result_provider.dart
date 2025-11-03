import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/fare_result.dart';

enum FareType { ft20, ft40 }

class SelectedFare {
  final FareResult row;
  final FareType type;
  final double rate; // 버튼 클릭 시의 할증률
  final int price; // 버튼 클릭 시의 금액
  final List<String> surchargeLabels; // 버튼 클릭 시의 할증 목록

  SelectedFare({
    required this.row,
    required this.type,
    required this.rate,
    required this.price,
    required this.surchargeLabels,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedFare &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          type == other.type;

  @override
  int get hashCode => row.hashCode ^ type.hashCode;
}

final selectedFareProvider =
    StateNotifierProvider<SelectedFareNotifier, List<SelectedFare>>(
      (ref) => SelectedFareNotifier(),
    );

class SelectedFareNotifier extends StateNotifier<List<SelectedFare>> {
  SelectedFareNotifier() : super([]);

  void toggle({
    required FareResult row,
    required FareType type,
    required double rate,
    required int price,
    required List<String> surchargeLabels,
  }) {
    final selected = SelectedFare(
      row: row,
      type: type,
      rate: rate,
      price: price,
      surchargeLabels: surchargeLabels,
    );
    if (state.contains(selected)) {
      state = state.where((e) => e != selected).toList();
    } else {
      state = [...state, selected];
    }
  }

  bool isSelected(FareResult row, FareType type) {
    return state.any((e) => e.row == row && e.type == type);
  }
}
