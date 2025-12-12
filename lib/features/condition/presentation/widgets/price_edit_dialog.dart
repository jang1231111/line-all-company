import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceEditDialog extends StatefulWidget {
  final int initialPrice;

  const PriceEditDialog({Key? key, required this.initialPrice})
    : super(key: key);

  @override
  State<PriceEditDialog> createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends State<PriceEditDialog> {
  late TextEditingController _controller;
  final NumberFormat _nf = NumberFormat.decimalPattern();
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPrice.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _parseValue() {
    final text = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28.0,
        vertical: 24.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width < 420 ? width - 40 : 420),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C63D6), Color(0xFF1760C8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '금액 수정',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.close, color: Colors.white),
                        //   onPressed: () =>
                        //       Navigator.of(context).pop<int?>(null),
                        //   splashRadius: 18,
                        //   padding: EdgeInsets.zero,
                        //   constraints: const BoxConstraints(),
                        // ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Big input field
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8), // 최대 8자리 제한
                          ],
                          decoration: InputDecoration(
                            prefixText: '₩ ',
                            prefixStyle: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: '예: 120000',
                            errorText: _isValid ? null : '유효한 숫자를 입력하세요.',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xFF1C63D6),
                              ),
                            ),
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          onSubmitted: (_) => _onSave(),
                        ),
                        const SizedBox(height: 12),

                        // Preview row: current / input formatted
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '기존 값: ${_nf.format(widget.initialPrice)}원',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C63D6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action buttons (rounded, modern)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop<int?>(null),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onSave,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: const Color(0xFF1C63D6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '저장',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final v = _parseValue();
    if (v == null) {
      setState(() => _isValid = false);
      return;
    }
    const maxValue = 99999999; // 8자리 최대값
    if (v > maxValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액은 최대 8자리까지 입력할 수 있습니다.')),
      );
      return;
    }
    Navigator.of(context).pop<int>(v);
  }
}
