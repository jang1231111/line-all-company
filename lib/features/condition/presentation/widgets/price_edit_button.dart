import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'price_edit_dialog.dart';

/// 가격 수정 버튼(위젯 분리)
class PriceEditButton extends StatelessWidget {
  final int price;
  final int index;
  final NumberFormat priceFmt;
  final Future<void> Function(int index, int newPrice) onUpdate;

  const PriceEditButton({
    Key? key,
    required this.price,
    required this.index,
    required this.priceFmt,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final newPrice = await showDialog<int?>(
          context: context,
          builder: (ctx) => PriceEditDialog(initialPrice: price),
        );

        if (newPrice != null) {
          await onUpdate(index, newPrice);
        }
      },
      icon: Icon(
        Icons.edit,
        size: 16.sp,
        color: const Color(0xFF1C63D6),
      ),
      label: Text(
        '${priceFmt.format(price)}원',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey.shade50,
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
