// extracted region selector rows
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/widgets/dropdown_field.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/region_provider.dart';

part 'region_selectors_helpers.dart'; // 헬퍼 함수 분리

class RegionSelectorsDialog extends ConsumerWidget {
  const RegionSelectorsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: const Color(0xFFF5F7FA),
      child: SizedBox(
        width: 520.w,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
          child: SingleChildScrollView( // 추가!
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 제목/설명/닫기디
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: Colors.indigo[700],
                      size: 36.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '지역 검색',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp, // 폰트 크게 + 반응형
                              color: Color(0xFF1C63D6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.close, color: Colors.black38, size: 28.sp),
                    //   onPressed: () => Navigator.of(context).pop(),
                    // ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(height: 1, color: Color(0xFFE0E0E0)),
                SizedBox(height: 22.h),
                // 지역 선택자
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.06),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                    border: Border.all(color: Colors.indigo.shade50),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 18.w),
                  child: const RegionSelectors(),
                ),
                SizedBox(height: 28.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.close_rounded, size: 24.sp),
                        label: Text('닫기', style: TextStyle(fontSize: 20.sp)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          textStyle: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.search_rounded, size: 24.sp),
                        label: Text('검색', style: TextStyle(fontSize: 20.sp)),
                        onPressed: () async {
                          Navigator.of(context).pop('search');
                          await viewModel.searchByRegion();
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
    final regionAsync = ref.watch(regionHierarchyProvider);

    return regionAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text(
          '지역 데이터 오류: $e',
          style: TextStyle(color: Colors.red, fontSize: 18.sp),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownField(
              initialValue: condition.sido ?? '시도 선택',
              items: sidos,
              hint: '시도',
              icon: Icons.map,
              style: TextStyle(fontSize: 22.sp),
              hintStyle: TextStyle(fontSize: 22.sp, color: Colors.grey),
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
            SizedBox(height: 16.h),
            DropdownField(
              initialValue: condition.sigungu ?? '시군구 선택',
              items: sigungus,
              hint: '시군구',
              icon: Icons.location_city,
              style: TextStyle(fontSize: 22.sp),
              hintStyle: TextStyle(fontSize: 22.sp, color: Colors.grey),
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
            SizedBox(height: 16.h),
            DropdownField(
              initialValue: condition.eupmyeondong ?? '읍면동 선택',
              items: eupmyeondongList.map((e) => e.toString()).toList(),
              hint: '읍면동',
              icon: Icons.home_work,
              style: TextStyle(fontSize: 22.sp),
              hintStyle: TextStyle(fontSize: 22.sp, color: Colors.grey),
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
            SizedBox(height: 16.h),
            DropdownField(
              initialValue: condition.beopjeongdong ?? '법정동(행정동) 선택',
              items: beopjeongdongList.map((e) => e.toString()).toList(),
              hint: '법정동(행정동)',
              icon: Icons.account_balance,
              style: TextStyle(fontSize: 22.sp),
              hintStyle: TextStyle(fontSize: 22.sp, color: Colors.grey),
              enabled: isSigunguSelected,
              onChanged: isSigunguSelected
                  ? (v) async {
                      if (v == '법정동(행정동) 선택') {
                        viewModel.update(
                          condition.copyWith(beopjeongdong: null),
                        );
                      } else {
                        String? newEupmyeondong = condition.eupmyeondong;
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
            SizedBox(height: 12.h),
            if (!isSidoSelected)
              Text(
                '시도를 선택하면 시군구을 선택할 수 있습니다.',
                style: TextStyle(color: Colors.indigo, fontSize: 18.sp),
              )
            else if (!isSigunguSelected)
              Text(
                '시군구를 선택하면 읍면동/법정동을 선택할 수 있습니다.',
                style: TextStyle(color: Colors.indigo, fontSize: 18.sp),
              ),
          ],
        );
      },
    );
  }
}
