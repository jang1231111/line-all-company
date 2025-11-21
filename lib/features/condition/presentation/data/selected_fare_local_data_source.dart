import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/selected_fare.dart';

class SelectedFareLocalDataSource {
  static const _historyKey = 'selected_fare_history';
  final Uuid _uuid = const Uuid();

  // 저장: 새로운 목록을 추가 (각 항목에 고유 id 포함, 각 fare에도 fare_id 추가)
  Future<void> addHistory(List<SelectedFare> fares) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final id = _uuid.v4(); // entry id
    final savedAt = now.toIso8601String();
    // final savedAt = '2013-08-17THH:mm:ss.mmmuuuZ'; // 테스트용

    final jsonList = fares.map((e) {
      final m = Map<String, dynamic>.from(e.toJson());
      m['fare_id'] = _uuid.v4(); // 개별 fare id
      return m;
    }).toList();

    final newEntry = {'id': id, 'saved_at': savedAt, 'fares': jsonList};

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

  // 인덱스로 특정 항목 삭제
  Future<void> deleteEntryAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    final List<dynamic> history = jsonDecode(raw);
    if (index < 0 || index >= history.length) return;
    history.removeAt(index);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // id로 특정 항목 삭제
  Future<void> deleteEntryById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    final List<dynamic> history = jsonDecode(raw);
    history.removeWhere((e) => e is Map && (e['id']?.toString() ?? '') == id);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // entry 내에서 fareId로 특정 fare 삭제 (개별 삭제)
  Future<void> deleteFareById(String entryId, String fareId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    final List<dynamic> history = jsonDecode(raw);
    final idx = history.indexWhere((e) => e is Map && (e['id']?.toString() ?? '') == entryId);
    if (idx == -1) return;
    final entry = Map<String, dynamic>.from(history[idx]);
    final fares = List<dynamic>.from(entry['fares'] ?? []);
    fares.removeWhere((f) => f is Map && (f['fare_id']?.toString() ?? '') == fareId);
    if (fares.isEmpty) {
      // fares가 비면 entry 자체를 삭제
      history.removeAt(idx);
    } else {
      entry['fares'] = fares;
      history[idx] = entry;
    }
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // entry 내에서 인덱스로 삭제
  Future<void> deleteFareAt(String entryId, int fareIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    final List<dynamic> history = jsonDecode(raw);
    final idx = history.indexWhere((e) => e is Map && (e['id']?.toString() ?? '') == entryId);
    if (idx == -1) return;
    final entry = Map<String, dynamic>.from(history[idx]);
    final fares = List<dynamic>.from(entry['fares'] ?? []);
    if (fareIndex < 0 || fareIndex >= fares.length) return;
    fares.removeAt(fareIndex);
    if (fares.isEmpty) {
      history.removeAt(idx);
    } else {
      entry['fares'] = fares;
      history[idx] = entry;
    }
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // saved_at 으로 여러 항목 삭제
  Future<void> deleteEntriesBySavedAt(String savedAt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    final List<dynamic> history = jsonDecode(raw);
    history.removeWhere(
      (e) => e is Map && (e['saved_at']?.toString() ?? '') == savedAt,
    );
    await prefs.setString(_historyKey, jsonEncode(history));
  }
}
