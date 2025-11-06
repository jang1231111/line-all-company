import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import '../data/condition_options.dart';
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
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 700.w, // width 넓게 조정
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Row(
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
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D365C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            if (selectedFares.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Container(
                  margin: EdgeInsets.only(bottom: 5.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 18.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '총 합계',
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat('#,###').format(totalPrice)}원',
                            style: TextStyle(
                              fontSize: 28.sp,
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Divider(height: 15.h, thickness: 1.4.w),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: selectedFares.length,
                    separatorBuilder: (_, __) => SizedBox(height: 5.h),
                    itemBuilder: (context, idx) {
                      final fare = selectedFares[idx];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Colors.indigo.shade200,
                            width: 2.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 18.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    getSectionLabel(fare.row.section),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${fare.row.sido} > ${fare.row.sigungu} > ${fare.row.eupmyeondong}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: fare.type == FareType.ft20
                                          ? Colors.indigo.shade100
                                          : Colors.deepOrange[50],
                                      borderRadius: BorderRadius.circular(
                                        8.r,
                                      ),
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
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '할증률: ${(fare.rate * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              if (fare.surchargeLabels.isNotEmpty)
                                Wrap(
                                  spacing: 10.w,
                                  children: fare.surchargeLabels
                                      .map(
                                        (label) => Chip(
                                          label: Text(
                                            label,
                                            style: TextStyle(fontSize: 16.sp),
                                          ),
                                          backgroundColor: Colors.blue[50],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '운임비: ${NumberFormat('#,###').format(fare.price)}원',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.h),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
