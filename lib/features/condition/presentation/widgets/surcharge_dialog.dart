import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';

class SurchargeDialog extends StatelessWidget {
  final SelectedFare fare;
  const SurchargeDialog({Key? key, required this.fare}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      ...List<String>.from(fare.surchargeLabels ?? <String>[]),
    ];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: const Color(0xFFFFF6E0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3C2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '총 할증률',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF232323),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '${(fare.rate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD18A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // list
            if (labels.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 320.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: labels.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final label = labels[i];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.orange.shade50),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(top: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Text(
                          //   '${_parsePercent(label).toStringAsFixed(0)}%',
                          //   style: TextStyle(
                          //     fontSize: 14.sp,
                          //     color: Colors.black54,
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: Text(
                  '적용된 할증이 없습니다.',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                ),
              ),

            SizedBox(height: 16.h),

            // close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용 예:
/// showDialog(context: context, builder: (_) => SurchargeDialog(fare: fare));
