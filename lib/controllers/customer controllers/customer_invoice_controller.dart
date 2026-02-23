// controllers/invoice_details_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/customer%20management/customer_notification_model.dart';
import 'package:smartbecho/models/customer%20management/invoice_details_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class InvoiceDetailsController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isNotifying = false.obs; // New loading state for notification

  // Invoice data
  var invoiceDetails = Rx<InvoiceDetailsModel?>(null);

  // UI state
  var selectedTabIndex = 0.obs;
  var isPaymentHistoryExpanded = false.obs;

  // Invoice ID
  late int invoiceId;

  @override
  void onInit() {
    super.onInit();
    // Get invoice ID from arguments
    invoiceId = Get.arguments["sale id"] ?? 0;
    if (invoiceId > 0) {
      fetchInvoiceDetails();
    } else {
      hasError.value = true;
      errorMessage.value = 'Invalid invoice ID';
    }
  }

  /// Fetch invoice details from API
  Future<void> fetchInvoiceDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.getInvoiceDetails}$invoiceId",
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final invoiceData = InvoiceDetailsModel.fromJson(response.data);
        invoiceDetails.value = invoiceData;
        log('Invoice details loaded successfully');
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to load invoice details. Status: ${response?.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading invoice details: $e';
      log('Error loading invoice details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh invoice details
  Future<void> refreshInvoiceDetails() async {
    await fetchInvoiceDetails();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// Toggle payment history expansion
  void togglePaymentHistoryExpansion() {
    isPaymentHistoryExpanded.value = !isPaymentHistoryExpanded.value;
  }

  /// Download invoice
  void downloadInvoice() {
    Get.snackbar(
      'Info',
      'Invoice download functionality will be implemented',
      backgroundColor: Color(0xFF6C5CE7),
      colorText: Colors.white,
    );
  }

  /// Notify customer - Updated with API integration
  int cusomterId = Get.arguments["customer id"];
  Future<void> notifyCustomer() async {
    try {
      isNotifying.value = true;
      log("customer id $cusomterId");
      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.notifyCustomer,
        authToken: true,
        dictParameter: {
          "customerIds": [cusomterId],
        },
      );

      if (response != null && response.statusCode == 200) {
        final notifyResponse = NotifyCustomerResponse.fromJson(response.data);

        if (notifyResponse.isSuccess) {
          if (notifyResponse.status == "Success") {
            log('Customer notification sent successfully');
          }
        } else {
          log(
            notifyResponse.message.isNotEmpty
                ? notifyResponse.message
                : 'Failed to notify customer',
          );
        }
      } else {
        log('Failed to send notification. Please try again.');
      }
    } catch (e) {
      log('Error notifying customer: $e');
    } finally {
      isNotifying.value = false;
    }
  }

  /// Add payment
  void addPayment() {
    Get.snackbar(
      'Info',
      'Add payment functionality will be implemented',
      backgroundColor: Color(0xFF6C5CE7),
      colorText: Colors.white,
    );
  }

  /// Get payment status color
  Color getPaymentStatusColor() {
    if (invoiceDetails.value == null) return Colors.grey;

    switch (invoiceDetails.value!.paymentStatus) {
      case 'Paid':
        return Color(0xFF51CF66);
      case 'Partial':
        return Color(0xFFFF9500);
      case 'Unpaid':
        return Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }

  /// Get payment status icon
  IconData getPaymentStatusIcon() {
    if (invoiceDetails.value == null) return Icons.help_outline;

    switch (invoiceDetails.value!.paymentStatus) {
      case 'Paid':
        return Icons.check_circle;
      case 'Partial':
        return Icons.schedule;
      case 'Unpaid':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  /// Format currency
  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  /// Format date
  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get specification color based on brand
  Color getSpecificationColor(String model) {
    if (model.toLowerCase().contains('galaxy') ||
        model.toLowerCase().contains('samsung')) {
      return Color(0xFF6C5CE7);
    } else if (model.toLowerCase().contains('redmi') ||
        model.toLowerCase().contains('xiaomi')) {
      return Color(0xFFFF9500);
    } else if (model.toLowerCase().contains('iphone') ||
        model.toLowerCase().contains('apple')) {
      return Color(0xFF000000);
    } else if (model.toLowerCase().contains('oneplus')) {
      return Color(0xFFFF6B6B);
    } else if (model.toLowerCase().contains('vivo')) {
      return Color(0xFF6C5CE7);
    } else if (model.toLowerCase().contains('oppo')) {
      return Color(0xFF51CF66);
    } else if (model.toLowerCase().contains('realme')) {
      return Color(0xFFFFD700);
    }
    return Color(0xFF6C5CE7);
  }

  /// Get accessory icon
  IconData getAccessoryIcon(bool accessoryIncluded) {
    return accessoryIncluded ? Icons.check_circle : Icons.cancel;
  }

  /// Get accessory color
  Color getAccessoryColor(bool accessoryIncluded) {
    return accessoryIncluded ? Color(0xFF51CF66) : Color(0xFFFF6B6B);
  }

  /// Calculate total amount
  double calculateTotalAmount() {
    if (invoiceDetails.value == null) return 0.0;
    return invoiceDetails.value!.totalAmount;
  }

  /// Calculate total quantity
  int calculateTotalQuantity() {
    if (invoiceDetails.value == null) return 0;
    return invoiceDetails.value!.totalQuantity;
  }

  /// Get payment progress percentage
  double getPaymentProgress() {
    if (invoiceDetails.value?.dues == null) return 0.0;
    return invoiceDetails.value!.dues!.paymentProgress;
  }

  /// Get payment progress percentage string
  String getPaymentProgressPercentage() {
    double progress = getPaymentProgress();
    return "${(progress * 100).toStringAsFixed(1)}%";
  }

  /// Get valid payment history
  List<PartialPayment> getValidPaymentHistory() {
    if (invoiceDetails.value?.dues == null) return [];
    return invoiceDetails.value!.dues!.validPayments;
  }

  /// Get payment method display name
  String getPaymentMethodDisplayName(dynamic paymentMethod) {
    if (paymentMethod == null) return 'Cash';
    return paymentMethod.toString().toUpperCase();
  }

  /// Get payment method color
  Color getPaymentMethodColor(dynamic paymentMethod) {
    String method = getPaymentMethodDisplayName(paymentMethod);
    switch (method) {
      case 'CASH':
        return Color(0xFF51CF66);
      case 'CARD':
        return Color(0xFF6C5CE7);
      case 'UPI':
        return Color(0xFF00CEC9);
      case 'BANK_TRANSFER':
        return Color(0xFFFF9500);
      default:
        return Color(0xFF51CF66);
    }
  }

  bool hasPaymentHistory() {
    return getValidPaymentHistory().isNotEmpty;
  }

  /// Get remaining due amount
  double getRemainingDueAmount() {
    if (invoiceDetails.value?.dues == null) return 0.0;
    return invoiceDetails.value!.dues!.remainingDue;
  }

  /// Get total paid amount
  double getTotalPaidAmount() {
    if (invoiceDetails.value?.dues == null) return 0.0;
    return invoiceDetails.value!.dues!.totalPaid;
  }

  /// Get total due amount
  double getTotalDueAmount() {
    if (invoiceDetails.value?.dues == null) return 0.0;
    return invoiceDetails.value!.dues!.totalDue;
  }

  /// Check if invoice is fully paid
  bool isFullyPaid() {
    if (invoiceDetails.value?.dues == null) return false;
    return invoiceDetails.value!.dues!.paid;
  }

  /// Check if invoice has partial payment
  bool hasPartialPayment() {
    return invoiceDetails.value?.paymentStatus == 'Partial';
  }

  /// Check if invoice is unpaid
  bool isUnpaid() {
    return invoiceDetails.value?.paymentStatus == 'Unpaid';
  }
}
