import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  const SearchBox({
    required this.initialValue,
    required this.onChanged,
    required this.onSearch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        color: const Color(0xFFDFF0FF),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 타이틀 & 설명
          Row(
            children: [
              Icon(Icons.manage_search, color: Colors.blue[700], size: 22),
              const SizedBox(width: 6),
              const Text(
                '빠른 행선지 검색',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF154E9C),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Text(
            '시도, 시군구, 읍면동, 법정동으로 즉시 검색',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          // 검색 입력창 + 버튼
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  decoration: InputDecoration(
                    // prefixIcon: const Icon(
                    //   Icons.search,
                    //   color: Color(0xFF154E9C),
                    // ),
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
