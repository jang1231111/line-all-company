import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchTypeSelectorRow extends ConsumerWidget {
  final VoidCallback onRegionSearch;
  final VoidCallback onRoadNameSearch;
  const SearchTypeSelectorRow({
    super.key,
    required this.onRegionSearch,
    required this.onRoadNameSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFB4C8F7), width: 1.2.w),
          ),
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              // 빠른 행선지 검색 카드
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C63D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 14.w,
                            ),
                            minimumSize: Size(0, 40.h),
                          ),
                          icon: Icon(Icons.search, size: 22.sp),
                          label: Text(
                            '지역 검색',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          onPressed: onRegionSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 세로 구분선
              Container(
                width: 1.2.w,
                height: 70.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: const Color(0xFFB4C8F7),
              ),
              // 도로명 검색 카드
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6EA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BAF5D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          icon: Icon(Icons.location_on, size: 22.sp),
                          label: Text(
                            '도로명 검색',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          onPressed: onRoadNameSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
