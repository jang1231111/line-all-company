import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/widgets/price_edit_button.dart';
import 'package:line_all/features/condition/presentation/widgets/save_consignor_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/surcharge_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/send_mail_flow_button.dart';
import '../data/condition_options.dart';
import '../providers/selected_fare_result_provider.dart';
import 'send_fare_input_dialog.dart';

class SelectedFareDialog extends ConsumerWidget {
  const SelectedFareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedFareViewModel = ref.read(selectedFareProvider.notifier);
    final totalPrice = selectedFares.fold<int>(
      0,
      (sum, fare) => sum + fare.price,
    );
    final priceFmt = NumberFormat('#,###');

    // 서버 전송은 ViewModel.sendSelectedFares로 처리합니다.
    // (선택한 항목 저장/상태 초기화는 ViewModel 내부에서 수행됩니다.)

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.list_alt_rounded,
                      color: Colors.indigo,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 운임 목록',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D365C),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          selectedFares.isEmpty
                              ? '선택된 항목이 없습니다.'
                              : '선택된 운임을 확인하고 전송하세요.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // total box (if any)
              if (selectedFares.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 12.w,
                  ),
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '총 합계',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${priceFmt.format(totalPrice)}원',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ),

              // list or empty
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: selectedFares.isEmpty ? 120.h : 320.h,
                ),
                child: selectedFares.isEmpty
                    ? Column(
                        children: [
                          SizedBox(height: 8.h),
                          Icon(
                            Icons.inbox_rounded,
                            color: Colors.indigo.shade100,
                            size: 56.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '선택된 항목이 없습니다.',
                            style: TextStyle(
                              color: Color(0xFF6B7684),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: selectedFares.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, idx) {
                          final fare = selectedFares[idx];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.indigo.shade100,
                                width: 1.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 1.h),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 12.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // title + type tag
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          getSectionLabel(fare.row.section),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: fare.type == FareType.ft20
                                              ? Colors.indigo.shade100
                                              : Colors.deepOrange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Text(
                                          fare.type == FareType.ft20
                                              ? '20FT'
                                              : '40FT',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w800,
                                            color: fare.type == FareType.ft20
                                                ? Colors.indigo.shade900
                                                : Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  // location + price + surcharge
                                  Text(
                                    '${fare.row.sido} > ${fare.row.sigungu} > ${fare.row.eupmyeondong}',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                SurchargeDialog(fare: fare),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3C2),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '할증률',
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              // 할증률은 버튼 기능 제거하고 단순 텍스트로 표시
                                              Text(
                                                '${(fare.rate * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFFD18A00,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 금액 텍스트를 버튼으로 교체하여 눌렀을 때 금액 수정 다이얼로그 표시
                                      PriceEditButton(
                                        price: fare.price,
                                        index: idx,
                                        priceFmt: priceFmt,
                                        onUpdate: selectedFareViewModel
                                            .updateFarePrice,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: 12.h),

              // action buttons: 닫기 / 저장 / 메일 전송
              Row(
                children: [
                  // 가운데: 저장
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        side: BorderSide(color: Colors.indigo.shade100),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        final consignor = await SaveConsignorDialog.show(context);
                        if (consignor != null) {
                          final success = await selectedFareViewModel.saveSelectedFares(consignor);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('저장이 완료되었습니다.')),
                            );
                            Navigator.of(context).pop('save');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('저장에 실패했습니다. 다시 시도하세요.')),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text('저장'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // 오른쪽: 메일 전송 (SendMailButton 사용)
                  Expanded(
                    child: SendMailButton(
                      sendFn: selectedFareViewModel.sendSelectedFares,
                      label: '메일 전송',
                      popParentOnSuccess: true,
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
