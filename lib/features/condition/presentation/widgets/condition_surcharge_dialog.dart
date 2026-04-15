import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart'; // isPeriod2026, isAprilGuideline
import 'package:line_all/features/condition/presentation/data/surcharge_calculator.dart';
import 'package:line_all/features/condition/presentation/data/surcharge_options.dart';
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
    final is2026Period = isPeriod2026(condition.period); // 2월/4월 모두 2026 옵션 사용
    final isOneWay = condition.section?.endsWith('-oneway') ?? false;
    final section = condition.section ?? '';

    // 지역 기점 배지는 4월 운영지침일 때만 표시
    final bool isIncheonSection = incheonAreaSections.contains(section);
    final bool isPyeongtaekSection = pyeongtaekAreaSections.contains(section);
    final bool isAreaBadgeVisible =
        isAprilGuideline(condition.period) && (isIncheonSection || isPyeongtaekSection);
    final String? areaBadgeLabel = isAreaBadgeVisible
        ? (isIncheonSection ? '인천 기점(20%)' : '평택 기점(18%)')
        : null;

    final options = is2026Period ? surcharge2026Options : surchargeCheckboxOptions;

    // 편도일 경우 냉동/냉장 옵션 비활성화 + 지역 기점 할증은 체크박스에서 제외
    final processedOptions = options
        .where(
          (opt) => opt.id != 'incheon_area' && opt.id != 'pyeongtaek_area',
        )
        .map((opt) {
          if (isOneWay && opt.id == 'refrigerated') {
            return CheckboxOption(
              id: opt.id,
              label: opt.label,
              rate: opt.rate,
              isFixed: opt.isFixed,
              isDivider: opt.isDivider,
              disabled: true,
            );
          }
          return opt;
        })
        .toList();

    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: surcharges,
      weightType: weightType,
      cancellationFee: cancellationFee,
      is2026Period: is2026Period,
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      backgroundColor: const Color(0xFFFFF6E0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 요약 (아이콘 + 할증 적용 + 퍼센트)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3C2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '할증 적용',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '${(surchargeResult.rate * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: const Color(0xFFD18A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // 지역 기점 할증 배지 (4월 운영지침 + 인천/평택 구간일 때만)
              if (areaBadgeLabel != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  margin: EdgeInsets.only(bottom: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 15.sp,
                        color: Colors.indigo.shade600,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        areaBadgeLabel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '자동 적용',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 초기화 버튼 (작게)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.orange.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.04),
                          blurRadius: 4.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          setState(() {
                            // 지역 기점 할증(incheon_area/pyeongtaek_area)은
                            // 구간 선택 시 자동 적용되므로 초기화 시에도 유지
                            final areaIds = ['incheon_area', 'pyeongtaek_area'];
                            surcharges =
                                surcharges
                                    .where((id) => areaIds.contains(id))
                                    .toList();
                            dangerType = '';
                            weightType = '';
                            specialType = '';
                            cancellationFee = '';
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 18.sp,
                                color: Colors.orange[700],
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '초기화',
                                style: TextStyle(
                                  fontSize: 14.sp,
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
                ],
              ),

              SizedBox(height: 8.h),
              Divider(color: Colors.orange.shade200, thickness: 1.h),

              // 체크박스 리스트 (폰트/간격 축소)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 240.h),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 4.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...processedOptions.map((opt) {
                          if (opt.isDivider) return Divider();
                          final isDisabled = opt.disabled;
                          final checked =
                              surcharges.contains(opt.id) && !isDisabled;
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey[100]
                                  : (checked
                                        ? Colors.orange[50]
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey.shade300
                                    : (checked
                                          ? Colors.orange
                                          : Colors.orange.shade100),
                                width: checked ? 2 : 1,
                              ),
                            ),
                            child: Opacity(
                              opacity: isDisabled ? 0.5 : 1.0,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 16.sp,
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
                                onChanged: isDisabled
                                    ? null
                                    : (v) {
                                        setState(() {
                                          if (v == true) {
                                            if (!surcharges.contains(opt.id)) {
                                              surcharges.add(opt.id);
                                            }
                                          } else {
                                            surcharges.remove(opt.id);
                                          }
                                        });
                                      },
                              ),
                            ),
                          );
                        }),

                        SizedBox(height: 12.h),
                        Text(
                          '중량물 할증',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w700,
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
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => weightType = v),
                        ),

                        SizedBox(height: 12.h),
                        Text(
                          '배차 취소료',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color.fromARGB(255, 109, 120, 166),
                            fontWeight: FontWeight.w700,
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
                                (cancellationFee != null &&
                                    cancellationFee != '')
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
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => cancellationFee = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // 하단 버튼: 닫기 / 할증 적용 (작고 일관된 스타일)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: Colors.black54,
                      ),
                      label: Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            backgroundColor: const Color(0xFFFFF6E0),
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '할증을 적용하시겠습니까?',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7A4B00),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    '기존 선택한 운임 건이 초기화됩니다.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  if (surchargeResult == null ||
                                      surchargeResult.labels.isEmpty)
                                    Text(
                                      '선택된 할증이 없습니다.',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  if (surchargeResult != null &&
                                      surchargeResult.labels.isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    ...surchargeResult.labels.map(
                                      (e) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.orange,
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '할증: ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${(surchargeResult.rate * 100).toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFD18A00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: 16.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            '취소',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            side: BorderSide(
                                              color: Colors.orange.shade600,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton(
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
                                            ref
                                                .read(
                                                  selectedFareProvider.notifier,
                                                )
                                                .clearState();
                                            Navigator.of(
                                              context,
                                            ).pop(); // confirm dialog
                                            Navigator.of(
                                              context,
                                            ).pop(); // surcharge dialog
                                          },
                                          child: Text(
                                            '적용',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade700,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
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
                      child: Text(
                        '할증 적용',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
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
