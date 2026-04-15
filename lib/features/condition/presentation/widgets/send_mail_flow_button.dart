import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/send_fare_input_dialog.dart';

typedef SendFn = Future<bool> Function(Map<String, String> input);

class SendMailButton extends ConsumerWidget {
  final SendFn sendFn;
  final String label;
  final bool popParentOnSuccess; // 성공 시 상위 다이얼로그를 닫을지 여부
  final Map<String, String>? initialInput;

  // 추가: 버튼 크기/아이콘 크기 조절 옵션
  final double? width;
  final double? height;
  final double iconSize;
  final TextStyle? labelStyle;

  const SendMailButton({
    super.key,
    required this.sendFn,
    this.label = '메일 전송',
    this.popParentOnSuccess = true,
    this.initialInput,
    this.width,
    this.height,
    this.iconSize = 18.0,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        // 최소 높이/너비를 설정해 레이아웃에서 너무 작아지는 것을 방지
        minimumSize: Size(width ?? 0, height ?? 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(Icons.mail, size: iconSize),
      // 라벨에 트렁케이션 적용 (Flexible 제거 — ElevatedButton.icon 내부가 이미 Flex)
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: labelStyle,
      ),
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

    // 필요시 고정된 크기로 래핑
    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }
    return button;
  }
}