// ============================================================================
// lib/services/permission_guard_service.dart (STRICT BLOCKING)
// ============================================================================

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_status.dart';

class PermissionGuardService {
  static final PermissionGuardService _instance =
      PermissionGuardService._internal();
  factory PermissionGuardService() => _instance;
  PermissionGuardService._internal();

  /// 🛡️ Check permission - STRICT METHOD
  /// ✅ ALLOWED → true (proceed)
  /// 🔒 LOCKED → show dialog, return false (block)
  /// 🚫 UNAUTHORIZED → show dialog, return false (block)
  /// ❌ NOT FOUND → show unauthorized dialog, return false (block)
  Future<bool> checkPermission({
    String? featureKey,
    BuildContext? context,
    bool showDialog = true,
  }) async {
    log("🛡️ [PermissionGuard] checkPermission() called");
    log("   ├─ featureKey: '$featureKey'");
    log("   ├─ showDialog: $showDialog");
    log("   └─ isRegistered: ${getx.Get.isRegistered<FeatureController>()}");

    // ========================================================================
    // ❌ NO FEATURE KEY - ALLOW (skip check)
    // ========================================================================
    if (featureKey == null || featureKey.isEmpty) {
      log("⏭️ [PermissionGuard] No featureKey - ALLOWING");
      return true;
    }

    try {
      // ========================================================================
      // ❌ CONTROLLER NOT REGISTERED - ALLOW (fail-safe)
      // ========================================================================
      if (!getx.Get.isRegistered<FeatureController>()) {
        log("⚠️ [PermissionGuard] Controller NOT registered - ALLOWING (fail-safe)");
        return true;
      }

      final controller = getx.Get.find<FeatureController>();
      final allFeatures = controller.getAllFeatures();

      // ========================================================================
      // ❌ FEATURE KEY NOT FOUND - BLOCK AS UNAUTHORIZED
      // ========================================================================
      if (!allFeatures.containsKey(featureKey)) {
        log("❌ [PermissionGuard] Feature '$featureKey' NOT FOUND in permissions");
        log("   ├─ Total features available: ${allFeatures.length}");
        log("   ├─ Available features: ${allFeatures.keys.toList()}");
        log("   └─ Treating as UNAUTHORIZED - BLOCKING API call");
        
        // if (showDialog) {
        //   _showUnauthorizedDialog(featureKey, context);
        // }
        return false; // Block - key doesn't exist = unauthorized
      }

      // ========================================================================
      // 📊 FEATURE FOUND - Check status
      // ========================================================================
      final status = controller.statusOf(featureKey);

      log("📊 [PermissionGuard] Feature '$featureKey' FOUND");
      log("   └─ Status: ${status.displayName}");

      // ✅ ALLOWED
      if (status == FeatureStatus.allowed) {
        log("✅ [PermissionGuard] '$featureKey' is ALLOWED - PROCEEDING");
        return true;
      }

      // 🔒 LOCKED
      if (status == FeatureStatus.locked) {
        log("🔒 [PermissionGuard] '$featureKey' is LOCKED - BLOCKING");
        if (showDialog) {
          // _showLockedDialog(featureKey, context);
        }
        return false;
      }

      // 🚫 UNAUTHORIZED
      if (status == FeatureStatus.unauthorized) {
        log("🚫 [PermissionGuard] '$featureKey' is UNAUTHORIZED - BLOCKING");
        if (showDialog) {
          // _showUnauthorizedDialog(featureKey, context);
        }
        return false;
      }

      log("⚠️ [PermissionGuard] Unknown status - BLOCKING (safe)");
      if (showDialog) {
        // _showUnauthorizedDialog(featureKey, context);
      }
      return false; // Block unknown status
    } catch (e) {
      log("❌ [PermissionGuard] Exception: $e");
      log("   └─ Treating as UNAUTHORIZED - BLOCKING");
      if (showDialog) {
        // _showUnauthorizedDialog(featureKey ?? 'unknown', context);
      }
      return false; // Block on exception
    }
  }

  // ========================================================================
  // QUICK CHECK METHODS
  // ========================================================================

  bool isAllowed(String featureKey) {
    try {
      if (!getx.Get.isRegistered<FeatureController>()) return false;
      final controller = getx.Get.find<FeatureController>();
      
      // If key not found, treat as NOT allowed
      if (!controller.getAllFeatures().containsKey(featureKey)) {
        return false;
      }
      
      return controller.isFeatureAllowed(featureKey);
    } catch (e) {
      return false;
    }
  }

  bool isLocked(String featureKey) {
    try {
      if (!getx.Get.isRegistered<FeatureController>()) return false;
      final controller = getx.Get.find<FeatureController>();
      
      // If key not found, not locked (it's unauthorized instead)
      if (!controller.getAllFeatures().containsKey(featureKey)) {
        return false;
      }
      
      return controller.isFeatureLocked(featureKey);
    } catch (e) {
      return false;
    }
  }

  bool isUnauthorized(String featureKey) {
    try {
      if (!getx.Get.isRegistered<FeatureController>()) return true; // Treat as unauthorized
      final controller = getx.Get.find<FeatureController>();
      
      // If key not found, treat as unauthorized
      if (!controller.getAllFeatures().containsKey(featureKey)) {
        return true;
      }
      
      return controller.isFeatureUnauthorized(featureKey);
    } catch (e) {
      return true; // Treat exception as unauthorized
    }
  }

  FeatureStatus getStatus(String featureKey) {
    try {
      if (!getx.Get.isRegistered<FeatureController>()) {
        return FeatureStatus.unauthorized;
      }
      final controller = getx.Get.find<FeatureController>();
      
      // If key not found, treat as unauthorized
      if (!controller.getAllFeatures().containsKey(featureKey)) {
        return FeatureStatus.unauthorized;
      }
      
      return controller.statusOf(featureKey);
    } catch (e) {
      return FeatureStatus.unauthorized;
    }
  }

  // ========================================================================
  // DIALOG METHODS
  // ========================================================================

  void _showLockedDialog(String feature, BuildContext? context) {
    getx.Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Premium Feature',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This feature is available in the premium plan.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feature: $feature',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              getx.Get.back();
              getx.Get.toNamed('/upgrade');
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Upgrade'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showUnauthorizedDialog(String feature, BuildContext? context) {
    getx.Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Access Denied',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You do not have permission to access this feature.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feature: $feature',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              getx.Get.back();
              getx.Get.snackbar(
                'Contact Admin',
                'Reach out to your system administrator',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showLockedDialog(String feature, {BuildContext? context}) =>
      _showLockedDialog(feature, context);

  void showUnauthorizedDialog(String feature, {BuildContext? context}) =>
      _showUnauthorizedDialog(feature, context);
}