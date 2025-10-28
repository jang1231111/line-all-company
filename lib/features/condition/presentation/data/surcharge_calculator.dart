import 'surcharge_options.dart';

/// 할증률 계산 결과 모델
class SurchargeResult {
  final double rate; // 예: 0.55 (55%)
  final double fixedAmount; // 고정금액 할증 (있다면)
  final List<String> labels; // 적용된 항목 라벨

  SurchargeResult({
    required this.rate,
    required this.fixedAmount,
    required this.labels,
  });
}

/// 할증률 계산 함수
SurchargeResult calculateSurcharge({
  required List<String> selectedCheckboxIds,
  String? dangerType,
  String? weightType,
  String? specialType,
  String? cancellationFee, // <- 파라미터는 남겨둬도 무방
}) {
  final rates = <double>[];
  double fixedAmount = 0;
  final labels = <String>[];

  // 체크박스 할증률
  for (final id in selectedCheckboxIds) {
    final opt = surchargeCheckboxOptions.firstWhere(
      (o) => o.id == id,
      orElse: () => CheckboxOption(id: '', label: ''),
    );
    if (opt.id.isNotEmpty) {
      if (opt.rate != null) {
        if (opt.isFixed) {
          fixedAmount += opt.rate!;
        } else {
          rates.add(opt.rate!);
        }
      }
      labels.add(opt.label);
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
        rates.add(opt.rate!);
        labels.add(opt.label);
      }
    }
  }

  addDropdownRate(dangerTypeOptions, dangerType);
  addDropdownRate(weightTypeOptions, weightType);
  addDropdownRate(specialTypeOptions, specialType);
  // addDropdownRate(cancellationFeeOptions, cancellationFee); // <- 제외

  // 할증률 계산 (가장 높은 할증률 100% + 나머지 50%)
  double finalRate = 0;
  if (rates.isNotEmpty) {
    rates.sort((a, b) => b.compareTo(a));
    final maxRate = rates.first;
    final rest = rates.skip(1).fold(0.0, (sum, r) => sum + r * 0.5);
    finalRate = maxRate + rest;
    finalRate = double.parse(finalRate.toStringAsFixed(6)); // 소수점 6자리
  }

  return SurchargeResult(rate: finalRate, fixedAmount: fixedAmount, labels: labels);
}