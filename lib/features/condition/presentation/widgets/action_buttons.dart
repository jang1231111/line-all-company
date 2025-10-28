import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool saving;
  final Future<void> Function() search;
  final VoidCallback onReset;

  const ActionButtons({
    required this.saving,
    required this.search,
    required this.onReset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontSize: 14),
          ),
          onPressed: saving ? null : () => search(),
          icon: const Icon(Icons.search),
          label: Text(saving ? '검색 중...' : '검색'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF154E9C),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontSize: 14),
          ),
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('초기화'),
        ),
      ],
    );
  }
}
