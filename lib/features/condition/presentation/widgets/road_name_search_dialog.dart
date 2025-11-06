import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/road_name_search_provider.dart';

class RoadNameSearchDialog extends ConsumerStatefulWidget {
  const RoadNameSearchDialog({super.key});

  @override
  ConsumerState<RoadNameSearchDialog> createState() => _RoadNameSearchDialogState();
}

class _RoadNameSearchDialogState extends ConsumerState<RoadNameSearchDialog> {
  late final TextEditingController controller;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      backgroundColor: const Color(0xFFF5F7FA),
      child: SizedBox(
        width: 520.w,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목/설명/닫기
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.green[700],
                    size: 36.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '도로명 검색',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                            color: Color(0xFF1BAF5D),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: Color(0xFFE0E0E0)),
              SizedBox(height: 22.h),
              // 입력창 + 검색 버튼
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: TextStyle(fontSize: 20.sp),
                      decoration: InputDecoration(
                        hintText: '도로명 입력',
                        hintStyle: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black45,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 14.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFB4C8F7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFB4C8F7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Color(0xFF1BAF5D),
                            width: 1.5.w,
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
                    height: 54.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BAF5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                      ),
                      onPressed: (state.keyword.trim().isEmpty)
                          ? null
                          : () {
                              final value = controller.text;
                              viewModel.setKeyword(value);
                              viewModel.search(value);
                            },
                      icon: Icon(Icons.search, size: 24.sp),
                      label: Text('검색', style: TextStyle(fontSize: 20.sp)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              // 검색 결과 컨테이너
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Color(0xFFB4C8F7), width: 1.2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.06),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                child: Builder(
                  builder: (_) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!state.isLoading && state.results.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '검색 결과 (${state.totalCount}건)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: Color(0xFF4B5B7A),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            constraints: BoxConstraints(maxHeight: 320.h),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: state.results.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                              itemBuilder: (context, idx) {
                                final item = state.results[idx];
                                return ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    color: Color(0xFF1BAF5D),
                                    size: 28.sp,
                                  ),
                                  title: Text(
                                    item.roadAddr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.jibunAddr} ${item.bdNm}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop(item);
                                  },
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 2.h,
                                    horizontal: 0,
                                  ),
                                  dense: true,
                                  minLeadingWidth: 28.w,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    if (!state.isLoading && state.results.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(color: Colors.grey, fontSize: 18.sp),
                          ),
                        ),
                      );
                    }
                    if (state.error != null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          state.error!,
                          style: TextStyle(color: Colors.red, fontSize: 18.sp),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
