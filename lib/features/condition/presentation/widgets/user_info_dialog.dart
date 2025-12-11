import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInfoDialog extends StatefulWidget {
  const UserInfoDialog({super.key});

  /// 호출 편의용 정적 함수: barrierDismissible=false 이므로 반드시 입력해야 닫힘
  static Future<void> showRequired(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UserInfoDialog(),
    );
  }

  @override
  State<UserInfoDialog> createState() => _UserInfoDialogState();
}

class _UserInfoDialogState extends State<UserInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _saving = false;
  bool _loading = true;

  // FocusNodes + field keys to ensure focused field is visible when keyboard appears
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final GlobalKey _companyKey = GlobalKey();
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();

  void _attachFocusListeners() {
    _companyFocus.addListener(
      () => _onFieldFocusChanged(_companyFocus, _companyKey),
    );
    _nameFocus.addListener(() => _onFieldFocusChanged(_nameFocus, _nameKey));
    _phoneFocus.addListener(() => _onFieldFocusChanged(_phoneFocus, _phoneKey));
    _emailFocus.addListener(() => _onFieldFocusChanged(_emailFocus, _emailKey));
  }

  void _removeFocusListeners() {
    _companyFocus.removeListener(
      () => _onFieldFocusChanged(_companyFocus, _companyKey),
    );
    _nameFocus.removeListener(() => _onFieldFocusChanged(_nameFocus, _nameKey));
    _phoneFocus.removeListener(
      () => _onFieldFocusChanged(_phoneFocus, _phoneKey),
    );
    _emailFocus.removeListener(
      () => _onFieldFocusChanged(_emailFocus, _emailKey),
    );
  }

  void _onFieldFocusChanged(FocusNode node, GlobalKey key) {
    if (!node.hasFocus) return;
    // wait a frame so keyboard has started animating, then ensure visible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.25, // show a bit above center
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _attachFocusListeners();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _companyCtrl.text = prefs.getString('user_company') ?? '';
    _nameCtrl.text = prefs.getString('user_name') ?? '';
    _phoneCtrl.text = prefs.getString('user_phone') ?? '';
    _emailCtrl.text = prefs.getString('user_email') ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _removeFocusListeners();
    _companyFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _companyCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_company', _companyCtrl.text.trim());
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_phone', _phoneCtrl.text.trim());
    await prefs.setString('user_email', _emailCtrl.text.trim());
    await prefs.setBool('user_info_saved_v1', true);
    if (mounted) Navigator.of(context).pop();
  }

  String? _notEmptyValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '필수 입력입니다';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '필수 입력입니다';
    final emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailReg.hasMatch(v.trim())) return '유효한 이메일을 입력하세요';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '필수 입력입니다';
    final phone = v.trim();
    final phoneReg = RegExp(r'^[0-9\-\+\s]{6,20}$');
    if (!phoneReg.hasMatch(phone)) return '유효한 연락처를 입력하세요';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1C63D6);
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom;
    // 키보드 높이를 뺀 사용 가능한 높이
    final availableHeight = mq.size.height - keyboard - 48.0; // 상하여유 48px

    return WillPopScope(
      // 뒤로가기 금지
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: SizedBox(
          height: (availableHeight * 0.9).h,
          child: Builder(
            builder: (context) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520.w,
                    maxHeight: (availableHeight * 0.9).h,
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _loading
                          ? SizedBox(
                              height: 140.h,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primary,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primary,
                                            const Color(0xFF154E9C),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '사용자 정보 등록',
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '앱을 사용하기 위해 아래 정보를 입력해주세요',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),
                                // Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildField(
                                        controller: _companyCtrl,
                                        label: '상호(회사명)',
                                        icon: Icons.business,
                                        validator: _notEmptyValidator,
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildField(
                                        controller: _nameCtrl,
                                        label: '성명',
                                        icon: Icons.person,
                                        validator: _notEmptyValidator,
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildField(
                                        controller: _phoneCtrl,
                                        label: '연락처',
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                        validator: _phoneValidator,
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildField(
                                        controller: _emailCtrl,
                                        label: '이메일',
                                        icon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: _emailValidator,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16.w,
                                      color: Colors.black45,
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        '입력하신 정보는 메일 전송시, 발신자 정보에 사용됩니다.',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _save,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                    ),
                                    child: _saving
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            '저장하고 계속하기',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // return a TextFormField with appropriate focusNode and key mapping
    FocusNode node;
    GlobalKey key;
    if (label.contains('회사') || label.contains('상호')) {
      node = _companyFocus;
      key = _companyKey;
    } else if (label == '성명') {
      node = _nameFocus;
      key = _nameKey;
    } else if (label == '연락처') {
      node = _phoneFocus;
      key = _phoneKey;
    } else {
      node = _emailFocus;
      key = _emailKey;
    }

    return Container(
      key: key,
      child: TextFormField(
        controller: controller,
        focusNode: node,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 20.w),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 12.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
