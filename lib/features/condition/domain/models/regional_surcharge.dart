/// [GET] /api/regional-surcharge 응답 데이터 모델
/// 인천/평택 지역의 거리별 할증 금액을 나타냅니다.
/// distance_range는 정확한 거리(km) 정수값입니다. (예: 37, 370, 371)
class RegionalSurcharge {
  final String regionName; // 'incheon' | 'pyeongtaek'
  final int distanceRange; // 거리(km) 정수값 - /api/routes의 distance와 직접 비교
  final int surchargePrice20ft; // 20FT 컨테이너 할증액 (원)
  final int surchargePrice40ft; // 40FT 컨테이너 할증액 (원)

  const RegionalSurcharge({
    required this.regionName,
    required this.distanceRange,
    required this.surchargePrice20ft,
    required this.surchargePrice40ft,
  });

  factory RegionalSurcharge.fromJson(Map<String, dynamic> json) {
    return RegionalSurcharge(
      regionName: json['region_name'] as String? ?? '',
      distanceRange: _toInt(json['distance_range']), // String "37" → int 37
      surchargePrice20ft: _toInt(json['surcharge_price_20ft']),
      surchargePrice40ft: _toInt(json['surcharge_price_40ft']),
    );
  }

  /// 다양한 타입의 값을 int로 안전하게 변환
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
