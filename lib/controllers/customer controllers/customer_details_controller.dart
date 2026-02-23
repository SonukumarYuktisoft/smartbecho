// controllers/customer_details_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/customer%20management/customer_details_model.dart';
import 'package:smartbecho/models/customer%20management/customer_notification_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/launch_phone_dailer_service.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/views/customer/components/customer%20details/add_payment_dailog.dart';

class CustomerDetailsController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isNotifying = false.obs;

  // Customer data
  var customerDetails = Rx<CustomerDetail?>(null);
  var totalPurchases = 0.0.obs;
  var totalDues = 0.0.obs;
  var purchaseCount = 0.obs;
  var duesList = <DueDetail>[].obs;
  var salesList = <Sale>[].obs;

  // UI state
  var selectedTabIndex = 0.obs;
  var expandedSaleId = 0.obs;
  var expandedDueId = 0.obs;

  // Customer ID
  late int customerId;

  @override
  void onInit() {
    super.onInit();
    // Get customer ID from arguments
    customerId = Get.arguments ?? 0;
    if (customerId > 0) {
      fetchCustomerDetails();
    } else {
      hasError.value = true;
      errorMessage.value = 'Invalid customer ID';
    }
  }

  /// Fetch customer details from API
  Future<void> fetchCustomerDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/customers/$customerId',
        authToken: true,
      );
      log(response!.data.toString());

      if (response != null && response.statusCode == 200) {
        final customerResponse = CustomerDetailsResponse.fromJson(
          response.data,
        );
        // Update observable variables
        customerDetails.value = customerResponse.payload.customer;
        totalPurchases.value = customerResponse.payload.totalPurchases;
        totalDues.value = customerResponse.payload.totalDues;
        purchaseCount.value = customerResponse.payload.purchaseCount;
        duesList.assignAll(customerResponse.payload.duesList);
        salesList.assignAll(customerResponse.payload.customer.sales);

        log('Customer details loaded successfully');
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to load customer details. Status: ${response?.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading customer details: $e';
      log('Error loading customer details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh customer details
  Future<void> refreshCustomerDetails() async {
    await fetchCustomerDetails();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// Toggle sale expansion
  void toggleSaleExpansion(int saleId) {
    print('Toggling sale expansion for ID: $saleId');
    print('Current expanded ID: ${expandedSaleId.value}');

    if (expandedSaleId.value == saleId) {
      expandedSaleId.value = 0;
      print('Collapsed sale: $saleId');
    } else {
      expandedSaleId.value = saleId;
      print('Expanded sale: $saleId');
    }
  }

  /// Toggle due expansion with debug logging
  void toggleDueExpansion(int dueId) {
    print('Toggling due expansion for ID: $dueId');
    print('Current expanded ID: ${expandedDueId.value}');

    if (expandedDueId.value == dueId) {
      expandedDueId.value = 0;
      print('Collapsed due: $dueId');
    } else {
      expandedDueId.value = dueId;
      print('Expanded due: $dueId');
    }
  }

  /// Call customer
  void callCustomer() async {
    if (customerDetails.value?.primaryNumber != null) {
      try {
        bool success = await PhoneDialerService.launchPhoneDialer(
          customerDetails.value!.primaryNumber,
        );
        if (!success) {
          ToastHelper.error(message: 'Failed to launch phone dialer');
        }
      } catch (e) {
        ToastHelper.error(message: 'Unable to make call: ${e.toString()}');
      }
    }
  }

  void notifyCustomer() async {
    if (customerDetails.value == null) {
      ToastHelper.error(message: 'Customer details not available');

      return;
    }

    try {
      isNotifying.value = true;

      log("cusomter id $customerId");
      // Make the API call
      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.notifyCustomer,
        showToast: true,
        dictParameter: {
          "customerIds": [customerId],
        },
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final notifyResponse = NotifyCustomerResponse.fromJson(response.data);

        if (notifyResponse.status == 'Success') {
          if (notifyResponse.payload.notified.contains(customerId)) {
            log('Customer notification sent successfully');
          } else if (notifyResponse.payload.notFound.contains(customerId)) {
            log('Customer not found for notification');
          } else {
            log('Notification processed but status unclear');
          }
        } else {
          log('Notification error : ${notifyResponse.message}');
        }
      } else {
        log('Failed to send notification. Status: ${response?.statusCode}');
      }
    } catch (e) {
      log('Failed to send notification: ${e.toString()}');
    } finally {
      isNotifying.value = false;
    }
  }

  /// Process partial payment API call
  var isProcessingPayment = false.obs;
  Future<void> processPartialPayment(
    int dueId,
    double amount,
    String paymentMethod,
    String remarks,
  ) async {
    try {
      isProcessingPayment.value = true;

      log(
        'Processing payment: DueId=$dueId, Amount=$amount, Method=$paymentMethod, Remarks=$remarks',
      );

      // Build the URL with query parameters as shown in the curl example
      String url =
          '${_config.baseUrl}/api/dues/partial-payment?Id=$dueId&amount=${amount.toInt()}&paymentMethod=${paymentMethod.toUpperCase()}&remarks=$remarks';

      dio.Response? response = await _apiService.requestPostForApi(
        url: url,
        dictParameter: {},
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 200) {
        // Parse response if needed
        log('Payment processed successfully: ${response.data}');
        log('Payment of ₹${amount.toStringAsFixed(0)} processed successfully!');

        // Refresh customer details to update the dues list
        await refreshCustomerDetails();
      } else {
        log( 'Payment of ₹${amount.toStringAsFixed(0)} processed successfully!');
       
        throw Exception('Payment failed with status: ${response?.statusCode}');
      }
    } catch (e) {
      log('Error processing payment: $e');
      
      rethrow;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Get due by ID for updating specific due after payment
  DueDetail? getDueById(int dueId) {
    try {
      return duesList.firstWhere((due) => due.id == dueId);
    } catch (e) {
      return null;
    }
  }

  /// View invoice
  void viewInvoice(Sale sale) {
    Get.toNamed(
      AppRoutes.invoiceDetails,
      arguments: {'sale id': sale.id, "customer id": customerId},
    );
  }

  /// View sale details
  void viewSaleDetails(Sale sale) {
    // TODO: Navigate to sale details page
    Get.snackbar(
      'Info',
      'Sale details page will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Add payment to due
  void addPaymentToDue(DueDetail due) {
    showPaymentDialog(due);
  }

  void showPaymentDialog(DueDetail due) {
    if (customerDetails.value == null) {
      Get.snackbar(
        'Error',
        'Customer details not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      PaymentDialog(dueDetail: due, customerName: customerDetails.value!.name),
      barrierDismissible: false,
    );
  }

  /// View due details
  void viewDueDetails(DueDetail due) {
    // TODO: Navigate to due details page
    Get.snackbar(
      'Info',
      'Due details page will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Get payment mode color
  Color getPaymentModeColor(String paymentMode) {
    switch (paymentMode.toUpperCase()) {
      case 'FULL':
        return Color(0xFF51CF66);
      case 'PARTIAL':
        return Color(0xFFFF9500);
      case 'EMI':
        return Color(0xFF6C5CE7);
      default:
        return Colors.grey;
    }
  }

  /// Get payment method color
  Color getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toUpperCase()) {
      case 'CASH':
        return Color(0xFF51CF66);
      case 'CARD':
        return Color(0xFF6C5CE7);
      case 'UPI':
        return Color(0x00CEC9);
      case 'BANK_TRANSFER':
        return Color(0xFFFF9500);
      default:
        return Colors.grey;
    }
  }

  /// Get status color
  Color getStatusColor(bool paid) {
    return paid ? Color(0xFF51CF66) : Color(0xFFFF6B6B);
  }

  /// Get due status color
  Color getDueStatusColor(DueDetail due) {
    if (due.paid) {
      return Color(0xFF51CF66);
    } else if (due.remainingDue > 0) {
      return Color(0xFFFF6B6B);
    }
    return Color(0xFFFF9500);
  }

  /// Format currency
  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  /// Get total items count for a sale
  int getTotalItemsCount(Sale sale) {
    return sale.items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get pending dues count
  int getPendingDuesCount() {
    return duesList.where((due) => !due.paid).length;
  }

  /// Get total pending amount
  double getTotalPendingAmount() {
    return duesList.fold(0.0, (sum, due) => sum + due.remainingDue);
  }

  /// Get customer type based on purchase history
  String getCustomerType() {
    if (totalPurchases.value >= 100000) {
      return 'VIP';
    } else if (purchaseCount.value >= 5) {
      return 'Repeated';
    } else if (purchaseCount.value >= 2) {
      return 'Regular';
    } else {
      return 'New';
    }
  }

  /// Get customer type color
  Color getCustomerTypeColor() {
    String type = getCustomerType();
    switch (type) {
      case 'VIP':
        return Color(0xFFFFD700);
      case 'Repeated':
        return Color(0xFF51CF66);
      case 'Regular':
        return Color(0xFF6C5CE7);
      case 'New':
        return Color(0x00CEC9);
      default:
        return Colors.grey;
    }
  }

  /// Get customer type icon
  IconData getCustomerTypeIcon() {
    String type = getCustomerType();
    switch (type) {
      case 'VIP':
        return Icons.star;
      case 'Repeated':
        return Icons.refresh;
      case 'Regular':
        return Icons.person;
      case 'New':
        return Icons.person_add;
      default:
        return Icons.person_outline;
    }
  }
}
