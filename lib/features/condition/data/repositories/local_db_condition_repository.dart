import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/condition.dart';
import '../../domain/repositories/condition_repository.dart';

/// 내부 DB(SharedPreferences) 기반 저장소 구현
class LocalDbConditionRepository implements ConditionRepository {
  static const _key = 'last_condition';

  @override
  Future<void> saveCondition(Condition condition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(condition.toJson()));
  }

  @override
  Future<Condition?> loadLastCondition() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;
    return Condition.fromJson(jsonDecode(jsonStr));
  }
}
