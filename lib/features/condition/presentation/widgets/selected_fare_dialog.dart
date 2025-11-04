import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/selected_fare_result_provider.dart';

class SelectedFareDialog extends ConsumerWidget {
  const SelectedFareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);
    final totalPrice = selectedFares.fold<int>(
      0,
      (sum, fare) => sum + fare.price,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        child: SizedBox(
          width: 540, // 가로길이 더 넓게
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.list_alt_rounded,
                    color: Colors.indigo,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '선택된 운임 목록',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D365C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (selectedFares.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        '합계: ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${NumberFormat('#,###').format(totalPrice)}원',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 10, thickness: 2),
              SizedBox(height: 10),
              if (selectedFares.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        color: Colors.indigo.shade100,
                        size: 64,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '선택된 항목이 없습니다.',
                        style: TextStyle(
                          color: Color(0xFF6B7684),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 260, // 세로길이 줄임
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: selectedFares.length,
                    separatorBuilder: (_, __) => const Divider(height: 10),
                    itemBuilder: (context, idx) {
                      final fare = selectedFares[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${fare.row.sido} > ${fare.row.sigungu} > ${fare.row.eupmyeondong}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF2D365C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fare.type == FareType.ft20
                                        ? Colors.indigo.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    fare.type == FareType.ft20
                                        ? '20FT'
                                        : '40FT',
                                    style: TextStyle(
                                      color: fare.type == FareType.ft20
                                          ? Colors.indigo.shade900
                                          : Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${NumberFormat('#,###').format(fare.price)}원',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 할증률 강조
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  '할증률: ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  '${(fare.rate * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            if (fare.surchargeLabels.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: fare.surchargeLabels
                                    .map(
                                      (label) => Chip(
                                        label: Text(
                                          label,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        backgroundColor: Colors.blue[50],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 26),
                      label: const Text('닫기'),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop('save'),
                      icon: const Icon(Icons.save_rounded, size: 26),
                      label: const Text('저장'),
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
