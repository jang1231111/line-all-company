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
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      backgroundColor: const Color(0xFFFFF6E0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3C2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '총 할증률',
                        style: TextStyle(
                          fontSize: 18.sp, // 축소
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF232323),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${(fare.rate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18.sp, // 축소
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD18A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // list
            if (labels.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: labels.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) {
                    final label = labels[i];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.orange.shade50),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 7.w,
                            height: 7.w,
                            margin: EdgeInsets.only(top: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14.sp, // 축소
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  '적용된 할증이 없습니다.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.black54), // 축소
                ),
              ),

            SizedBox(height: 12.h),

            // close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontSize: 14.sp, // 축소
                    fontWeight: FontWeight.w700,
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
