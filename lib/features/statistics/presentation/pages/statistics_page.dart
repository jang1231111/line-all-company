import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운임 통계'),
        backgroundColor: const Color(0xFF1C63D6),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, color: Colors.indigo, size: 64),
            const SizedBox(height: 18),
            const Text(
              '운임 통계 페이지',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D365C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '여기에 운임 통계 관련 차트와 데이터가 표시됩니다.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7684)),
            ),
          ],
        ),
      ),
    );
  }
}
