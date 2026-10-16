import 'package:intl/intl.dart';

/// Helper utility for formatting dates in Indonesian locale
class DateFormatter {
  DateFormatter._();

  /// Format String ISO date or SQL datetime to "dd MMMM yyyy" (e.g. 17 September 2026)
  static String formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return '-';

    try {
      final parsed = DateTime.parse(date.trim());
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return date;
    }
  }

  /// Format to "dd MMM yyyy, HH:mm" (e.g. 17 Sep 2026, 08:30)
  static String formatDateTime(String? date) {
    if (date == null || date.trim().isEmpty) return '-';

    try {
      final parsed = DateTime.parse(date.trim());
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      return date;
    }
  }

  /// Format to "HH:mm" (e.g. 08:30)
  static String formatTime(String? date) {
    if (date == null || date.trim().isEmpty) return '-';

    try {
      final parsed = DateTime.parse(date.trim());
      return DateFormat('HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      return date;
    }
  }

  /// Format DateTime object to "dd MMMM yyyy"
  static String formatDateTimeObject(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }
}

/// Top-level function for backward-compatibility with existing calls to `formatDate(...)`
String formatDate(String? date) => DateFormatter.formatDate(date);

