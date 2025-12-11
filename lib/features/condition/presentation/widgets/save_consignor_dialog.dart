import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 화주명만 입력받는 간단한 저장 다이얼로그
/// 사용 예: final consignor = await SaveConsignorDialog.show(context);
class SaveConsignorDialog extends StatefulWidget {
  const SaveConsignorDialog({Key? key}) : super(key: key);

  /// Returns 입력된 화주명 (String) or null if cancelled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SaveConsignorDialog(),
    );
  }

  @override
  State<SaveConsignorDialog> createState() => _SaveConsignorDialogState();
}

class _SaveConsignorDialogState extends State<SaveConsignorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _consignorCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _consignorCtrl.dispose();
    super.dispose();
  }

  void _onCancel() => Navigator.of(context).pop<String?>(null);

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    // 잠깐의 시각적 대기(필요 없으면 제거)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.of(context).pop<String>(_consignorCtrl.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              children: [
                const Icon(Icons.save, color: Color(0xFF1C63D6)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '저장 (화주명 입력)',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                  onPressed: _saving ? null : _onCancel,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Form(
              key: _formKey,
              child: TextFormField(
                enabled: !_saving,
                controller: _consignorCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '화주명 입력',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '화주명을 입력해주세요.';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _onSave(),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('취소', style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      backgroundColor: const Color(0xFF1C63D6),
                    ),
                    child: _saving
                        ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('저장', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}