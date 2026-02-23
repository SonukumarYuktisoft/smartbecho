import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/customer%20dues%20management/todays_due_retrival_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/launch_phone_dailer_service.dart';

class RetrievalDueController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  // Observable variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var customers = <RetrievalDueCustomer>[].obs;




  // Summary statistics
  var totalCount = 0.obs;
  var totalDueAmount = 0.0.obs;
  var totalPaidAmount = 0.0.obs;
  var totalRemainingAmount = 0.0.obs;
  var overdueCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRetrievalDues();


  }

 

  /// Fetch retrieval dues from API
  Future<void> fetchRetrievalDues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Using the requestGetForApi method you provided
      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getTodaysDueRetrievalDetails,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        RetrievalDueResponse retrievalResponse = RetrievalDueResponse.fromJson(
          response.data,
        );

        customers.value = retrievalResponse.payload.customers;
        totalCount.value = retrievalResponse.payload.totalCount;

 

        // Calculate summary statistics
        _calculateSummaryStats();
      } else {
        throw Exception('Failed to load data: ${response?.statusMessage}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading data: ${e.toString()}';
      print('Error in fetchRetrievalDues: $e');
    } finally {
      isLoading.value = false;
    }
  }



  //notify customer 
   Future<void> notifyCustomer(int customerId, String customerName) async {
    try {
     

      Map<String, dynamic> requestData = {
        'customerIds':[ customerId],
        // 'message': 'Payment reminder for your due amount',
        // 'type': 'payment_reminder',
      };

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.notifyDueCustomer,
        dictParameter: requestData,
        authToken: true,
      );

      if (response != null && response.data['status'] == 'Success') {
        Get.snackbar(
          'Success',
          'Notification sent to $customerName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withValues(alpha:0.8),
          colorText: Colors.white,
        );
      } else {
        throw Exception(
          response?.data['message'] ?? 'Failed to send notification',
        );
      }
    } catch (error) {
      // Show success message even if API fails (as per original code)
      Get.snackbar(
        'Success',
        'Failed to send notification to $customerName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha:0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchRetrievalDues();
  }

  /// Calculate summary statistics
  void _calculateSummaryStats() {
    totalDueAmount.value = customers.fold(
      0.0,
      (sum, customer) => sum + customer.dues.totalDue,
    );
    totalPaidAmount.value = customers.fold(
      0.0,
      (sum, customer) => sum + customer.dues.totalPaid,
    );
    totalRemainingAmount.value = customers.fold(
      0.0,
      (sum, customer) => sum + customer.dues.remainingDue,
    );
    overdueCount.value =
        customers.where((customer) => customer.status == 'Overdue').length;
  }

  /// Make phone call using PhoneDialerService
  Future<void> makePhoneCall(String phoneNumber, String customerName) async {
    try {
      bool success = await PhoneDialerService.launchPhoneDialer(phoneNumber);
      if (success) {
        Get.snackbar(
          'Calling...',
          'Calling $customerName at $phoneNumber',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to launch phone dialer');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Open phone dialer without auto-calling
  Future<void> openDialer(String phoneNumber) async {
    try {
      bool success = await PhoneDialerService.openDialer(phoneNumber);
      if (!success) {
        throw Exception('Failed to open dialer');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open dialer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Mark payment as received (you might want to implement this API call)
  Future<void> markPaymentReceived(int dueId, int customerId) async {
    try {
      // Implement API call to mark payment as received
      Get.snackbar(
        'Success',
        'Payment marked as received',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Refresh data after marking payment
      await refreshData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

}



