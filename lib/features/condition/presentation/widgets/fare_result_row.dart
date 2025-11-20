import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 반응형 패키지 추가

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
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        // ...decoration 생략...
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: Colors.teal, size: 22.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${row.sido}>${row.sigungu}>${row.eupmyeondong}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: FareSelectButton(
                    selected: is20Selected,
                    label: '20FT',
                    price: ft20WithSurcharge,
                    selectedColor: Colors.indigo[700]!,
                    unselectedColor: Colors.indigo[50]!,
                    onTap: on20Tap,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: FareSelectButton(
                    selected: is40Selected,
                    label: '40FT',
                    price: ft40WithSurcharge,
                    selectedColor: Colors.deepOrange,
                    unselectedColor: Colors.deepOrange[50]!,
                    onTap: on40Tap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FareSelectButton extends StatelessWidget {
  final bool selected;
  final String label;
  final int price;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const FareSelectButton({
    super.key,
    required this.selected,
    required this.label,
    required this.price,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? selectedColor : unselectedColor,
        foregroundColor: selected ? Colors.white : selectedColor,
        elevation: selected ? 4 : 0,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
      ),
      onPressed: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : selectedColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${NumberFormat('#,###').format(price)}원',
            style: TextStyle(
              color: selected ? Colors.white : selectedColor,
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}
