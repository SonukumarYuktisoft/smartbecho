// ============================================================================
// lib/core/enums/feature_status.dart (ENHANCED)
// ============================================================================

import 'package:flutter/material.dart';

enum FeatureStatus { allowed, locked, unauthorized }

extension FeatureStatusExtension on FeatureStatus {
  // ========================================================================
  // BOOLEAN GETTERS
  // ========================================================================

  bool get isAllowed => this == FeatureStatus.allowed;
  bool get isLocked => this == FeatureStatus.locked;
  bool get isUnauthorized => this == FeatureStatus.unauthorized;

  /// ✅ Can access (ALLOWED or LOCKED - can still view)
  bool get canAccess => isAllowed || isLocked;

  /// 🚫 Cannot access at all
  bool get isDenied => isUnauthorized;

  /// 🔒 Needs upgrade
  bool get needsUpgrade => isLocked;

  /// ✅ Fully accessible without upgrade
  bool get isFree => isAllowed;

  // ========================================================================
  // DISPLAY STRINGS
  // ========================================================================

  String get displayName {
    switch (this) {
      case FeatureStatus.allowed:
        return 'Available';
      case FeatureStatus.locked:
        return 'Premium Feature';
      case FeatureStatus.unauthorized:
        return 'Unauthorized';
    }
  }

  String get label {
    switch (this) {
      case FeatureStatus.allowed:
        return 'ALLOWED';
      case FeatureStatus.locked:
        return 'LOCKED';
      case FeatureStatus.unauthorized:
        return 'UNAUTHORIZED';
    }
  }

  /// Emoji representation
  String get emoji {
    switch (this) {
      case FeatureStatus.allowed:
        return '✅';
      case FeatureStatus.locked:
        return '🔒';
      case FeatureStatus.unauthorized:
        return '🚫';
    }
  }

  /// Full emoji + label
  String get emojiLabel {
    return '$emoji $label';
  }

  /// Short code
  String get shortCode {
    switch (this) {
      case FeatureStatus.allowed:
        return 'A';
      case FeatureStatus.locked:
        return 'L';
      case FeatureStatus.unauthorized:
        return 'U';
    }
  }

  // ========================================================================
  // COLOR REPRESENTATION
  // ========================================================================

  /// Get color for UI display
  /// Import: import 'package:flutter/material.dart';
  Color get color {
    switch (this) {
      case FeatureStatus.allowed:
        return const Color(0xFF10B981); // Green
      case FeatureStatus.locked:
        return const Color(0xFFF59E0B); // Orange
      case FeatureStatus.unauthorized:
        return const Color(0xFFEF4444); // Red
    }
  }

  /// Light background color
  Color get backgroundColor {
    switch (this) {
      case FeatureStatus.allowed:
        return const Color(0xFFD1FAE5); // Light green
      case FeatureStatus.locked:
        return const Color(0xFFFEF3C7); // Light orange
      case FeatureStatus.unauthorized:
        return const Color(0xFFFEE2E2); // Light red
    }
  }

  /// Icon data representation
  /// Import: import 'package:flutter/material.dart';
  IconData get icon {
    switch (this) {
      case FeatureStatus.allowed:
        return Icons.check_circle;
      case FeatureStatus.locked:
        return Icons.lock_outline;
      case FeatureStatus.unauthorized:
        return Icons.block;
    }
  }

  // ========================================================================
  // ACTION MESSAGES
  // ========================================================================

  String get actionMessage {
    switch (this) {
      case FeatureStatus.allowed:
        return 'You can access this feature';
      case FeatureStatus.locked:
        return 'Upgrade to access this premium feature';
      case FeatureStatus.unauthorized:
        return 'You do not have permission to access this feature';
    }
  }

  String get buttonText {
    switch (this) {
      case FeatureStatus.allowed:
        return 'Access Feature';
      case FeatureStatus.locked:
        return 'Upgrade Now';
      case FeatureStatus.unauthorized:
        return 'Contact Admin';
    }
  }

  // ========================================================================
  // COMPARISON METHODS
  // ========================================================================

  /// Compare two statuses
  int compareTo(FeatureStatus other) {
    // allowed (0) < locked (1) < unauthorized (2)
    const order = {
      FeatureStatus.allowed: 0,
      FeatureStatus.locked: 1,
      FeatureStatus.unauthorized: 2,
    };
    return (order[this] ?? 0).compareTo(order[other] ?? 0);
  }

  /// Is this status better or equal to another
  bool isBetterOrEqual(FeatureStatus other) {
    return compareTo(other) <= 0;
  }

  /// Is this status worse than another
  bool isWorseThan(FeatureStatus other) {
    return compareTo(other) > 0;
  }

  // ========================================================================
  // CONVERSION
  // ========================================================================

  /// Convert from string
  static FeatureStatus fromString(String value) {
    final upperValue = value.toUpperCase().trim();
    switch (upperValue) {
      case 'ALLOWED':
        return FeatureStatus.allowed;
      case 'LOCKED':
        return FeatureStatus.locked;
      case 'UNAUTHORIZED':
        return FeatureStatus.unauthorized;
      default:
        return FeatureStatus.unauthorized;
    }
  }

  /// Convert to string
  String toStringValue() => label;

  // ========================================================================
  // LOGGING
  // ========================================================================

  /// Format for logging
  String get logMessage {
    switch (this) {
      case FeatureStatus.allowed:
        return '[✅ ALLOWED] Feature is accessible';
      case FeatureStatus.locked:
        return '[🔒 LOCKED] Feature requires premium upgrade';
      case FeatureStatus.unauthorized:
        return '[🚫 UNAUTHORIZED] Feature access denied - contact admin';
    }
  }

  // ========================================================================
  // UTILITY METHODS
  // ========================================================================

  /// Get description for user display
  String getDescription(String featureName) {
    switch (this) {
      case FeatureStatus.allowed:
        return '$featureName is available for you';
      case FeatureStatus.locked:
        return '$featureName is available only in Premium Plan';
      case FeatureStatus.unauthorized:
        return 'You do not have access to $featureName';
    }
  }

  /// Get next better status if upgrade
  FeatureStatus? getUpgradedStatus() {
    switch (this) {
      case FeatureStatus.allowed:
        return null; // Already best
      case FeatureStatus.locked:
        return FeatureStatus.allowed; // Upgrade to allowed
      case FeatureStatus.unauthorized:
        return FeatureStatus.locked; // At least locked (view-only)
    }
  }

  /// Check if requires payment
  bool get requiresPayment {
    return isLocked || isUnauthorized;
  }

  /// Check if can be upgraded
  bool get canBeUpgraded {
    return isLocked || isUnauthorized;
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/*
import 'package:flutter/material.dart';

// Basic checks
FeatureStatus status = FeatureStatus.locked;

if (status.isAllowed) {
  print('Feature is free');
}

if (status.isLocked) {
  print('Feature is premium');
}

if (status.isUnauthorized) {
  print('Feature is denied');
}

// Display in UI
Text(status.displayName); // "Premium Feature"
Text(status.label); // "LOCKED"
Text(status.emoji); // "🔒"
Text(status.emojiLabel); // "🔒 LOCKED"

// Colors
Container(
  color: status.color,
  child: Icon(status.icon),
);

// Messages
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(status.displayName),
    content: Text(status.actionMessage),
    actions: [
      ElevatedButton(
        onPressed: () {},
        child: Text(status.buttonText),
      ),
    ],
  ),
);

// Logging
log(status.logMessage);

// Comparisons
FeatureStatus s1 = FeatureStatus.allowed;
FeatureStatus s2 = FeatureStatus.locked;

if (s1.isBetterOrEqual(s2)) {
  print('s1 is better or equal to s2');
}

if (s2.isWorseThan(s1)) {
  print('s2 is worse than s1');
}

// Conversion
String str = 'LOCKED';
FeatureStatus status = FeatureStatus.fromString(str);

String back = status.toStringValue(); // "LOCKED"

// Descriptions
print(status.getDescription('Invoice Export')); 
// "Invoice Export is available only in Premium Plan"

// Upgrade path
FeatureStatus upgraded = status.getUpgradedStatus();
// Returns FeatureStatus.allowed (next better status)

// Feature checks
if (status.requiresPayment) {
  print('This feature requires payment');
}

if (status.canBeUpgraded) {
  print('User can upgrade for this feature');
}
*/