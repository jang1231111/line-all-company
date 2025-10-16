import '../models/condition.dart';

class CalculateConditionUseCase {
  // stub: implement calculation orchestration
  Future<String> execute(Condition condition) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'ok';
  }
}
