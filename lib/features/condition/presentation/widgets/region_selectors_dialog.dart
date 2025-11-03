// extracted region selector rows
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';

import '../providers/region_provider.dart';

part 'region_selectors_helpers.dart'; // 헬퍼 함수 분리

class RegionSelectorsDialog extends StatelessWidget {
  const RegionSelectorsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목/설명/닫기
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.map, color: Colors.indigo[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '지역 선택',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1C63D6),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '지역별로 행선지를 선택하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5B7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black38),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 18),
              // 지역 선택자
              RegionSelectors(),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegionSelectors extends ConsumerWidget {
  const RegionSelectors({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    final regionAsync = ref.watch(regionHierarchyProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 & 안내문구
          // Row(
          //   children: [
          //     Icon(Icons.map, color: Colors.blue[700], size: 18),
          //     const SizedBox(width: 6),
          //     const Text(
          //       '지역 검색',
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 15,
          //         color: Color(0xFF154E9C),
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //   ],
          // ),
          // const Text(
          //   '※ 고시지역 외 구간은 법정동 선택',
          //   style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          // ),
          // const SizedBox(height: 10),
          regionAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                '지역 데이터 오류: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (region) {
              final sidos = withLabel(region.sidos, '시도 선택');
              final sigungus = getSigungus(region.sigungus, condition.sido);
              final eupmyeondongList = getEupmyeondongs(
                region.eupmyeondongs,
                condition.sido,
                condition.sigungu,
              );
              final beopjeongdongList = getBeopjeongdongs(
                region.beopjeongdongs,
                condition.sido,
                condition.sigungu,
              );

              final isSidoSelected =
                  condition.sido != null && condition.sido != '시도 선택';
              final isSigunguSelected =
                  isSidoSelected &&
                  condition.sigungu != null &&
                  condition.sigungu != '시군구 선택';

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownField(
                          initialValue: condition.sido ?? '시도 선택',
                          items: sidos,
                          hint: '시도 선택',
                          icon: Icons.map,
                          onChanged: (v) async {
                            viewModel.update(
                              condition.copyWith(
                                sido: v == '시도 선택' ? null : v,
                                sigungu: null,
                                eupmyeondong: null,
                                beopjeongdong: null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownField(
                          initialValue: condition.sigungu ?? '시군구 선택',
                          items: sigungus,
                          hint: '시군구 선택',
                          icon: Icons.location_city,
                          enabled: isSidoSelected,
                          onChanged: isSidoSelected
                              ? (v) async {
                                  viewModel.update(
                                    condition.copyWith(
                                      sigungu: v == '시군구 선택' ? null : v,
                                      eupmyeondong: null,
                                      beopjeongdong: null,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownField(
                          initialValue: condition.eupmyeondong ?? '읍면동 선택',
                          items: eupmyeondongList
                              .map((e) => e.toString())
                              .toList(),
                          hint: '읍면동 선택',
                          icon: Icons.home_work,
                          enabled: isSigunguSelected,
                          onChanged: isSigunguSelected
                              ? (v) async {
                                  viewModel.update(
                                    condition.copyWith(
                                      eupmyeondong: v == '읍면동 선택' ? null : v,
                                      beopjeongdong: null,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownField(
                          initialValue:
                              condition.beopjeongdong ?? '법정동(행정동) 선택',
                          items: beopjeongdongList
                              .map((e) => e.toString())
                              .toList(),
                          hint: '법정동(행정동) 선택',
                          icon: Icons.account_balance,
                          enabled: isSigunguSelected,
                          onChanged: isSigunguSelected
                              ? (v) async {
                                  if (v == '법정동(행정동) 선택') {
                                    viewModel.update(
                                      condition.copyWith(
                                        beopjeongdong: null,
                                        // eupmyeondong은 기존값 유지
                                      ),
                                    );
                                  } else {
                                    String? newEupmyeondong =
                                        condition.eupmyeondong;
                                    final match = RegExp(
                                      r'\(([^)]+)\)',
                                    ).firstMatch(v ?? '');
                                    if (match != null) {
                                      newEupmyeondong = match.group(1);
                                    }
                                    viewModel.update(
                                      condition.copyWith(
                                        beopjeongdong: v,
                                        eupmyeondong: newEupmyeondong,
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
