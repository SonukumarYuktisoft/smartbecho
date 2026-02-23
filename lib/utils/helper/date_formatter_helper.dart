import 'package:intl/intl.dart';
class DateFormatterHelper {
  DateFormatterHelper._(); // private constructor (no instance)

  /// 🔹 Auto-detect and parse (handles all formats)
  static DateTime _parseAuto(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      // Try different formats
      if (date.isEmpty) throw ArgumentError('Date string is empty');

      // Try ISO format first (2026-02-10)
      try {
        return DateTime.parse(date);
      } catch (_) {}

      // Try "10 Feb 2026" format
      try {
        return DateFormat('dd MMM yyyy').parse(date);
      } catch (_) {}

      // Try "10/02/2026" format
      try {
        return DateFormat('dd/MM/yyyy').parse(date);
      } catch (_) {}

      // Try "10-02-2026" format
      try {
        return DateFormat('dd-MM-yyyy').parse(date);
      } catch (_) {}

      // Try "Feb 10, 2026" format
      try {
        return DateFormat('MMM dd, yyyy').parse(date);
      } catch (_) {}

      throw ArgumentError('Unable to parse date: $date');
    } else {
      throw ArgumentError('Invalid date type. Expected DateTime or String.');
    }
  }

  /// 🔹 **ALL IN ONE** - Smart format that handles everything
  /// Returns: "Just now", "5 min ago", "2 hrs ago", "Today", "Yesterday", "07 Feb 2026"
  static String smartFormat(dynamic date) {
    final dt = _parseAuto(date);
    final now = DateTime.now();
    final diff = now.difference(dt);

    // Future dates
    if (dt.isAfter(now)) {
      final futureDiff = dt.difference(now);
      if (futureDiff.inSeconds < 60) return "In a moment";
      if (futureDiff.inMinutes < 60) return "In ${futureDiff.inMinutes} min";
      if (futureDiff.inHours < 24) return "In ${futureDiff.inHours} hrs";
      if (isTomorrow(dt)) return "Tomorrow";
      return format(dt); // "07 Feb 2026"
    }

    // Just now (less than 1 minute)
    if (diff.inSeconds < 60) return "Just now";

    // Minutes ago (1-59 minutes)
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";

    // Hours ago (1-23 hours)
    if (diff.inHours < 24) {
      // Check if it's still today
      if (isToday(dt)) {
        return "${diff.inHours} ${diff.inHours == 1 ? 'hr' : 'hrs'} ago";
      }
    }

    // Yesterday
    if (isYesterday(dt)) return "Yesterday";

    // Today (but more than 24 hours ago - edge case)
    if (isToday(dt)) return "Today";

    // Last 7 days (2-6 days ago)
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    // Older dates - show full date
    return format(dt); // "07 Feb 2026"
  }

  /// 🔹 **ALL IN ONE WITH TIME** - Smart format with time
  /// Returns: "Just now", "5 min ago", "Today at 2:30 PM", "Yesterday at 10:00 AM", "07 Feb 2026 at 3:45 PM"
  static String smartFormatWithTime(dynamic date) {
    final dt = _parseAuto(date);
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time = DateFormat('h:mm a').format(dt); // "2:30 PM"

    // Future dates
    if (dt.isAfter(now)) {
      final futureDiff = dt.difference(now);
      if (futureDiff.inSeconds < 60) return "In a moment";
      if (futureDiff.inMinutes < 60) return "In ${futureDiff.inMinutes} min";
      if (futureDiff.inHours < 24) return "In ${futureDiff.inHours} hrs";
      if (isTomorrow(dt)) return "Tomorrow at $time";
      return "${format(dt)} at $time"; // "07 Feb 2026 at 3:45 PM"
    }

    // Just now
    if (diff.inSeconds < 60) return "Just now";

    // Minutes ago
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";

    // Hours ago (still today)
    if (diff.inHours < 24 && isToday(dt)) {
      return "${diff.inHours} ${diff.inHours == 1 ? 'hr' : 'hrs'} ago";
    }

    // Today (but show time)
    if (isToday(dt)) return "Today at $time";

    // Yesterday
    if (isYesterday(dt)) return "Yesterday at $time";

    // Last 7 days
    if (diff.inDays < 7) return "${diff.inDays} days ago at $time";

    // Older dates
    return "${format(dt)} at $time"; // "07 Feb 2026 at 3:45 PM"
  }

  /// 🔹 **COMPACT FORMAT** - Ultra short format
  /// Returns: "now", "5m", "2h", "Today", "Yesterday", "07 Feb"
  static String compactFormat(dynamic date) {
    final dt = _parseAuto(date);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24 && isToday(dt)) return "${diff.inHours}h";
    if (isToday(dt)) return "Today";
    if (isYesterday(dt)) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d";

    // Show date without year if same year
    if (dt.year == now.year) {
      return DateFormat('dd MMM').format(dt); // "07 Feb"
    }

    return DateFormat('dd MMM yy').format(dt); // "07 Feb 26"
  }

  /// 🔹 API string (yyyy-MM-dd) → DateTime
  static DateTime parse(String date) {
    return DateTime.parse(date);
  }

  /// 🔹 DateTime → "07 Feb 2026" (auto-handles String too)
  static String format(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('dd MMM yyyy').format(dt);
  }

  /// 🔹 String date → "07 Feb 2026"
  static String formatFromString(String date) {
    return format(parse(date));
  }

  /// 🔹 Today check (auto-handles String or DateTime)
  static bool isToday(dynamic date) {
    final dt = _parseAuto(date);
    final now = DateTime.now();
    return now.year == dt.year && now.month == dt.month && now.day == dt.day;
  }

  /// 🔹 Yesterday check (auto-handles String or DateTime)
  static bool isYesterday(dynamic date) {
    final dt = _parseAuto(date);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == dt.year &&
        yesterday.month == dt.month &&
        yesterday.day == dt.day;
  }

  /// 🔹 Tomorrow check (auto-handles String or DateTime)
  static bool isTomorrow(dynamic date) {
    final dt = _parseAuto(date);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.year == dt.year &&
        tomorrow.month == dt.month &&
        tomorrow.day == dt.day;
  }

  /// 🔹 Today / Yesterday / Date format (auto-handles String or DateTime)
  static String smartDate(dynamic date) {
    final dt = _parseAuto(date);

    if (isToday(dt)) return "Today";
    if (isYesterday(dt)) return "Yesterday";
    if (isTomorrow(dt)) return "Tomorrow";

    return format(dt);
  }

  /// 🔹 With time (07 Feb 2026 • 10:30 AM) (auto-handles String or DateTime)
  static String formatWithTime(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  /// 🔹 API send format (yyyy-MM-dd) - Works with all date formats
  /// Input: "10 Feb 2026" or DateTime or "2026-02-10" etc
  /// Returns: "2026-02-10"
  static String toApi(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  /// 🔹 Full readable date (Saturday, 7 February 2026) (auto-handles String or DateTime)
  static String fullDate(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('EEEE, d MMMM yyyy').format(dt);
  }

  /// 🔹 Relative time (2 days ago, 5 minutes ago) (auto-handles String or DateTime)
  static String timeAgo(dynamic date) {
    final dt = _parseAuto(date);
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return format(dt);
  }

  /// 🔹 Short date (07/02/26) (auto-handles String or DateTime)
  static String shortDate(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('dd/MM/yy').format(dt);
  }

  /// 🔹 Month and Year (February 2026) (auto-handles String or DateTime)
  static String monthYear(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('MMMM yyyy').format(dt);
  }

  /// 🔹 Day and Month (07 Feb) (auto-handles String or DateTime)
  static String dayMonth(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('dd MMM').format(dt);
  }

  /// 🔹 Time only (10:30 AM) (auto-handles String or DateTime)
  static String timeOnly(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('hh:mm a').format(dt);
  }

  /// 🔹 Check if date is in the past (auto-handles String or DateTime)
  static bool isPast(dynamic date) {
    final dt = _parseAuto(date);
    return dt.isBefore(DateTime.now());
  }

  /// 🔹 Check if date is in the future (auto-handles String or DateTime)
  static bool isFuture(dynamic date) {
    final dt = _parseAuto(date);
    return dt.isAfter(DateTime.now());
  }

  /// 🔹 Get difference in days (auto-handles String or DateTime)
  static int daysBetween(dynamic date1, dynamic date2) {
    final dt1 = _parseAuto(date1);
    final dt2 = _parseAuto(date2);
    return dt1.difference(dt2).inDays.abs();
  }

  /// 🔹 Add days to date (auto-handles String or DateTime)
  static DateTime addDays(dynamic date, int days) {
    final dt = _parseAuto(date);
    return dt.add(Duration(days: days));
  }

  /// 🔹 Subtract days from date (auto-handles String or DateTime)
  static DateTime subtractDays(dynamic date, int days) {
    final dt = _parseAuto(date);
    return dt.subtract(Duration(days: days));
  }

  /// 🔹 Start of day (00:00:00) (auto-handles String or DateTime)
  static DateTime startOfDay(dynamic date) {
    final dt = _parseAuto(date);
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// 🔹 End of day (23:59:59) (auto-handles String or DateTime)
  static DateTime endOfDay(dynamic date) {
    final dt = _parseAuto(date);
    return DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
  }

  /// 🔹 First day of month (auto-handles String or DateTime)
  static DateTime firstDayOfMonth(dynamic date) {
    final dt = _parseAuto(date);
    return DateTime(dt.year, dt.month, 1);
  }

  /// 🔹 Last day of month (auto-handles String or DateTime)
  static DateTime lastDayOfMonth(dynamic date) {
    final dt = _parseAuto(date);
    return DateTime(dt.year, dt.month + 1, 0);
  }

  /// 🔹 Age calculator (auto-handles String or DateTime)
  static int calculateAge(dynamic birthDate) {
    final dt = _parseAuto(birthDate);
    final today = DateTime.now();
    int age = today.year - dt.year;
    if (today.month < dt.month ||
        (today.month == dt.month && today.day < dt.day)) {
      age--;
    }
    return age;
  }

  /// 🔹 Format for filename (2026-02-07_10-30-45)
  static String filenameFormat(dynamic date) {
    final dt = _parseAuto(date);
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(dt);
  }

  /// 🔹 ISO 8601 format (2026-02-07T10:30:45.000Z)
  static String toIso8601(dynamic date) {
    final dt = _parseAuto(date);
    return dt.toIso8601String();
  }

  /// 🔹 Convert DateTime to String (yyyy-MM-dd)
  /// Usage: String dateStr = DateFormatterHelper.dateTimeToString(customEndDate.value);
  static String dateTimeToString(DateTime? dateTime) {
    if (dateTime == null) return '';
    return toApi(dateTime); // Returns "yyyy-MM-dd" format
  }

  /// 🔹 Convert String to DateTime (supports all formats)
  /// Input: "10 Feb 2026" or "2026-02-10" or "10/02/2026" etc
  /// Usage: DateTime? date = DateFormatterHelper.stringToDateTime("10 Feb 2026");
  static DateTime? stringToDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _parseAuto(dateString);
    } catch (e) {
      return null;
    }
  }
}
