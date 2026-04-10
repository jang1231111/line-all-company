import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:line_all/features/condition/domain/models/regional_surcharge.dart';
import 'condition_provider.dart';

/// 앱 시작 시 인천/평택 두 지역의 할증 데이터를 한 번에 fetch하여 캐싱합니다.
/// FutureProvider이므로 첫 watch 시 자동 실행되며, 이후 캐시에서 사용합니다.
final regionalSurchargeProvider =
    FutureProvider<Map<String, List<RegionalSurcharge>>>((ref) async {
      final repo = ref.read(conditionRepositoryProvider);

      // 두 지역 데이터를 병렬로 가져와 캐싱
      final results = await Future.wait([
        repo.getRegionalSurcharge(region: 'incheon'),
        repo.getRegionalSurcharge(region: 'pyeongtaek'),
      ]);

      return {'incheon': results[0], 'pyeongtaek': results[1]};
    });
