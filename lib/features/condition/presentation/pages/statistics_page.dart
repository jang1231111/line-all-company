import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/widgets/surcharge_dialog.dart';
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
    // load recent consignors (local history)
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
    final suggestions = recent.where((s) => seen.add(s)).take(5).toList();

    final controller = TextEditingController(text: _searchQuery);
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 12.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('화주 검색', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
              ],
            ),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: '화주명 입력'),
              onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
            ),
            if (suggestions.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('최근 화주', style: TextStyle(color: Colors.black54)),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: suggestions.map((s) {
                  return ActionChip(
                    label: Text(s, overflow: TextOverflow.ellipsis),
                    onPressed: () => Navigator.of(ctx).pop(s),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text('취소'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: Text('검색'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );

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
              // range label removed (기간은 아래 버튼에서만 표시/설정)
              _buildSearchAndDateControls(),
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

  Widget _buildSearchAndDateControls() {
    // shows active filter chips above controls + compact controls row
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filter chips (shown only when active)
          if (_searchQuery.isNotEmpty ||
              (_rangeStart != null && _rangeEnd != null))
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  if (_searchQuery.isNotEmpty)
                    InputChip(
                      label: Text(
                        '화주: $_searchQuery',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: () => setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    ),
                  if (_rangeStart != null && _rangeEnd != null)
                    InputChip(
                      label: Text(
                        '${DateFormat('yyyy.MM.dd').format(_rangeStart!)} — ${DateFormat('yyyy.MM.dd').format(_rangeEnd!)}',
                      ),
                      onDeleted: _clearDateFilter,
                    ),
                ],
              ),
            ),

          // Controls row
          Row(
            children: [
              // Search button: simple, always shows as a button (doesn't display current query)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSearchModal(context),
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text(
                    '화주 검색',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Date range button
              SizedBox(
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: Icon(Icons.date_range, color: Colors.indigo),
                  label: Row(
                    children: [
                      Text(
                        (_rangeStart != null && _rangeEnd != null)
                            ? '${DateFormat('yyyy.MM.dd').format(_rangeStart!)}'
                            : '기간',
                        style: TextStyle(color: Colors.indigo),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.arrow_drop_down, color: Colors.indigo),
                    ],
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.indigo.shade50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // reset shortcut
              IconButton(
                onPressed: _clearDateFilter,
                icon: Icon(Icons.refresh, color: Colors.black45),
              ),
            ],
          ),
        ],
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
}
