import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/domain/models/condition.dart';
import 'package:line_all/features/condition/domain/models/fare_result.dart';
import 'package:line_all/features/condition/domain/models/regional_surcharge.dart';
import 'package:line_all/features/condition/domain/repositories/condition_repository.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';

class MockConditionRepository implements ConditionRepository {
  String? lastPassedSection;
  int searchCallCount = 0;

  @override
  Future<List<FareResult>> searchByRegion({
    required String period,
    required String type,
    required String section,
    String? sido,
    String? sigungu,
    String? eupmyeondong,
    String? dong,
    String? destinationSearch,
    int? unnotice,
    String? mode,
  }) async {
    lastPassedSection = section;
    searchCallCount++;
    return [];
  }

  @override
  Future<List<FareResult>> searchByRoadName({
    required String period,
    required String type,
    required String section,
    required String sido,
    required String sigungu,
    String? eupmyeondong,
    String? destinationSearch,
    String? dong,
  }) async {
    lastPassedSection = section;
    searchCallCount++;
    return [];
  }

  @override
  Future<List<RegionalSurcharge>> getRegionalSurcharge({
    required String region,
  }) async => [];

  @override
  Future<List<String>> fetchRegions({
    required String mode,
    required String period,
    required String section,
    String? sido,
    String? sigungu,
  }) async => [];
}

void main() {
  late MockConditionRepository mockRepository;
  late ProviderContainer container;
  late ConditionViewModel viewModel;

  setUp(() {
    mockRepository = MockConditionRepository();
    container = ProviderContainer(
      overrides: [
        conditionRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    // ProviderContainer에서 Ref 취득용 element 생성
    viewModel = ConditionViewModel(mockRepository, container.read(dummyRefProvider));
  });

  tearDown(() {
    container.dispose();
  });

  group('ConditionViewModel - 배차취소료 선택 시 편도 구간 왕복 운임 적용 테스트', () {
    test('배차취소료 미선택 시 편도 구간(-oneway) 그대로 검색 파라미터로 전달된다', () async {
      const condition = Condition(
        period: '2026-04-01~2026-12-31',
        type: '안전위탁운임',
        section: 'regional-oneway',
        cancellationFee: null,
      );

      viewModel.update(condition);
      await Future.delayed(Duration.zero); // microtask 대기

      expect(mockRepository.lastPassedSection, 'regional-oneway');
    });

    test('배차취소료 선택 시 편도 구간(-oneway)이 왕복 구간으로 변환되어 검색 파라미터로 전달된다', () async {
      const condition = Condition(
        period: '2026-04-01~2026-12-31',
        type: '안전위탁운임',
        section: 'regional-oneway',
        cancellationFee: 'cancellation_fee_20',
      );

      viewModel.update(condition);
      await Future.delayed(Duration.zero); // microtask 대기

      expect(mockRepository.lastPassedSection, 'regional');
    });

    test('배차취소료 선택 상태 변경 시 유효 구간(effectiveSection) 변경으로 인해 자동 재검색이 실행된다', () async {
      // 1. 배차취소료 없이 초기 검색 조건 입력
      const initialCondition = Condition(
        period: '2026-04-01~2026-12-31',
        type: '안전위탁운임',
        section: 'regional-oneway',
        cancellationFee: null,
      );
      viewModel.update(initialCondition);
      await Future.delayed(Duration.zero);

      expect(mockRepository.searchCallCount, 1);
      expect(mockRepository.lastPassedSection, 'regional-oneway');

      // 2. 배차취소료 추가 선택 -> searchCallCount 증가 및 regional 변환 확인
      final updatedCondition = initialCondition.copyWith(
        cancellationFee: 'cancellation_fee_20',
      );
      viewModel.update(updatedCondition);
      await Future.delayed(Duration.zero);

      expect(mockRepository.searchCallCount, 2);
      expect(mockRepository.lastPassedSection, 'regional');
    });
  });
}

final dummyRefProvider = Provider<Ref>((ref) => ref);
