import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 화주명만 입력받는 저장 다이얼로그 (SendFareInputDialog 스타일에 맞춤)
/// 사용: final consignor = await SaveConsignorDialog.show(context);
class SaveConsignorDialog extends StatefulWidget {
  const SaveConsignorDialog({Key? key}) : super(key: key);

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
  bool _canSubmit = false;

  final Color primaryColor = Colors.indigo;
  final Color titleColor = const Color(0xFF2D365C);
  final Color surfaceColor = const Color(0xFFF3F6FB);
  final Color inputSurface = Colors.white;
  final Color textPrimary = const Color(0xFF2D365C);

  @override
  void initState() {
    super.initState();
    _consignorCtrl.addListener(_updateCanSubmit);
  }

  @override
  void dispose() {
    _consignorCtrl.removeListener(_updateCanSubmit);
    _consignorCtrl.dispose();
    super.dispose();
  }

  void _updateCanSubmit() {
    final next = _consignorCtrl.text.trim().isNotEmpty;
    if (next != _canSubmit) setState(() => _canSubmit = next);
  }

  void _onCancel() {
    if (_saving) return;
    Navigator.of(context).pop<String?>(null);
  }

  void _onSave() {
    if (!_canSubmit) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);

    // 짧은 딜레이로 로딩 표출 후 값 반환
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      Navigator.of(context).pop<String>(_consignorCtrl.text.trim());
    });
  }

  InputDecoration _input(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black38),
      filled: true,
      fillColor: inputSurface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      prefixIcon: icon == null
          ? null
          : Padding(
              padding: EdgeInsets.only(left: 8.w, right: 6.w),
              child: Icon(icon, size: 18.sp, color: primaryColor),
            ),
      prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: surfaceColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 540.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.save, color: Colors.indigo, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '화주명은 필수 항목입니다.',
                          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // 입력 카드
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        enabled: !_saving,
                        controller: _consignorCtrl,
                        autofocus: true,
                        decoration: _input('화주명', icon: Icons.business),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return '화주명을 입력해주세요.';
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSave(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // actions: 취소 / 저장
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _onCancel,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text('취소'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_canSubmit || _saving ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? Colors.indigo : Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: _saving
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text('저장', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}