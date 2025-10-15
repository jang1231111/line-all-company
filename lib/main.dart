import 'package:flutter/material.dart';
  
class _CustomFreightTable extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  const _CustomFreightTable({required this.results});

  @override
  Widget build(BuildContext context) {
    final columns = [
      '항구', '지역(시도)', '지역(시군구)', '지역(읍면동)', '거리(KM)', '20FT(원)', '40FT(원)'
    ];
    final data = results.isEmpty
        ? [
            {
              '항구': '-',
              '지역(시도)': '-',
              '지역(시군구)': '-',
              '지역(읍면동)': '-',
              '거리(KM)': '-',
              '20FT(원)': '-',
              '40FT(원)': '-',
              '20FT_할인전': null,
              '40FT_할인전': null,
              'bold': false,
            }
          ]
        : results;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(90),
          1: FixedColumnWidth(100),
          2: FixedColumnWidth(90),
          3: FixedColumnWidth(100),
          4: FixedColumnWidth(70),
          5: FixedColumnWidth(110),
          6: FixedColumnWidth(110),
        },
        border: TableBorder.symmetric(inside: BorderSide(color: Color(0xFFE3F0FF), width: 1)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // 헤더
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
            ),
            children: columns
                .map((col) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text(
                        col,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // 데이터 행
          ...List.generate(data.length, (i) {
            final row = data[i];
            final isEven = i % 2 == 0;
            final isBold = row['bold'] == true;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFF8FBFF) : Colors.white,
              ),
              children: [
                for (int c = 0; c < columns.length; c++)
                  _buildCell(
                    context,
                    columns[c],
                    row[columns[c]],
                    row,
                    isBold: isBold,
                    highlight: c == 5 || c == 6,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, String col, dynamic value, Map row, {bool isBold = false, bool highlight = false}) {
    if (col == '20FT(원)' || col == '40FT(원)') {
      final before = row['${col.split('(')[0]}_할인전'];
      final after = value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (before != null && before != after)
              Text(
                before.toString(),
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Container(
              decoration: highlight && after != '-' ? BoxDecoration(
                color: const Color(0xFFB6D0FF),
                borderRadius: BorderRadius.circular(8),
              ) : null,
              padding: highlight && after != '-' ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : EdgeInsets.zero,
              child: Text(
                after?.toString() ?? '-',
                style: TextStyle(
                  color: highlight && after != '-' ? const Color(0xFF2563EB) : const Color(0xFF222222),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 일반 셀
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        value?.toString() ?? '-',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold ? Colors.black : const Color(0xFF222222),
          fontSize: 15,
        ),
      ),
    );
  }
}

// 운임 계산 결과 커스텀 테이블 위젯 (사진 스타일)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '안전운임제 계산기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FF),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.blue.shade50,
          selectedColor: Colors.blue.shade200,
          labelStyle: const TextStyle(color: Colors.black),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const SafeFreightCalculatorPage(),
    );
  }
}

class SafeFreightCalculatorPage extends StatefulWidget {
  const SafeFreightCalculatorPage({super.key});

  @override
  State<SafeFreightCalculatorPage> createState() => _SafeFreightCalculatorPageState();
}

class _SafeFreightCalculatorPageState extends State<SafeFreightCalculatorPage> {
  // 입력값 변수들 (예시)
  String? period;
  String? type;
  String? section;
  String? searchQuery;
  String? region;
  List<String> selectedSurcharges = [];
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> selectedItems = [];

  // 할증 항목 예시
  final List<Map<String, String>> surchargeOptions = [
    {'label': '탱크 30%', 'value': 'tank'},
    {'label': '냉동·냉장 30%', 'value': 'cold'},
    {'label': '덤프 25%', 'value': 'dump'},
    {'label': '플렉시백 20%', 'value': 'flexi'},
    {'label': '헝오 및 오지 20%', 'value': 'remote'},
    {'label': '일요일 및 공휴일 20%', 'value': 'holiday'},
    {'label': '심야(22:00~06:00) 20%', 'value': 'night'},
  ];

  // 지역 검색용 변수 추가
  String? selectedSido;
  String? selectedSigungu;
  String? selectedEupmyeondong;
  String? selectedBeopjeongdong;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 조건/검색/결과
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 32, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 로고 및 타이틀
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 36,
                            errorBuilder: (_, __, ___) => const Icon(Icons.local_shipping, color: Color(0xFF2563EB), size: 32),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'LINE-ALL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF222222),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'GENERAIVE OPERATOR',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF2563EB),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // 운임 계산 조건 설정 카드
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.settings, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  const Text('운임 계산 조건 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: '기간',
                                        hintText: '2022년 07월 01일 ~ 12월 31일',
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '유형'),
                                      items: ['안전운송운임', '기타'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: type,
                                      onChanged: (v) => setState(() => type = v),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '구간'),
                                      items: ['인천신항기점(왕복)', '기타'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: section,
                                      onChanged: (v) => setState(() => section = v),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // 빠른 행선지 검색
                              TextField(
                                decoration: InputDecoration(
                                  labelText: '빠른 행선지 검색',
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: '예: 강남구, 역삼동, 법정동, 테헤란로...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F8FF),
                                ),
                                onChanged: (v) => setState(() => searchQuery = v),
                              ),
                              const SizedBox(height: 10),
                              // 지역 검색
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '시도 선택'),
                                      items: ['강원도', '경기도', '서울특별시'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: selectedSido,
                                      onChanged: (v) => setState(() => selectedSido = v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '시군구 선택'),
                                      items: ['동해시', '원주시', '춘천시'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: selectedSigungu,
                                      onChanged: (v) => setState(() => selectedSigungu = v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '읍면동 선택'),
                                      items: ['북삼동', '문막읍', '남산면'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: selectedEupmyeondong,
                                      onChanged: (v) => setState(() => selectedEupmyeondong = v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(labelText: '법정동(행정동) 선택'),
                                      items: ['북삼동', '문막읍', '남산면'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      value: selectedBeopjeongdong,
                                      onChanged: (v) => setState(() => selectedBeopjeongdong = v),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 운임 계산 결과 테이블
                      const Text('운임 계산 결과', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 8),
                      _CustomFreightTable(results: results),
                    ],
                  ),
                ),
              ),
              // 오른쪽: 할증 적용 및 견적서
              Container(
                width: 340,
                margin: const EdgeInsets.only(top: 32, right: 32, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 할증 적용 카드
                    Card(
                      color: const Color(0xFFFFF9E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBC02D)),
                                const SizedBox(width: 8),
                                const Text('할증 적용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFB28704))),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF3C1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '45.00%', // 실제 할증률 계산값으로 대체 가능
                                    style: const TextStyle(
                                      color: Color(0xFFF57C00),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('tank'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('tank');
                                      } else {
                                        selectedSurcharges.remove('tank');
                                      }
                                    });
                                  },
                                  title: const Text('탱크 30%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('cold'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('cold');
                                      } else {
                                        selectedSurcharges.remove('cold');
                                      }
                                    });
                                  },
                                  title: const Text('냉동·냉장 30%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('dump'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('dump');
                                      } else {
                                        selectedSurcharges.remove('dump');
                                      }
                                    });
                                  },
                                  title: const Text('덤프 25%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('flexi'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('flexi');
                                      } else {
                                        selectedSurcharges.remove('flexi');
                                      }
                                    });
                                  },
                                  title: const Text('플렉시백 20%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('remote'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('remote');
                                      } else {
                                        selectedSurcharges.remove('remote');
                                      }
                                    });
                                  },
                                  title: const Text('헝오 및 오지 20%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('holiday'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('holiday');
                                      } else {
                                        selectedSurcharges.remove('holiday');
                                      }
                                    });
                                  },
                                  title: const Text('일요일 및 공휴일 20%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: selectedSurcharges.contains('night'),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSurcharges.add('night');
                                      } else {
                                        selectedSurcharges.remove('night');
                                      }
                                    });
                                  },
                                  title: const Text('심야(22:00~06:00) 20%', style: TextStyle(color: Color(0xFFB28704), fontWeight: FontWeight.w600)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Color(0xFFFBC02D),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: '위험물 종류',
                                      filled: true,
                                      fillColor: Color(0xFFFFF3C1),
                                    ),
                                    items: ['없음', '중량물 할증', '위험물 할증', '기타'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                    value: null,
                                    onChanged: (v) {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: '할대품 할증',
                                      filled: true,
                                      fillColor: Color(0xFFFFF3C1),
                                    ),
                                    items: ['없음', '배차 취소료', '기타'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                    value: null,
                                    onChanged: (v) {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 견적서 생성하기 버튼 (오른쪽 상단 고정)
          Positioned(
            top: 18,
            right: 38,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    const Text('견적서 생성하기', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 16)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${selectedItems.length}건 선택됨',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}