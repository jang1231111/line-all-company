import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';

import '../../domain/models/condition.dart';
import '../../domain/models/road_name_address.dart';
import '../../domain/repositories/condition_repository.dart';
import '../data/condition_options.dart';
import '../data/surcharge_calculator.dart';
import '../data/surcharge_options.dart'; // 지역 기점 할증 구간 상수
import '../providers/fare_result_provider.dart';

class ConditionViewModel extends StateNotifier<Condition> {
  ConditionViewModel(this._repository, this._ref) : super(const Condition()) {
    // 초기 상태에서 period가 비어있다면 2026-01-01~2026-01-31 안전하게 기본값을 설정합니다.
    if ((state.period == null || state.period!.isEmpty) &&
        periodOptions.isNotEmpty) {
      state = state.copyWith(period: periodOptions.first.value);
    }
  }

  final ConditionRepository _repository;
  final Ref _ref;

  void reset() {
    // 초기 상태로 리셋 (period는 기본값으로 설정)
    state = Condition(period: periodOptions.first.value);
  }

  void update(Condition condition) {
    var newState = condition;

    // 구간이 편도로 변경될 경우, 편도에서 허용되지 않는 할증 항목(냉동/냉장) 자동 제거
    final isOneWay = newState.section?.endsWith('-oneway') ?? false;
    if (isOneWay) {
      final filteredSurcharges = newState.surcharges
          .where((id) => id != 'refrigerated')
          .toList();

      if (filteredSurcharges.length != newState.surcharges.length) {
        newState = newState.copyWith(surcharges: filteredSurcharges);
      }
    }

    // [인천/평택 지역 기점 할증 - surchargeRate(%) 포함 방식]
    // 인천(20%)/평택(18%)은 top-3 할증 계산에 항상 포함되는 % 할증
    // 단, 실제 적용 base는 fare_result_table에서 구간별로 다르게 처리:
    //   - areaSubtract: surchargeBase = routes - regional (운송/운수) 또는 round(routes/divRate, 10) (안전위탁)
    //   - areaAdd     : surchargeBase = routes(거리별), areaAddon(regional 또는 routes/divRate)별도 가산
    final section = newState.section ?? '';
    var updatedSurcharges = List<String>.from(newState.surcharges);
    // 먼저 기존 area 할증 제거 후 재판단
    updatedSurcharges.removeWhere(
      (id) => id == 'incheon_area' || id == 'pyeongtaek_area',
    );
    if (isAprilGuideline(newState.period)) {
      // 4월 운영지침: 구간에 따라 인천(20%) 또는 평택(18%) 할증 자동 추가
      if (incheonAreaSections.contains(section)) {
        updatedSurcharges.add('incheon_area'); // 20%
      } else if (pyeongtaekAreaSections.contains(section)) {
        updatedSurcharges.add('pyeongtaek_area'); // 18%
      }
    }
    final areaChanged =
        updatedSurcharges.length != newState.surcharges.length ||
        !updatedSurcharges.toSet().containsAll(newState.surcharges) ||
        !newState.surcharges.toSet().containsAll(updatedSurcharges);
    if (areaChanged) {
      newState = newState.copyWith(surcharges: updatedSurcharges);
    }

    // 상태 업데이트 전 할증 결과 재계산
    // isPeriod2026: 2월/4월 운영지침 모두 2026 할증 옵션 사용
    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: newState.surcharges,
      weightType: newState.weightType,
      cancellationFee: newState.cancellationFee,
      is2026Period: isPeriod2026(newState.period),
    );

    final wasFullySelected = state.period?.isNotEmpty == true &&
        state.type?.isNotEmpty == true &&
        state.section?.isNotEmpty == true;
    final isFullySelected = newState.period?.isNotEmpty == true &&
        newState.type?.isNotEmpty == true &&
        newState.section?.isNotEmpty == true;
    final conditionChanged = state.period != newState.period ||
        state.type != newState.type ||
        state.section != newState.section;

    state = newState.copyWith(surchargeResult: surchargeResult);

    // 기간/유형/구간 모두 선택 시 자동 API 호출
    if (isFullySelected && conditionChanged) {
      Future.microtask(() => searchByRegion());
    } else if (!isFullySelected && wasFullySelected) {
      Future.microtask(() => _ref.read(fareResultViewModelProvider.notifier).clear());
    }
  }

  Future<void> searchByRegion() async {
    _ref.read(fareResultViewModelProvider.notifier).setLoading();

    try {
      final results = await _repository.searchByRegion(
        period: state.period!,
        type: state.type!,
        section: state.section ?? '',
        sido: state.sido,
        sigungu: state.sigungu,
        eupmyeondong: state.eupmyeondong,
      );

      // 정렬 처리
      if (distanceBaseSections.contains(state.section)) {
        // 거리별 구간일 경우: 1km, 2km, 3km 등 거리(distance) 오름차순
        results.sort((a, b) => a.distance.compareTo(b.distance));
      } else {
        // 단거리/일반 구간일 경우: 가나다(오름차순) 정렬 (sido > sigungu > eupmyeondong)
        results.sort((a, b) {
          final sidoComp = a.sido.compareTo(b.sido);
          if (sidoComp != 0) return sidoComp;
          final sigunguComp = a.sigungu.compareTo(b.sigungu);
          if (sigunguComp != 0) return sigunguComp;
          return a.eupmyeondong.compareTo(b.eupmyeondong);
        });
      }

      // 결과를 FareResultViewModel에 저장
      _ref.read(fareResultViewModelProvider.notifier).setResults(results);
    } catch (e, stackTrace) {
      _ref.read(fareResultViewModelProvider.notifier).setError(e, stackTrace);
    }
  }

  // searchByRoadName 전용 sido 보정
  String _normalizeSidoForRoadName(String? sido) {
    if (sido == null) return '';
    final s = sido.trim();
    if (s == '전북특별자치도') return '전라북도';
    if (s == '강원특별자치도') return '강원도';
    return s;
  }

  Future<void> searchByRoadName(RoadNameAddress address) async {
    // 주소에서 넘어온 sido를 검색용으로 보정
    String sido = _normalizeSidoForRoadName(address.siNm);
    String sigungu = address.sggNm;
    String? eupmyeondong;
    List<FareResult> results;

    _ref.read(fareResultViewModelProvider.notifier).setLoading();

    try {
      // hemdNm non-null
      if (address.hemdNm != null) {
        // 음면동 값 추출
        final hemdNm = address.hemdNm;
        if (hemdNm!.isNotEmpty) {
          final parts = hemdNm.split(' ');
          eupmyeondong = parts.isNotEmpty ? parts.last : null;
        }

        // 1차 검색
        results = await _repository.searchByRoadName(
          period: state.period!,
          type: state.type!,
          section: state.section ?? '',
          sido: sido,
          sigungu: sigungu,
          eupmyeondong: eupmyeondong,
        );

        // 2차: 결과가 없고 eupmyeondong이 4글자 이상이면 앞2+뒤2글자 조합으로 재검색
        if (results.isEmpty && eupmyeondong != null && eupmyeondong.length >= 4) {
          results = await _repository.searchByRoadName(
            period: state.period!,
            type: state.type!,
            section: state.section ?? '',
            sido: sido,
            sigungu: sigungu,
            destinationSearch:
                '${eupmyeondong.substring(0, 2)}&${eupmyeondong.substring(eupmyeondong.length - 2)}',
          );
        }
      }
      // hemdNm 값 null
      else {
        results = await _repository.searchByRoadName(
          period: state.period!,
          type: state.type!,
          section: state.section ?? '',
          sido: sido,
          sigungu: sigungu,
          dong: address.emdNm,
        );
      }

      // 정렬 처리
      if (distanceBaseSections.contains(state.section)) {
        results.sort((a, b) => a.distance.compareTo(b.distance));
      } else {
        // 가나다(오름차순) 정렬: sido > sigungu > eupmyeondong
        results.sort((a, b) {
          final sidoComp = a.sido.compareTo(b.sido);
          if (sidoComp != 0) return sidoComp;
          final sigunguComp = a.sigungu.compareTo(b.sigungu);
          if (sigunguComp != 0) return sigunguComp;
          return a.eupmyeondong.compareTo(b.eupmyeondong);
        });
      }

      // 결과를 FareResultViewModel에 저장
      _ref.read(fareResultViewModelProvider.notifier).setResults(results);
    } catch (e, stackTrace) {
      _ref.read(fareResultViewModelProvider.notifier).setError(e, stackTrace);
    }
  }

  /// 할증 관련 값이 바뀌일 때 호출
  void updateSurcharge() {
    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: state.surcharges,
      weightType: state.weightType,
      cancellationFee: state.cancellationFee,
      is2026Period: isPeriod2026(state.period), // 2월/4월 모두 해당
    );
    state = state.copyWith(surchargeResult: surchargeResult);
  }

  Future<void> searchOnSidoChange() async {
    // 2026년도 두 운영지침 모두 유효
    if (isPeriod2026(state.period)) {
      await searchByRegion();
    }
  }
}
