// add private widgets near bottom of file:
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
        color: const Color(0xFFDFF0FF),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF154E9C)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              decoration: const InputDecoration(
                hintText: '예: 강남구, 역삼동, 역삼1동, ...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.black54),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: onSearch,
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }
}
