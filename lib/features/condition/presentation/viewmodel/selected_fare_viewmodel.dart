import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/domain/repositories/selected_fare_repository.dart';
import '../../domain/models/fare_result.dart';
import '../models/selected_fare.dart';
import '../data/selected_fare_local_data_source.dart';

class SelectedFareViewModel extends StateNotifier<List<SelectedFare>> {
  final SelectedFareLocalDataSource _localDataSource;
  final SelectedFareRepository _repository;

  SelectedFareViewModel(this._localDataSource, this._repository) : super([]);

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

  /// 서버로 선택 항목 전송. input에는 'consignor'/'email' 등 다이얼로그에서 받은 값이 들어옵니다.
  /// 성공하면 로컬 DB에 저장하고 상태 초기화.
  /// 반환값: 성공(true) / 실패(false)
  Future<bool> sendSelectedFares(Map<String, String> input) async {
    if (state.isEmpty) return false;

    final consignor = (input['consignor'] ?? '').trim();
    final email = (input['email'] ?? '').trim();

    // 간단 검증: 필수값 체크
    if (consignor.isEmpty || email.isEmpty) return false;

    try {
      final success = await _repository.sendSelectedFares(
        consignor: consignor,
        email: email,
        fares: state,
      );
      if (success) {
        // 전송 성공 시 기존 루틴: DB 저장 및 상태 초기화
        await saveCurrentToDb();
        clearState();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}
