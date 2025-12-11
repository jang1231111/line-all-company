import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:line_all/features/condition/domain/repositories/selected_fare_repository.dart';
import 'package:line_all/features/condition/presentation/providers/fare_result_provider.dart';
import 'package:line_all/features/condition/presentation/providers/road_name_search_provider.dart';
import '../../domain/models/fare_result.dart';
import '../models/selected_fare.dart';
import '../data/selected_fare_local_data_source.dart';

class SelectedFareViewModel extends StateNotifier<List<SelectedFare>> {
  final Ref ref; // ref 주입하여 다른 provider 접근
  final SelectedFareLocalDataSource _localDataSource;
  final SelectedFareRepository _repository;

  SelectedFareViewModel(this.ref, this._localDataSource, this._repository)
    : super([]);

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

  // 내부DB 저장 (consignor 함께 저장)
  Future<void> saveCurrentToDb(String consignor) async {
    await _localDataSource.addHistory(state, consignor);
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

  /// 저장만 할경우 화주명만 입력받아 저장
  Future<bool> saveSelectedFares(String consignor) async {
    if (state.isEmpty) return false;
    // 간단 검증: 필수값 체크
    if (consignor.isEmpty) {
      return false;
    }
    try {
      // 전송 성공 시 기존 루틴: DB 저장 및 상태 초기화
      await saveCurrentToDb(consignor);
      // 모든 상태 초기화 처리
      try {
        clearState();
        ref.read(conditionViewModelProvider.notifier).reset();
        ref.read(roadNameSearchViewModelProvider.notifier).clearKeyword();
        ref.read(fareResultViewModelProvider.notifier).clear();
      } catch (_) {
        // 안전하게 무시(ConditionViewModel에 reset이 없거나 provider 이름이 다를 경우)
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 서버로 선택 항목 전송. input에는 'consignor'/'email' 등 다이얼로그에서 받은 값이 들어옵니다.
  /// 성공하면 로컬 DB에 저장하고 상태 초기화.
  /// 반환값: 성공(true) / 실패(false)
  Future<bool> sendSelectedFares(Map<String, String> input) async {
    if (state.isEmpty) return false;

    final consignor = (input['consignor'] ?? '-').trim();
    final recipient = (input['recipient'] ?? '-').trim();
    final recipient_email = (input['recipient_email'] ?? '-').trim();
    final recipient_company = (input['recipient_company'] ?? '-').trim();
    final recipient_phone = (input['recipient_phone'] ?? '-').trim();
    final note = (input['note'] ?? '-').trim();

    // 간단 검증: 필수값 체크
    if (consignor.isEmpty || recipient.isEmpty || recipient_email.isEmpty) {
      return false;
    }

    try {
      final success = await _repository.sendSelectedFares(
        consignor: consignor,
        recipient: recipient,
        recipientEmail: recipient_email,
        recipientCompany: recipient_company,
        recipientPhone: recipient_phone,
        note: note,
        fares: state,
      );
      if (success) {
        // 전송 성공 시 기존 루틴: DB 저장 및 상태 초기화
        await saveCurrentToDb(consignor);
        // 모든 상태 초기화 처리
        try {
          clearState();
          ref.read(conditionViewModelProvider.notifier).reset();
          ref.read(roadNameSearchViewModelProvider.notifier).clearKeyword();
          ref.read(fareResultViewModelProvider.notifier).clear();
        } catch (_) {
          // 안전하게 무시(ConditionViewModel에 reset이 없거나 provider 이름이 다를 경우)
        }
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateFarePrice(int index, int newPrice) async {
    if (index < 0 || index >= state.length) return;

    final old = state[index];
    SelectedFare updated;

    // 가능하면 copyWith 사용, 없으면 수동 복사
    try {
      // if SelectedFare has copyWith({price})
      updated = old.copyWith(price: newPrice);
    } catch (_) {
      // fallback: SelectedFare 생성자에 맞게 필드 복사
      updated = SelectedFare(
        row: old.row,
        type: old.type,
        rate: old.rate,
        price: newPrice,
        surchargeLabels: List<String>.from(old.surchargeLabels),
      );
    }

    final newList = List<SelectedFare>.from(state);
    newList[index] = updated;
    state = newList;
  }
}
