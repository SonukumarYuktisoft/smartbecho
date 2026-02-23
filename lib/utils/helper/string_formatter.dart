class StringFormatter {
  StringFormatter._(); // no instance

  /// 🔹 SALE_DUES_DOWNPAYMENT → SALE DUES DOWNPAYMENT
  static String fromSnakeUpper(String value) {
    return value.replaceAll('_', ' ').trim();
  }

  /// 🔹 SALE_DUES_DOWNPAYMENT → Sale Dues Downpayment
  static String toTitleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// 🔹 sale_dues_downpayment → SALE DUES DOWNPAYMENT
  static String toUpperWords(String value) {
    return value.replaceAll('_', ' ').toUpperCase();
  }

  /// 🔹 camelCase / PascalCase → CAMEL CASE
  static String fromCamelCase(String value) {
    return value
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toUpperCase();
  }

  /// 🔹 Common smart formatter (auto detect)
  static String smart(String value) {
    if (value.contains('_')) {
      return fromSnakeUpper(value);
    }
    if (RegExp(r'[a-z][A-Z]').hasMatch(value)) {
      return fromCamelCase(value);
    }
    return value;
  }

  static String toTitle(dynamic value) {
    if (value == null) return "";

    String text = value.toString().trim();
    if (text.isEmpty) return "";

    // 1️⃣ camelCase / PascalCase → space
    text = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );

    // 2️⃣ underscores / multiple spaces → single space
    text = text.replaceAll(RegExp(r'[_\s]+'), ' ');

    // 3️⃣ lowercase + capitalize each word
    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}
