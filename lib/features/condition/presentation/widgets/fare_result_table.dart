import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart'; // Lottie 패키지 import
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_surcharge_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/fare_result_row.dart';
import '../providers/fare_result_provider.dart';
import '../providers/condition_provider.dart';

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
                          ],
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
                        final ft20WithSurcharge =
                            (((row.ft20 * (1 + surchargeRate)) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount;
                        final ft40WithSurcharge =
                            (((row.ft40 * (1 + surchargeRate)) *
                                        cancellationFeeAmount /
                                        100)
                                    .round() *
                                100) +
                            surchargeFixedAmount;
                        100;

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
                                selectedFareNotifier.toggle(
                                  row: row,
                                  type: FareType.ft20,
                                  rate: condition.surchargeResult.rate,
                                  price: ft20WithSurcharge,
                                  surchargeLabels: List<String>.from(
                                    condition.surchargeResult.labels,
                                  ),
                                );
                              },
                              on40Tap: () {
                                selectedFareNotifier.toggle(
                                  row: row,
                                  type: FareType.ft40,
                                  rate: condition.surchargeResult.rate,
                                  price: ft40WithSurcharge,
                                  surchargeLabels: List<String>.from(
                                    condition.surchargeResult.labels,
                                  ),
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
