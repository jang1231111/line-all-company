// 운임 조건 관련 드롭다운 옵션 정의

/// 드롭다운 옵션 클래스
class DropdownOption {
  final String value;
  final String label;
  final bool disabled;

  const DropdownOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
}

// 드롭다운 옵션들
const periodOptions = [
  DropdownOption(value: '', label: '기간 (필수 선택)'),
  DropdownOption(
    value: '2022-07-01~2022-12-31',
    label: '2022년 07월 (07월 01일 ~ 12월 31일)',
  ),
  DropdownOption(
    value: '2022-04-01~2022-06-30',
    label: '2022년 04월 (04월 01일 ~ 06월 30일)',
  ),
  DropdownOption(
    value: '2022-02-18~2022-03-31',
    label: '2022년 02월 (02월 18일 ~ 03월 31일)',
  ),
  DropdownOption(
    value: '2021-12-01~2022-02-17',
    label: '2021년 12월 (12월 01일 ~ 02월 17일)',
  ),
  DropdownOption(
    value: '2021-09-01~2021-11-30',
    label: '2021년 09월 (09월 01일 ~ 11월 30일)',
  ),
  DropdownOption(
    value: '2021-06-01~2021-08-31',
    label: '2021년 06월 (06월 01일 ~ 08월 31일)',
  ),
  DropdownOption(
    value: '2021-01-01~2021-05-31',
    label: '2021년 01월 (01월 01일 ~ 05월 31일)',
  ),
];

const typeOptions = [
  DropdownOption(value: '', label: '유형 (필수 선택)'),
  DropdownOption(value: 'transport', label: '안전운송운임'),
  DropdownOption(value: 'driver', label: '운수사업자간운임'),
  DropdownOption(value: 'safe', label: '안전위탁운임'),
];

const sectionOptions = [
  DropdownOption(value: '', label: '구간 (필수 선택)'),
  DropdownOption(value: '', label: '(왕복-기점별)', disabled: true),
  DropdownOption(value: 'busan-north', label: '부산북항기점(왕복)'),
  DropdownOption(value: 'busan-new', label: '부산신항기점(왕복)'),
  DropdownOption(value: 'incheon', label: '인천항기점(왕복)'),
  DropdownOption(value: 'incheon-new', label: '인천신항기점(왕복)'),
  DropdownOption(value: 'incheon-intl', label: '인천항국제여객터미널기점(왕복)'),
  DropdownOption(value: 'gwangyang', label: '광양항기점(왕복)'),
  DropdownOption(value: 'pyeongtaek', label: '평택항기점(왕복)'),
  DropdownOption(value: 'ulsan-old', label: '울산구항기점(왕복)'),
  DropdownOption(value: 'ulsan-new', label: '울산신항기점(왕복)'),
  DropdownOption(value: 'pohang', label: '포항항기점(왕복)'),
  DropdownOption(value: 'gunsan', label: '군산항기점(왕복)'),
  DropdownOption(value: 'masan', label: '마산항기점(왕복)'),
  DropdownOption(value: 'daesan', label: '대산항기점(왕복)'),
  DropdownOption(value: 'uiwang', label: '의왕ICD기점(왕복)'),
  DropdownOption(value: '', label: '(왕복-거리별)', disabled: true),
  DropdownOption(value: 'distance', label: '거리(KM)별 운임(왕복)'),
  DropdownOption(value: 'distance-incheon', label: '거리(KM)별-인천지역(왕복)'),
  DropdownOption(value: 'distance-pyeongtaek', label: '거리(KM)별-평택지역(왕복)'),
  DropdownOption(value: '', label: '(편도)', disabled: true),
  DropdownOption(
    value: 'busan-north-oneway',
    label: '부산북항기점(편도, 공컨테이너 장치장: 의왕ICD)',
  ),
  DropdownOption(
    value: 'busan-new-oneway',
    label: '부산신항기점(편도, 공컨테이너 장치장: 의왕ICD)',
  ),
  DropdownOption(
    value: 'gwangyang-oneway',
    label: '광양항기점(편도, 공컨테이너 장치장: 의왕ICD)',
  ),
];

/// 시도 리스트 (destination_hierarchy.json 참고)
const sidoOptions = [
  '서울특별시',
  '부산광역시',
  '대구광역시',
  '인천광역시',
  '광주광역시',
  '대전광역시',
  '울산광역시',
  '경기도',
  '강원도',
  '충청북도',
  '충청남도',
  '전라북도',
  '전라남도',
  '경상북도',
  '경상남도',
  '세종특별자치시',
];

// 시군구, 읍면동, 법정동 등은 json에서 동적으로 파싱해서 사용 권장

// section label 가져오기 함수
String getSectionLabel(String value) {
  final option = sectionOptions.firstWhere(
    (opt) => opt.value == value,
    orElse: () => const DropdownOption(value: '', label: '알 수 없음'),
  );
  return option.label;
}
