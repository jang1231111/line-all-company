import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/selected_fare_result_provider.dart';
import 'selected_fare_dialog.dart';

class SelectedFareBottomBar extends ConsumerWidget {
  final VoidCallback? onConfirm;

  const SelectedFareBottomBar({
    super.key,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFares = ref.watch(selectedFareProvider);
    final selectedCount = selectedFares.length;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: BottomAppBar(
        elevation: 12,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E7EF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF1C63D6)),
                  const SizedBox(width: 8),
                  Text(
                    selectedCount > 0 ? '선택: $selectedCount건' : '선택된 항목이 없습니다',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF232323),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C63D6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: selectedCount > 0
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => const SelectedFareDialog(),
                        );
                      }
                    : null, // 0건일 때 비활성화
                icon: const Icon(Icons.visibility), // 보기 아이콘으로 변경
                label: const Text('보기'),           // '보기'로 텍스트 변경
              ),
            ],
          ),
        ),
      ),
    );
  }
}