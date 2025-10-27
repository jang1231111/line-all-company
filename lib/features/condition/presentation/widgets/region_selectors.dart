// extracted region selector rows
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_form_widget.dart';

part 'region_selectors_helpers.dart'; // 헬퍼 함수 분리

class RegionSelectors extends ConsumerWidget {
  const RegionSelectors({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    final regionAsync = ref.watch(regionHierarchyProvider);

    return regionAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('지역 데이터 오류: $e'),
      data: (region) {
        final sidos = withAll(region.sidos);
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

        final isSidoSelected = condition.sido != null && condition.sido != '전체';
        final isSigunguSelected =
            isSidoSelected &&
            condition.sigungu != null &&
            condition.sigungu != '전체';

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownField(
                    initialValue: condition.sido ?? '전체',
                    items: sidos,
                    hint: '시도 선택',
                    icon: Icons.map,
                    onChanged: (v) {
                      viewModel.update(
                        condition.copyWith(
                          sido: v,
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
                    initialValue: condition.sigungu ?? '전체',
                    items: sigungus,
                    hint: '시군구 선택',
                    icon: Icons.location_city,
                    enabled: isSidoSelected, // 시도 선택 전엔 비활성화
                    onChanged: isSidoSelected
                        ? (v) {
                            viewModel.update(
                              condition.copyWith(
                                sigungu: v,
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
                    initialValue: condition.eupmyeondong ?? '전체',
                    items: eupmyeondongList.map((e) => e.toString()).toList(),
                    hint: '읍면동 선택',
                    icon: Icons.home_work,
                    enabled: isSigunguSelected, // 시군구 선택 전엔 비활성화
                    onChanged: isSigunguSelected
                        ? (v) => viewModel.update(
                            condition.copyWith(eupmyeondong: v),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownField(
                    initialValue: condition.beopjeongdong ?? '전체',
                    items: beopjeongdongList.map((e) => e.toString()).toList(),
                    hint: '법정동(행정동) 선택',
                    icon: Icons.account_balance,
                    enabled: isSigunguSelected, // 시군구 선택 전엔 비활성화
                    onChanged: isSigunguSelected
                        ? (v) {
                            String? newEupmyeondong = condition.eupmyeondong;
                            // 괄호 안 값 추출
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
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
