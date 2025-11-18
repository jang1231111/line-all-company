import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/condition_form_widget.dart';
import '../widgets/fare_result_table.dart';
import '../widgets/selected_fare_bottom_bar.dart';

class ConditionFormPage extends ConsumerStatefulWidget {
  const ConditionFormPage({super.key});

  @override
  ConsumerState<ConditionFormPage> createState() => _ConditionFormPageState();
}

class _ConditionFormPageState extends ConsumerState<ConditionFormPage> {
  static const String _tutorialShownKey = 'condition_tutorial_shown_v1';
  final GlobalKey periodTargetKey = GlobalKey();
  final GlobalKey sectionTargetKey = GlobalKey();
  final GlobalKey regionButtonKey = GlobalKey();
  final GlobalKey roadButtonKey = GlobalKey();
  final GlobalKey surchargeTargetKey = GlobalKey();
  final GlobalKey resultsTargetKey = GlobalKey();

  // 추가된 키들
  final GlobalKey selectedBottomKey = GlobalKey();
  final GlobalKey statsIconKey = GlobalKey();
  final GlobalKey selectedConfirmKey = GlobalKey(); // 확인 버튼 하이라이트용 키

  // 튜토리얼 중복 실행 방지 플래그
  bool _tutorialRunning = false;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  Future<void> _maybeStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_tutorialShownKey) ?? false;
    if (shown) return;

    await _startTutorial(); // 실제 튜토리얼 실행
    await prefs.setBool(_tutorialShownKey, true); // 다시 안보이게 플래그 저장
  }

  Future<void> _startTutorial() async {
    if (_tutorialRunning) return;
    _tutorialRunning = true;
    final screenW = MediaQuery.of(context).size.width;
    // 안정화
    await Future.delayed(const Duration(milliseconds: 120));

    targets = [
      TargetFocus(
        identify: "period_section",
        keyTarget: periodTargetKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.85),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('기간·구간 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      SizedBox(height: 6.h),
                      Text('여기에서 검색할 기간과 구간을 먼저 선택하세요. (필수)', style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "region_search",
        keyTarget: regionButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.75),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('지역 검색 버튼을 눌러 실제 지역 검색을 체험합니다.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "road_search",
        keyTarget: roadButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.75),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('도로명 검색 버튼입니다. 도로명으로 검색해보세요.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "surcharge",
        keyTarget: surchargeTargetKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.85),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('할증 정보: 조회 결과에 적용되는 할증율과 안내입니다.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "results",
        keyTarget: resultsTargetKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.85),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('검색 결과: 리스트에서 항목을 선택하면 상세/결제가 가능합니다.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      // SelectedFareBottomBar 설명
      TargetFocus(
        identify: "selected_bottom",
        keyTarget: selectedBottomKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.85),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('선택한 운임 확인·결제 바: 선택한 항목이 여기에 표시됩니다.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      // 확인 버튼을 눌러보도록 유도하는 타깃
      TargetFocus(
        identify: "selected_confirm",
        keyTarget: selectedConfirmKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.7),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text('확인 버튼을 눌러 선택한 운임을 확인해보세요.', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      // 통계(앱바) 설명
      TargetFocus(
        identify: "statistics",
        keyTarget: statsIconKey,
        shape: ShapeLightFocus.Circle,
        radius: 6,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.7),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('통계 아이콘: 누르면 통계 화면으로 이동합니다. 앱 사용 현황을 확인하세요.', style: TextStyle(fontSize: 13.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    // 화면에 보이도록 스크롤 보정 (존재하면)
    try {
      if (periodTargetKey.currentContext != null) {
        await Scrollable.ensureVisible(periodTargetKey.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.2);
      }
      // 바텀/앱바도 화면에 보이도록(있다면)
      if (selectedBottomKey.currentContext != null) {
        await Scrollable.ensureVisible(selectedBottomKey.currentContext!, duration: const Duration(milliseconds: 300), alignment: 1.0);
      }
      if (statsIconKey.currentContext != null) {
        // 앱바는 이미 보이지만 ensureVisible 호출해도 안전
        await Scrollable.ensureVisible(statsIconKey.currentContext!, duration: const Duration(milliseconds: 200), alignment: 0.0);
      }
    } catch (_) {}

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black54,
      textSkip: "건너뛰기",
      textStyleSkip: TextStyle(color: Colors.white),
      paddingFocus: 8,
      pulseEnable: false,
      focusAnimationDuration: const Duration(milliseconds: 0),
      // 실행 상태 정리
      onFinish: () {
        _tutorialRunning = false;
      },
      onSkip: () {
        _tutorialRunning = false;
        return true;
      },
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 72.h,
            titleSpacing: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.r),
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C63D6), Color(0xFF154E9C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
            title: Row(
              children: [
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    // color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '안전 위탁 운임-차주용',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '신속하고 정확한 운임 산출',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // 앱 사용법: 아이콘+텍스트의 라운드 버튼 (앱 스타일과 일관성 유지)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_tutorialRunning) return;
                    await _startTutorial();
                  },
                  icon: Icon(Icons.help_outline, color: Colors.white, size: 18.sp),
                  label: Text(
                    '앱 사용법',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    backgroundColor: Colors.white.withOpacity(0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    side: BorderSide(color: Colors.white.withOpacity(0.14)),
                  ),
                ),
              ),

              // 기존 통계 아이콘
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/statistics');
                },
                child: Container(
                  key: statsIconKey,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
          backgroundColor: const Color(0xFFF5F7FA),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: ListView(
                      padding: EdgeInsets.all(3.w),
                      children: [
                        ConditionFormWidget(
                          periodTargetKey: periodTargetKey,
                          sectionTargetKey: sectionTargetKey,
                          regionButtonKey: regionButtonKey,
                          roadButtonKey: roadButtonKey,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: FareResultTable(
                        surchargeTargetKey: surchargeTargetKey,
                        resultsTargetKey: resultsTargetKey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: Container(
            key: selectedBottomKey,
            child: SelectedFareBottomBar(
              confirmButtonKey: selectedConfirmKey, // 키 전달
            ),
          ),
        );
      },
    );
  }
}
