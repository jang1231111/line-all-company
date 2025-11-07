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
  const FareResultTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(fareResultViewModelProvider);
    final condition = ref.watch(conditionViewModelProvider);
    final surchargeRate = condition.surchargeResult.rate;
    final cancellationFeeAmount =
        condition.surchargeResult.cancellationFeeAmount;
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedFareNotifier = ref.read(selectedFareProvider.notifier);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.indigo.shade100, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 18.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: resultsAsync.when(
          loading: () => SizedBox(
            height: 300.h,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
              // Lottie.asset(
              //   'lib/assets/loading.json',
              //   width: 120.w,
              //   height: 120.h,
              //   fit: BoxFit.contain,
              // ),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              '오류가 발생했습니다.\n$err',
              style: TextStyle(fontSize: 20.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          data: (results) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 할증 정보 미니 컨테이너
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: const Color(0xFFFFF3C2),
                    borderRadius: BorderRadius.circular(10.r),
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
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.orange.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.06),
                              blurRadius: 4.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange[700],
                                  size: 32.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  '할증 적용 ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '${(surchargeRate * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: Color(0xFFD18A00),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24.h, thickness: 3.w, color: Color(0xFFE0E7EF)),
              if (results.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.indigo.shade100,
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.07),
                            blurRadius: 16.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            color: Colors.indigo.shade300,
                            size: 54.sp,
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(
                              color: Color(0xFF3A4374),
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '조건을 다시 입력해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.indigo.shade200,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, idx) {
                      final row = results[idx];
                      final ft20WithSurcharge =
                          ((row.ft20Safe * (1 + surchargeRate)) *
                                  cancellationFeeAmount /
                                  100)
                              .round() *
                          100;
                      final ft40WithSurcharge =
                          ((row.ft40Safe * (1 + surchargeRate)) *
                                  cancellationFeeAmount /
                                  100)
                              .round() *
                          100;

                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.indigo.shade100,
                            width: 1.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.06),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 12.w,
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
            ],
          ),
        ),
      ),
    );
  }
}
