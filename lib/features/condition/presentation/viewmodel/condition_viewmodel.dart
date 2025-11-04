import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';

import '../../domain/models/condition.dart';
import '../../domain/models/road_name_address.dart';
import '../../domain/repositories/condition_repository.dart';
import '../data/surcharge_calculator.dart';
import '../providers/fare_result_provider.dart'; // 추가

class ConditionViewModel extends StateNotifier<Condition> {
  ConditionViewModel(this._repository, this._ref) : super(const Condition());

  final ConditionRepository _repository;
  final Ref _ref;
  void update(Condition condition) {
    state = condition;
  }

  Future<void> searchByRegion() async {
    final results = await _repository.searchByRegion(
      period: state.period,
      section: state.section,
      sido: state.sido,
      sigungu: state.sigungu,
      eupmyeondong: state.eupmyeondong,
      type: state.type,
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

  Future<void> searchByRoadName(RoadNameAddress address) async {
    String sido = address.siNm;
    String sigungu = address.sggNm;
    String? eupmyeondong;
    List<FareResult> results;

    // hemdNm non-null
    if (address.hemdNm != null) {
      // 읍면동 값 추출
      final hemdNm = address.hemdNm;
      if (hemdNm!.isNotEmpty) {
        final parts = hemdNm.split(' ');
        eupmyeondong = parts.isNotEmpty ? parts.last : null;
      }

      // 1차 검색
      results = await _repository.searchByRoadName(
        period: state.period!,
        section: state.section!,
        sido: sido,
        sigungu: sigungu,
        eupmyeondong: eupmyeondong,
      );

      // 2차: 결과가 없고 eupmyeondong이 4글자 이상이면 앞2+뒤2글자 조합으로 재검색
      if (results.isEmpty && eupmyeondong != null && eupmyeondong.length >= 4) {
        final shortEupmyeondong =
            eupmyeondong.substring(0, 2) +
            eupmyeondong.substring(eupmyeondong.length - 2);

        ///

        results = await _repository.searchByRoadName(
          period: state.period!,
          section: state.section!,
          sido: sido,
          sigungu: sigungu,
          eupmyeondong: shortEupmyeondong,
        );
      }

      // 3차: 그래도 결과가 없고 eupmyeondong에 "제"가 있으면 "제"를 제거해서 재검색
      if (results.isEmpty &&
          eupmyeondong != null &&
          eupmyeondong.contains('제')) {
        final removedJe = eupmyeondong.replaceAll('제', '');
        if (removedJe.isNotEmpty) {
          results = await _repository.searchByRoadName(
            period: state.period!,
            section: state.section!,
            sido: sido,
            sigungu: sigungu,
            eupmyeondong: removedJe,
          );
        }
      }
    }
    // hemdNm 값 null
    else {
      results = await _repository.searchByRoadName(
        period: state.period!,
        section: state.section!,
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

  /// 할증 관련 값이 바뀔 때 호출
  void updateSurcharge() {
    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: state.surcharges,
      dangerType: state.dangerType,
      weightType: state.weightType,
      specialType: state.specialType,
      cancellationFee: state.cancellationFee,
    );
    state = state.copyWith(surchargeResult: surchargeResult);
  }
}
