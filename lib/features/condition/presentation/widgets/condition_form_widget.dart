import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 반응형 패키지 추가
import 'package:line_all/features/condition/domain/models/road_name_address.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/period_dropdown_row.dart';
import 'package:line_all/features/condition/presentation/widgets/region_selectors_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/road_name_search_dialog.dart';

class ConditionFormWidget extends ConsumerStatefulWidget {
  final GlobalKey periodTargetKey;
  final GlobalKey typeTargetKey;
  final GlobalKey sectionTargetKey;
  final GlobalKey? serachKey;
  final GlobalKey? regionButtonKey;
  final GlobalKey? roadButtonKey;

  const ConditionFormWidget({
    super.key,
    required this.periodTargetKey,
    required this.typeTargetKey,
    required this.sectionTargetKey,
    this.serachKey,
    this.regionButtonKey,
    this.roadButtonKey,
  });

  @override
  ConsumerState<ConditionFormWidget> createState() =>
      _ConditionFormWidgetState();
}

class _ConditionFormWidgetState extends ConsumerState<ConditionFormWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

    final isFullySelected = condition.period?.isNotEmpty == true &&
        condition.type?.isNotEmpty == true &&
        condition.section?.isNotEmpty == true;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1100.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAFF),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: Colors.blue.shade100, width: 1.2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.06),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.indigo,
                          size: 20.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '운임 계산 조건 설정',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // Period (튜토리얼용 key 전달)
                    PeriodDropdownRow(
                      key: widget.periodTargetKey,
                      typeKey: widget.typeTargetKey,
                      sectionKey: widget.sectionTargetKey,
                    ),
                    SizedBox(height: 4.h),
                    // 검색 버튼들을 인라인으로 두어 개별 키 부여
                    Container(
                      key: widget.serachKey,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: MediaQuery(
                              // 버튼 내부 텍스트/레이아웃의 시스템 textScaleFactor 영향을 차단
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              child: ElevatedButton.icon(
                                key: widget.regionButtonKey,
                                icon: Icon(Icons.search, size: 18.sp),
                                label: Text('지역 검색', style: TextStyle(fontSize: 13.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  minimumSize: Size(double.infinity, 44.h), // 고정 높이
                                ),
                                onPressed: isFullySelected
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const RegionSelectorsDialog(),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 6,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              child: ElevatedButton.icon(
                                key: widget.roadButtonKey,
                                icon: Icon(Icons.place, size: 18.sp),
                                label: Text('도로명, 지번 검색', style: TextStyle(fontSize: 13.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  minimumSize: Size(double.infinity, 44.h),
                                ),
                                onPressed: isFullySelected
                                    ? () async {
                                        RoadNameAddress? result = await showDialog(
                                          context: context,
                                          builder: (context) => const RoadNameSearchDialog(),
                                        );
                                        if (result != null) {
                                          await viewModel.searchByRoadName(result);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
