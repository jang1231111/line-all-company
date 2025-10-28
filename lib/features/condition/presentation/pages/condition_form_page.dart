import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/fare_result_table.dart';

import '../widgets/condition_form_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConditionFormPage extends ConsumerWidget {
  ConditionFormPage({super.key});

  // 예시: 임시 데이터
  final List<Map<String, dynamic>> dummyResults = [
    {
      '항구': '부산북항',
      '지역(시도)': '강원도',
      '지역(시군구)': '강릉시',
      '지역(읍면동)': '경포동',
      '거리(KM)': 369,
      '20FT(원)': '764,800',
      '40FT(원)': '866,400',
    },
    {
      '항구': '부산북항',
      '지역(시도)': '강원도',
      '지역(시군구)': '동해시',
      '지역(읍면동)': '북삼동',
      '거리(KM)': 317,
      '20FT(원)': '692,400',
      '40FT(원)': '775,400',
    },
    {
      '항구': '부산북항',
      '지역(시도)': '강원도',
      '지역(시군구)': '원주시',
      '지역(읍면동)': '문막읍',
      '거리(KM)': 348,
      '20FT(원)': '736,800',
      '40FT(원)': '830,800',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 72.h,
            titleSpacing: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.r),
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C63D6), Color(0xFF154E9C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
            title: Row(
              children: [
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '운임 계산기',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '신속하고 정확한 운임 산출',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
              SizedBox(width: 8.w),
            ],
          ),
          backgroundColor: const Color(0xFFF5F7FA),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 720.w) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ConditionFormWidget()),
                    SizedBox(width: 16),
                    // SizedBox(width: 380, child: ConditionSurchargePanel()),
                    FareResultTable(results: dummyResults),
                  ],
                );
              } else {
                return ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    ConditionFormWidget(),
                    SizedBox(height: 12),
                    // ConditionSurchargePanel(),
                    FareResultTable(results: dummyResults),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }
}
