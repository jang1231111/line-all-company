import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/surcharge_dialog.dart';
import 'package:line_all/features/condition/presentation/widgets/send_mail_flow_button.dart';
import '../data/condition_options.dart';
import '../models/selected_fare.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late TextEditingController _searchController;
  String _searchQuery = '';

  // 기간 필터: 기본은 이번 달 1일부터 말일까지
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _initDefaultRange();
    final viewModel = ref.read(selectedFareProvider.notifier);
    _historyFuture = viewModel.loadHistoryFromDb();

    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _initDefaultRange() {
    final now = DateTime.now();
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // last day of current month
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q == _searchQuery) return;
    setState(() {
      _searchQuery = q;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 필터 적용: 화주 검색 + 기간(일 단위, inclusive)
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> rawHistory,
  ) {
    return rawHistory.where((entry) {
      final consignorText = (entry['consignor']?.toString() ?? '')
          .toLowerCase();
      if (_searchQuery.isNotEmpty &&
          !consignorText.contains(_searchQuery.toLowerCase()))
        return false;

      if (_rangeStart != null && _rangeEnd != null) {
        final savedAt = DateTime.tryParse(entry['saved_at'] ?? '');
        if (savedAt == null) return false;
        if (savedAt.isBefore(_rangeStart!) || savedAt.isAfter(_rangeEnd!))
          return false;
      }
      return true;
    }).toList();
  }

  void _clearDateFilter() {
    setState(() {
      _initDefaultRange(); // reset to this month
    });
  }

  // Modal for search: shows recent consignors + text input
  Future<void> _showSearchModal(BuildContext context) async {
    final raw = await ref
        .read(selectedFareProvider.notifier)
        .loadHistoryFromDb();
    final recent = raw
        .map((e) => (e['consignor'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList()
        .reversed
        .toList();
    final seen = <String>{};
    final suggestions = recent.where((s) => seen.add(s)).take(10).toList();

    final controller = TextEditingController(text: _searchQuery);

    // ensure sheet moves up when keyboard opens: use AnimatedPadding with MediaQuery.viewInsets
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: AnimatedPadding(
            // padding follows viewInsets (keyboard) so modal content shifts up automatically
            padding: MediaQuery.of(ctx).viewInsets,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: DraggableScrollableSheet(
                expand: false,
                // increase initial height so input stays visible when keyboard opens
                initialChildSize: 0.72,
                minChildSize: 0.32,
                maxChildSize: 0.9,
                builder: (_, scrollCtl) {
                  return StatefulBuilder(
                    builder: (stCtx, setSt) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        // keep a small bottom padding (keyboard handled by AnimatedPadding)
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // drag handle
                            Center(
                              child: Container(
                                width: 40.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '화주 검색',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(null),
                                ),
                              ],
                            ),

                            // search input (rounded, subtle shadow)
                            SizedBox(height: 6.h),
                            Material(
                              elevation: 1,
                              borderRadius: BorderRadius.circular(12.r),
                              child: TextField(
                                controller: controller,
                                autofocus: false,
                                onChanged: (v) => setSt(() {}),
                                onSubmitted: (v) =>
                                    Navigator.of(ctx).pop(v.trim()),
                                decoration: InputDecoration(
                                  hintText: '화주명 입력',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.w,
                                      right: 8.w,
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 40.w,
                                  ),
                                  suffixIcon: controller.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            controller.clear();
                                            setSt(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: 12.w,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : null,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                    horizontal: 12.w,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // recent / suggestion pills (visually distinct pill style)
                            if (suggestions.isNotEmpty) ...[
                              Text(
                                '최근 화주',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                height: 40.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: suggestions.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 8.w),
                                  itemBuilder: (c, i) {
                                    final s = suggestions[i];
                                    return GestureDetector(
                                      onTap: () => Navigator.of(ctx).pop(s),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withOpacity(
                                            0.06,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.indigo.withOpacity(
                                              0.12,
                                            ),
                                          ),
                                        ),

                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 14.sp,
                                              color: Colors.indigo.shade700,
                                            ),
                                            SizedBox(width: 8.w),

                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 120.w,
                                              ),
                                              child: Text(
                                                s,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.indigo.shade900,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],

                            // optional list of matches (simple filtered list)
                            Expanded(
                              child: Builder(
                                builder: (_) {
                                  final q = controller.text.trim();
                                  final list = q.isEmpty
                                      ? <String>[]
                                      : suggestions
                                            .where(
                                              (e) => e.toLowerCase().contains(
                                                q.toLowerCase(),
                                              ),
                                            )
                                            .toList();
                                  if (q.isEmpty) {
                                    return Center(
                                      child: Text(
                                        '검색어를 입력하면 결과가 표시됩니다.',
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                    );
                                  }
                                  if (list.isEmpty) {
                                    return Center(
                                      child: Text(
                                        '검색 결과가 없습니다.',
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    controller: scrollCtl,
                                    itemCount: list.length,
                                    separatorBuilder: (_, __) =>
                                        Divider(height: 1.h),
                                    itemBuilder: (_, i) {
                                      final val = list[i];
                                      return ListTile(
                                        leading: Icon(
                                          Icons.person_outline,
                                          color: Colors.indigo,
                                        ),
                                        title: Text(
                                          val,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onTap: () => Navigator.of(ctx).pop(val),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // actions
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(null),
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black54,
                                    ),
                                    label: Text(
                                      '취소',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: controller.text.trim().isEmpty
                                        ? null
                                        : () => Navigator.of(
                                            ctx,
                                          ).pop(controller.text.trim()),
                                    icon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      '검색',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      backgroundColor:
                                          controller.text.trim().isEmpty
                                          ? Colors.indigo.shade100
                                          : Colors.indigo,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    // dispose focus node once bottom sheet is dismissed
    // try { focusNode.dispose(); } catch (_) {}

    if (result != null) {
      setState(() {
        _searchController.text = result;
        _searchQuery = result;
      });
    }
  }

  // Keep existing _pickDate but can be minimal: showDateRangePicker and set _rangeStart/_rangeEnd
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final preset = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Material(
              color: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // header
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '기간 선택',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(ctx).pop(null),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, thickness: 1),

                  // options
                  _presetTile(
                    ctx,
                    Icons.calendar_today,
                    '이번달',
                    '현재 달의 시작~말일까지',
                    'this',
                  ),
                  _presetTile(ctx, Icons.history, '지난달', '바로 이전 달', 'last'),
                  _presetTile(
                    ctx,
                    Icons.access_time,
                    '최근 3개월',
                    '최근 3개월 전체',
                    '3m',
                  ),
                  _presetTile(
                    ctx,
                    Icons.edit_calendar,
                    '직접 선택',
                    '날짜 범위 직접 선택',
                    'custom',
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (preset == null) return;
    if (preset == 'this') {
      setState(() {
        _rangeStart = DateTime(now.year, now.month, 1);
        _rangeEnd = DateTime(now.year, now.month + 1, 0);
      });
      return;
    }
    if (preset == 'last') {
      final last = DateTime(now.year, now.month - 1, 1);
      setState(() {
        _rangeStart = DateTime(last.year, last.month, 1);
        _rangeEnd = DateTime(last.year, last.month + 1, 0);
      });
      return;
    }
    if (preset == '3m') {
      final end = DateTime(now.year, now.month + 1, 0);
      final start = DateTime(now.year, now.month - 2, 1);
      setState(() {
        _rangeStart = start;
        _rangeEnd = end;
      });
      return;
    }
    // custom: 기존 데이트레인지 피커
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: (_rangeStart != null && _rangeEnd != null)
          ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _rangeStart = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      _rangeEnd = DateTime(picked.end.year, picked.end.month, picked.end.day);
    });
  }

  int _sumFaresForEntries(List<Map<String, dynamic>> entries) {
    var total = 0;
    for (var e in entries) {
      final fares = (e['fares'] as List? ?? [])
          .map((x) => SelectedFare.fromJson(Map<String, dynamic>.from(x)))
          .toList();
      total += fares.fold(0, (s, f) => s + f.price);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final rawHistory = snapshot.data!;
          final filtered = _applyFilters(rawHistory);
          filtered.sort((a, b) {
            final da =
                DateTime.tryParse(a['saved_at'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final db =
                DateTime.tryParse(b['saved_at'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return db.compareTo(da);
          });

          return Column(
            children: [
              // controls (search / date / reset)
              _buildSearchAndDateControls(),
              _buildActiveFilterChips(),
              Padding(
                padding: EdgeInsets.only(right: 18.w, top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '선택 기간 합계:',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${NumberFormat('#,###').format(_sumFaresForEntries(filtered))}원',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildList(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 72.h,
      titleSpacing: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C63D6), Color(0xFF154E9C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      title: Row(
        children: [
          SizedBox(width: 12.w),
          InkWell(
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운임 통계',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '운임 통계 기록',
                style: TextStyle(fontSize: 11.sp, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeLabel() {
    final label = (_rangeStart != null && _rangeEnd != null)
        ? '${DateFormat('yyyy.MM.dd').format(_rangeStart!)} — ${DateFormat('yyyy.MM.dd').format(_rangeEnd!)}'
        : DateFormat('yyyy.MM').format(DateTime.now());
    return Padding(
      padding: EdgeInsets.only(top: 18.h, left: 18.w, right: 18.w, bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.indigo, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Consolidated filter panel: small consignor search button + wide date button (date text shown here)
  Widget _buildSearchAndDateControls() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasRange = _rangeStart != null && _rangeEnd != null;

    String rangeLabel() {
      if (!hasRange) return '기간검색';
      if (_rangeStart == _rangeEnd)
        return DateFormat('yyyy.MM.dd').format(_rangeStart!);
      return '${DateFormat('yyyy.MM.dd').format(_rangeStart!)} — ${DateFormat('yyyy.MM.dd').format(_rangeEnd!)}';
    }

    return Padding(
      // padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 12.h),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // small icon-only consignor search button
                  SizedBox(
                    width: 44.w,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () => _showSearchModal(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.indigo,
                        elevation: 0,
                      ),
                      child: Icon(
                        Icons.person_search,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // wide date button (shows full date text)
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: OutlinedButton(
                        onPressed: () => _pickDate(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.indigo.shade50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.indigo,
                              size: 18.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                rangeLabel(),
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.indigo),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // no reset here — reset will appear next to chips when a consignor is applied
                ],
              ),

              // separator spacing
              // if (hasSearch) SizedBox(height: 10.h),

              // // active filter chips — only consignor chip (date removed) + reset placed at right inside same container
              // if (hasSearch)
              //   Row(
              //     children: [
              //       Expanded(
              //         child: SingleChildScrollView(
              //           scrollDirection: Axis.horizontal,
              //           child: Row(
              //             children: [
              //               Padding(
              //                 padding: EdgeInsets.only(right: 8.w),
              //                 child: Container(
              //                   padding: EdgeInsets.symmetric(
              //                     horizontal: 10.w,
              //                     vertical: 6.h,
              //                   ),
              //                   decoration: BoxDecoration(
              //                     color: Colors.indigo.withOpacity(0.06),
              //                     borderRadius: BorderRadius.circular(18.r),
              //                     border: Border.all(
              //                       color: Colors.indigo.withOpacity(0.12),
              //                     ),
              //                   ),
              //                   child: Row(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Icon(
              //                         Icons.person,
              //                         size: 14.sp,
              //                         color: Colors.indigo.shade700,
              //                       ),
              //                       SizedBox(width: 8.w),
              //                       ConstrainedBox(
              //                         constraints: BoxConstraints(
              //                           maxWidth: 160.w,
              //                         ),
              //                         child: Text(
              //                           '화주: $_searchQuery',
              //                           overflow: TextOverflow.ellipsis,
              //                           style: TextStyle(
              //                             color: Colors.indigo.shade900,
              //                             fontWeight: FontWeight.w600,
              //                           ),
              //                         ),
              //                       ),
              //                       SizedBox(width: 8.w),
              //                       GestureDetector(
              //                         onTap: () => setState(() {
              //                           _searchQuery = '';
              //                           _searchController.clear();
              //                         }),
              //                         child: Icon(
              //                           Icons.close,
              //                           size: 16.sp,
              //                           color: Colors.indigo.shade300,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),

              //       // reset button appears only when a consignor (화주) is set
              //       SizedBox(width: 8.w),
              //       if (hasSearch)
              //         SizedBox(
              //           width: 40.w,
              //           height: 40.h,
              //           child: OutlinedButton(
              //             onPressed: () => setState(() {
              //               _searchQuery = '';
              //               _searchController.clear();
              //               _initDefaultRange();
              //             }),
              //             style: OutlinedButton.styleFrom(
              //               padding: EdgeInsets.zero,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(10.r),
              //               ),
              //               side: BorderSide(color: Colors.grey.shade200),
              //               backgroundColor: Colors.white,
              //             ),
              //             child: Icon(
              //               Icons.refresh,
              //               color: Colors.black54,
              //               size: 20.sp,
              //             ),
              //           ),
              //         ),
              // ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Active chips container: chips on the left, reset button fixed on the right.
  // Reset button is visible only when a real filter is applied (화주 입력 OR 날짜가 기본값과 다를 때).
  Widget _buildActiveFilterChips() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasRange = _rangeStart != null && _rangeEnd != null;

    // Detect if current range equals the default (this month). If so, consider it NOT an active range filter.
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month, 1);
    final defaultEnd = DateTime(now.year, now.month + 1, 0);
    final isRangeDefault =
        hasRange &&
        _rangeStart!.year == defaultStart.year &&
        _rangeStart!.month == defaultStart.month &&
        _rangeStart!.day == defaultStart.day &&
        _rangeEnd!.year == defaultEnd.year &&
        _rangeEnd!.month == defaultEnd.month &&
        _rangeEnd!.day == defaultEnd.day;

    final hasActiveRange = hasRange && !isRangeDefault;
    final anyFilterActive = hasSearch || hasActiveRange;

    if (!anyFilterActive) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0.h, 18.w, 0.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),

        child: Row(
          children: [
            // left: horizontally scrollable chips (only consignor chip shown here)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (hasSearch)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: Colors.indigo.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 14.sp,
                                color: Colors.indigo.shade700,
                              ),
                              SizedBox(width: 8.w),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 160.w),
                                child: Text(
                                  '화주: $_searchQuery',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.indigo.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.indigo.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // (날짜칩을 더이상 여기 표시하지 않음 — 날짜는 날짜 버튼에서 보여짐)
                  ],
                ),
              ),
            ),

            // right: reset button — only shown when anyFilterActive is true (we already return shrink otherwise)
            SizedBox(width: 8.w),
            // SizedBox(
            //   width: 40.w,
            //   height: 40.h,
            //   child: OutlinedButton(
            //     onPressed: () => setState(() {
            //       _searchQuery = '';
            //       _searchController.clear();
            //       _initDefaultRange();
            //     }),
            //     style: OutlinedButton.styleFrom(
            //       padding: EdgeInsets.zero,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10.r),
            //       ),
            //       side: BorderSide(color: Colors.grey.shade200),
            //       backgroundColor: Colors.white,
            //     ),
            //     child: Icon(Icons.refresh, color: Colors.black54, size: 20.sp),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final controller = TextEditingController(text: _searchQuery);
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('화주명 검색'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: '검색어를 입력하고 확인을 누르세요'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('검색'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _searchController.text = result;
        _searchQuery = result;
      });
    }
  }

  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.search_off, color: Colors.indigo, size: 72.sp),
  //         SizedBox(height: 18.h),
  //         Text(
  //           '검색 결과가 없습니다.',
  //           style: TextStyle(
  //             fontSize: 18.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black54,
  //           ),
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           _searchQuery.isNotEmpty
  //               ? '화주명 "${_searchQuery}" 으로 검색한 결과가 없습니다.'
  //               : (_rangeStart != null && _rangeEnd != null
  //                     ? '${DateFormat('yyyy.MM.dd').format(_rangeStart!)} — ${DateFormat('yyyy.MM.dd').format(_rangeEnd!)} 기간의 기록이 없습니다.'
  //                     : '저장된 운임 데이터가 없습니다.'),
  //           style: TextStyle(fontSize: 14.sp, color: Colors.black45),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: Colors.indigo, size: 72.sp),
          SizedBox(height: 18.h),
          Text(
            '검색 결과가 없습니다.',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty
                ? '화주명 "${_searchQuery}" 으로 검색한 결과가 없습니다.'
                : (_rangeStart != null && _rangeEnd != null
                      ? '${DateFormat('yyyy.MM.dd').format(_rangeStart!)} — ${DateFormat('yyyy.MM.dd').format(_rangeEnd!)} 기간의 기록이 없습니다.'
                      : '저장된 운임 데이터가 없습니다.'),
            style: TextStyle(fontSize: 14.sp, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> filtered) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final entry = filtered[idx];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final savedAt = DateTime.tryParse(entry['saved_at'] ?? '');
    final consignorText = (entry['consignor']?.toString() ?? '').trim();
    final faresRaw = List<Map<String, dynamic>>.from(
      (entry['fares'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );
    final fares = faresRaw
        .map((m) {
          try {
            return SelectedFare.fromJson(Map<String, dynamic>.from(m));
          } catch (_) {
            return null;
          }
        })
        .whereType<SelectedFare>()
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      margin: EdgeInsets.only(bottom: 18.h),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.indigo.shade300,
                  size: 21.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    savedAt != null
                        ? DateFormat('yyyy.MM.dd HH:mm').format(savedAt)
                        : '알 수 없음',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade300,
                    ),
                  ),
                ),
                if (consignorText.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Text(
                      '화주: $consignorText',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 14.h),
            ...List.generate(
              fares.length,
              (i) => _buildFareItem(fares[i], faresRaw[i], entry),
            ),
            // 메일 전송 버튼 (화주명은 entry에 있는 consignor로 고정 전달)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 45.h,
                child: IgnorePointer(
                  ignoring: fares.isEmpty,
                  child: Opacity(
                    opacity: fares.isEmpty ? 0.5 : 1.0,
                    child: SendMailButton(
                      // closure captures `fares` and calls viewmodel method that accepts (input, fares)
                      sendFn: (input) async =>
                          await ref.read(selectedFareProvider.notifier)
                              .sendFaresMailForStatics(input, fares),
                      label: '메일 전송',
                      popParentOnSuccess: false,
                      initialInput: {'consignor': consignorText},
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareItem(
    SelectedFare fare,
    Map<String, dynamic> fareMap,
    Map<String, dynamic> entry,
  ) {
    final fareId = (fareMap['fare_id']?.toString() ?? '');
    final entryId = (entry['id']?.toString() ?? '');

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      getSectionLabel(fare.row.section),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${fare.row.sido}>${fare.row.sigungu}>${fare.row.eupmyeondong}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: fare.type == FareType.ft20
                          ? Colors.indigo.shade100
                          : Colors.deepOrange[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      fare.type == FareType.ft20 ? '20FT' : '40FT',
                      style: TextStyle(
                        color: fare.type == FareType.ft20
                            ? Colors.indigo.shade900
                            : Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: const Color(0xFFFFF3C2),
                    borderRadius: BorderRadius.circular(10.r),
                    child: InkWell(
                      splashColor: Colors.orange.withOpacity(0.1),
                      highlightColor: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => SurchargeDialog(fare: fare),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.orange.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.06),
                              blurRadius: 4.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 10.w),
                                Text(
                                  '할증률:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '${(fare.rate * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: const Color(0xFFD18A00),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(fare.price)}원',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          right: 10.w,
          top: 18.h,
          child: GestureDetector(
            onTap: (entryId.isEmpty || fareId.isEmpty)
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: Colors.white,
                        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '삭제 확인',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          '항목을 삭제하면 복구할 수 없습니다.\n계속 진행하시겠습니까?',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        actionsPadding: EdgeInsets.only(
                          right: 12.w,
                          bottom: 12.h,
                        ),
                        actions: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(dctx).pop(false),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.of(dctx).pop(true),
                            child: Text(
                              '삭제',
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    final vm = ref.read(selectedFareProvider.notifier);
                    await vm.deleteFareInEntry(entryId, fareId);
                    setState(() {
                      _historyFuture = vm.loadHistoryFromDb();
                    });
                  },
            child: Container(
              width: 26.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18.sp,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _presetTile(
    BuildContext ctx,
    IconData icon,
    String title,
    String subtitle,
    String value,
  ) {
    return InkWell(
      onTap: () => Navigator.of(ctx).pop(value),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: Colors.indigo, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
