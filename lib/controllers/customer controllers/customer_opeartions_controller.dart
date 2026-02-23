import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class CustomerOperationsController extends GetxController {
  @override
  void onClose() {
    // Dispose controllers
    customerNameController.dispose();
    primaryPhoneController.dispose();
    emailController.dispose();
    locationController.dispose();
    primaryAddressController.dispose();
    super.onClose();
  }

  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;

  // ADD CUSTOMER FORM
  final GlobalKey<FormState> addCustomerFormKey = GlobalKey<FormState>();

  // Add Customer Form Controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController primaryPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController primaryAddressController =
      TextEditingController();

  // Add Customer Form States
  final RxBool isAddingCustomer = false.obs;
  final RxBool hasAddCustomerError = false.obs;
  final RxString addCustomerErrorMessage = ''.obs;
  final Rx<File?> selectedCustomerImage = Rx<File?>(null);
  final RxString selectedStates = ''.obs;
  final RxList<String> statesList =
      <String>[
        'Andhra Pradesh',
        'Arunachal Pradesh',
        'Assam',
        'Bihar',
        'Chhattisgarh',
        'Goa',
        'Gujarat',
        'Haryana',
        'Himachal Pradesh',
        'Jharkhand',
        'Karnataka',
        'Kerala',
        'Madhya Pradesh',
        'Maharashtra',
        'Manipur',
        'Meghalaya',
        'Mizoram',
        'Nagaland',
        'Odisha',
        'Punjab',
        'Rajasthan',
        'Sikkim',
        'Tamil Nadu',
        'Telangana',
        'Tripura',
        'Uttar Pradesh',
        'Uttarakhand',
        'West Bengal',
      ].obs;

  /// Handle state selection
  void onSelectState(String state) {
    selectedStates.value = state;
  }

  /// Handle customer image selection
  void onCustomerImageSelected(File? image) {
    selectedCustomerImage.value = image;
  }

  /// Validate form fields
  String? validateCustomerName(String? value) {
    return value == null || value.isEmpty ? 'Please enter customer name' : null;
  }

  String? validatePrimaryPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter primary phone number';
    }
    if (value.length < 10) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'Please enter valid email';
      }
    }
    return null;
  }

  String? validateLocation(String? value) {
    return value == null || value.isEmpty ? 'Please enter location' : null;
  }

  String? validatePrimaryAddress(String? value) {
    return value == null || value.isEmpty
        ? 'Please enter primary address'
        : null;
  }

  /// Add customer to database
  Future<void> addCustomer() async {
    if (!addCustomerFormKey.currentState!.validate()) {
      return;
    }

    try {
      isAddingCustomer.value = true;
      hasAddCustomerError.value = false;
      addCustomerErrorMessage.value = '';

      // Create FormData for multipart request
      dio.FormData formData = dio.FormData.fromMap({
        'name': customerNameController.text,
        'primaryPhone': primaryPhoneController.text,
        'email': emailController.text,
        'location': locationController.text,
        'primaryAddress': primaryAddressController.text,
        'shopId': 'SHOP001', // You might want to make this dynamic
        'state': selectedStates.value,
      });

      // Add file if selected
      if (selectedCustomerImage.value != null) {
        String fileName =
            "${customerNameController.text}_${DateTime.now().millisecondsSinceEpoch}.${selectedCustomerImage.value!.path.split('.').last}";
        formData.files.add(
          MapEntry(
            'file',
            await dio.MultipartFile.fromFile(
              selectedCustomerImage.value!.path,
              filename: fileName,
            ),
          ),
        );
      }

      // Make API call
      dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.addNewCustomer,
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        log('Customer added successfully!');

        resetAddCustomerForm();
      } else {
        String errorMessage = 'Failed to add customer';
        if (response?.data != null) {
          errorMessage = response?.data['message'] ?? errorMessage;
        }
        log('Failed to add customer :$errorMessage');

        throw Exception(errorMessage);
      }
    } catch (error) {
      hasAddCustomerError.value = true;
      addCustomerErrorMessage.value = 'Error adding customer: $error';
      log("❌ Error in addCustomer: $error");
    } finally {
      isAddingCustomer.value = false;
    }
  }

  /// Reset add customer form
  void resetAddCustomerForm() {
    addCustomerFormKey.currentState?.reset();
    customerNameController.clear();
    primaryPhoneController.clear();
    emailController.clear();
    locationController.clear();
    primaryAddressController.clear();
    selectedCustomerImage.value = null;
    hasAddCustomerError.value = false;
    addCustomerErrorMessage.value = '';
  }

  /// Cancel add customer
  void cancelAddCustomer() {
    resetAddCustomerForm();
    Get.back();
  }
}
