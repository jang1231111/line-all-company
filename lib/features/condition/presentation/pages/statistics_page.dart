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
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Provider로 ViewModel 받아서 사용
    final viewModel = ref.read(selectedFareProvider.notifier);
    _historyFuture = viewModel.loadHistoryFromDb();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> groupByMonth(
    List<Map<String, dynamic>> history,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var entry in history) {
      final savedAt =
          DateTime.tryParse(entry['saved_at'] ?? '') ?? DateTime.now();
      final key = DateFormat('yyyy-MM').format(savedAt);
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  int getMonthTotal(List<Map<String, dynamic>> entries) {
    int total = 0;
    for (var entry in entries) {
      final fares = (entry['fares'] as List)
          .map((e) => SelectedFare.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      total += fares.fold(0, (sum, fare) => sum + fare.price);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          mainAxisAlignment: MainAxisAlignment.start,
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
              children: [
                Text(
                  '운임 통계',
                  style: TextStyle(
                    fontSize: 16.sp, // -2
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '운임 통계 기록',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ), // -1
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.indigo,
                    size: 72.sp, // -8
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    '운임 통계 페이지',
                    style: TextStyle(
                      fontSize: 28.sp, // -4
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D365C),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '저장된 운임 데이터가 없습니다.',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Color(0xFF6B7684),
                    ), // -2
                  ),
                ],
              ),
            );
          }

          final grouped = groupByMonth(history);
          final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 18.h, left: 18.w, right: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.indigo,
                        size: 30.sp, // -2
                      ),
                      onPressed: _currentPage > 0
                          ? () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          : null,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.indigo,
                          size: 34.sp, // -2
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          '${months[_currentPage]}월',
                          style: TextStyle(
                            fontSize: 18.sp, // -2
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.indigo,
                        size: 30.sp, // -2
                      ),
                      onPressed: _currentPage < months.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 18.w, top: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이 달의 운임 합계:',
                          style: TextStyle(
                            fontSize: 13.sp, // -2
                            // fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${NumberFormat('#,###').format(getMonthTotal(grouped[months[_currentPage]]!))}원',
                          style: TextStyle(
                            fontSize: 22.sp, // -2
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: months.length,
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final month = months[idx];
                    final entries = grouped[month] ?? [];
                    // 최신 등록순(내림차순)으로 정렬
                    final entriesSorted =
                        List<Map<String, dynamic>>.from(entries)..sort((a, b) {
                          final da =
                              DateTime.tryParse(a['saved_at'] ?? '') ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final db =
                              DateTime.tryParse(b['saved_at'] ?? '') ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          return db.compareTo(da);
                        });

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 5.w,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 8.h,
                                horizontal: 8.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: Colors.indigo.shade100,
                                  width: 2.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.04),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: ListView(
                                children: entriesSorted.map((entry) {
                                  final savedAt = DateTime.tryParse(
                                    entry['saved_at'] ?? '',
                                  );
                                  // consignor 읽기
                                  final consignorText =
                                      (entry['consignor']?.toString() ?? '')
                                          .trim();
                                  // 원시 Map 리스트와 SelectedFare 리스트를 같이 만듭+안전 처리
                                  final faresRaw =
                                      List<Map<String, dynamic>>.from(
                                        (entry['fares'] as List? ?? []).map(
                                          (e) => Map<String, dynamic>.from(e),
                                        ),
                                      );
                                  final fares = faresRaw
                                      .map((m) {
                                        try {
                                          return SelectedFare.fromJson(
                                            Map<String, dynamic>.from(m),
                                          );
                                        } catch (_) {
                                          return null;
                                        }
                                      })
                                      .whereType<SelectedFare>()
                                      .toList();

                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    margin: EdgeInsets.only(bottom: 18.h),
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                        horizontal: 10.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // header: 시간 + 우측에 화주(일관된 칩) + 우측 상단 삭제 버튼 (entry 전체 삭제)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.indigo.shade300,
                                                size: 21.sp, // -2
                                              ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: Text(
                                                  savedAt != null
                                                      ? DateFormat(
                                                          'yyyy.MM.dd HH:mm',
                                                        ).format(savedAt)
                                                      : '알 수 없음',
                                                  style: TextStyle(
                                                    fontSize: 16.sp, // -2
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.indigo.shade300,
                                                  ),
                                                ),
                                              ),
                                              if (consignorText.isNotEmpty)
                                                SizedBox(width: 8.w),
                                              if (consignorText.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 4.w,
                                                  ),
                                                  child: Text(
                                                    '$consignorText',
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors
                                                          .indigo
                                                          .shade700,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 14.h),

                                          // fares를 인덱스 기준으로 순회 -> fareMap에서 fare_id 읽어서 개별 삭제 버튼 추가
                                          ...List.generate(fares.length, (i) {
                                            final fare = fares[i];
                                            final fareMap = faresRaw[i];
                                            final fareId =
                                                (fareMap['fare_id']
                                                    ?.toString() ??
                                                '');
                                            final entryId =
                                                (entry['id']?.toString() ?? '');
                                            return Stack(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    vertical: 8.h,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12.h, // -2
                                                    horizontal: 14.w, // -2
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.indigo.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              getSectionLabel(
                                                                fare
                                                                    .row
                                                                    .section,
                                                              ),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    16.sp, // -2
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .indigo,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${fare.row.sido}>${fare.row.sigungu}>${fare.row.eupmyeondong}',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    16.sp, // -2
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 12
                                                                      .w, // -2
                                                                  vertical: 6.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  fare.type ==
                                                                      FareType
                                                                          .ft20
                                                                  ? Colors
                                                                        .indigo
                                                                        .shade100
                                                                  : Colors
                                                                        .deepOrange[50],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8.r,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              fare.type ==
                                                                      FareType
                                                                          .ft20
                                                                  ? '20FT'
                                                                  : '40FT',
                                                              style: TextStyle(
                                                                color:
                                                                    fare.type ==
                                                                        FareType
                                                                            .ft20
                                                                    ? Colors
                                                                          .indigo
                                                                          .shade900
                                                                    : Colors
                                                                          .deepOrange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    14.sp, // -2
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.h),

                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Material(
                                                                color:
                                                                    const Color(
                                                                      0xFFFFF3C2,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.r,
                                                                    ),
                                                                child: InkWell(
                                                                  splashColor: Colors
                                                                      .orange
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  highlightColor:
                                                                      Colors
                                                                          .orange
                                                                          .withOpacity(
                                                                            0.1,
                                                                          ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10.r,
                                                                      ),
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (_) =>
                                                                          SurchargeDialog(
                                                                            fare:
                                                                                fare,
                                                                          ),
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10.r,
                                                                          ),
                                                                      border: Border.all(
                                                                        color: Colors
                                                                            .orange
                                                                            .shade200,
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.orange.withOpacity(
                                                                            0.06,
                                                                          ),
                                                                          blurRadius:
                                                                              4.r,
                                                                          offset: Offset(
                                                                            0,
                                                                            1.h,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          1.w,
                                                                        ),
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              4.h,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 10.w,
                                                                            ),
                                                                            Text(
                                                                              '할증률:',
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 14.sp, // -2
                                                                                color: Colors.black87,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5.w,
                                                                            ),
                                                                            Text(
                                                                              '${(fare.rate * 100).toStringAsFixed(1)}%',
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 14.sp, // -2
                                                                                color: Color(
                                                                                  0xFFD18A00,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 14.w,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            '${NumberFormat('#,###').format(fare.price)}원',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  18.sp, // -2
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // 개별 삭제 버튼 (작은 원형), 우측 상단
                                                Positioned(
                                                  right: 10.w,
                                                  top: 18.h, // -2
                                                  child: GestureDetector(
                                                    onTap:
                                                        (entryId.isEmpty ||
                                                            fareId.isEmpty)
                                                        ? null
                                                        : () async {
                                                            final confirmed = await showDialog<bool>(
                                                              context: context,
                                                              builder: (dctx) => AlertDialog(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        16.r,
                                                                      ),
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                titlePadding:
                                                                    EdgeInsets.fromLTRB(
                                                                      20.w,
                                                                      20.h,
                                                                      20.w,
                                                                      0,
                                                                    ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20.w,
                                                                      vertical:
                                                                          12.h,
                                                                    ),
                                                                title: Row(
                                                                  children: [
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            8.w,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .red
                                                                            .shade50,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .delete_outline,
                                                                        color: Colors
                                                                            .redAccent,
                                                                        size: 20
                                                                            .sp, // -2
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          12.w,
                                                                    ),
                                                                    Text(
                                                                      '삭제 확인',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            22.sp, // -2
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                content: Text(
                                                                  '항목을 삭제하면 복구할 수 없습니다.\n계속 진행하시겠습니까?',
                                                                  style: TextStyle(
                                                                    fontSize: 16
                                                                        .sp, // -2
                                                                    color: Colors
                                                                        .black87,
                                                                    height: 1.4,
                                                                  ),
                                                                ),
                                                                actionsPadding:
                                                                    EdgeInsets.only(
                                                                      right:
                                                                          12.w,
                                                                      bottom:
                                                                          12.h,
                                                                    ),
                                                                actions: [
                                                                  OutlinedButton(
                                                                    style: OutlinedButton.styleFrom(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            14.w,
                                                                        vertical:
                                                                            8.h,
                                                                      ),
                                                                      side: BorderSide(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        width:
                                                                            1.w,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8.r,
                                                                            ),
                                                                      ),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    onPressed: () =>
                                                                        Navigator.of(
                                                                          dctx,
                                                                        ).pop(
                                                                          false,
                                                                        ),
                                                                    child: Text(
                                                                      '취소',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            17.sp, // -2
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .redAccent,
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16.w,
                                                                        vertical:
                                                                            8.h,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8.r,
                                                                            ),
                                                                      ),
                                                                      elevation:
                                                                          0,
                                                                    ),
                                                                    onPressed: () =>
                                                                        Navigator.of(
                                                                          dctx,
                                                                        ).pop(
                                                                          true,
                                                                        ),
                                                                    child: Text(
                                                                      '삭제',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            17.sp, // -2
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                            if (confirmed !=
                                                                true)
                                                              return;
                                                            final vm = ref.read(
                                                              selectedFareProvider
                                                                  .notifier,
                                                            );
                                                            await vm
                                                                .deleteFareInEntry(
                                                                  entryId,
                                                                  fareId,
                                                                );
                                                            setState(() {
                                                              _historyFuture = vm
                                                                  .loadHistoryFromDb();
                                                            });
                                                          },
                                                    child: Container(
                                                      width: 26.w, // -2
                                                      height: 26.h, // -2
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.9),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        size: 18.sp, // -2
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 22.h), // -2
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h, // -2
                                  horizontal: 20.w, // -4
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.indigo.shade200,
                                    width: 1.2.w,
                                  ),
                                ),
                                child: Text(
                                  '${_currentPage + 1} / ${months.length}',
                                  style: TextStyle(
                                    fontSize: 15.sp, // -2
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
