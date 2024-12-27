import 'package:intl/intl.dart';

class NumberFormatter {
  static final _arabicFormatter = NumberFormat('#,##0.0', 'ar');
  static final _arabicIntFormatter = NumberFormat('#,##0', 'ar');
  
  /// Formats a number with Arabic locale and thousands separators
  /// If the number is a whole number, removes decimal places
  static String formatNumber(double number) {
    if (number == number.toInt()) {
      return _arabicIntFormatter.format(number);
    }
    // Check if decimal part is significant
    String decimalPart = (number - number.toInt()).toStringAsFixed(2);
    if (decimalPart == "0.00") {
      return _arabicIntFormatter.format(number);
    }
    return _arabicFormatter.format(number);
  }

  /// Formats a number for calculator display
  static String formatCalculatorNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  /// Formats currency amount with Arabic locale
  static String formatCurrency(double amount) {
    return '${formatNumber(amount)} جنية';
  }

  /// Get the appropriate font size for a number based on screen width
  static double getAppropriateTextSize(double number, double baseSize) {
    if (number >= 1000000) {
      return baseSize * 0.6; // 60% of original size for millions
    } else if (number >= 100000) {
      return baseSize * 0.7; // 70% of original size for hundred thousands
    } else if (number >= 10000) {
      return baseSize * 0.8; // 80% of original size for ten thousands
    }
    return baseSize; // Original size for smaller numbers
  }
}
