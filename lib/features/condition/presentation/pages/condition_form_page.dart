import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/widgets/ToolSheet.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/condition_form_widget.dart';
import '../widgets/fare_result_table.dart';
import '../widgets/selected_fare_bottom_bar.dart';
import '../widgets/user_info_dialog.dart';

class ConditionFormPage extends ConsumerStatefulWidget {
  const ConditionFormPage({super.key});

  @override
  ConsumerState<ConditionFormPage> createState() => _ConditionFormPageState();
}

class _ConditionFormPageState extends ConsumerState<ConditionFormPage> {
  static const String _tutorialShownKey = 'condition_tutorial_shown_v1';
  final GlobalKey periodTargetKey = GlobalKey();
  final GlobalKey typeTargetKey = GlobalKey();
  final GlobalKey sectionTargetKey = GlobalKey();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey regionButtonKey = GlobalKey();
  final GlobalKey roadButtonKey = GlobalKey();
  final GlobalKey surchargeTargetKey = GlobalKey();
  final GlobalKey resultsTargetKey = GlobalKey();

  // 추가된 키들
  final GlobalKey selectedBottomKey = GlobalKey();
  final GlobalKey selectedConfirmKey = GlobalKey(); // 확인 버튼 하이라이트용 키
  final GlobalKey statsIconKey = GlobalKey();
  final GlobalKey tutorialKey = GlobalKey();

  // 튜토리얼 중복 실행 방지 플래그
  bool _tutorialRunning = false;
  List<TargetFocus> targets = [];
  TutorialCoachMark? _tutorialCoachMark; // 튜토리얼 인스턴스 보관

  // Overlay로 전역 터치 흡수 처리
  OverlayEntry? _tutorialBlockingOverlay;

  // 열고 싶은 사이트 URL (실제 도메인으로 교체)
  static const String _companyUrl = 'http://www.lineall.co.kr';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeShowUserInfoDialog(); // 최초 사용자 정보 입력(필수)
      _maybeStartTutorial();
    });
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

    // 키들이 준비될 때까지 대기 (타깃들이 렌더되기 전 호출로 인한 NPE 방지)
    await _waitForKeysReady([
      periodTargetKey,
      searchKey,
      regionButtonKey,
      roadButtonKey,
      surchargeTargetKey,
      resultsTargetKey,
      selectedBottomKey,
      selectedConfirmKey,
      statsIconKey,
      tutorialKey,
    ], timeout: const Duration(milliseconds: 1200));

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
                      Text(
                        '기간·구간 선택',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '검색할 기간과 구간을 먼저 선택하세요. \n필수로 입력해야합니다.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "search",
        keyTarget: searchKey,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '운임 건 검색',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '구간과 기간을 선택했으면 \n주소를 입력해서 운임 건을 검색해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지역 검색',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '지역명을 통해 운임 건을 검색해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '도로명 검색',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '정확한 도로명 주소를 알고 있을때에는\n도로명으로 검색해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '할증 적용',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '할증 적용 버튼을 누르면\n조회 결과에 적용되는 할증을 추가할 수 있습니다.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '운임 검색 결과창',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '검색 결과창 입니다. \n운임 건을 검색하여 내 운임 건 목록에 추가해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택된 운임 건 수',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '현재 선택된 운임 건 수가 표시됩니다.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택된 운임 건 확인',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '확인 버튼을 눌러 선택한 운임을 확인해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
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
        shape: ShapeLightFocus.RRect,
        radius: 6,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.7),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 운임 건 통계',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '내가 저장한 운임 건 목록을 확인할수 있습니다.\n사용 현황을 확인해보세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 통계(앱바) 설명
      TargetFocus(
        identify: "tutorial",
        keyTarget: tutorialKey,
        shape: ShapeLightFocus.RRect,
        radius: 6,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW * 0.7),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '앱 사용법',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '사용 방법을 다시 보고싶을 때에는 이 버튼을 눌러주세요.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    // context가 없는 keyTarget을 가진 타깃은 제거
    targets = targets.where((t) {
      final k = t.keyTarget;
      return k == null || k.currentContext != null;
    }).toList();

    // 화면에 보이도록 스크롤 보정 (존재하면)
    try {
      if (periodTargetKey.currentContext != null) {
        await Scrollable.ensureVisible(
          periodTargetKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.2,
        );
      }
      if (selectedBottomKey.currentContext != null) {
        await Scrollable.ensureVisible(
          selectedBottomKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 1.0,
        );
      }
      if (statsIconKey.currentContext != null) {
        await Scrollable.ensureVisible(
          statsIconKey.currentContext!,
          duration: const Duration(milliseconds: 200),
          alignment: 0.0,
        );
      }
    } catch (_) {}

    // TutorialCoachMark는 내부 클릭 콜백에서 직접 next()를 호출하지 않음.
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black54,
      textSkip: "",
      textStyleSkip: TextStyle(color: Colors.white),
      paddingFocus: 8,
      pulseEnable: false,
      focusAnimationDuration: const Duration(milliseconds: 0),
      onClickOverlay: (_) {},
      onClickTarget: (_) {},
      onFinish: () {
        _tutorialRunning = false;
        _tutorialCoachMark = null;
        if (_tutorialBlockingOverlay != null) {
          _tutorialBlockingOverlay!.remove();
          _tutorialBlockingOverlay = null;
        }
      },
      onSkip: () {
        _tutorialRunning = false;
        _tutorialCoachMark = null;
        if (_tutorialBlockingOverlay != null) {
          _tutorialBlockingOverlay!.remove();
          _tutorialBlockingOverlay = null;
        }
        return false;
      },
    );
    _tutorialCoachMark!.show(context: context);

    // 튜토리얼 오버레이 위에 최상단 overlay를 한 번 더 넣어 모든 터치를 흡수하고
    // onPointerUp에서 next()를 호출하도록 함.
    _tutorialBlockingOverlay = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerUp: (event) {
            if (!_tutorialRunning) return;
            try {
              _tutorialCoachMark?.next();
            } catch (_) {}
          },
          child: Container(color: Colors.transparent),
        ),
      ),
    );

    // show 이후에 삽입하도록 소량 딜레이
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_tutorialRunning) return;
      try {
        Overlay.of(context)?.insert(_tutorialBlockingOverlay!);
      } catch (_) {}
    });
  }

  Future<void> _launchWebsite() async {
    final uri = Uri.parse(_companyUrl);
    try {
      // if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(const SnackBar(content: Text('웹사이트를 열 수 없습니다.')));
      // }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  // 파일 맨 아래 근처에 추가 (조건: dialog가 로컬 prefs에 저장되어 있지 않으면 강제 표시)
  Future<void> _maybeShowUserInfoDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('user_info_saved_v1') ?? false;
    if (shown) return;
    // barrierDismissible=false 이므로 사용자가 반드시 입력해야 닫힘
    await UserInfoDialog.showRequired(context);
  }

  @override
  void dispose() {
    if (_tutorialBlockingOverlay != null) {
      _tutorialBlockingOverlay!.remove();
      _tutorialBlockingOverlay = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: false,
      builder: (context, child) {
        return Scaffold(
          // AppBar 전체를 PreferredSize + MediaQuery로 감싸서
          // 시스템 textScaleFactor(접근성 폰트 크기)의 영향으로 높이가 변하지 않게 고정
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(72.h),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                toolbarHeight: 72.h, // 고정 높이 (ScreenUtil 단위)
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
                // title / actions 내부도 MediaQuery 영향 제외로 안전
                title: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _launchWebsite,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.asset(
                                    'lib/assets/lineall_logo2.png',
                                    width: 130.w,
                                    height: 20.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.asset(
                                    'lib/assets/laxgp_logo2.png',
                                    width: 80.w,
                                    height: 20.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(Icons.local_shipping, color: Colors.white, size: 18.sp),
                              SizedBox(width: 7.w),
                              Text(
                                '안전운임 - 화주 및 운송사용',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/statistics'),
                    child: Container(
                      key: statsIconKey,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 20.sp),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.r),
                          ),
                        ),
                        builder: (ctx) => ToolsSheet(
                          onStartTutorial: () {
                            if (_tutorialRunning) return;
                            _startTutorial();
                          },
                          onShowUserInfo: () => UserInfoDialog.showRequired(context),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5F7FA),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    flex: 11,
                    child: ListView(
                      padding: EdgeInsets.all(3.w),
                      children: [
                        ConditionFormWidget(
                          periodTargetKey: periodTargetKey,
                          typeTargetKey: typeTargetKey,
                          sectionTargetKey: sectionTargetKey,
                          serachKey: searchKey,
                          regionButtonKey: regionButtonKey,
                          roadButtonKey: roadButtonKey,
                        ),
                        SizedBox(height: 6.h),
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

  // keys 준비 대기 헬퍼
  Future<void> _waitForKeysReady(List<GlobalKey> keys, {Duration timeout = const Duration(milliseconds: 800)}) async {
    final sw = Stopwatch()..start();
    while (sw.elapsed < timeout) {
      var allReady = true;
      for (final k in keys) {
        if (k == null) continue;
        if (k.currentContext == null) {
          allReady = false;
          break;
        }
      }
      if (allReady) return;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
