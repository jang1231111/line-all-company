import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/road_name_search_provider.dart';

class RoadNameSearchDialog extends ConsumerStatefulWidget {
  const RoadNameSearchDialog({super.key});

  @override
  ConsumerState<RoadNameSearchDialog> createState() =>
      _RoadNameSearchDialogState();
}

class _RoadNameSearchDialogState extends ConsumerState<RoadNameSearchDialog> {
  late final TextEditingController controller;
  dynamic _selected; // 선택된 결과 (타입 모름으로 dynamic 사용)
  String? _selectedId; // 선택 식별자 (객체 비교 문제 방지용)

  @override
  void initState() {
    super.initState();
    final state = ref.read(roadNameSearchViewModelProvider);
    controller = TextEditingController(text: state.keyword);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roadNameSearchViewModelProvider);
    final viewModel = ref.read(roadNameSearchViewModelProvider.notifier);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 520.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Material(
            color: const Color(0xFFF6F8FB),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7EE),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xFF1BAF5D),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '도로명 검색',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                color: const Color(0xFF1B7B4A),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '도로명으로 빠르게 주소를 찾아보세요.',
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
                          color: Colors.black38,
                          size: 18.sp,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(height: 1, color: Color(0xFFE6EAF0)),
                  SizedBox(height: 14.h),

                  // input row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          style: TextStyle(fontSize: 15.sp, height: 1.2),
                          decoration: InputDecoration(
                            hintText: '도로명 입력 (예: 테헤란로)',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black45,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 12.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(color: Color(0xFFDAE8F5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(color: Color(0xFFDAE8F5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: Color(0xFF1BAF5D),
                                width: 1.2.w,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            viewModel.setKeyword(value);
                          },
                          onFieldSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              viewModel.setKeyword(value);
                              viewModel.search(value);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 44.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BAF5D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            textStyle: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                          ),
                          onPressed: (state.keyword.trim().isEmpty)
                              ? null
                              : () {
                                  final value = controller.text;
                                  viewModel.setKeyword(value);
                                  viewModel.search(value);
                                },
                          icon: Icon(Icons.search, size: 18.sp),
                          label: Text('검색', style: TextStyle(fontSize: 15.sp)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // results container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Color(0xFFEAEEF5), width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 8.w,
                    ),
                    child: Builder(
                      builder: (_) {
                        if (state.isLoading) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!state.isLoading && state.results.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '검색 결과 (${state.totalCount}건)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: Color(0xFF4B5B7A),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                constraints: BoxConstraints(maxHeight: 300.h),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: state.results.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: Color(0xFFF1F3F6),
                                  ),
                                  itemBuilder: (context, idx) {
                                    final item = state.results[idx];
                                    // 고유 키 생성 (도로명 + 지번으로 간단 식별)
                                    final keyId = '${item.roadAddr}|${item.jibunAddr}';
                                    final isSelected = _selectedId == keyId;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selected = item;
                                          _selectedId = keyId;
                                        });
                                      },
                                      onLongPress: () {
                                        Navigator.of(context).pop(item);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFEEF9F3) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // 왼쪽 컬러 바 (선택 시만 표시) — 애니메이션 제거
                                            Container(
                                            width: 6.w,
                                              height: 42.h,
                                              decoration: BoxDecoration(
                                                color: isSelected ? const Color(0xFF1BAF5D) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Icon(
                                              Icons.location_on,
                                              color: isSelected ? const Color(0xFF126B3A) : const Color(0xFF1BAF5D),
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.roadAddr,
                                                    style: TextStyle(
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                      fontSize: 15.sp,
                                                      color: isSelected ? const Color(0xFF0F3F2A) : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    '${item.jibunAddr} ${item.bdNm}',
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: isSelected ? Colors.black87 : Colors.black54,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 단순 표시: 선택 시 작은 점 또는 비활성
                                            SizedBox(width: 8.w),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        if (!state.isLoading && state.results.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: Text(
                                '검색 결과가 없습니다.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          );
                        }
                        if (state.error != null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Text(
                              state.error!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 하단 액션 버튼: 닫기 / 확인
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('닫기'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selected != null
                                ? const Color(0xFF1BAF5D)
                                : Colors.grey.shade300,
                            foregroundColor:
                                _selected != null ? Colors.white : Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: _selected != null
                              ? () {
                                  Navigator.of(context).pop(_selected);
                                }
                              : null,
                          child: Text('확인'),
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
    );
  }
}
