import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppFormatterHelper {
  static String formatIndianNumber(num number) {
    final formatter = NumberFormat.decimalPattern('hi_IN');
    return formatter.format(number);
  }

  static num parseAmount(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value;
    }

    if (value is String) {
      return num.tryParse(value) ?? 0;
    }

    return 0;
  }

  static String amountFormatter(num amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toString();
    }
  }

  static String formatRamForUI(String value) {
    // Extract only digits
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    return '$numbers GB';
  }

  static String fastCorrector(
    String input, {
    bool trim = true,
    bool toUpper = false,
    bool toLower = false,
    bool removeExtraSpaces = true,
    bool allowOnlyDigits = false,
    bool allowAlphaNumeric = false,
  }) {
    String value = input;

    if (trim) {
      value = value.trim();
    }

    if (removeExtraSpaces) {
      value = value.replaceAll(RegExp(r'\s+'), ' ');
    }

    if (allowOnlyDigits) {
      value = value.replaceAll(RegExp(r'[^0-9]'), '');
    } else if (allowAlphaNumeric) {
      value = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }

    if (toUpper) {
      value = value.toUpperCase();
    } else if (toLower) {
      value = value.toLowerCase();
    }

    return value;
  }

  static String capitalizeFirst(String value) {
    if (value.trim().isEmpty) return '';
    final cleaned = value.trim();
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }

  static String formatGST(String value) {
    return fastCorrector(value, toUpper: true, allowAlphaNumeric: true);
  }

  static Color getCollectionColor(double value) {
    if (value > 0) return Colors.green;
    if (value == 0) return Colors.grey;
    return Colors.red;
  }

  static String getCollectionLabel(double value) {
    if (value > 0) return "CREDIT";
    if (value < 0) return "DEBIT";
    return "BALANCE";
  }

  static String getFormattedValue(double value) {
    if (value > 0) return "+${value.abs()}";
    if (value < 0) return "-${value.abs()}";
    return value.toString();
  }

  static double _parseValue(dynamic value) {
    if (value == null) return 0;

    if (value is num) return value.toDouble();

    if (value is String) {
      // remove ₹, commas, spaces
      final cleaned = value.replaceAll('₹', '').replaceAll(',', '').trim();

      return double.tryParse(cleaned) ?? 0;
    }

    return 0;
  }

  static Widget formatAmountWidget({
    required dynamic value,
    bool compact = true,
    bool colored = true,
    bool showSign = false,
    bool showType = false,
    bool showTypeOnly = false,
    bool showRupee = false,
    bool reverseValue = false,
    TextStyle? style,
  }) {
    double amount = _parseValue(value);

    // 🔥 FORCE DEBIT MODE
    if (reverseValue) {
      amount = -amount.abs();
    }

    // ---------- TYPE ----------
    final bool isCredit = amount > 0;
    final bool isDebit = amount < 0;

    final String type =
        isCredit
            ? "CREDIT"
            : isDebit
            ? "DEBIT"
            : "BALANCE";

    // ---------- COLOR ----------
    final Color color =
        !colored
            ? Colors.black
            : isCredit
            ? const Color(0xFF10B981)
            : isDebit
            ? const Color(0xFFEF4444)
            : Colors.grey;

    // ---------- TYPE ONLY ----------
    if (showTypeOnly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Text(
          type,
          style: (style ??
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
              .copyWith(color: color),
        ),
      );
    }

    // ---------- SIGN ----------
    final String sign =
        showSign
            ? isCredit
                ? "+"
                : isDebit
                ? "-"
                : ""
            : "";

    // ---------- FORMAT ----------
    final double abs = amount.abs();
    String formattedValue;

    if (!compact) {
      formattedValue = NumberFormat.decimalPattern('en_IN').format(abs.round());
    } else if (abs >= 10000000) {
      formattedValue = "${(abs / 10000000).toStringAsFixed(1)} Cr";
    } else if (abs >= 100000) {
      formattedValue = "${(abs / 100000).toStringAsFixed(1)} L";
    } else if (abs >= 1000) {
      formattedValue = "${(abs / 1000).toStringAsFixed(1)} K";
    } else {
      formattedValue = abs.toStringAsFixed(0);
    }

    final String rupee = showRupee ? "₹" : "";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showType) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            child: Text(
              type,
              style: (style ??
                      const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ))
                  .copyWith(color: color),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          "$sign$rupee$formattedValue",
          style: (style ??
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
              .copyWith(color: color),
        ),
      ],
    );
  }
}
