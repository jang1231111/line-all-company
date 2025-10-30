import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/fare_result_table.dart';

import '../widgets/condition_form_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConditionFormPage extends ConsumerWidget {
  const ConditionFormPage({super.key});

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
                      '안전 위탁 운임-차주용',
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
                    Expanded(child: FareResultTable()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(3.w),
                        children: [
                          ConditionFormWidget(),
                          SizedBox(height: 12),
                          // ConditionSurchargePanel(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: FareResultTable(),
                      ),
                    ),
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
