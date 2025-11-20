import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/condition/presentation/pages/condition_form_page.dart';
import 'features/condition/presentation/pages/statistics_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: '안전운임제 계산기',
          theme: appTheme(),
          home: const SplashScreen(),
          routes: {'/statistics': (context) => const StatisticsPage()},
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // initial: laxgp visible immediately
  bool _showLaxgp = true;
  // after delay: show small pair logos above laxgp, and truck below
  bool _showPairLogos = false;
  bool _showTruck = false;

  @override
  void initState() {
    super.initState();

    // small logos + truck appear together after short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _showPairLogos = true;
        _showTruck = true;
      });
    });

    // 이후 필요하면 페이지 전환 타이밍 추가
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConditionFormPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = ScreenUtil().screenWidth;
    final topOffset = (-0.14 * sw).clamp(-220.0, -40.0);
    final logo1W = (sw * 0.18).clamp(48.0, 120.0);
    final logo2W = (sw * 0.26).clamp(70.0, 180.0);
    final laxgpW = (sw * 0.66).clamp(160.0, 420.0);
    final truckW = (sw * 0.36).clamp(120.0, 300.0);
    final gapBetween = 12.h;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Transform.translate(
            offset: Offset(0, topOffset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 위쪽: small pair logos (appear above laxgp)
                AnimatedSlide(
                  offset: _showPairLogos ? Offset.zero : const Offset(0, -0.2),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showPairLogos ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 420),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'lib/assets/optilo_logo.png',
                          width: logo1W,
                          height: logo1W * 0.42,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 10.w),
                        Image.asset(
                          'lib/assets/lineall_logo.png',
                          width: logo2W,
                          height: logo2W * 0.32,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: gapBetween * 2),

                // 가운데: laxgp (항상 보임)
                Image.asset(
                  'lib/assets/laxgp_logo2.png',
                  width: laxgpW,
                  height: laxgpW * 0.27,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: gapBetween * 9),

                // 아래: 트럭 이미지 (appear from below)
                AnimatedSlide(
                  offset: _showTruck ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showTruck ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: truckW,
                          height: truckW * 0.54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_shipping_rounded,
                            size: truckW * 0.42,
                            color: const Color(0xFF1C63D6),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // 설명 텍스트은 트럭 위 또는 아래 원하시는 위치로 조정 가능
                        Text(
                          '간편하고 정확한 운임 조회',
                          style: TextStyle(
                            color: const Color(0xFF4B6EA8),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
