import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  static const int maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;

    String formatted = digits;

    if (digits.startsWith('02')) {
      if (digits.length <= 2) {
        formatted = digits;
      } else if (digits.length <= 6) {
        formatted = digits.substring(0, 2) + '-' + digits.substring(2);
      } else {
        final part2 = digits.substring(2, digits.length - 4);
        final part3 = digits.substring(digits.length - 4);
        formatted = '02-$part2-$part3';
      }
    } else {
      if (digits.length <= 3) {
        formatted = digits;
      } else if (digits.length <= 7) {
        formatted = digits.substring(0, 3) + '-' + digits.substring(3);
      } else {
        final part2 = digits.substring(3, digits.length - 4);
        final part3 = digits.substring(digits.length - 4);
        formatted = '${digits.substring(0, 3)}-$part2-$part3';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}