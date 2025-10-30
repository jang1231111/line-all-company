import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/data/surcharge_calculator.dart';

import '../providers/condition_provider.dart';
import '../data/surcharge_options.dart'; // 드롭다운/체크박스 옵션

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

    // 할증률 계산은 임시 값으로
    final surchargeResult = calculateSurcharge(
      selectedCheckboxIds: surcharges,
      dangerType: dangerType,
      weightType: weightType,
      specialType: specialType,
      cancellationFee: cancellationFee,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFFFF6E0),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 요약 (아이콘 + 할증 적용 + 퍼센트)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3C2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '할증 적용',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF232323),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          surchargeResult != null
                              ? '${(surchargeResult.rate * 100).toStringAsFixed(2)}%'
                              : '0.00%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFD18A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // header.dart 스타일의 초기화 버튼
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          viewModel.update(
                            condition.copyWith(
                              surcharges: [],
                              dangerType: '',
                              weightType: '',
                              specialType: '',
                              cancellationFee: '',
                            ),
                          );
                          viewModel.updateSurcharge();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 18,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '초기화',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFD18A00),
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 18),

              // 체크박스 리스트
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340), // 높이 넉넉히 조정
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 체크박스 리스트
                      ...surchargeCheckboxOptions.map((opt) {
                        if (opt.isDivider) return const Divider();
                        final checked = surcharges.contains(opt.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: checked ? Colors.orange[50] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: checked
                                  ? Colors.orange
                                  : Colors.orange.shade100,
                              width: checked ? 1.5 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 13,
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

                      // const SizedBox(height: 10),

                      // 드롭다운 4개 (세로 배치)
                      // Text(
                      //   '위험물 종류',
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     color: Colors.orange[800],
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 4),
                      // DropdownButtonFormField<String>(
                      //   isExpanded: true,
                      //   value: dangerType ?? '',
                      //   decoration: fieldDecoration(
                      //     context,
                      //     hint: '위험물 종류',
                      //     icon: Icons.warning_amber_rounded,
                      //     fillColor: (dangerType != null && dangerType != '')
                      //         ? const Color(0xFFFFF9C4) // 연한 오렌지
                      //         : Colors.white,
                      //     borderColor: Colors.orange.shade100,
                      //   ),
                      //   items: dangerTypeOptions
                      //       .map(
                      //         (e) => DropdownMenuItem(
                      //           value: e.value,
                      //           child: Text(
                      //             e.label,
                      //             style: const TextStyle(fontSize: 13),
                      //           ),
                      //         ),
                      //       )
                      //       .toList(),
                      //   onChanged: (v) {
                      //     setState(() {
                      //       dangerType = v;
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 12),
                      Text(
                        '중량물 할증',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                                  style: const TextStyle(fontSize: 13),
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
                      // const SizedBox(height: 12),
                      // Text(
                      //   '활대품 할증',
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     color: Colors.orange[800],
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 4),
                      // DropdownButtonFormField<String>(
                      //   isExpanded: true,
                      //   value: specialType ?? '',
                      //   decoration: fieldDecoration(
                      //     context,
                      //     hint: '활대품 할증',
                      //     icon: Icons.extension,
                      //     fillColor: (specialType != null && specialType != '')
                      //         ? const Color(0xFFFFF9C4)
                      //         : Colors.white,
                      //     borderColor: Colors.orange.shade100,
                      //   ),
                      //   items: specialTypeOptions
                      //       .map(
                      //         (e) => DropdownMenuItem(
                      //           value: e.value,
                      //           child: Text(
                      //             e.label,
                      //             style: const TextStyle(fontSize: 13),
                      //           ),
                      //         ),
                      //       )
                      //       .toList(),
                      //   onChanged: (v) {
                      //     setState(() {
                      //       specialType = v;
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 12),
                      Text(
                        '배차 취소료',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color.fromARGB(255, 109, 120, 166),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                                  style: const TextStyle(fontSize: 13),
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

              const SizedBox(height: 18),
              // 할증 적용 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // 할증 적용 확인 다이얼로그
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: const Color(0xFFFFF6E0),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange[700],
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    '할증을 적용하시겠습니까?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF7A4B00),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              if (surchargeResult == null ||
                                  surchargeResult.labels.isEmpty)
                                const Text(
                                  '선택된 할증이 없습니다.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (surchargeResult != null &&
                                  surchargeResult.labels.isNotEmpty) ...[
                                ...surchargeResult.labels.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '할증: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${(surchargeResult.rate * 100).toStringAsFixed(2)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD18A00),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 28),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('취소'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () async {
                                        // 여기서만 실제 저장!
                                        viewModel.update(
                                          condition.copyWith(
                                            surcharges: surcharges,
                                            dangerType: dangerType,
                                            weightType: weightType,
                                            specialType: specialType,
                                            cancellationFee: cancellationFee,
                                          ),
                                        );
                                        viewModel.updateSurcharge();
                                        await viewModel.search();
                                        Navigator.of(
                                          context,
                                        ).pop(); // 확인 다이얼로그 닫기
                                        Navigator.of(
                                          context,
                                        ).pop(); // 할증 다이얼로그 닫기
                                      },
                                      child: const Text('적용'),
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
                  child: const Text('할증 적용'),
                ),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor ?? Colors.blue.shade100),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor ?? Colors.blue.shade100),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: borderColor ?? Colors.blue.shade300,
        width: 1.5,
      ),
    ),
    prefixIcon: icon != null ? Icon(icon, size: 18) : null,
  );
}
