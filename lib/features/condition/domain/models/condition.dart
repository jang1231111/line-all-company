class Condition {
  final String? period;
  final String? type;
  final String? section;
  final String? searchQuery;
  final String? sido;
  final String? sigungu;
  final String? eupmyeondong;
  final String? beopjeongdong;
  final List<String> surcharges;

  const Condition({
    this.period,
    this.type,
    this.section,
    this.searchQuery,
    this.sido,
    this.sigungu,
    this.eupmyeondong,
    this.beopjeongdong,
    this.surcharges = const [],
  });

  Condition copyWith({
    String? period,
    String? type,
    String? section,
    String? searchQuery,
    String? sido,
    String? sigungu,
    String? eupmyeondong,
    String? beopjeongdong,
    List<String>? surcharges,
  }) {
    return Condition(
      period: period ?? this.period,
      type: type ?? this.type,
      section: section ?? this.section,
      searchQuery: searchQuery ?? this.searchQuery,
      sido: sido ?? this.sido,
      sigungu: sigungu ?? this.sigungu,
      eupmyeondong: eupmyeondong ?? this.eupmyeondong,
      beopjeongdong: beopjeongdong ?? this.beopjeongdong,
      surcharges: surcharges ?? this.surcharges,
    );
  }
}
