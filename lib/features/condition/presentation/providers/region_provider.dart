import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';

/// API 기반 시도 목록 Provider
/// 기간과 구간 조건에 해당하는 시도 목록을 서버에서 조회합니다.
final sidoListApiProvider = FutureProvider.family<
  List<String>,
  ({String period, String section})
>((ref, arg) async {
  final repository = ref.watch(conditionRepositoryProvider);
  return await repository.fetchRegions(
    mode: 'sido',
    period: arg.period,
    section: arg.section,
  );
});

/// API 기반 시군구 목록 Provider
/// 선택한 시도에 해당하는 시군구 목록을 서버에서 동적으로 조회합니다.
final sigunguListApiProvider = FutureProvider.family<
  List<String>,
  ({String period, String section, String sido})
>((ref, arg) async {
  final repository = ref.watch(conditionRepositoryProvider);
  return await repository.fetchRegions(
    mode: 'sigungu',
    period: arg.period,
    section: arg.section,
    sido: arg.sido,
  );
});

/// API 기반 읍면동 목록 Provider
/// 선택한 시도 및 시군구에 해당하는 읍면동 목록을 서버에서 동적으로 조회합니다.
final eupmyeondongListApiProvider = FutureProvider.family<
  List<String>,
  ({String period, String section, String sido, String sigungu})
>((ref, arg) async {
  final repository = ref.watch(conditionRepositoryProvider);
  return await repository.fetchRegions(
    mode: 'eupmyeondong',
    period: arg.period,
    section: arg.section,
    sido: arg.sido,
    sigungu: arg.sigungu,
  );
});
