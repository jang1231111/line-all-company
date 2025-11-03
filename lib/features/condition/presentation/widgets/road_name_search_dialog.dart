import 'package:flutter/material.dart';

class RoadNameSearchDialog extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final List<RoadSearchResult> results; // 검색 결과 리스트
  final int totalCount; // 전체 결과 개수

  const RoadNameSearchDialog({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onSearch,
    required this.results,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목/설명/닫기
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.green[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '도로명 검색',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1BAF5D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '도로명으로 행선지를 검색하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black38),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 18),
              // 입력창 + 검색 버튼
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: initialValue,
                      decoration: InputDecoration(
                        hintText: '도로명, 지번, 건물명을 입력하세요',
                        hintStyle: const TextStyle(fontSize: 15, color: Colors.black45),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFB4C8F7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFB4C8F7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1BAF5D), width: 1.5),
                        ),
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BAF5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: onSearch,
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('검색'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // 검색 결과 영역
              if (results.isNotEmpty) ...[
                Text(
                  '검색 결과 ($totalCount건)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF4B5B7A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    itemBuilder: (context, idx) {
                      final item = results[idx];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xFF1BAF5D)),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: item.onTap,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        dense: true,
                        minLeadingWidth: 28,
                      );
                    },
                  ),
                ),
              ],
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 검색 결과 모델 예시
class RoadSearchResult {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  RoadSearchResult({
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
