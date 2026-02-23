import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class AddDuesController extends GetxController {
  @override
  void onClose() {
    // Dispose controllers
    totalDueController.dispose();
    totalPaidController.dispose();
    paymentDateController.dispose();
    super.onClose();
  }

  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;

  // ADD DUE FORM
  final GlobalKey<FormState> addDueFormKey = GlobalKey<FormState>();

  // Add Due Form Controllers
  final TextEditingController totalDueController = TextEditingController();
  final TextEditingController totalPaidController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();

  // Add Due Form States
  final RxBool isAddingDue = false.obs;
  final RxBool hasAddDueError = false.obs;
  final RxString addDueErrorMessage = ''.obs;
  final RxString selectedCustomerId = ''.obs;
  final RxString selectedCustomerName = ''.obs;
  final RxDouble remainingDueAmount = 0.0.obs;

  // Customer Data
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCustomers = false.obs;

  // Selected Payment Date
  final Rx<DateTime?> selectedPaymentDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCustomers();

    // Listen to due amount changes to calculate remaining
    totalDueController.addListener(calculateRemainingDue);
    totalPaidController.addListener(calculateRemainingDue);
  }

  /// Load customers from API
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getCustomerDataDropdown,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['payload'] != null && data['payload'] != null) {
          customers.value = List<Map<String, dynamic>>.from(
            data['payload'].map(
              (customer) => {
                'id': customer['id'],
                'name': customer['name'],
                'primaryNumber': customer['primaryNumber'],
                'defaultAddress': customer['defaultAddress'],
                'profilePhoto': customer['profilePhoto'],
              },
            ),
          );
        }

        log("✅ Customers loaded successfully: ${customers.length}");
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (error) {
      log("❌ Error loading customers: $error");
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  /// Handle customer selection for due entry
  void onCustomerSelected(String customerId, String customerName) {
    selectedCustomerId.value = customerId;
    selectedCustomerName.value = customerName;
    calculateRemainingDue();
  }

  /// Calculate remaining due amount
  void calculateRemainingDue() {
    double totalDue = double.tryParse(totalDueController.text) ?? 0.0;
    double totalPaid = double.tryParse(totalPaidController.text) ?? 0.0;
    remainingDueAmount.value = totalDue - totalPaid;
  }

  /// Handle payment date selection
  Future<void> selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPaymentDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedPaymentDate.value = picked;
      paymentDateController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  /// Validate form fields
  String? validateCustomer(String? value) {
    return selectedCustomerId.value.isEmpty ? 'Please select a customer' : null;
  }

  String? validateTotalDue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter total due amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter valid amount';
    }
    return null;
  }

  String? validateTotalPaid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter total paid amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter valid amount';
    }
    double totalDue = double.tryParse(totalDueController.text) ?? 0.0;
    double totalPaid = double.tryParse(value) ?? 0.0;
    if (totalPaid > totalDue) {
      return 'Paid amount cannot exceed due amount';
    }
    return null;
  }

  String? validatePaymentDate(String? value) {
    return selectedPaymentDate.value == null
        ? 'Please select payment date'
        : null;
  }

  /// Add due entry to database
  Future<void> addDueEntry() async {
    if (!addDueFormKey.currentState!.validate()) {
      return;
    }

    try {
      isAddingDue.value = true;
      hasAddDueError.value = false;
      addDueErrorMessage.value = '';

      // Prepare request data
      Map<String, dynamic> requestData = {
        'customerId': int.parse(selectedCustomerId.value),
        'totalDue': double.parse(totalDueController.text),
        'totalPaid': double.parse(totalPaidController.text),
        'paymentRetrievableDate': [
          selectedPaymentDate.value!.year,
          selectedPaymentDate.value!.month,
          selectedPaymentDate.value!.day,
        ],
      };

      // Make API call
      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.addCustomerDue,
        dictParameter: requestData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        log('Due entry created successfully!');

        resetAddDueForm();
        refreshDues();
      } else {
        String errorMessage = 'Failed to create due entry';
        if (response?.data != null) {
          errorMessage = response?.data['message'] ?? errorMessage;
        }
        log('Failed to create due entry: errorMessage');
        throw Exception(errorMessage);
      }
    } catch (error) {
      hasAddDueError.value = true;
      addDueErrorMessage.value = 'Error creating due entry: $error';
      log("❌ Error in addDueEntry: $error");
    } finally {
      isAddingDue.value = false;
    }
  }
   Future<void> refreshDues() async {
    if (Get.isRegistered<CustomerDuesController>()) {
      await Get.find<CustomerDuesController>().refreshData();
    }
  }

  /// Reset add due form
  void resetAddDueForm() {
    addDueFormKey.currentState?.reset();
    totalDueController.clear();
    totalPaidController.clear();
    paymentDateController.clear();
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    selectedPaymentDate.value = null;
    remainingDueAmount.value = 0.0;
    hasAddDueError.value = false;
    addDueErrorMessage.value = '';
  }

  /// Cancel add due
  void cancelAddDue() {
    resetAddDueForm();
    Get.back();
  }
}
