import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/send_fare_input_dialog.dart';

typedef SendFn = Future<bool> Function(Map<String, String> input);

class SendMailButton extends ConsumerWidget {
  final SendFn sendFn;
  final String label;
  final bool popParentOnSuccess; // 성공 시 상위 다이얼로그를 닫을지 여부
  final Map<String, String>? initialInput;

  const SendMailButton({
    super.key,
    required this.sendFn,
    this.label = '메일 전송',
    this.popParentOnSuccess = true,
    this.initialInput,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.mail),
      label: Text(label),
      onPressed: () async {
        // pass initialInput through to dialog (may be null)
        final input = await SendFareInputDialog.show(context, initialInput: initialInput);
        if (input == null) return;

        // progress 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        bool success = false;
        try {
          success = await sendFn(input);
        } catch (_) {
          success = false;
        }

        // progress 닫기
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();

        if (success) {
          if (popParentOnSuccess && Navigator.of(context).canPop()) {
            Navigator.of(context).pop('save'); // 기존 동작과 동일하게 상위 다이얼로그 닫음
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('전송이 완료되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('전송에 실패했습니다. 다시 시도하세요.')),
          );
        }
      },
    );
  }
}