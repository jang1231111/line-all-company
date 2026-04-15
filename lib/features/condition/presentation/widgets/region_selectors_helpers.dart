part of 'region_selectors_dialog.dart';

// 각 드롭다운의 첫 번째 항목을 의미에 맞게 지정
List<String> withLabel(List<String>? list, String label) => [label, ...?list];

List<String> getSigungus(Map<String, List<String>> map, String? sido) =>
    sido != null && map.containsKey(sido) ? withLabel(map[sido], '시군구 선택') : ['시군구 선택'];

List<String> getEupmyeondongs(
  Map<String, List<String>> map,
  String? sido,
  String? sigungu,
) => (sido != null && sigungu != null)
    ? withLabel(map['${sido}_$sigungu'], '읍면동 선택')
    : ['읍면동 선택'];

List<String> getBeopjeongdongs(
  Map<String, List<String>> map,
  String? sido,
  String? sigungu,
) => (sido != null && sigungu != null)
    ? withLabel(map['${sido}_$sigungu'], '법정동 선택')
    : ['법정동 선택'];

// 2026년 특별 로직: API 결과(FareResult)에서 직접 목록 생성
List<String> getSigungusFromResults(List<FareResult> results, String? sido) {
  if (sido == null) return ['시군구 선택'];
  final sigungus = results
      .where((r) => r.sido == sido)
      .map((r) => r.sigungu)
      .toSet()
      .toList()
    ..sort();
  return withLabel(sigungus, '시군구 선택');
}

List<String> getEupmyeondongsFromResults(
    List<FareResult> results, String? sido, String? sigungu) {
  if (sido == null || sigungu == null) return ['읍면동 선택'];
  final eupmyeondongs = results
      .where((r) => r.sido == sido && r.sigungu == sigungu)
      .map((r) => r.eupmyeondong)
      .toSet()
      .toList()
    ..sort();
  return withLabel(eupmyeondongs, '읍면동 선택');
}
