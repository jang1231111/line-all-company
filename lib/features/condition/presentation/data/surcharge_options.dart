// 2026-02 특별 할증 옵션 (라벨+rate)
const surcharge2026Options = [
  CheckboxOption(id: 'danger-30', label: '위험물,유해화학물질 30%', rate: 0.3),
  CheckboxOption(id: 'tank', label: '탱크 30%', rate: 0.3),
  CheckboxOption(id: 'refrigerated', label: '냉동·냉장 30%', rate: 0.3),
  CheckboxOption(id: 'rough', label: '험로 및 오지 20%', rate: 0.2),
  CheckboxOption(id: 'container45ft', label: '45ft 컨테이너 12.5%', rate: 0.125),
  CheckboxOption(id: 'dump', label: '덤프 25%', rate: 0.25),
  CheckboxOption(id: 'restricted', label: '통행제한 30%', rate: 0.3),
  CheckboxOption(id: 'liquid', label: '플렉시백 컨테이너(액체) 20%', rate: 0.2),
  CheckboxOption(id: 'powder', label: '플렉시백 컨테이너(분말) 10%', rate: 0.1),
  CheckboxOption(id: 'holiday', label: '일요일 및 공휴일 20%', rate: 0.2),
  CheckboxOption(id: 'night', label: '심야(22:00~06:00) 20%', rate: 0.2),
  CheckboxOption(
    id: 'xray',
    label: 'X-RAY 통과 비용 : 100,000원',
    rate: null,
    isFixed: true,
  ),
  CheckboxOption(
    id: 'incheon',
    label: '인천터미널 반납 편도 추가 : 40,000원',
    rate: null,
    isFixed: true,
  ),
  // 지역 기점 할증 - 자동 적용 (UI 체크박스에 미표시)
  CheckboxOption(id: 'incheon_area', label: '인천 기점 20%', rate: 0.2),
  CheckboxOption(id: 'pyeongtaek_area', label: '평택 기점 18%', rate: 0.18),
];

class SurchargeDropdownOption {
  final String value;
  final String label;
  final bool disabled;
  final double? rate;

  const SurchargeDropdownOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.rate,
  });
}

class CheckboxOption {
  final String id;
  final String label;
  final double? rate;
  final bool isFixed;
  final bool isDivider;
  final bool disabled;

  const CheckboxOption({
    required this.id,
    required this.label,
    this.rate,
    this.isFixed = false,
    this.isDivider = false,
    this.disabled = false,
  });
}

// 체크박스 옵션들 (할증률 포함)
const surchargeCheckboxOptions = [
  CheckboxOption(id: 'tank', label: '탱크 30%', rate: 0.3),
  CheckboxOption(id: 'refrigerated', label: '냉동‧냉장 30%', rate: 0.3),
  // CheckboxOption(id: 'dump', label: '덤프 25%', rate: 0.25),
  // CheckboxOption(id: 'container45ft', label: '45FT 컨테이너 12.5%', rate: 0.125),
  // CheckboxOption(id: 'divider', label: 'divider', isDivider: true),
  // CheckboxOption(id: 'weekday', label: '주간통행제한지역 30%', rate: 0.3),
  // CheckboxOption(id: 'bulk', label: '험로 및 오지 20%', rate: 0.2),
  CheckboxOption(id: 'holiday', label: '일요일 및 공휴일 20%', rate: 0.2),
  CheckboxOption(id: 'night', label: '심야(22:00~06:00) 20%', rate: 0.2),
  CheckboxOption(id: 'flexibag', label: '플렉시백 20%', rate: 0.2),
  CheckboxOption(id: 'danger-30', label: '위험물,유해화학물질 30%', rate: 0.3),
  // CheckboxOption(id: 'xray', label: '검색대(X-ray) 통과 96,000원', rate: 96000, isFixed: true),
  // CheckboxOption(id: 'divider2', label: 'divider', isDivider: true),
];

// 중량물 할증 드롭다운
const weightTypeOptions = [
  SurchargeDropdownOption(value: '', label: '중량물 할증'),
  SurchargeDropdownOption(value: 'over1t', label: '1톤 초과 10%', rate: 0.1),
  SurchargeDropdownOption(value: 'over2t', label: '2톤 초과 20%', rate: 0.2),
  SurchargeDropdownOption(value: 'over3t', label: '3톤 초과 30%', rate: 0.3),
  SurchargeDropdownOption(value: 'over4t', label: '4톤 초과 40%', rate: 0.4),
  SurchargeDropdownOption(value: 'over5t', label: '5톤 초과 50%', rate: 0.5),
  SurchargeDropdownOption(value: 'over6t', label: '6톤 초과 60%', rate: 0.6),
  SurchargeDropdownOption(value: 'over7t', label: '7톤 초과 70%', rate: 0.7),
  SurchargeDropdownOption(value: 'over8t', label: '8톤 초과 80%', rate: 0.8),
  SurchargeDropdownOption(value: 'over9t', label: '9톤 초과 90%', rate: 0.9),
];

// 위험물 종류 드롭다운
// const dangerTypeOptions = [
//   SurchargeDropdownOption(value: '', label: '위험물 종류'),
//   SurchargeDropdownOption(
//     value: 'danger-30',
//     label: '위험물,유독물,유해화학물질 30%',
//     rate: 0.3,
//   ),
//   SurchargeDropdownOption(value: 'explosive-100', label: '화약류 100%', rate: 1.0),
//   SurchargeDropdownOption(
//     value: 'radioactive-200',
//     label: '방사성물질 200%',
//     rate: 2.0,
//   ),
// ];

// 활대품 할증 드롭다운
// const specialTypeOptions = [
//   SurchargeDropdownOption(value: '', label: '활대품 할증'),
//   SurchargeDropdownOption(value: 'over10cm', label: '10cm 초과 10%', rate: 0.1),
//   SurchargeDropdownOption(value: 'over20cm', label: '20cm 초과 20%', rate: 0.2),
//   SurchargeDropdownOption(value: 'over30cm', label: '30cm 초과 30%', rate: 0.3),
//   SurchargeDropdownOption(value: 'over40cm', label: '40cm 초과 40%', rate: 0.4),
//   SurchargeDropdownOption(value: 'over50cm', label: '50cm 초과 50%', rate: 0.5),
// ];

// 배차 취소료 드롭다운
const cancellationFeeOptions = [
  SurchargeDropdownOption(value: '', label: '배차 취소료'),
  SurchargeDropdownOption(
    value: 'waiting1h',
    label: '상차 현장 대기 1시간 50%',
    rate: 0.5,
  ),
  SurchargeDropdownOption(value: 'moving', label: '상차 후 이동중 70%', rate: 0.7),
  SurchargeDropdownOption(value: 'arrived', label: '행선지 도착 후 100%', rate: 1.0),
  SurchargeDropdownOption(
    value: 'completed',
    label: '작업 완료 후 이동중 회차 및 재작업 200%',
    rate: 2.0,
  ),
];

// ============================================================
// 지역 기점 할증 관련 상수 (인천/평택 구간)
// ============================================================

/// 인천 기점 할증 역산율 (routes = net × 1.2 → net = routes / 1.2)
const kIncheonDivRate = 1.2;

/// 평택 기점 할증 역산율 (routes = net × 1.18 → net = routes / 1.18)
const kPyeongtaekDivRate = 1.18;

/// 인천 관련 구간 목록 (areaSubtract + areaAdd 모두 포함)
const incheonAreaSections = [
  'incheon',
  'incheon-new',
  'incheon-intl',
  'distance-incheon',
];

/// 평택 관련 구간 목록 (areaSubtract + areaAdd 모두 포함)
const pyeongtaekAreaSections = ['pyeongtaek', 'distance-pyeongtaek'];

/// regional-surcharge 요금을 routes 값에서 차감하는 기점 구간
/// (routes에 인천/평택 할증이 내포되어 있으므로 차감 후 기본값 산출)
const originBaseSections = ['incheon', 'incheon-new', 'incheon-intl', 'pyeongtaek'];

/// regional-surcharge 요금을 distance base에 더하는 거리별 구간
/// (distance 운임에는 인천/평택 할증 미포함 → 별도 가산)
const distanceBaseSections = ['distance-incheon', 'distance-pyeongtaek'];

/// 구간 코드를 regional-surcharge 지역명으로 변환
/// 반환: 'incheon' | 'pyeongtaek' | ''
String regionForSection(String section) {
  if (incheonAreaSections.contains(section)) return 'incheon';
  if (pyeongtaekAreaSections.contains(section)) return 'pyeongtaek';
  return '';
}
