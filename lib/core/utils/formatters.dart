import 'package:intl/intl.dart';

/// Reusable formatting helpers so number/date presentation stays consistent
/// across every screen.
abstract final class Formatters {
  static final NumberFormat _thousands = NumberFormat('#,##0');
  static final NumberFormat _decimal1 = NumberFormat('#,##0.0');
  static final NumberFormat _decimal2 = NumberFormat('#,##0.00');

  static String integer(num value) => _thousands.format(value);

  static String oneDecimal(num value) => _decimal1.format(value);

  static String twoDecimal(num value) => _decimal2.format(value);

  static String currency(num value, String symbol, {int decimals = 2}) {
    final formatter = decimals == 0 ? _thousands : _decimal2;
    return '$symbol${formatter.format(value)}';
  }

  static String signedPercent(num value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${_decimal1.format(value)}%';
  }

  static String percent(num value) => '${_decimal1.format(value)}%';

  static String dayMonthYear(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  static String fullDate(DateTime date) =>
      DateFormat('d MMMM yyyy, h:mm a').format(date);

  static String shortDate(DateTime date) => DateFormat('d MMM').format(date);

  static String weekday(DateTime date) => DateFormat('EEE').format(date);

  static String monthShort(DateTime date) => DateFormat('MMM').format(date);

  /// Friendly relative grouping label used by the History screen.
  static String relativeGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return dayMonthYear(date);
  }
}
