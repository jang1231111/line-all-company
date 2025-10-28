import 'package:flutter/material.dart';

class FareResultTable extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  const FareResultTable({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀 & 안내문구
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.indigo[700], size: 22),
                const SizedBox(width: 6),
                const Text(
                  '운임 계산 결과',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '컨테이너 사이즈별 가격을 클릭하여 선택하세요.',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE0E7EF)),
            // 결과 리스트
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final row = results[idx];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blueGrey.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1줄: 항구명
                        Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 6),
                            Text(
                              row['항구'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 2줄: 지역 > 시군구 > 읍면동 + 거리
                        Row(
                          children: [
                            Icon(Icons.place, color: Colors.teal, size: 18),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${row['지역(시도)'] ?? ''} > ${row['지역(시군구)'] ?? ''} > ${row['지역(읍면동)'] ?? ''}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.route, color: Colors.grey[600], size: 18),
                            const SizedBox(width: 2),
                            Text('${row['거리(KM)'] ?? ''}km', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3줄: 20FT, 40FT 버튼 (반반)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[50],
                                  foregroundColor: Colors.indigo[900],
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // 20FT 클릭 시 동작
                                },
                                child: Column(
                                  children: [
                                    Text('20FT', style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${row['20FT(원)'] ?? ''}원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // 40FT 클릭 시 동작
                                },
                                child: Column(
                                  children: [
                                    Text('40FT', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${row['40FT(원)'] ?? ''}원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
