import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/selected_fare_result_provider.dart';
import 'selected_fare_dialog.dart';

class SelectedFareBottomBar extends ConsumerWidget {
  final GlobalKey? confirmButtonKey; // 추가

  const SelectedFareBottomBar({super.key, this.confirmButtonKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedCount = selectedFares.length;

    return SafeArea(
      minimum: EdgeInsets.only(bottom: 12.h),
      child: BottomAppBar(
        elevation: 12,
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E7EF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF1C63D6),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '선택: $selectedCount건',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: ElevatedButton.icon(
                  key: confirmButtonKey, // 키 붙임
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C63D6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: selectedCount > 0
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => const SelectedFareDialog(),
                          );
                        }
                      : null,
                  icon: Icon(Icons.visibility, size: 20.sp),
                  label: Text('확인', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
