import 'package:freezed_annotation/freezed_annotation.dart';

part 'road_name_address.freezed.dart';
part 'road_name_address.g.dart';

@freezed
abstract class RoadNameAddress with _$RoadNameAddress {
  const factory RoadNameAddress({
    String? detBdNmList, // 상세건물명 리스트
    required String emdNm, // 읍/면/동
    required String rn, // 도로명
    required String emdNo, // 읍면동일련번호
    required String siNm, // 시/도
    required String sggNm, // 시/군/구
    required String admCd, // 행정구역코드
    required String roadAddr, // 도로명 전체 주소
    required String lnbrMnnm, // 지번본번
    required String lnbrSlno, // 지번부번
    required String hstryYn, // 변경이력여부
    String? relJibun, // 관련지번
    required String bdKdcd, // 건물관리번호구분코드
    required String rnMgtSn, // 도로명코드
    String? liNm, // 리명
    required String bdMgtSn, // 건물관리번호
    required String engAddr, // 영문 주소
    required String zipNo, // 우편번호
    String? roadAddrPart2, // 도로명 주소(뒷부분)
    required String jibunAddr, // 지번 주소
    required String roadAddrPart1, // 도로명 주소(앞부분)
    String? bdNm, // 건물명
    required String udrtYn, // 지하여부
    String? hemdNm, // 행정동명
    required String buldMnnm, // 건물본번
    required String mtYn, // 산여부
    required String buldSlno, // 건물부번
  }) = _RoadNameAddress;

  factory RoadNameAddress.fromJson(Map<String, dynamic> json) =>
      _$RoadNameAddressFromJson(json);
}
