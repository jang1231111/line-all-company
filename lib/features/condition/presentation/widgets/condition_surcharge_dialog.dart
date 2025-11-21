import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/data/surcharge_calculator.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';

import '../providers/condition_provider.dart';
import '../data/surcharge_options.dart';

class ConditionSurchargeDialog extends ConsumerStatefulWidget {
  const ConditionSurchargeDialog({super.key});

  @override
  ConsumerState<ConditionSurchargeDialog> createState() =>
      _ConditionSurchargeDialogState();
}

class _ConditionSurchargeDialogState
    extends ConsumerState<ConditionSurchargeDialog> {
  late List<String> surcharges;
  String? dangerType;
  String? weightType;
  String? specialType;
  String? cancellationFee;

  @override
  void initState() {
    super.initState();
    final condition = ref.read(conditionViewModelProvider);
    surcharges = List<String>.from(condition.surcharges);
    dangerType = condition.dangerType;
    weightType = condition.weightType;
    specialType = condition.specialType;
    cancellationFee = condition.cancellationFee;
  }

  @override
  Widget build(BuildContext context) {
    final condition = ref.read(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: surcharges,
      dangerType: dangerType,
      weightType: weightType,
      specialType: specialType,
      cancellationFee: cancellationFee,
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: const Color(0xFFFFF6E0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 요약 (아이콘 + 할증 적용 + 퍼센트)
            Padding(
              padding: EdgeInsets.only(top: 24.h, left: 24.w, right: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3C2),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 28.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '할증 적용',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            color: const Color(0xFF232323),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          surchargeResult != null
                              ? '${(surchargeResult.rate * 100).toStringAsFixed(2)}%'
                              : '0.00%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            color: const Color(0xFFD18A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.orange.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.06),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () {
                        setState(() {
                          surcharges = [];
                          dangerType = '';
                          weightType = '';
                          specialType = '';
                          cancellationFee = '';
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 22.sp,
                              color: Colors.orange[700],
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '초기화',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFFD18A00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
            Divider(
              color: Colors.orange.shade200,
              thickness: 1.5.h,
              height: 32.h,
            ),

            // 체크박스 리스트
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280.h),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...surchargeCheckboxOptions.map((opt) {
                        if (opt.isDivider) return Divider();
                        final checked = surcharges.contains(opt.id);
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: checked ? Colors.orange[50] : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: checked
                                  ? Colors.orange
                                  : Colors.orange.shade100,
                              width: checked ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: checked
                                    ? Colors.orange[800]
                                    : Colors.black87,
                                fontWeight: checked
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            value: checked,
                            activeColor: Colors.orange,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  if (!surcharges.contains(opt.id))
                                    surcharges.add(opt.id);
                                } else {
                                  surcharges.remove(opt.id);
                                }
                              });
                            },
                          ),
                        );
                      }),
                      SizedBox(height: 18.h),
                      Text(
                        '중량물 할증',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: weightType ?? '',
                        decoration: fieldDecoration(
                          context,
                          hint: '중량물 할증',
                          icon: Icons.scale,
                          fillColor: (weightType != null && weightType != '')
                              ? const Color(0xFFFFF9C4)
                              : Colors.white,
                          borderColor: Colors.orange.shade100,
                        ),
                        items: weightTypeOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(
                                  e.label,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            weightType = v;
                          });
                        },
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        '배차 취소료',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: const Color.fromARGB(255, 109, 120, 166),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: cancellationFee ?? '',
                        decoration: fieldDecoration(
                          context,
                          hint: '배차 취소료',
                          icon: Icons.cancel,
                          fillColor:
                              (cancellationFee != null && cancellationFee != '')
                              ? const Color(0xFFF5F6FA)
                              : Colors.white,
                          borderColor: Colors.orange.shade100,
                        ),
                        items: cancellationFeeOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(
                                  e.label,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            cancellationFee = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        elevation: 0,
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: Icon(Icons.close_rounded, size: 24.sp),
                      label: Text('닫기', style: TextStyle(fontSize: 20.sp)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            backgroundColor: const Color(0xFFFFF6E0),
                            child: Padding(
                              padding: EdgeInsets.all(32.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '할증을 적용하시겠습니까?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22.sp,
                                          color: Color(0xFF7A4B00),
                                        ),
                                      ),
                                      Text(
                                        '기존 선택한 운임 건이 초기화됩니다.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 22.h),
                                  if (surchargeResult == null ||
                                      surchargeResult.labels.isEmpty)
                                    Text(
                                      '선택된 할증이 없습니다.',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  if (surchargeResult != null &&
                                      surchargeResult.labels.isNotEmpty) ...[
                                    ...surchargeResult.labels.map(
                                      (e) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                          horizontal: 10.w,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.orange,
                                              size: 22.sp,
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 22.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '할증: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                        Text(
                                          '${(surchargeResult.rate * 100).toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD18A00),
                                            fontSize: 22.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: 32.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.orange[700],
                                            side: BorderSide(
                                              color: Colors.orange[700]!,
                                              width: 2,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18.h,
                                            ),
                                            textStyle: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            '취소',
                                            style: TextStyle(fontSize: 18.sp),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange[700],
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18.h,
                                            ),
                                            textStyle: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () async {
                                            viewModel.update(
                                              condition.copyWith(
                                                surcharges: surcharges,
                                                dangerType: dangerType,
                                                weightType: weightType,
                                                specialType: specialType,
                                                cancellationFee:
                                                    cancellationFee,
                                              ),
                                            );
                                            viewModel.updateSurcharge();

                                            // 적용 후 선택된 운임들 초기화
                                            ref
                                                .read(
                                                  selectedFareProvider.notifier,
                                                )
                                                .clearState();

                                            Navigator.of(
                                              context,
                                            ).pop(); // 확인 다이얼로그 닫기
                                            Navigator.of(
                                              context,
                                            ).pop(); // 할증 다이얼로그 닫기
                                          },
                                          child: Text(
                                            '적용',
                                            style: TextStyle(fontSize: 18.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text('할증 적용', style: TextStyle(fontSize: 20.sp)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 공통 스타일을 위한 fieldDecoration 함수 예시
InputDecoration fieldDecoration(
  BuildContext context, {
  required String hint,
  IconData? icon,
  Color? fillColor,
  Color? borderColor,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: fillColor ?? Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: borderColor ?? Colors.blue.shade100),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: borderColor ?? Colors.blue.shade100),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: borderColor ?? Colors.blue.shade300,
        width: 2,
      ),
    ),
    prefixIcon: icon != null ? Icon(icon, size: 22.sp) : null,
  );
}
