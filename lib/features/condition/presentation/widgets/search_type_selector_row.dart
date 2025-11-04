import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTypeSelectorRow extends ConsumerWidget {
  final VoidCallback onRegionSearch;
  final VoidCallback onRoadNameSearch;
  const SearchTypeSelectorRow({
    super.key,
    required this.onRegionSearch,
    required this.onRoadNameSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB4C8F7), width: 1.2),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 빠른 행선지 검색 카드
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C63D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text(
                            '지역 검색',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: onRegionSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 세로 구분선
              Container(
                width: 1.2,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFB4C8F7),
              ),
              // 도로명 검색 카드
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BAF5D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.location_on),
                          label: const Text(
                            '도로명 검색',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: onRoadNameSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
