import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendFareInputDialog extends StatefulWidget {
  const SendFareInputDialog({super.key});

  /// 사용 예:
  /// final result = await SendFareInputDialog.show(context);
  /// result == null -> 취소
  /// result['consignor'], result['email'] 사용
  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SendFareInputDialog(),
    );
  }

  @override
  State<SendFareInputDialog> createState() => _SendFareInputDialogState();
}

class _SendFareInputDialogState extends State<SendFareInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _consignorCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _consignorCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '이메일을 입력하세요.';
    final email = v.trim();
    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email) ? null : '유효한 이메일을 입력하세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.send, color: Colors.indigo, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '전송 정보 입력',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '화주명과 이메일을 입력하세요.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _consignorCtrl,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: '화주명',
                      hintText: '회사명 또는 개인명',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '화주명을 입력하세요.' : null,
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@company.com',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    validator: _emailValidator,
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      final result = {
                        'consignor': _consignorCtrl.text.trim(),
                        'email': _emailCtrl.text.trim(),
                      };
                      Navigator.of(context).pop(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('전송', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
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