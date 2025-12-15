import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendFareInputDialog extends StatefulWidget {
  const SendFareInputDialog({super.key});

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
  final _recipientCtrl = TextEditingController();
  final _recipientEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // FocusNodes for input fields
  final FocusNode _consignorFocus = FocusNode();
  final FocusNode _recipientFocus = FocusNode();
  final FocusNode _recipientEmailFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  // Keys for each input container to ensure visibility
  final GlobalKey _consignorKey = GlobalKey();
  final GlobalKey _recipientKey = GlobalKey();
  final GlobalKey _recipientEmailKey = GlobalKey();
  final GlobalKey _companyKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();
  final GlobalKey _noteKey = GlobalKey();

  // Scroll controller for the dialog's SingleChildScrollView
  final ScrollController _scrollController = ScrollController();

  // Keyboard visibility subscription
  late final Stream<bool> _keyboardStream;
  StreamSubscription<bool>? _kbSub;

  bool _sending = false;
  bool _canSubmit = false;
  bool _expanded = false;

  // recent recipients stored as "name|email"
  final List<Map<String, String>> _recentRecipients = [];
  static const _recentKey = 'recent_recipients_v1';
  static const int _recentMax = 6;

  // Palette aligned with SelectedFareDialog for consistent readability
  final Color primaryColor = Colors.indigo;
  final Color titleColor = const Color(0xFF2D365C);
  final Color surfaceColor = const Color(0xFFF3F6FB);
  final Color inputSurface = Colors.white;
  final Color textPrimary = const Color(0xFF2D365C);

  @override
  void initState() {
    super.initState();
    _consignorCtrl.addListener(_updateCanSubmit);
    _recipientCtrl.addListener(_updateCanSubmit);
    _recipientEmailCtrl.addListener(_updateCanSubmit);
    // focus listeners: when a field gets focus, ensure it is visible
    _attachFocusListeners();
    // keyboard visibility subscription to re-check visible field when keyboard opens
    _keyboardStream = KeyboardVisibilityController().onChange;
    _kbSub = _keyboardStream.listen((visible) {
      if (visible) {
        // slight delay to allow keyboard animation then ensure focused field visible
        Future.delayed(
          const Duration(milliseconds: 120),
          _ensureFocusedVisible,
        );
      }
    });
    _loadRecentRecipients();
  }

  void _updateCanSubmit() {
    final consignor = _consignorCtrl.text.trim();
    final recipient = _recipientCtrl.text.trim();
    final email = _recipientEmailCtrl.text.trim();
    final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    final next = consignor.isNotEmpty && recipient.isNotEmpty && emailValid;
    if (next != _canSubmit) setState(() => _canSubmit = next);
  }

  // String _missingFieldsText() {
  //   final missing = <String>[];
  //   if (_consignorCtrl.text.trim().isEmpty) missing.add('화주명');
  //   if (_recipientCtrl.text.trim().isEmpty) missing.add('수신인');
  //   final email = _recipientEmailCtrl.text.trim();
  //   final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  //   if (email.isEmpty || !emailValid) missing.add('유효한 이메일');
  //   if (missing.isEmpty) return '';
  //   return '${missing.join(' · ')} 입력 필요';
  // }

  Future<void> _loadRecentRecipients() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? [];
    _recentRecipients.clear();
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2)
        _recentRecipients.add({'name': parts[0], 'email': parts[1]});
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveRecentRecipient(String name, String email) async {
    if (name.trim().isEmpty || email.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final keyVal = '${name.trim()}|${email.trim()}';
    final list = prefs.getStringList(_recentKey) ?? [];
    list.removeWhere(
      (e) => e.split('|').length >= 2 && e.split('|')[1] == email.trim(),
    );
    list.insert(0, keyVal);
    if (list.length > _recentMax) list.removeRange(_recentMax, list.length);
    await prefs.setStringList(_recentKey, list);
    await _loadRecentRecipients();
  }

  Future<void> _removeRecentAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_recentKey, list);
      await _loadRecentRecipients();
    }
  }

  @override
  void dispose() {
    _consignorCtrl.removeListener(_updateCanSubmit);
    _recipientCtrl.removeListener(_updateCanSubmit);
    _recipientEmailCtrl.removeListener(_updateCanSubmit);
    _consignorCtrl.dispose();
    _recipientCtrl.dispose();
    _recipientEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    // dispose focus nodes
    _consignorFocus.dispose();
    _recipientFocus.dispose();
    _recipientEmailFocus.dispose();
    _companyFocus.dispose();
    _phoneFocus.dispose();
    _noteFocus.dispose();
    _kbSub?.cancel();
    _scrollController.dispose();
    super.dispose();
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

  void _attachFocusListeners() {
    final map = {
      _consignorFocus: _consignorKey,
      _recipientFocus: _recipientKey,
      _recipientEmailFocus: _recipientEmailKey,
      _companyFocus: _companyKey,
      _phoneFocus: _phoneKey,
      _noteFocus: _noteKey,
    };
    map.forEach((node, key) {
      node.addListener(() {
        if (node.hasFocus) {
          // wait frame so layout with keyboard settled
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(
              const Duration(milliseconds: 80),
              () => _ensureVisibleByKey(key),
            );
          });
        }
      });
    });
  }

  void _ensureFocusedVisible() {
    final nodes = <FocusNode, GlobalKey>{
      _consignorFocus: _consignorKey,
      _recipientFocus: _recipientKey,
      _recipientEmailFocus: _recipientEmailKey,
      _companyFocus: _companyKey,
      _phoneFocus: _phoneKey,
      _noteFocus: _noteKey,
    };
    for (final entry in nodes.entries) {
      if (entry.key.hasFocus) {
        _ensureVisibleByKey(entry.value);
        break;
      }
    }
  }

  void _ensureVisibleByKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: 0.12,
    );
  }

  Widget _clearable(
    TextEditingController c, {
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool autofocus = false,
    FocusNode? focusNode,
    GlobalKey? fieldKey,
  }) {
    return Container(
      key: fieldKey,
      child: TextFormField(
        enabled: !_sending,
        controller: c,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: keyboardType,
        style: TextStyle(color: textPrimary),
        decoration: _input(hint, icon: icon).copyWith(
          suffixIcon: c.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear, size: 18.sp, color: Colors.black45),
                  onPressed: () => setState(() => c.clear()),
                ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          if ((c == _consignorCtrl || c == _recipientCtrl) &&
              (v == null || v.trim().isEmpty))
            return '필수 입력';
          if (c == _recipientEmailCtrl) {
            if (v == null || v.trim().isEmpty) return '필수 입력';
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                ? null
                : '유효한 이메일을 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }

  Widget _recentChips() {
    if (_recentRecipients.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _recentRecipients.length,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, idx) {
          final item = _recentRecipients[idx];
          final name = (item['name'] ?? '').trim();
          final label = name.isEmpty
              ? '알 수 없음'
              : (name.length > 14 ? '${name.substring(0, 14)}…' : name);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _recipientCtrl.text = item['name'] ?? '';
                _recipientEmailCtrl.text = item['email'] ?? '';
                _updateCanSubmit();
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                constraints: BoxConstraints(minWidth: 64.w, maxWidth: 130.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: inputSurface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.indigo.shade50),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => _removeRecentAt(idx),
                      child: Icon(
                        Icons.close,
                        size: 14.sp,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmSend() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('메일 전송 확인'),
        content: const Text('입력한 내용으로 메일을 전송하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
    final screenH = mq.size.height;
    final dialogMaxH = screenH * 0.9;
    return Dialog(
      backgroundColor: surfaceColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        height: screenH * 0.6,
        child: Center(
          child: ConstrainedBox(
            // width는 네가 쓰던대로, height는 실제 constraints 기준으로
            constraints: BoxConstraints(
              maxWidth: 640.w,
              maxHeight: dialogMaxH, // 원하면 *0.9 안 해도 됨
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // header (aligned with SelectedFareDialog)
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.email,
                              color: Colors.indigo,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '메일 전송',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '선택한 항목을 이메일로 전송합니다.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.close,
                              size: 20.sp,
                              color: Colors.black54,
                            ),
                            onPressed: _sending
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // Card-like area for inputs for improved readability
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_recentRecipients.isNotEmpty) ...[
                              Text(
                                '최근 수신인',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _recentChips(),
                              SizedBox(height: 10.h),
                            ],
                            Text(
                              '수신인 정보',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Simple constrained form area. Focus listeners + keyboard_visibility will ensure fields are visible.
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.26,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _clearable(
                                        _consignorCtrl,
                                        hint: '상호,화주명',
                                        icon: Icons.business,
                                        autofocus: true,
                                        focusNode: _consignorFocus,
                                        fieldKey: _consignorKey,
                                      ),
                                      SizedBox(height: 10.h),
                                      _clearable(
                                        _recipientCtrl,
                                        hint: '수신인',
                                        icon: Icons.person,
                                        focusNode: _recipientFocus,
                                        fieldKey: _recipientKey,
                                      ),
                                      SizedBox(height: 10.h),
                                      _clearable(
                                        _recipientEmailCtrl,
                                        hint: '수신인 이메일',
                                        icon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        focusNode: _recipientEmailFocus,
                                        fieldKey: _recipientEmailKey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // additional info
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50.withOpacity(
                                  0.12,
                                ), // 배경 색상 추가
                                borderRadius: BorderRadius.circular(
                                  12.r,
                                ), // 모서리 둥글게
                                border: Border.all(
                                  color: Colors.indigo.shade100,
                                ), // 연한 테두리
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        setState(() => _expanded = !_expanded),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '수신인 정보(선택)',
                                          style: TextStyle(color: textPrimary),
                                        ),
                                        Icon(
                                          _expanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Column(
                                      children: [
                                        _clearable(
                                          _phoneCtrl,
                                          hint: '연락처',
                                          icon: Icons.phone,
                                          keyboardType: TextInputType.phone,
                                          focusNode: _phoneFocus,
                                          fieldKey: _phoneKey,
                                        ),
                                        SizedBox(height: 10.h),
                                        Container(
                                          key: _noteKey,
                                          child: TextFormField(
                                            enabled: !_sending,
                                            controller: _noteCtrl,
                                            maxLines: 1,
                                            focusNode: _noteFocus,
                                            style: TextStyle(
                                              color: textPrimary,
                                            ),
                                            decoration: _input(
                                              '비고',
                                              icon: Icons.note,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    crossFadeState: _expanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 200),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // 버튼 영역은 항상 렌더링합니다. 전송 가능 여부는 버튼의 onPressed로 제어합니다.
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _sending
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
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
                            child: ElevatedButton.icon(
                              onPressed: (_canSubmit && !_sending)
                                  ? () async {
                                      final confirm = await _confirmSend();
                                      if (confirm != true) return;
                                      if (_formKey.currentState?.validate() !=
                                          true)
                                        return;
                                      setState(() => _sending = true);

                                      final res = <String, String>{
                                        'consignor': _consignorCtrl.text.trim(),
                                        'recipient': _recipientCtrl.text.trim(),
                                        'recipient_email': _recipientEmailCtrl
                                            .text
                                            .trim(),
                                        'recipient_phone': _phoneCtrl.text
                                            .trim(),
                                        'note': _noteCtrl.text.trim(),
                                      };
                                      await _saveRecentRecipient(
                                        res['recipient'] ?? '',
                                        res['recipient_email'] ?? '',
                                      );
                                      if (mounted)
                                        Navigator.of(context).pop(res);
                                    }
                                  : null,
                              icon: _sending
                                  ? const SizedBox.shrink()
                                  : Icon(
                                      Icons.send,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                              label: _sending
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '메일 전송',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canSubmit
                                    ? Colors.indigo
                                    : Colors.grey.shade300,
                                foregroundColor: _canSubmit
                                    ? Colors.white
                                    : Colors.black38,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
