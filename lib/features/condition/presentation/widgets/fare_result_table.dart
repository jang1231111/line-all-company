import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_surcharge_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/fare_result_row.dart';
import '../providers/fare_result_provider.dart';
import '../providers/condition_provider.dart';

class FareResultTable extends ConsumerWidget {
  const FareResultTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(fareResultViewModelProvider);
    final condition = ref.watch(conditionViewModelProvider);
    final surchargeRate = condition.surchargeResult.rate;
    final cancellationFeeAmount =
        condition.surchargeResult.cancellationFeeAmount;
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedFareNotifier = ref.read(selectedFareProvider.notifier);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.indigo.shade100, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 할증 정보 미니 컨테이너 (Stack으로 "할증 적용" 텍스트를 border에 걸치게)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: Material(
                color: const Color(0xFFFFF3C2), // 컨테이너 배경색과 동일하게!
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  splashColor: Colors.orange.withOpacity(0.1),
                  highlightColor: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConditionSurchargeDialog(),
                    );
                  },
                  child: Container(
                    // width: double.infinity,
                    decoration: BoxDecoration(
                      // color: const Color(0xFFFFF3C2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange[700],
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '할증 적용 ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${(surchargeRate * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFFD18A00),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Text(
                            //   '배차 취소료 ${(cancellationFeeAmount * 100).toStringAsFixed(0)}%',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 20,
                            //     color: Colors.blueGrey[700],
                            //   ),
                            // ),
                            // const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE0E7EF)),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.indigo.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          color: Colors.indigo.shade300,
                          size: 48,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '검색 결과가 없어요',
                          style: TextStyle(
                            color: Color(0xFF3A4374),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '조건을 다시 선택하거나\n검색어를 변경해보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.indigo.shade200,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, idx) {
                    final row = results[idx];
                    final ft20WithSurcharge =
                        ((row.ft20Safe * (1 + surchargeRate)) *
                                cancellationFeeAmount /
                                100)
                            .round() *
                        100;
                    final ft40WithSurcharge =
                        ((row.ft40Safe * (1 + surchargeRate)) *
                                cancellationFeeAmount /
                                100)
                            .round() *
                        100;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.indigo.shade100,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        child: FareResultRow(
                          row: row,
                          is20Selected: selectedFareNotifier.isSelected(
                            row,
                            FareType.ft20,
                          ),
                          is40Selected: selectedFareNotifier.isSelected(
                            row,
                            FareType.ft40,
                          ),
                          ft20WithSurcharge: ft20WithSurcharge,
                          ft40WithSurcharge: ft40WithSurcharge,
                          on20Tap: () {
                            selectedFareNotifier.toggle(
                              row: row,
                              type: FareType.ft20,
                              rate: condition.surchargeResult.rate,
                              price: ft20WithSurcharge,
                              surchargeLabels: List<String>.from(
                                condition.surchargeResult.labels,
                              ),
                            );
                          },
                          on40Tap: () {
                            selectedFareNotifier.toggle(
                              row: row,
                              type: FareType.ft40,
                              rate: condition.surchargeResult.rate,
                              price: ft40WithSurcharge,
                              surchargeLabels: List<String>.from(
                                condition.surchargeResult.labels,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
