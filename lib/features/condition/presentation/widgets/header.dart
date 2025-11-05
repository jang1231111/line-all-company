// new extracted header widget
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Header extends StatelessWidget {
  final String title;
  final VoidCallback onReset;
  final IconData? leadingIcon;
  final TextStyle? titleStyle;

  const Header({
    required this.title,
    required this.onReset,
    this.leadingIcon,
    this.titleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: Colors.indigo[700], size: 28.sp),
              SizedBox(width: 10.w),
            ],
            Text(
              title,
              style: titleStyle ??
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.sp,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.06),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: onReset,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 22.sp, color: Colors.blue[700]),
                      SizedBox(width: 6.w),
                      Text(
                        '초기화',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF154E9C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
