import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/fare_result.dart';
import '../models/selected_fare.dart';
import '../data/selected_fare_local_data_source.dart';

class SelectedFareViewModel extends StateNotifier<List<SelectedFare>> {
  final SelectedFareLocalDataSource _localDataSource;

  SelectedFareViewModel({SelectedFareLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? SelectedFareLocalDataSource(),
      super([]);

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

  void clearState() {
    state = [];
  }

  bool isSelected(FareResult row, FareType type) {
    return state.any((e) => e.row == row && e.type == type);
  }

  // 내부DB 저장
  Future<void> saveCurrentToDb() async {
    await _localDataSource.addHistory(state);
  }

  // 내부DB 불러오기
  Future<List<Map<String, dynamic>>> loadHistoryFromDb() async {
    return await _localDataSource.loadHistory();
  }

  // 내부DB 전체 삭제
  Future<void> clearHistoryInDb() async {
    await _localDataSource.clearHistory();
  }

  // id로 특정 항목 삭제 (SelectedFareLocalDataSource의 deleteEntryById 사용)
  Future<void> deleteEntryById(String id) async {
    await _localDataSource.deleteEntryById(id);
  }

  // entry 내 개별 fare 삭제
  Future<void> deleteFareInEntry(String entryId, String fareId) async {
    await _localDataSource.deleteFareById(entryId, fareId);
  }

  Future<void> deleteFareInEntryAt(String entryId, int fareIndex) async {
    await _localDataSource.deleteFareAt(entryId, fareIndex);
  }
}
