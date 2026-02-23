import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/current_subscription_model.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/subscription_plan_model.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/upgrade_price_model.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/user_subscription_model.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/subscription_history_model.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';

class SubscriptionController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  @override
  void onInit() {
    super.onInit();
    getSubscriptionPlans();
  }

  // ==================== RX VARIABLES ====================

  // Plans
  var plansLoading = false.obs;
  var plansList = <SubscriptionPlan>[].obs;
  
  // 🔥 NEW: Plans with upgrade prices
  var plansWithUpgrade = <SubscriptionPlanWithUpgrade>[].obs;

  // Current Subscription
  var currentSubscriptionLoading = false.obs;
  var currentSubscriptionplanCode = ''.obs;
  var currentSubscriptions = <UserSubscription>[].obs;

  // Subscription History
  var historyLoading = false.obs;
  var historyList = <UserSubscription>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var hasMoreHistory = true.obs;

  // Trial
  var startTrialLoading = false.obs;

  // Upgrade Price
  var upgradePriceLoading = false.obs;
  var upgradePrice = Rxn<UpgradePricePayload>();

  // ==================== FETCH SUBSCRIPTION PLANS ====================
  /// Get all available subscription plans with upgrade prices
  Future<void> getSubscriptionPlans() async {
    try {
      plansLoading.value = true;

      log("📡 Fetching subscription plans with upgrade prices");

      // First get current subscription
      await getCurrentSubscription();

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/subscriptions/public/plans/with-upgrade-prices',
        dictParameter: {'userId': dashboardController.userId.value},
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final plansResponse = SubscriptionPlanWithUpgradeResponse.fromJson(response.data);

        if (plansResponse.status == "SUCCESS") {
          plansWithUpgrade.value = plansResponse.payload ?? [];
          log("✅ Plans with upgrade prices loaded: ${plansWithUpgrade.length} plans found");
        } else {
          throw Exception(plansResponse.message);
        }
      } else {
        throw Exception('Failed to fetch plans');
      }
    } catch (error) {
      log("❌ Error fetching plans: $error");
     
    } finally {
      plansLoading.value = false;
    }
  }

  // ==================== GET CURRENT SUBSCRIPTION ====================
  /// Get user's current active subscription
  Future<void> getCurrentSubscription() async {
    try {
      currentSubscriptionLoading.value = true;

      log(
        "📡 Fetching current subscription for user: ${dashboardController.userId.value}",
      );

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/subscriptions/current/${dashboardController.userId}',
        dictParameter: {},
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final subscriptionResponse = CurrentSubscriptionResponse.fromJson(
          response.data,
        );

        if (subscriptionResponse.status == "SUCCESS") {
          currentSubscriptions.value = subscriptionResponse.payload ?? [];

          if (currentSubscriptions.isNotEmpty) {
            currentSubscriptionplanCode.value =
                currentSubscriptions.first.planCode ?? '';
            log("✅ Current subscription: ${currentSubscriptionplanCode.value}");
          }
        } else {
          throw Exception(subscriptionResponse.message);
        }
      } else {
        throw Exception('Failed to fetch current subscription');
      }
    } catch (error) {
      log("❌ Error fetching current subscription: $error");
    } finally {
      currentSubscriptionLoading.value = false;
    }
  }

  // ==================== GET SUBSCRIPTION HISTORY ====================
  /// Get user's subscription history with pagination
  Future<void> getSubscriptionHistory({
    required String userId,
    int page = 0,
    int size = 10,
    bool loadMore = false,
  }) async {
    try {
      historyLoading.value = true;

      log("📜 Fetching subscription history - Page: $page");

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/subscriptions/history/$userId',
        dictParameter: {'page': page, 'size': size},
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final historyResponse = SubscriptionHistoryResponse.fromJson(
          response.data,
        );

        if (historyResponse.status == "SUCCESS" &&
            historyResponse.payload != null) {
          final payload = historyResponse.payload!;

          if (loadMore) {
            historyList.addAll(payload.content?.cast<UserSubscription>() ?? []);
          } else {
            historyList.value = payload.content?.cast<UserSubscription>() ?? [];
          }

          currentPage.value = payload.number ?? 0;
          totalPages.value = payload.totalPages ?? 0;
          hasMoreHistory.value = !(payload.last ?? true);

          log("✅ History loaded: ${historyList.length} items");
        } else {
          throw Exception(historyResponse.message);
        }
      } else {
        throw Exception('Failed to fetch history');
      }
    } catch (error) {
      log("❌ Error fetching history: $error");
    } finally {
      historyLoading.value = false;
    }
  }

  // ==================== LOAD MORE HISTORY ====================
  /// Load more subscription history (pagination)
  Future<void> loadMoreHistory(String userId, {int size = 10}) async {
    if (!hasMoreHistory.value || historyLoading.value) return;
    await getSubscriptionHistory(
      userId: userId,
      page: currentPage.value + 1,
      size: size,
      loadMore: true,
    );
  }

  // ==================== START TRIAL ====================
  /// Start trial for a plan
  Future<bool> startTrial(int userId) async {
    try {
      startTrialLoading.value = true;

      log("⏱️ Starting trial for user: $userId");

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/api/subscriptions/start-trial/$userId',
        dictParameter: {},
        authToken: true,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Trial started successfully");

        Get.snackbar(
          'Success',
          'Trial started successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh current subscription
        await getCurrentSubscription();
        return true;
      } else {
        throw Exception('Failed to start trial');
      }
    } catch (error) {
      log("❌ Error starting trial: $error");

      Get.snackbar(
        'Error',
        'Failed to start trial',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      startTrialLoading.value = false;
    }
  }

  // ==================== GET UPGRADE PRICE ====================
  /// Calculate upgrade price when changing plans (OLD METHOD - kept for backward compatibility)
  Future<void> getUpgradePrice({
    required String planCode,
    required String period,
  }) async {
    try {
      upgradePriceLoading.value = true;
      upgradePrice.value = null; // Clear previous value

      log("🔄 Calculating upgrade price");
      log(
        "   User: ${dashboardController.userId} | Plan: $planCode | Period: $period",
      );

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/subscriptions/upgrade-price/${dashboardController.userId}',
        dictParameter: {'planCode': planCode, 'period': period},
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final upgradePriceResponse = UpgradePriceResponse.fromJson(
          response.data,
        );

        if (upgradePriceResponse.status == "SUCCESS") {
          final payload = upgradePriceResponse.payload;
          upgradePrice.value = payload;

          log("✅ Upgrade price calculated");
          log(
            "   Current Plan: ${payload?.currentPlanCode} - ₹${payload?.currentPlanPrice}",
          );
          log(
            "   New Plan: ${payload?.newPlanCode} - ₹${payload?.newPlanPrice}",
          );
          log("   Upgrade Price: ₹${payload?.upgradePrice}");
          log("   Message: ${payload?.message}");

          // Show warnings or messages
          if (payload != null) {
            if (payload.upgradePrice == 0 ||
                payload.upgradePrice == null ||
                payload.upgradePrice! <= 0) {
              log("💚 Free upgrade! Upgrade price is 0");
            } else if (payload.isSamePlan ?? false) {
              log("⚠️ Same plan selected");
            } else if (payload.isDowngrade ?? false) {
              log("📉 Downgrading plan");
            } else {
              log("📈 Upgrading plan");
            }
          }
        } else {
          log("❌ Error: ${upgradePriceResponse.message}");
          throw Exception(upgradePriceResponse.message);
        }
      } else {
        log("❌ HTTP Error: ${response?.statusCode}");
        throw Exception('Failed to calculate upgrade price');
      }
    } catch (error) {
      log("❌ Error calculating upgrade price: $error");
      upgradePrice.value = null;
    } finally {
      upgradePriceLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Show warning if same plan is selected
  void _showSamePlanWarning() {
    Get.snackbar(
      'Same Plan',
      'You are already on this plan',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show message if credit covers upgrade
  void _showFullyCreditedMessage() {
    Get.snackbar(
      'Great News!',
      'This upgrade is free with your current credit!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Get display price for payment
  double getDisplayPrice({required double basePlanPrice}) {
    final payload = upgradePrice.value;
    if (payload != null && (payload.upgradePrice ?? 0) > 0) {
      return payload.upgradePrice!;
    }
    return basePlanPrice;
  }

  /// Check if downgrade
  bool isDowngrade() {
    return upgradePrice.value?.isDowngrade ?? false;
  }

  /// Check if same plan
  bool isSamePlan() {
    final currentCode = currentSubscriptionplanCode.value.trim();
    return currentCode.isNotEmpty &&
        currentCode == (upgradePrice.value?.currentPlanCode?.trim() ?? '');
  }

  /// Check if fully credited (price is 0)
  bool isFullyCredited() {
    final price = upgradePrice.value?.upgradePrice ?? 0;
    return price <= 0;
  }

  /// Clear upgrade price
  void clearUpgradePrice() {
    upgradePrice.value = null;
    log("🗑️ Upgrade price cleared");
  }
  
  // 🔥 NEW HELPER METHODS for SubscriptionPlanWithUpgrade
  
  /// Get plan with upgrade info by code and period
  SubscriptionPlanWithUpgrade? getPlanWithUpgrade(String planCode, String period) {
    return plansWithUpgrade.firstWhereOrNull(
      (plan) => plan.planCode?.trim() == planCode.trim() && plan.period == period,
    );
  }
  
  /// Check if user can purchase a specific plan
  bool canPurchasePlan(String planCode, String period) {
    final plan = getPlanWithUpgrade(planCode, period);
    return plan?.canPurchase ?? false;
  }
  
  /// Check if plan is same as current
  bool isSamePlanByCode(String planCode, String period) {
    final plan = getPlanWithUpgrade(planCode, period);
    return plan?.isSamePlan ?? false;
  }
  
  /// Check if plan is an upgrade
  bool isUpgradePlan(String planCode, String period) {
    final plan = getPlanWithUpgrade(planCode, period);
    return plan?.isUpgrade ?? false;
  }
}