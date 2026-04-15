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
    final cancellationFeeAmount =
        condition.surchargeResult.cancellationFeeAmount;
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
    final isOriginBaseSection = originBaseSections.contains(section);
    final isDistanceBaseSection = distanceBaseSections.contains(section);

    // 지역 기점 배지 (4월 운영지침 + 인천/평택 구간일 때만 표시)
    // 인천 20% / 평택 18% 는 areaAddon으로 포함되며, 배지는 정보성 표시용
    final String? areaBadgeLabel = (isAprilGuidelinePeriod && isAreaSection)
        ? (isIncheonSection ? '인천 기점(20%)' : '평택 기점(18%)')
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
          error: (err, stack) => Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBFF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.indigo.shade50),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.redAccent.shade200,
                    size: 38.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '네트워크 수신 오류',
                  style: TextStyle(
                    color: const Color(0xFF2D3748),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '네트워크 상태를 확인하고 잠시 후 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF718096),
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 28.h),
                ElevatedButton.icon(
                  onPressed: () {
                    // 제일 무난한 전체 다시 조회
                    ref
                        .read(conditionViewModelProvider.notifier)
                        .searchByRegion();
                  },
                  icon: Icon(Icons.refresh_rounded, size: 20.sp),
                  label: Text(
                    '결과 다시 불러오기',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 14.h,
                    ),
                    elevation: 0, // 플랫하고 모던한 느낌
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (results) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명 텍스트 추가: 사용자 안내용
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // 전체 중앙 정렬로 변경
                  children: [
                    // 1. 타이틀 + COMBINE 행
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 타이틀 파트
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
                        // COMBINE 파트
                        Row(
                          children: [
                            Text(
                              'COMBINE (180%)',
                              style: TextStyle(
                                fontSize: 13.sp, // 더 좁은 공간을 위해 약간 축소
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Tooltip(
                              message: '동일화주 운송 시 컨테이너 가격의 180%가 적용됩니다.',
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outline,
                                size: 14.sp,
                                color: Colors.indigo.shade300,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Transform.scale(
                              scale: 0.7, // 공간 확보를 위해 스케일 축소
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
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // 2. 할증 적용 버튼 + 지역 배지 행
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          key: surchargeTargetKey,
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
                                horizontal: 10.w,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange[700],
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 6.w),
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
                        // 지역 기점 배지
                        if (areaBadgeLabel != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14.sp,
                                  color: Colors.indigo.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  areaBadgeLabel,
                                  style: TextStyle(
                                    fontSize: 13.sp,
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
                    // 이전 3. COMBINE 토글 행 섹션 로직을 위 1번 타이틀 행 우측으로 통합했으므로 제거
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
                        final combineMultiplier = condition.isCombine
                            ? 1.8
                            : 1.0;

                        // 인천(1.2) / 평택(1.18) 역산율
                        final divRate = isIncheonSection
                            ? kIncheonDivRate
                            : kPyeongtaekDivRate;

                        // ─────────────────────────────────────────────────────
                        // 2026 4월 운영지침 × 인천/평택 구간 스위칭(Switching) 룰
                        //
                        // 1. 단독 모드: 타 할증 없이 인천/평택만 있을 때
                        //    -> 수학적 % 계산 무효화. 기점구간(routes), 거리구간(routes+regional) 사용
                        // 2. 혼합 모드: 타 할증(탱크 30% 등)이 추가되었을 때
                        //    -> regional 고정액 소멸. Base를 (routes-regional) 등 역산하여 Top-3 순수 % 계산
                        // ─────────────────────────────────────────────────────
                        int percentSurchargeBase20 = row.ft20;
                        int percentSurchargeBase40 = row.ft40;
                        int regionalFixedExtra20 = 0;
                        int regionalFixedExtra40 = 0;
                        double appliedSurchargeRate =
                            surchargeRate; // 실제 연산에 최종 곱해질 % 할증률

                        if (isAprilGuidelinePeriod && isAreaSection) {
                          // 인천(0.20) 또는 평택(0.18)만 단독으로 들어있는지 판단
                          // (Top-3 룰에 의해 타 할증이 붙으면 surchargeRate는 무조건 이 값보다 커짐)
                          final bool isOnlyRegionalRate =
                              (isIncheonSection &&
                                  (surchargeRate - 0.20).abs() < 0.001) ||
                              (isPyeongtaekSection &&
                                  (surchargeRate - 0.18).abs() < 0.001);

                          if (isOnlyRegionalRate) {
                            // [스위칭 룰 1] 단독 모드: 안전위탁, 안전운송, 운수 기점/거리 상관없이
                            // 무조건 공시 운임(routes)을 최종 기본값으로 사용
                            appliedSurchargeRate = 0.0;
                            percentSurchargeBase20 = row.ft20;
                            percentSurchargeBase40 = row.ft40;
                            regionalFixedExtra20 = 0;
                            regionalFixedExtra40 = 0;
                          } else {
                            // [스위칭 룰 2] 다른 할증 혼합 모드: 지역 고정액 소멸 및 새로운 Base 세팅
                            appliedSurchargeRate = surchargeRate;
                            regionalFixedExtra20 = 0;
                            regionalFixedExtra40 = 0;

                            if (type == 'safe') {
                              // 안전위탁: 모든 구간 역산(/1.2 후 반올림)으로 Base 산출
                              percentSurchargeBase20 =
                                  ((row.ft20 / divRate) / 10).round() * 10;
                              percentSurchargeBase40 =
                                  ((row.ft40 / divRate) / 10).round() * 10;
                            } else {
                              // 안전운송/운수: 모든 구간 (routes - regional)을 Base로 산출
                              final matched = _findMatchingSurcharge(
                                row.distance,
                                regionalSurchargeList,
                              );
                              if (matched != null) {
                                percentSurchargeBase20 =
                                    row.ft20 - matched.surchargePrice20ft;
                                percentSurchargeBase40 =
                                    row.ft40 - matched.surchargePrice40ft;
                              } else {
                                percentSurchargeBase20 = row.ft20;
                                percentSurchargeBase40 = row.ft40;
                              }
                            }
                          }
                        }

                        // 최종 가격 계산
                        // 공식: percentSurchargeBase × (1 + appliedSurchargeRate) × combineMultiplier × cancellationRate
                        //          + surchargeFixedAmount + regionalFixedExtra
                        // 참고: regionalFixedExtra는 단독 모드 거리구간에서만 발생
                        final ft20WithSurcharge =
                            (((percentSurchargeBase20 *
                                            (1 + appliedSurchargeRate) *
                                            combineMultiplier) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount +
                            regionalFixedExtra20; // 스위칭 룰에 따른 추가액
                        final ft40WithSurcharge =
                            (((percentSurchargeBase40 *
                                            (1 + appliedSurchargeRate) *
                                            combineMultiplier) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount +
                            regionalFixedExtra40;

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
                              isCombine: condition.isCombine,
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
