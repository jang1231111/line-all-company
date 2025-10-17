import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_all/features/condition/presentation/widgets/condition_form_widget.dart';

void main() {
  testWidgets('기간 미입력시 에러 메시지 노출', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: Scaffold(body: ConditionFormWidget()))),
    );
    // 저장 버튼 클릭
    final saveBtn = find.widgetWithText(ElevatedButton, '저장');
    await tester.tap(saveBtn);
    await tester.pump();
    // 에러 메시지 노출 확인
    expect(find.text('기간을 입력하세요'), findsOneWidget);
  });

  testWidgets('기간 입력 후 저장 성공 메시지', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: Scaffold(body: ConditionFormWidget()))),
    );
    // 기간 입력
  final periodField = find.byType(TextFormField).first;
  await tester.enterText(periodField, '2025');
    // 저장 버튼 클릭
    final saveBtn = find.widgetWithText(ElevatedButton, '저장');
    await tester.tap(saveBtn);
    await tester.pump();
    // 성공 메시지 노출
    expect(find.text('저장되었습니다'), findsOneWidget);
  });
}
