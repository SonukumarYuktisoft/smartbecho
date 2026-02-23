// subscription_bottom_sheet.dart
// Reusable bottom sheet to show subscription prompt
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/views/subscription%20plan/subscription_plan_screen.dart';

class SubscriptionBottomSheet {
  static void show({
    String? title,
    String? message,
    String? currentPlan,
    bool showTrial = true,
  }) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title ?? 'Upgrade Your Plan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message ??
                  'Get access to premium features and unlock your full potential!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Current Plan Info
            if (currentPlan != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Current: $currentPlan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 24),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const SubscriptionPlanScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Plans',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Maybe Later Button
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  
}

// Service to auto-show bottom sheet after 2 minutes
class SubscriptionPromptService {
  static DateTime? _appStartTime;
  static bool _hasShownPrompt = false;

  static void init() {
    _appStartTime = DateTime.now();
    _hasShownPrompt = false;
  }

  static void checkAndShowPrompt({
    required bool hasActivePlan,
    String? currentPlan,
  }) {
    // Don't show if user has active plan (not trial/free)
    if (hasActivePlan && currentPlan != 'TRIAL' && currentPlan != 'FREE') {
      return;
    }

    // Don't show if already shown
    if (_hasShownPrompt) {
      return;
    }

    // Check if 2 minutes have passed
    if (_appStartTime != null) {
      final elapsed = DateTime.now().difference(_appStartTime!);
      if (elapsed.inMinutes >= 2) {
        _hasShownPrompt = true;
        
        // Show bottom sheet
        Future.delayed(const Duration(milliseconds: 500), () {
          SubscriptionBottomSheet.show(
            title: 'Unlock Premium Features',
            message: 'Upgrade your plan to access exclusive features and grow your business faster!',
            currentPlan: currentPlan,
          );
        });
      }
    }
  }

  static void reset() {
    _hasShownPrompt = false;
  }
}