import 'surcharge_options.dart';

/// 할증률 계산 결과 모델
class SurchargeResult {
  final double rate; // 예: 0.55 (55%)
  final double cancellationFeeAmount; // 배차 취소료
  final List<String> labels; // 적용된 항목 라벨
  final int fixedAmount; // 고정 금액 합계

  const SurchargeResult({
    this.rate = 0.0,
    this.cancellationFeeAmount = 1.0,
    this.labels = const [],
    this.fixedAmount = 0,
  });
}

/// 할증률 계산 함수

SurchargeResult calculateSurcharge({
  required List<String> selectedCheckboxIds,
  String? weightType,
  String? cancellationFee,
  bool is2026Period = false,
}) {
  final rateItems = <({double rate, String label})>[];
  final labels = <String>[];

  int fixedAmount = 0;

  final options = is2026Period
      ? surcharge2026Options
      : surchargeCheckboxOptions;
  // 체크박스 할증률 및 고정금액
  for (final id in selectedCheckboxIds) {
    final opt = options.firstWhere(
      (o) => o.id == id,
      orElse: () => CheckboxOption(id: '', label: ''),
    );
    if (opt.id.isNotEmpty) {
      if (opt.isFixed) {
        if (opt.id == 'xray') fixedAmount += 100000;
        if (opt.id == 'incheon') fixedAmount += 40000;
        labels.add(opt.label);
      } else if (opt.rate != null) {
        rateItems.add((rate: opt.rate!, label: opt.label));
      }
    }
  }

  // 드롭다운 할증률 (cancellationFeeOptions 제외)
  void addDropdownRate(List<SurchargeDropdownOption> options, String? value) {
    if (value != null && value.isNotEmpty) {
      final opt = options.firstWhere(
        (o) => o.value == value,
        orElse: () => SurchargeDropdownOption(value: '', label: ''),
      );
      if (opt.value.isNotEmpty && opt.rate != null) {
        rateItems.add((rate: opt.rate!, label: opt.label));
      }
    }
  }

  // addDropdownRate(dangerTypeOptions, dangerType);
  addDropdownRate(weightTypeOptions, weightType);
  // addDropdownRate(specialTypeOptions, specialType);

  // 취소수수료(고정금액)만 별도로 추출
  double cancellationFeeAmount = 1.0;
  if (cancellationFee != null && cancellationFee.isNotEmpty) {
    final opt = cancellationFeeOptions.firstWhere(
      (o) => o.value == cancellationFee,
      orElse: () => SurchargeDropdownOption(value: '', label: ''),
    );
    if (opt.value.isNotEmpty && opt.rate != null) {
      cancellationFeeAmount = opt.rate!;
      labels.add(opt.label);
    }
  }

  // 할증률 계산 (가장 높은 할증률 100% + 나머지 상위 2개 50%) - 최대 상위 3개만 적용
  double finalRate = 0;
  if (rateItems.isNotEmpty) {
    // 할증률 기준 내림차순 정렬
    rateItems.sort((a, b) => b.rate.compareTo(a.rate));

    // 상위 3개만 추출
    final top3Items = rateItems.take(3).toList();

    // 상위 3개 항목의 라벨을 추가
    labels.addAll(top3Items.map((e) => e.label));

    final maxRate = top3Items.first.rate;
    final rest = top3Items.skip(1).fold(0.0, (sum, r) => sum + r.rate * 0.5);
    finalRate = maxRate + rest;
    finalRate = double.parse(finalRate.toStringAsFixed(6)); // 소수점 6자리
  }

  return SurchargeResult(
    rate: finalRate,
    cancellationFeeAmount: cancellationFeeAmount,
    labels: labels,
    fixedAmount: fixedAmount,
  );
}
