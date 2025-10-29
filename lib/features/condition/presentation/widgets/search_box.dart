import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final VoidCallback onRegionSearch; // 추가된 부분
  const SearchBox({
    required this.initialValue,
    required this.onChanged,
    required this.onSearch,
    required this.onRegionSearch, // 추가된 부분
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        color: const Color(0xFFDFF0FF),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 타이틀 & 지역검색 버튼 Row
          Row(
            children: [
              Icon(Icons.manage_search, color: Colors.blue[700], size: 30),
              const SizedBox(width: 6),
              const Text(
                '도로명 검색',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF154E9C),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: '지역 검색',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(36, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onRegionSearch,
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('지역검색'),
                ),
              ),
            ],
          ),
          const Text(
            '시도, 시군구, 읍면동, 법정동으로 즉시 검색',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          // 검색 입력창 + 검색 버튼 Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  decoration: InputDecoration(
                    hintText: '예: 강남구, 역삼동, 역삼1동...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.blue.shade300,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF154E9C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 0,
                  ),
                  onPressed: onSearch,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('검색'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
