import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToolsSheet extends StatelessWidget {
  final VoidCallback onStartTutorial;
  final VoidCallback onShowUserInfo;

  const ToolsSheet({
    Key? key,
    required this.onStartTutorial,
    required this.onShowUserInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 16.h),

              // 카드 행
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ActionCard(
                      color: const Color.fromARGB(255, 235, 163, 161), // 튜토리얼
                      icon: Icons.help_outline,
                      title: '튜토리얼',
                      subtitle: '앱 사용법 확인',
                      onTap: () {
                        Navigator.of(context).pop();
                        onStartTutorial();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ActionCard(
                      color: const Color.fromARGB(255, 50, 69, 190), // 회사정보
                      icon: Icons.info_outline,
                      title: '사용자 정보 수정',
                      subtitle: '발신자 설정',
                      onTap: () {
                        Navigator.of(context).pop();
                        onShowUserInfo();
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 색 대비 계산 (자연스럽게 눈에 잘 들어오도록)
    final bool useDarkText = color.computeLuminance() > 0.45;
    final Color titleColor = useDarkText ? Colors.black87 : Colors.white;
    final Color subtitleColor = useDarkText ? Colors.black54 : Colors.white70;
    final Color iconCircleBg = useDarkText ? Colors.white : Colors.white.withOpacity(0.12);
    final Color iconColor = useDarkText ? color.withOpacity(0.95) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 120.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            // 은은한 톤 차이의 그라데이션 (과하지 않음)
            gradient: LinearGradient(
              begin: Alignment(-0.8, -0.6),
              end: Alignment(0.8, 0.6),
              colors: [
                color.withOpacity(0.98),
                color.withOpacity(0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12.r,
                offset: Offset(0, 6.h),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 원형 (미세한 테두리 + 그림자)
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: iconCircleBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 26.sp)),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  shadows: [
                    // 아주 약한 텍스트 쉐도우로 가독성 보강 (과하지 않음)
                    Shadow(color: Colors.black.withOpacity(0.08), blurRadius: 2.r),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
