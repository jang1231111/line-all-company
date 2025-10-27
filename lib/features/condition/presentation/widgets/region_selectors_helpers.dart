part of 'region_selectors.dart';

List<String> withAll(List<String>? list) => ['전체', ...?list];

List<String> getSigungus(Map<String, List<String>> map, String? sido) =>
    sido != null && map.containsKey(sido) ? withAll(map[sido]) : ['전체'];

List<String> getEupmyeondongs(
  Map<String, List<String>> map,
  String? sido,
  String? sigungu,
) => (sido != null && sigungu != null)
    ? withAll(map['${sido}_$sigungu'])
    : ['전체'];

List<String> getBeopjeongdongs(
  Map<String, List<String>> map,
  String? sido,
  String? sigungu,
) => (sido != null && sigungu != null)
    ? withAll(map['${sido}_$sigungu'])
    : ['전체'];
