// Update the PaymentController to avoid setState during build

import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/pdf_downloader_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/utils/common/congratulations_page.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';
import 'package:smartbecho/models/subscription%20models/payment_models/payment_history_model.dart';
import 'package:smartbecho/models/subscription%20models/promo_code_response.dart';
import 'package:smartbecho/models/subscription%20models/razorpay_order_response.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';

class PaymentController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ==================== RX VARIABLES ====================

  // Loading states
  var subscribeLoading = false.obs;
  var promoLoading = false.obs;
  var orderLoading = false.obs;
  var historyLoading = false.obs;

  // Amount calculations
  var baseAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var gstAmount = 0.0.obs;
  var finalAmount = 0.0.obs;

  // Promo code
  var appliedPromoCode = Rxn<PromoCodeResponse>();

  // Payment history
  var paymentHistory = <PaymentHistory>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var hasMorePages = true.obs;

  // Razorpay
  late Razorpay _razorpay;

  // Payment context
  String? _currentPlanCode;
  String? _currentPlanName;
  String? _currentPeriod;
  String? _currentPromoCode;

  // Constants
  static const double GST_PERCENTAGE = 18.0;
  static const String RAZORPAY_KEY = 'rzp_test_Rwei7wqeaO8bWN';

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ==================== RAZORPAY CALLBACKS ====================
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("✅ Payment Success: ${response.paymentId}");
    log("   Order ID: ${response.orderId}");
    log("   Signature: ${response.signature}");

    // Subscribe using stored context
    if (_currentPlanCode != null &&
        _currentPeriod != null &&
        _currentPlanName != null) {
      final success = await subscribeToPlan(
        planCode: _currentPlanCode!,
        period: _currentPeriod!,
        planName: _currentPlanName!,
        amount: finalAmount.value,
        txnId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        promoCode: _currentPromoCode,
      );

      if (success) {
        // 🔥 Delay before refreshing to avoid build phase conflicts
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh payment history
        await getPaymentHistory(page: 0, refresh: true);

        // Refresh subscription data
        final subscriptionController = Get.find<SubscriptionController>();
        await subscriptionController.getCurrentSubscription();
        // subscriptionController.clearUpgradePrice();

        log("✅ Payment and subscription completed successfully");

        // Close payment page
        Get.back();
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log("❌ Payment Error: ${response.message}");

    // 🔥 USE ToastHelper INSTEAD OF Get.snackbar
    ToastHelper.error(
      message: 'Payment Failed',
      description: response.message ?? 'Payment was unsuccessful',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("💳 External Wallet: ${response.walletName}");

    ToastHelper.info(
      message: 'Wallet Selected',
      description: 'Using: ${response.walletName}',
    );
  }

  // ==================== SET PAYMENT CONTEXT ====================
  void setPaymentContext({
    required String planCode,
    required String planName,
    required String period,
    required double amount,
    String? promoCode,
  }) {
    _currentPlanCode = planCode;
    _currentPeriod = period;
    _currentPromoCode = promoCode;
    _currentPlanName = planName;
    discountAmount.value = 0.0;
    calculateAmounts(amount);

    log("💾 Payment Context Set:");
    log("   Plan: $planCode | Period: $period");
    log("   Base Amount: ₹$amount");
  }

  // ==================== CALCULATE AMOUNTS ====================
  void calculateAmounts(double price) {
    baseAmount.value = price;

    double afterDiscount = price - discountAmount.value;

    gstAmount.value = (afterDiscount * GST_PERCENTAGE) / 100;

    finalAmount.value = afterDiscount + gstAmount.value;

    log("💰 Amount Calculation:");
    log("   Base: ₹${baseAmount.value.toStringAsFixed(2)}");
    if (discountAmount.value > 0) {
      log("   Discount: -₹${discountAmount.value.toStringAsFixed(2)}");
    }
    log("   After Discount: ₹${afterDiscount.toStringAsFixed(2)}");
    log("   GST (18%): +₹${gstAmount.value.toStringAsFixed(2)}");
    log("   Final: ₹${finalAmount.value.toStringAsFixed(2)}");
  }

  // ==================== PROMO CODE ====================
  Future<void> validatePromoCode({
    required String code,
    required String planCode,
    required double basePrice,
    bool isUpgrade = false,
  }) async {
    try {
      promoLoading.value = true;

      log("🎟️ Validating promo code: $code");

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/api/promo-codes/validate',
        dictParameter: {},
        queryParameters: {
          'code': code,
          'planCode': planCode,
          'baseAmount': basePrice,
          'isUpgrade': isUpgrade,
        },
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 200) {
        final promoResponse = PromoCodeResponse.fromJson(response.data);

        if (promoResponse.isValid) {
          // 🔥 Use Future.microtask to avoid build phase issues
          Future.microtask(() {
            appliedPromoCode.value = promoResponse;
            discountAmount.value = promoResponse.payload.discountAmount ?? 0.0;
            calculateAmounts(basePrice);

            log("✅ Promo code applied: Discount ₹${discountAmount.value}");
          });
        } else {
          Future.microtask(() {
            appliedPromoCode.value = null;
            discountAmount.value = 0.0;
            calculateAmounts(basePrice);

            log("❌ Invalid promo code");
          });
        }
      }
    } catch (error) {
      log("❌ Error validating promo: $error");
      Future.microtask(() {
        appliedPromoCode.value = null;
        discountAmount.value = 0.0;
      });
    } finally {
      promoLoading.value = false;
    }
  }

  void removePromoCode(double basePrice) {
    // 🔥 Use Future.microtask to defer state updates
    Future.microtask(() {
      appliedPromoCode.value = null;
      discountAmount.value = 0.0;
      _currentPromoCode = null;
      calculateAmounts(basePrice);
      log("🗑️ Promo code removed");
    });
  }

  // ==================== RAZORPAY ORDER ====================
  Future<RazorpayOrderResponse?> createRazorpayOrder({
    required double amount,
  }) async {
    try {
      orderLoading.value = true;

      log("🔐 Creating Razorpay Order: ₹$amount");

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/api/create-order',
        dictParameter: {},
        queryParameters: {'amount': amount.toInt()},
        authToken: true,
        showToast: true,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Razorpay Order Created");

        try {
          final orderData = RazorpayOrderResponse.fromJson(
            response.data is String ? jsonDecode(response.data) : response.data,
          );

          log("   Order ID: ${orderData.id}");
          log("   Amount: ${orderData.amount} paise");

          return orderData;
        } catch (parseError) {
          log("❌ Parse error: $parseError");
          return null;
        }
      } else {
        log("❌ Failed to create order");
        return null;
      }
    } catch (error) {
      log("❌ Error creating order: $error");
      return null;
    } finally {
      orderLoading.value = false;
    }
  }

  // ==================== OPEN CHECKOUT ====================
  Future<void> openRazorpayCheckout({
    required String planName,
    String? promoCode,
  }) async {
    final orderData = await createRazorpayOrder(amount: finalAmount.value);

    if (orderData == null) {
      // 🔥 USE ToastHelper
      ToastHelper.error(
        message: 'Error',
        description: 'Failed to create payment order',
      );
      return;
    }

    var options = {
      'key': RAZORPAY_KEY,
      'amount': orderData.amount,
      'name': 'Smart Becho',
      'order_id': orderData.id,
      'description': '$planName - $_currentPeriod',
      'timeout': 300,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#4C5EEB'},
      'notes': {
        'plan_code': _currentPlanCode,
        'period': _currentPeriod,
        'promo_code': _currentPromoCode ?? '',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log("❌ Error opening checkout: $e");
      ToastHelper.error(
        message: 'Error',
        description: 'Failed to open payment gateway',
      );
    }
  }

  // ==================== SUBSCRIBE ====================
  Future<bool> subscribeToPlan({
    required String planCode,
    required String period,
    required String planName,
    required double amount,
    required String txnId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    String? promoCode,
  }) async {
    try {
      subscribeLoading.value = true;

      log("💳 Subscribing to plan: $planCode");

      dio.Response? response = await _apiService.requestPostForApi(
        url:
            '${_config.baseUrl}/api/subscriptions/subscribe/${dashboardController.userId.value}',
        dictParameter: {},
        queryParameters: {
          'planCode': planCode,
          'period': period,
          'amount': amount,
          'txnId': txnId,
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        },
        authToken: true,
        showToast: true,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Subscription created successfully");
        final subscriptionController = Get.find<SubscriptionController>();
        await subscriptionController.getSubscriptionPlans();
        // 🔥 Use Future.microtask
        Future.microtask(() {
          appliedPromoCode.value = null;
          discountAmount.value = 0.0;
        });
        Get.off(
          CongratulationsPage(
            planName: planName,
            period: period,
            amountPaid: amount,
            gstAmount: 000,
            onDashboardTap: () {
              Get.off(BottomNavigationScreen());
            },
          ),
          fullscreenDialog: true,
        );
        // CongratulationsPage.show(
        //   planName: planName,
        //   period: period,
        //   amountPaid: amount,
        //   gstAmount: 000,
        //   onDashboardTap: () {
        //     Get.off(BottomNavigationScreen());
        //   },
        // );

        return true;
      } else {
        log("❌ Subscription failed");
        return false;
      }
    } catch (error) {
      log("❌ Error subscribing: $error");
      ToastHelper.error(
        message: 'Subscription Error',
        description: error.toString(),
      );
      return false;
    } finally {
      subscribeLoading.value = false;
    }
  }

  // ==================== PAYMENT HISTORY ====================
  /// Get payment history with pagination
  Future<void> getPaymentHistory({
    int page = 0,
    int size = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        paymentHistory.clear();
      }

      historyLoading.value = true;

      log("📜 Fetching payment history: Page $page, Size $size");

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/subscriptions/payments/${dashboardController.userId.value}',
        dictParameter: {'page': page, 'size': size},
        authToken: true,
        showToast: false,
      );

      if (response != null && response.statusCode == 200) {
        final historyResponse = PaymentHistoryResponse.fromJson(response.data);

        // 🔥 Use Future.microtask to avoid build phase conflicts
        Future.microtask(() {
          if (refresh) {
            paymentHistory.value = historyResponse.payload.content;
          } else {
            paymentHistory.addAll(historyResponse.payload.content);
          }

          currentPage.value = historyResponse.payload.number;
          totalPages.value = historyResponse.payload.totalPages;
          hasMorePages.value = !historyResponse.payload.last;

          log("✅ History loaded: ${paymentHistory.length} items");
          log("   Page: ${currentPage.value + 1}/${totalPages.value}");
          log("   Total Elements: ${historyResponse.payload.totalElements}");

          if (paymentHistory.isEmpty) {
            log("ℹ️ No payment history found");
          }
        });
      } else {
        log("❌ Failed to load history - Status: ${response?.statusCode}");
      }
    } catch (error) {
      log("❌ Error loading history: $error");
      ToastHelper.error(
        message: 'Error',
        description: 'Failed to load payment history',
      );
    } finally {
      historyLoading.value = false;
    }
  }

  /// Load more payment history
  Future<void> loadMorePaymentHistory() async {
    if (!hasMorePages.value || historyLoading.value) return;
    await getPaymentHistory(page: currentPage.value + 1);
  }

  void downloadInvoice(PaymentHistory paymentHistory) {
    log(paymentHistory.receiptUrl ?? '');

    // Extract filename from URL or create a custom one
    String fileName = 'receipt_invoice${paymentHistory.id}.pdf';

    // Download the PDF
    PDFDownloadService.downloadPDF(
      url: paymentHistory.receiptUrl ?? '',
      fileName: fileName,
      customPath: 'Invoices',
      openAfterDownload: true,
      onDownloadComplete: () {
        // Optional: Additional actions after download
        print('Invoice ${paymentHistory.receiptUrl} downloaded successfully');
      },
    );
  }
}
