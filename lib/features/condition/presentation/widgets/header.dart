// new extracted header widget
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final VoidCallback onReset;
  const Header({required this.title, required this.onReset, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF154E9C),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF154E9C)),
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}
