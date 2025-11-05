import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import '../providers/selected_fare_result_provider.dart';

class SelectedFareDialog extends ConsumerWidget {
  const SelectedFareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedFareViewModel = ref.read(selectedFareProvider.notifier);
    final totalPrice = selectedFares.fold<int>(
      0,
      (sum, fare) => sum + fare.price,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 28.w),
        child: SizedBox(
          width: 440.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.list_alt_rounded,
                    color: Colors.indigo,
                    size: 36.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '선택된 운임 목록',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D365C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (selectedFares.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 18.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 18.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      SizedBox(width: 10.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '총 합계: ',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              '${NumberFormat('#,###').format(totalPrice)}원',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 26.sp,
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Divider(height: 24.h, thickness: 1.4.w),
              if (selectedFares.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        color: Colors.indigo.shade100,
                        size: 64.sp,
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        '선택된 항목이 없습니다.',
                        style: TextStyle(
                          color: Color(0xFF6B7684),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: selectedFares.length,
                    separatorBuilder: (_, __) => Divider(height: 26.h),
                    itemBuilder: (context, idx) {
                      final fare = selectedFares[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 18.h,
                          horizontal: 18.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${fare.row.sido} > ${fare.row.sigungu} > ${fare.row.eupmyeondong}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: Color(0xFF2D365C),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fare.type == FareType.ft20
                                        ? Colors.indigo.shade100
                                        : Colors.deepOrange[50],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    fare.type == FareType.ft20
                                        ? '20FT'
                                        : '40FT',
                                    style: TextStyle(
                                      color: fare.type == FareType.ft20
                                          ? Colors.indigo.shade900
                                          : Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  '${NumberFormat('#,###').format(fare.price)}원',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ],
                            ),
                            if (fare.surchargeLabels.isNotEmpty) ...[
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 8.w,
                                children: fare.surchargeLabels
                                    .map(
                                      (label) => Chip(
                                        label: Text(
                                          label,
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        backgroundColor: Colors.blue[50],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Text(
                              '할증률: ${(fare.rate * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        elevation: 0,
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, size: 26.sp),
                      label: Text('닫기', style: TextStyle(fontSize: 20.sp)),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        await selectedFareViewModel.saveCurrentToDb();
                        selectedFareViewModel.clearState();
                        Navigator.of(context).pop('save');
                      },
                      icon: Icon(Icons.save_rounded, size: 26.sp),
                      label: Text('저장', style: TextStyle(fontSize: 20.sp)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
