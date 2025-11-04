import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/providers/condition_provider.dart';
import 'package:line_all/features/condition/presentation/widgets/header.dart';
import 'package:line_all/features/condition/presentation/widgets/period_dropdown_row.dart';
import 'package:line_all/features/condition/presentation/widgets/region_selectors_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/road_name_search_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/search_type_selector_row.dart';

import '../../domain/models/condition.dart';

class ConditionFormWidget extends ConsumerStatefulWidget {
  const ConditionFormWidget({super.key});

  @override
  ConsumerState<ConditionFormWidget> createState() =>
      _ConditionFormWidgetState();
}

class _ConditionFormWidgetState extends ConsumerState<ConditionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _periodFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _sectionFocusNode = FocusNode();

  // 각 입력란의 GlobalKey
  final _periodKey = GlobalKey();
  final _typeKey = GlobalKey();
  final _sectionKey = GlobalKey();

  bool _periodError = false;
  bool _sectionError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _periodFocusNode.dispose();
    _typeFocusNode.dispose();
    _sectionFocusNode.dispose();
    super.dispose();
  }

  // 스크롤 및 포커스 + 메시지
  Future<void> _focusAndScroll(
    GlobalKey key,
    FocusNode focusNode,
    String message,
  ) async {
    focusNode.requestFocus();
    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: 0.2, // 위에서 약간 띄워서 보이게
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blue.shade100, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: '운임 계산 조건 설정',
                      leadingIcon: Icons.receipt_long,
                      onReset: () {
                        viewModel.update(Condition());
                      },
                    ),
                    const SizedBox(height: 14),
                    // Period
                    PeriodDropdownRow(
                      key: _periodKey,
                      periodFocusNode: _periodFocusNode,
                      typeFocusNode: _typeFocusNode,
                      sectionFocusNode: _sectionFocusNode,
                      typeKey: _typeKey,
                      sectionKey: _sectionKey,
                    ),
                    const SizedBox(height: 5),
                    SearchTypeSelectorRow(
                      onRegionSearch: () {
                        _validateAndHandleSearchType(() {
                          // 지역 검색 다이얼로그 띄우기
                          showDialog(
                            context: context,
                            builder: (context) => const RegionSelectorsDialog(),
                          );
                        });
                      },
                      onRoadNameSearch: () {
                        _validateAndHandleSearchType(() {
                          // 도로명 검색 다이얼로그 띄우기
                          showDialog(
                            context: context,
                            builder: (context) => const RoadNameSearchDialog(),
                          );
                        });
                      },
                    ),
                    // const SizedBox(height: 10),
                    // const RegionSelectors(),
                    const SizedBox(height: 18),
                    // 검색 버튼 추가
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF154E9C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await viewModel.searchByRegion();
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('검색'),
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
