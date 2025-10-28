part of 'region_selectors.dart';

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
