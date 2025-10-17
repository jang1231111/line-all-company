import 'package:flutter_test/flutter_test.dart';
import 'package:line_all/features/condition/domain/models/condition.dart';
import 'package:line_all/features/condition/presentation/viewmodel/condition_viewmodel.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:line_all/features/condition/domain/repositories/condition_repository.dart';

class FakeConditionRepository implements ConditionRepository {
  Condition? lastSaved;
  @override
  Future<void> saveCondition(Condition condition) async {
    lastSaved = condition;
  }
  @override
  Future<Condition?> loadLastCondition() async => lastSaved;
}

void main() {
  group('ConditionViewModel', () {
    late FakeConditionRepository repo;
    late ConditionViewModel viewModel;

    setUp(() {
      repo = FakeConditionRepository();
      viewModel = ConditionViewModel(repo);
    });

    test('초기값은 빈 Condition', () {
      expect(viewModel.state, const Condition());
    });

    test('update로 상태 변경', () {
      final updated = const Condition(period: '2025');
      viewModel.update(updated);
      expect(viewModel.state, updated);
    });

    test('save 호출 시 repo에 저장', () async {
      final updated = const Condition(period: '2025');
      viewModel.update(updated);
      await viewModel.save();
      expect(repo.lastSaved, updated);
    });
  });
}
