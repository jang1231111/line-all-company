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

    // [4월 운영지침일 때만] 인천/평택 구간에 따라 지역 기점 할증 자동 관리
    // 2월 운영지침에서는 지역 할증 적용 안 함 → area 할증 id 전체 제거
    final section = newState.section ?? '';
    var updatedSurcharges = List<String>.from(newState.surcharges);
    updatedSurcharges.removeWhere(
      (id) => id == 'incheon_area' || id == 'pyeongtaek_area',
    );
    if (isAprilGuideline(newState.period)) {
      // 4월 우영지침: 구간에 맞는 지역 기점 할증 자동 선택
      if (incheonAreaSections.contains(section)) {
        updatedSurcharges.add('incheon_area');
      } else if (pyeongtaekAreaSections.contains(section)) {
        updatedSurcharges.add('pyeongtaek_area');
      }
    }
    // 상태가 실제로 변경된 경우만 copyWith 호출
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

    state = newState.copyWith(surchargeResult: surchargeResult);
  }

  Future<void> searchByRegion() async {
    _ref.read(fareResultViewModelProvider.notifier).setLoading();

    // distance-incheon / distance-pyeongtaek 선택 시 API는 section=distance로 호출
    final routeApiSection = _toRouteApiSection(state.section);

    final results = await _repository.searchByRegion(
      period: state.period!,
      type: state.type!,
      section: routeApiSection,
      sido: state.sido,
      sigungu: state.sigungu,
      eupmyeondong: state.eupmyeondong,
    );

    // 가나다(오름차순) 정렬: sido > sigungu > eupmyeondong
    results.sort((a, b) {
      final sidoComp = a.sido.compareTo(b.sido);
      if (sidoComp != 0) return sidoComp;
      final sigunguComp = a.sigungu.compareTo(b.sigungu);
      if (sigunguComp != 0) return sigunguComp;
      return a.eupmyeondong.compareTo(b.eupmyeondong);
    });

    // 결과를 FareResultViewModel에 저장
    _ref.read(fareResultViewModelProvider.notifier).setResults(results);
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

    // distance-incheon / distance-pyeongtaek 선택 시 API는 section=distance로 호출
    final routeApiSection = _toRouteApiSection(state.section);

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
        section: routeApiSection,
        sido: sido,
        sigungu: sigungu,
        eupmyeondong: eupmyeondong,
      );

      // 2차: 결과가 없고 eupmyeondong이 4글자 이상이면 앞2+뒤2글자 조합으로 재검색
      if (results.isEmpty && eupmyeondong != null && eupmyeondong.length >= 4) {
        results = await _repository.searchByRoadName(
          period: state.period!,
          type: state.type!,
          section: routeApiSection,
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
        section: routeApiSection,
        sido: sido,
        sigungu: sigungu,
        dong: address.emdNm,
      );
    }

    // 가나다(오름차순) 정렬: sido > sigungu > eupmyeondong
    results.sort((a, b) {
      final sidoComp = a.sido.compareTo(b.sido);
      if (sidoComp != 0) return sidoComp;
      final sigunguComp = a.sigungu.compareTo(b.sigungu);
      if (sigunguComp != 0) return sigunguComp;
      return a.eupmyeondong.compareTo(b.eupmyeondong);
    });

    // 결과를 FareResultViewModel에 저장
    _ref.read(fareResultViewModelProvider.notifier).setResults(results);
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

  /// distance-incheon / distance-pyeongtaek 선택 시
  /// /api/routes 호출에 실제로 사용하는 section 값으로 변환합니다.
  /// (UI 구간명 → API 파라미터 변환)
  String _toRouteApiSection(String? section) {
    if (section == 'distance-incheon' || section == 'distance-pyeongtaek') {
      // 두 구간 모두 API에는 단순 'distance' section으로 조회
      return 'distance';
    }
    return section ?? '';
  }
}
