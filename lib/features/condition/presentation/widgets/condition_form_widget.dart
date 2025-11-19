import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 반응형 패키지 추가
import 'package:line_all/features/condition/domain/models/road_name_address.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/period_dropdown_row.dart';
import 'package:line_all/features/condition/presentation/widgets/region_selectors_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/road_name_search_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/search_type_selector_row.dart';

class ConditionFormWidget extends ConsumerStatefulWidget {
  final GlobalKey? periodTargetKey;
  final GlobalKey? sectionTargetKey;
  final GlobalKey? serachKey;
  final GlobalKey? regionButtonKey;
  final GlobalKey? roadButtonKey;

  const ConditionFormWidget({
    super.key,
    this.periodTargetKey,
    this.sectionTargetKey,
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
  final _periodFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _sectionFocusNode = FocusNode();

  final _periodKey = GlobalKey();
  final _typeKey = GlobalKey();
  final _sectionKey = GlobalKey();

  bool _periodError = false;
  bool _sectionError = false;

  @override
  void dispose() {
    _periodFocusNode.dispose();
    _typeFocusNode.dispose();
    _sectionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _focusAndScroll(
    GlobalKey key,
    FocusNode focusNode,
    String message,
  ) async {
    // focusNode.requestFocus();
    // await Scrollable.ensureVisible(
    //   key.currentContext!,
    //   duration: const Duration(milliseconds: 200),
    //   curve: Curves.easeInOut,
    //   alignment: 0.2,
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18.sp)),
      ),
    );
  }

  void _validateAndHandleSearchType(Function onValid) async {
    final condition = ref.read(conditionViewModelProvider);
    setState(() {
      _periodError = condition.period == null || condition.period!.isEmpty;
      _sectionError = condition.section == null || condition.section!.isEmpty;
    });

    if (_periodError) {
      await _focusAndScroll(_periodKey, _periodFocusNode, '기간을 선택해주세요.');
      return;
    }
    if (_sectionError) {
      await _focusAndScroll(_sectionKey, _sectionFocusNode, '구간을 선택해주세요.');
      return;
    }
    onValid();
  }

  @override
  Widget build(BuildContext context) {
    final condition = ref.watch(conditionViewModelProvider);
    final viewModel = ref.read(conditionViewModelProvider.notifier);

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
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14.h),
                    // Period (튜토리얼용 key 전달)
                    PeriodDropdownRow(
                      key: widget.periodTargetKey ?? _periodKey,
                      periodFocusNode: _periodFocusNode,
                      typeFocusNode: _typeFocusNode,
                      sectionFocusNode: _sectionFocusNode,
                      typeKey: _typeKey,
                      sectionKey: widget.sectionTargetKey ?? _sectionKey,
                    ),
                    SizedBox(height: 10.h),
                    // 검색 버튼들을 인라인으로 두어 개별 키 부여
                    Container(
                      key: widget.serachKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              key: widget.regionButtonKey,
                              icon: const Icon(Icons.search),
                              label: const Text('지역 검색'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                              onPressed: () {
                                _validateAndHandleSearchType(() {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const RegionSelectorsDialog(),
                                  );
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              key: widget.roadButtonKey,
                              icon: const Icon(Icons.place),
                              label: const Text('도로명 검색'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {
                                _validateAndHandleSearchType(() async {
                                  RoadNameAddress? result = await showDialog(
                                    context: context,
                                    builder: (context) => const RoadNameSearchDialog(),
                                  );
                                  if (result != null) {
                                    await viewModel.searchByRoadName(result);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
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
