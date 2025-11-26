import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';

import '../../domain/models/fare_result.dart';

class FareResultRow extends StatelessWidget {
  final FareResult row;
  final bool is20Selected;
  final bool is40Selected;
  final int ft20WithSurcharge;
  final int ft40WithSurcharge;
  final VoidCallback on20Tap;
  final VoidCallback on40Tap;

  const FareResultRow({
    super.key,
    required this.row,
    required this.is20Selected,
    required this.is40Selected,
    required this.ft20WithSurcharge,
    required this.ft40WithSurcharge,
    required this.on20Tap,
    required this.on40Tap,
  });

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 아이콘 + 위치 + 거리
        Row(
          children: [
            Icon(
              Icons.local_shipping,
              color: Colors.indigo,
              size: 17.sp, // 아이콘 약간 확대
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                getSectionLabel(row.section),
                style: TextStyle(
                  fontSize: 16.sp, // 폰트 크기 +2
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Icon(Icons.route, size: 15.sp, color: Colors.black87),
                SizedBox(width: 2.w),
                Text(
                  '${row.distance}km',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // 서브 위치(작게)
        Row(
          children: [
            Icon(Icons.place, size: 18.sp, color: Colors.green.shade700),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '${row.sido} > ${row.sigungu} > ${row.eupmyeondong}',
                style: TextStyle(
                  fontSize: 18.sp, // +1 폰트
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // 가격 선택 버튼들 (20FT / 40FT)
        Row(
          children: [
            Expanded(
              child: _PricePill(
                label: '20FT',
                price: priceFmt.format(ft20WithSurcharge),
                selected: is20Selected,
                selectedColor: Colors.indigo.shade700,
                onTap: on20Tap,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _PricePill(
                label: '40FT',
                price: priceFmt.format(ft40WithSurcharge),
                selected: is40Selected,
                selectedColor: Colors.deepOrange.shade400,
                onTap: on40Tap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final String price;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _PricePill({
    required this.label,
    required this.price,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : selectedColor.withOpacity(0.18);
    final textColor = selected ? Colors.white : selectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 14.w,
        ), // 약간 여유증가
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? selectedColor.withOpacity(0.9)
                : Colors.transparent,
            width: selected ? 0 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 17.sp, // +1
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '$price원',
              style: TextStyle(
                fontSize: 18.sp, // +2
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
