import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_surcharge_dialog.dart';
import '../providers/fare_result_provider.dart';
import '../providers/condition_provider.dart';

class FareResultTable extends ConsumerWidget {
  const FareResultTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(fareResultViewModelProvider);

    final condition = ref.watch(conditionViewModelProvider);
    final surchargeRate = condition.surchargeResult?.rate ?? 0.0;
    final cancellationFeeAmount =
        condition.surchargeResult?.cancellationFeeAmount ?? 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Center(
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      width: double.infinity,
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
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 5,
                        top: 10,
                        bottom: 10,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[700],
                                size: 30,
                              ),
                              Text(
                                '할증 +${(surchargeRate * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '배차 취소료 ${(cancellationFeeAmount * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: const Color.fromARGB(
                                    255,
                                    109,
                                    120,
                                    166,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                SizedBox(
                  height: 400, // 또는 원하는 높이
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.blueGrey.shade100,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: Colors.teal,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      '${row.sido} > ${row.sigungu} > ${row.eupmyeondong}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo[50],
                                        foregroundColor: Colors.indigo[900],
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {},
                                      child: Column(
                                        children: [
                                          Text(
                                            '20FT',
                                            style: TextStyle(
                                              color: Colors.indigo[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${NumberFormat('#,###').format(ft20WithSurcharge)}원',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange[50],
                                        foregroundColor: Colors.deepOrange,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {},
                                      child: Column(
                                        children: [
                                          Text(
                                            '40FT',
                                            style: TextStyle(
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${NumberFormat('#,###').format(ft40WithSurcharge)}원',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
