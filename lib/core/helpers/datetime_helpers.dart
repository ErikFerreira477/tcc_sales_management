import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String formatNumericDayMonthYear() {
    final day = NumberFormat('00').format(this.day);
    final month = NumberFormat('00').format(this.month);
    final year = NumberFormat('00').format(this.year);

    return '$day/$month/$year';
  }
}
