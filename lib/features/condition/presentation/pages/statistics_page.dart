import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_all/features/condition/presentation/providers/selected_fare_result_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '운임 통계 기록',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
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
                    size: 80.sp,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    '운임 통계 페이지',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D365C),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '저장된 운임 데이터가 없습니다.',
                    style: TextStyle(fontSize: 22.sp, color: Color(0xFF6B7684)),
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
                        size: 32.sp,
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
                          size: 36.sp,
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          '${months[_currentPage]}월',
                          style: TextStyle(
                            fontSize: 20.sp,
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
                        size: 32.sp,
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
                            fontSize: 15.sp,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${NumberFormat('#,###').format(getMonthTotal(grouped[months[_currentPage]]!))}원',
                          style: TextStyle(
                            fontSize: 24.sp,
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
                    final entries = grouped[month]!;

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
                                horizontal: 0,
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
                                children: entries.map((entry) {
                                  final savedAt = DateTime.tryParse(
                                    entry['saved_at'] ?? '',
                                  );
                                  final fares = (entry['fares'] as List)
                                      .map(
                                        (e) => SelectedFare.fromJson(
                                          Map<String, dynamic>.from(e),
                                        ),
                                      )
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
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.indigo.shade300,
                                                size: 23.sp,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                savedAt != null
                                                    ? DateFormat(
                                                        'yyyy.MM.dd HH:mm',
                                                      ).format(savedAt)
                                                    : '알 수 없음',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo.shade300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.h),
                                          ...fares.map(
                                            (fare) => Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 8.h,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 14.h,
                                                horizontal: 16.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    // fare.type == FareType.ft20
                                                    Colors.indigo.shade50,
                                                // : Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        getSectionLabel(
                                                          fare.row.section,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.indigo,
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
                                                      Text(
                                                        '${fare.row.sido}>${fare.row.sigungu}>${fare.row.eupmyeondong}',
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 14.w,
                                                              vertical: 6.h,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              fare.type ==
                                                                  FareType.ft20
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
                                                                  FareType.ft20
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
                                                                FontWeight.bold,
                                                            fontSize: 16.sp,
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
                                                      Text(
                                                        '할증률: ${(fare.rate * 100).toStringAsFixed(1)}%',
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '운임비: ${NumberFormat('#,###').format(fare.price)}원',
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // SizedBox(height: 2.h),
                                                  if (fare
                                                      .surchargeLabels
                                                      .isNotEmpty)
                                                    Wrap(
                                                      spacing: 10.w,
                                                      children: fare
                                                          .surchargeLabels
                                                          .map(
                                                            (label) => Chip(
                                                              label: Text(
                                                                label,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                    ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .blue[50],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.r,
                                                                    ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                  horizontal: 24.w,
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
                                    fontSize: 22.sp,
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
