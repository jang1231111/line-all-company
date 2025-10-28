// new extracted header widget
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final VoidCallback onReset;
  final IconData? leadingIcon; // 추가: 아이콘 선택 가능
  const Header({
    required this.title,
    required this.onReset,
    this.leadingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color:  Colors.indigo[700], size: 20),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onReset,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      const Text(
                        '초기화',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF154E9C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
