import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/selected_fare_result_provider.dart';

class SelectedFareDialog extends ConsumerWidget {
  const SelectedFareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);

    return AlertDialog(
      title: const Text('선택된 목록'),
      content: SizedBox(
        width: double.maxFinite,
        child: selectedFares.isEmpty
            ? const Text('선택된 항목이 없습니다.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: selectedFares.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, idx) {
                  final fare = selectedFares[idx];
                  return ListTile(
                    title: Text(
                      '${fare.row.sido} > ${fare.row.sigungu} > ${fare.row.eupmyeondong}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fare.type == FareType.ft20 ? '20FT' : '40FT',
                              style: TextStyle(
                                color: fare.type == FareType.ft20
                                    ? Colors.indigo
                                    : Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${NumberFormat('#,###').format(fare.price)}원',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (fare.surchargeLabels.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: fare.surchargeLabels
                                .map((label) => Chip(
                                      label: Text(label,
                                          style: const TextStyle(fontSize: 12)),
                                      backgroundColor: Colors.blue[50],
                                    ))
                                .toList(),
                          ),
                        ],
                        Text(
                          '할증률: ${(fare.rate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
