import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart'; // Lottie 패키지 import
import 'package:line_all/features/condition/domain/models/regional_surcharge.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_surcharge_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/fare_result_row.dart';
import '../data/surcharge_options.dart';
import '../data/condition_options.dart'; // isPeriod2026, isAprilGuideline
import '../providers/fare_result_provider.dart';
import '../providers/condition_provider.dart';
import '../providers/regional_surcharge_provider.dart';

/// routes의 distance(km) 값으로 regional-surcharge 목록에서 정확히 일치하는 항목을 찾습니다.
/// distance_range는 범위가 아닌 정확한 거리(km) 정수값이므로 단순 일치 비교합니다.
/// (예: distance=37 → distanceRange=37인 항목 반환)
RegionalSurcharge? _findMatchingSurcharge(
  int distance,
  List<RegionalSurcharge> surcharges,
) {
  try {
    return surcharges.firstWhere((s) => s.distanceRange == distance);
  } catch (_) {
    // 일치하는 거리 구간이 없을 경우 null 반환
    return null;
  }
}

class FareResultTable extends ConsumerWidget {
  final GlobalKey? surchargeTargetKey;
  final GlobalKey? resultsTargetKey;

  const FareResultTable({
    super.key,
    this.surchargeTargetKey,
    this.resultsTargetKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(fareResultViewModelProvider);
    final condition = ref.watch(conditionViewModelProvider);
    final surchargeRate = condition.surchargeResult.rate; // 비율할증액
    final surchargeFixedAmount = condition.surchargeResult.fixedAmount; // 고정할증액
    final cancellationFeeAmount = condition.surchargeResult.cancellationFeeAmount;
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedFareNotifier = ref.read(selectedFareProvider.notifier);

    // 4월 운영지침 + 인천/평택 구간 여부
    // → 2월 운영지침에서는 지역 할증 동작 안 함
    final isAprilGuidelinePeriod = isAprilGuideline(condition.period);
    final section = condition.section ?? '';
    final type = condition.type ?? '';
    final isIncheonSection = incheonAreaSections.contains(section);
    final isPyeongtaekSection = pyeongtaekAreaSections.contains(section);
    final isAreaSection = isIncheonSection || isPyeongtaekSection;
    final isAreaSubtract = areaSubtractSections.contains(section);
    final isAreaAdd = areaAddSections.contains(section);

    // 지역 기점 배지 (4월 운영지침 + 인천/평택 구간일 때만 표시)
    final String? areaBadgeLabel = (isAprilGuidelinePeriod && isAreaSection)
        ? (isIncheonSection ? '인천 기점(20%)' : '평택 기점(20%)')
        : null;

    // regional-surcharge 데이터 (1회 fetch 후 캐시)
    final regionalSurchargeAsync = ref.watch(regionalSurchargeProvider);
    final regionalSurchargeMap = regionalSurchargeAsync.value ?? {};
    final regionKey = isIncheonSection
        ? 'incheon'
        : (isPyeongtaekSection ? 'pyeongtaek' : '');
    final regionalSurchargeList = regionKey.isNotEmpty
        ? (regionalSurchargeMap[regionKey] ?? <RegionalSurcharge>[])
        : <RegionalSurcharge>[];

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.indigo.shade900.withOpacity(0.2),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        child: resultsAsync.when(
          loading: () => SizedBox(
            height: 300.h,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              '오류가 발생했습니다.\n$err',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          data: (results) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명 텍스트 추가: 사용자 안내용
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              color: Colors.indigo,
                              size: 20.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '운임 계산 결과',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // 할증 버튼 + 지역 배지
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              key: surchargeTargetKey, // <-- key 전달
                              color: const Color(0xFFFFF3C2),
                              borderRadius: BorderRadius.circular(8.r),
                              child: InkWell(
                                splashColor: Colors.orange.withOpacity(0.1),
                                highlightColor: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const ConditionSurchargeDialog(),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.orange.shade100,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.h,
                                    horizontal: 4.w,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange[700],
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '할증 적용',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${(surchargeRate * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                          color: Color(0xFFD18A00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 지역 기점 배지 (인천/평택 구간 + 2026 기간)
                            if (areaBadgeLabel != null) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.indigo.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 12.sp,
                                      color: Colors.indigo.shade700,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      areaBadgeLabel,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.indigo.shade700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // COMBINE 토글 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'COMBINE 운송 (180%)',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Tooltip(
                          message: '동일화주 운송 시 컨테이너 가격의 180%가 적용됩니다.',
                          child: Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: Colors.indigo.shade300,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: condition.isCombine,
                            activeColor: Colors.indigo,
                            onChanged: (value) {
                              ref
                                  .read(conditionViewModelProvider.notifier)
                                  .update(
                                    condition.copyWith(isCombine: value),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '컨테이너 사이즈별 가격을 클릭하여 선택하세요.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 할증 정보 박스에 키 추가
              SizedBox(height: 5.h),
              Divider(height: 5.h, thickness: 2.5.w, color: Color(0xFFEAF0F6)),
              SizedBox(height: 4.h),

              if (results.isEmpty)
                // ...empty UI...
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  child: Center(
                    child: Container(
                      key: resultsTargetKey, // <-- 전체 결과 영역 키
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.indigo.shade50,
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.04),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            color: Colors.indigo.shade200,
                            size: 46.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(
                              color: Color(0xFF3A4374),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '조건을 다시 입력해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.indigo.shade200,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    key: resultsTargetKey, // <-- 전체 결과 영역 키
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, idx) {
                        final row = results[idx];
                        final combineMultiplier =
                            condition.isCombine ? 1.8 : 1.0;

                        // ─────────────────────────────────────────────
                        // 2026 기간 + 인천/평택 구간별 기본 운임 계산 분기
                        // ─────────────────────────────────────────────
                        int base20 = row.ft20;
                        int base40 = row.ft40;

                        if (isAprilGuidelinePeriod && isAreaSection) {
                          if (type == 'safe') {
                            // [안전위탁운임]: routes / 1.2 → 10의 자리 반올림
                            // (routes 값에 20%가 내포되어 있으므로 역산)
                            base20 = ((row.ft20 / 1.2) / 10).round() * 10;
                            base40 = ((row.ft40 / 1.2) / 10).round() * 10;
                          } else if (type == 'transport' ||
                              type == 'driver') {
                            // [안전운송/운수사업자]: regional-surcharge 매칭
                            final matched = _findMatchingSurcharge(
                              row.distance,
                              regionalSurchargeList,
                            );
                            if (matched != null) {
                              if (isAreaAdd) {
                                // distance 구간: base + regional_surcharge 추가
                                base20 =
                                    row.ft20 + matched.surchargePrice20ft;
                                base40 =
                                    row.ft40 + matched.surchargePrice40ft;
                              } else if (isAreaSubtract) {
                                // 일반 구간: routes - regional_surcharge 차감
                                base20 =
                                    row.ft20 - matched.surchargePrice20ft;
                                base40 =
                                    row.ft40 - matched.surchargePrice40ft;
                              }
                            }
                          }
                        }

                        final ft20WithSurcharge =
                            (((base20 *
                                            (1 + surchargeRate) *
                                            combineMultiplier) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount;
                        final ft40WithSurcharge =
                            (((base40 *
                                            (1 + surchargeRate) *
                                            combineMultiplier) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.2),
                              width: 1.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.03),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 10.w,
                            ),
                            child: FareResultRow(
                              row: row,
                              is20Selected: selectedFareNotifier.isSelected(
                                row,
                                FareType.ft20,
                              ),
                              is40Selected: selectedFareNotifier.isSelected(
                                row,
                                FareType.ft40,
                              ),
                              ft20WithSurcharge: ft20WithSurcharge,
                              ft40WithSurcharge: ft40WithSurcharge,
                              on20Tap: () {
                                final labels = List<String>.from(
                                  condition.surchargeResult.labels,
                                );
                                if (condition.isCombine) {
                                  labels.add('COMBINE 운송');
                                }
                                selectedFareNotifier.toggle(
                                  row: row,
                                  type: FareType.ft20,
                                  rate: condition.surchargeResult.rate,
                                  price: ft20WithSurcharge,
                                  surchargeLabels: labels,
                                );
                              },
                              on40Tap: () {
                                final labels = List<String>.from(
                                  condition.surchargeResult.labels,
                                );
                                if (condition.isCombine) {
                                  labels.add('COMBINE 운송');
                                }
                                selectedFareNotifier.toggle(
                                  row: row,
                                  type: FareType.ft40,
                                  rate: condition.surchargeResult.rate,
                                  price: ft40WithSurcharge,
                                  surchargeLabels: labels,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
