import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/selected_fare.dart';

class SelectedFareLocalDataSource {
  static const _historyKey = 'selected_fare_history';

  // 저장: 새로운 목록을 추가
  Future<void> addHistory(List<SelectedFare> fares) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final jsonList = fares.map((e) => e.toJson()).toList();
    final newEntry = {
      'saved_at': now,
      'fares': jsonList,
    };

    final raw = prefs.getString(_historyKey);
    List<dynamic> history = raw != null ? jsonDecode(raw) : [];
    history.add(newEntry);

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // 전체 저장 내역 불러오기
  Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  // 저장 내역 전체 삭제
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}