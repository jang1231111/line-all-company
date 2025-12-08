import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSaved();
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
    return WillPopScope(
      // 뒤로가기 금지
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: _loading
                ? SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: primary)))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [primary, const Color(0xFF154E9C)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('사용자 정보 등록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('앱을 사용하기 위해 아래 정보를 입력해주세요', style: TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(controller: _companyCtrl, label: '상호(회사명)', icon: Icons.business, validator: _notEmptyValidator),
                            const SizedBox(height: 10),
                            _buildField(controller: _nameCtrl, label: '성명', icon: Icons.person, validator: _notEmptyValidator),
                            const SizedBox(height: 10),
                            _buildField(controller: _phoneCtrl, label: '연락처', icon: Icons.phone, keyboardType: TextInputType.phone, validator: _phoneValidator),
                            const SizedBox(height: 10),
                            _buildField(controller: _emailCtrl, label: '이메일', icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: _emailValidator),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Privacy note
                      Row(
                        children: const [
                          Icon(Icons.info_outline, size: 16, color: Colors.black45),
                          SizedBox(width: 6),
                          Expanded(child: Text('입력하신 정보는 기기 내 저장되며 외부로 자동 전송되지 않습니다.', style: TextStyle(fontSize: 12, color: Colors.black54))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('저장하고 계속하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
