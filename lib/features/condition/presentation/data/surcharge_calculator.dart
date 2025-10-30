import 'surcharge_options.dart';

/// 할증률 계산 결과 모델
class SurchargeResult {
  final double rate; // 예: 0.55 (55%)
  final double cancellationFeeAmount; // 배차 취소료
  final List<String> labels; // 적용된 항목 라벨

  SurchargeResult({
    required this.rate,
    required this.cancellationFeeAmount,
    required this.labels,
  });
}

/// 할증률 계산 함수
SurchargeResult calculateSurcharge({
  required List<String> selectedCheckboxIds,
  String? dangerType,
  String? weightType,
  String? specialType,
  String? cancellationFee,
}) {
  final rates = <double>[];
  final labels = <String>[];

  // 체크박스 할증률 (고정금액 무시)
  for (final id in selectedCheckboxIds) {
    final opt = surchargeCheckboxOptions.firstWhere(
      (o) => o.id == id,
      orElse: () => CheckboxOption(id: '', label: ''),
    );
    if (opt.id.isNotEmpty) {
      if (opt.rate != null && !opt.isFixed) {
        rates.add(opt.rate!);
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

  // 할증률 계산 (가장 높은 할증률 100% + 나머지 50%)
  double finalRate = 0;
  if (rates.isNotEmpty) {
    rates.sort((a, b) => b.compareTo(a));
    final maxRate = rates.first;
    final rest = rates.skip(1).fold(0.0, (sum, r) => sum + r * 0.5);
    finalRate = maxRate + rest;
    finalRate = double.parse(finalRate.toStringAsFixed(6)); // 소수점 6자리
  }

  return SurchargeResult(
    rate: finalRate,
    cancellationFeeAmount: cancellationFeeAmount,
    labels: labels,
  );
}
