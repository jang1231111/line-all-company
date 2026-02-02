// extracted region selector rows
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/fare_result.dart';
import '../providers/fare_result_provider.dart';
import '../providers/region_provider.dart';

part 'region_selectors_helpers.dart'; // 헬퍼 함수 분리

class RegionSelectorsDialog extends ConsumerWidget {
  const RegionSelectorsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    final bool isSidoSelected =
        condition.sido != null && condition.sido != '시도 선택';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Material(
              color: const Color(0xFFF7F9FC),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 18.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 제목/설명/닫기
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(8.w),
                            child: Icon(
                              Icons.map_rounded,
                              color: Colors.indigo[700],
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '지역 검색',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.sp,
                                    color: Color(0xFF1C63D6),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '원하는 지역을 선택해 운임을 검색하세요.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black38,
                              size: 20.sp,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(height: 1, color: Color(0xFFE6EAF0)),
                      SizedBox(height: 18.h),

                      // 지역 선택자 컨테이너
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.08),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 18.h,
                          horizontal: 14.w,
                        ),
                        child: const RegionSelectors(),
                      ),

                      SizedBox(height: 18.h),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                textStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: Icon(Icons.close_rounded, size: 18.sp),
                              label: Text(
                                '닫기',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSidoSelected
                                    ? Colors.indigo[700]
                                    : Colors.grey.shade300,
                                foregroundColor: isSidoSelected
                                    ? Colors.white
                                    : Colors.black38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                textStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              icon: Icon(Icons.search_rounded, size: 18.sp),
                              label: Text(
                                '검색',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              onPressed: isSidoSelected
                                  ? () async {
                                      Navigator.of(context).pop('search');
                                      await viewModel.searchByRegion();
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
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
    final isSpecialPeriod = condition.period == '2026-01-01~2026-01-31';

    final regionAsync = ref.watch(regionHierarchyProvider);

    return regionAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          '지역 데이터 오류: $e',
          style: TextStyle(color: Colors.red, fontSize: 14.sp),
        ),
      ),
      data: (region) {
        // '시도' 목록은 항상 최상위 계층에서 가져옴
        final sidos = withLabel(region.sidos, '시도 선택');
        final isSidoSelected =
            condition.sido != null && condition.sido != '시도 선택';
        final isSigunguSelected =
            isSidoSelected &&
            condition.sigungu != null &&
            condition.sigungu != '시군구 선택';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 시도 드롭다운 (공통)
            DropdownField(
              initialValue: condition.sido ?? '시도 선택',
              items: sidos,
              hint: '시도',
              icon: Icons.map,
              style: TextStyle(fontSize: 16.sp),
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
              onChanged: (v) async {
                viewModel.update(
                  condition.copyWith(
                    sido: v == '시도 선택' ? null : v,
                    sigungu: null,
                    eupmyeondong: null,
                    beopjeongdong: null,
                  ),
                );
                await viewModel.searchOnSidoChange();
              },
            ),
            SizedBox(height: 12.h),

            // 2. 분기: 2026-02 vs 나머지
            if (isSpecialPeriod)
              _buildSpecialPeriodSelectors(
                context,
                ref,
                isSidoSelected,
                isSigunguSelected,
              )
            else
              _buildDefaultPeriodSelectors(
                context,
                ref,
                (
                  sidos: region.sidos,
                  sigungus: region.sigungus,
                  eupmyeondongs: region.eupmyeondongs,
                  beopjeongdongs: region.beopjeongdongs,
                ),
                isSidoSelected,
                isSigunguSelected,
              ),

            SizedBox(height: 8.h),
            if (!isSidoSelected)
              Text(
                '시도를 선택하면 시군구를 선택할 수 있습니다.',
                style: TextStyle(color: Colors.indigo, fontSize: 12.sp),
              )
            else if (!isSigunguSelected)
              Text(
                '시군구를 선택하면 읍면동${isSpecialPeriod ? '' : '/법정동'}을 선택할 수 있습니다.',
                style: TextStyle(color: Colors.indigo, fontSize: 12.sp),
              ),
          ],
        );
      },
    );
  }

  // 기본 기간(JSON 기반) 위젯 빌더
  Widget _buildDefaultPeriodSelectors(
    BuildContext context,
    WidgetRef ref,
    ({
      List<String> sidos,
      Map<String, List<String>> sigungus,
      Map<String, List<String>> eupmyeondongs,
      Map<String, List<String>> beopjeongdongs,
    })
    region,
    bool isSidoSelected,
    bool isSigunguSelected,
  ) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

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

    return Column(
      children: [
        DropdownField(
          initialValue: condition.sigungu ?? '시군구 선택',
          items: sigungus,
          hint: '시군구',
          icon: Icons.location_city,
          style: TextStyle(fontSize: 16.sp),
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
        SizedBox(height: 12.h),
        DropdownField(
          initialValue: condition.eupmyeondong ?? '읍면동 선택',
          items: eupmyeondongList,
          hint: '읍면동',
          icon: Icons.home_work,
          style: TextStyle(fontSize: 16.sp),
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
        SizedBox(height: 12.h),
        DropdownField(
          initialValue: condition.beopjeongdong ?? '법정동(행정동) 선택',
          items: beopjeongdongList,
          hint: '법정동(행정동)',
          icon: Icons.account_balance,
          style: TextStyle(fontSize: 16.sp),
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
          enabled: isSigunguSelected,
          onChanged: isSigunguSelected
              ? (v) async {
                  if (v == '법정동(행정동) 선택') {
                    viewModel.update(condition.copyWith(beopjeongdong: null));
                  } else {
                    String? newEupmyeondong = condition.eupmyeondong;
                    final match = RegExp(r'\(([^)]+)\)').firstMatch(v ?? '');
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
      ],
    );
  }

  // 특별 기간(2026-02, API 기반) 위젯 빌더
  Widget _buildSpecialPeriodSelectors(
    BuildContext context,
    WidgetRef ref,
    bool isSidoSelected,
    bool isSigunguSelected,
  ) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);
    final fareResultsAsync = ref.watch(fareResultViewModelProvider);

    // API 호출이 끝나지 않았으면 로딩/에러 처리
    if (fareResultsAsync.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: Text('2026년 운임표 로딩중...')),
      );
    }
    if (fareResultsAsync.hasError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          '2026년 운임표 오류: ${fareResultsAsync.error}',
          style: TextStyle(color: Colors.red, fontSize: 14.sp),
        ),
      );
    }
    final results = fareResultsAsync.value ?? [];
    // 선택된 시도/시군구에 맞춰 동적으로 필터링
    final sigungus = getSigungusFromResults(results, condition.sido);
    final eupmyeondongs = getEupmyeondongsFromResults(
      results,
      condition.sido,
      condition.sigungu,
    );

    return Column(
      children: [
        DropdownField(
          initialValue: condition.sigungu ?? '시군구 선택',
          items: sigungus,
          hint: '시군구',
          icon: Icons.location_city,
          style: TextStyle(fontSize: 16.sp),
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
          enabled: isSidoSelected,
          onChanged: isSidoSelected
              ? (v) async {
                  viewModel.update(
                    condition.copyWith(
                      sigungu: v == '시군구 선택' ? null : v,
                      eupmyeondong: null,
                      // beopjeongdong은 사용 안함
                    ),
                  );
                }
              : null,
        ),
        SizedBox(height: 12.h),
        DropdownField(
          initialValue: condition.eupmyeondong ?? '읍면동 선택',
          items: eupmyeondongs,
          hint: '읍면동',
          icon: Icons.home_work,
          style: TextStyle(fontSize: 16.sp),
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
          enabled: isSigunguSelected,
          onChanged: isSigunguSelected
              ? (v) async {
                  viewModel.update(
                    condition.copyWith(
                      eupmyeondong: v == '읍면동 선택' ? null : v,
                      // beopjeongdong은 사용 안함
                    ),
                  );
                }
              : null,
        ),
        // 2026-02의 경우 법정동 선택 안 함
      ],
    );
  }
}
