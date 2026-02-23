import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/settings%20model/user_settings_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class InvoiceSettingsController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;


  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Shop settings
  Rx<ShopSettingsModel?> shopSettings = Rx<ShopSettingsModel?>(null);

  // Individual observables for easy access
  final RxBool upiPaymentEnabled = false.obs;
  final RxBool stampEnabled = false.obs;
  final RxBool signatureEnabled = false.obs;
  final RxBool qrCodeScannerEnabled = false.obs;

  final RxString upiId = ''.obs;
  final RxString stampImageUrl = ''.obs;
  final RxString signatureImageUrl = ''.obs;
  final RxString scannerImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoiceSettings();
  }

  // Fetch shop settings for invoice
  Future<void> fetchInvoiceSettings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final url = '${_config.baseUrl}/api/shop-settings';

      log("📡 Fetching invoice settings...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: url,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final shopSettingsResponse = ShopSettingsResponse.fromJson(response.data);
        
        if (shopSettingsResponse.payload != null) {
          shopSettings.value = shopSettingsResponse.payload;
          
          // Update observables
          upiPaymentEnabled.value = shopSettingsResponse.payload!.upiPaymentEnabled ?? false;
          stampEnabled.value = shopSettingsResponse.payload!.stampEnabled ?? false;
          signatureEnabled.value = shopSettingsResponse.payload!.signatureEnabled ?? false;
          qrCodeScannerEnabled.value = shopSettingsResponse.payload!.qrCodeScannerEnabled ?? false;

          upiId.value = shopSettingsResponse.payload!.upiId ?? '';
          stampImageUrl.value = shopSettingsResponse.payload!.shopStampImageUrl ?? '';
          signatureImageUrl.value = shopSettingsResponse.payload!.shopSignatureImageUrl ?? '';
          scannerImageUrl.value = shopSettingsResponse.payload!.scannerImageUrl ?? '';

          log("✅ Invoice settings loaded successfully");
          log("UPI Enabled: ${upiPaymentEnabled.value}");
          log("Stamp Enabled: ${stampEnabled.value}");
          log("Signature Enabled: ${signatureEnabled.value}");
          log("QR Scanner Enabled: ${qrCodeScannerEnabled.value}");
        }
      } else {
        throw Exception('Failed to load invoice settings');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error in fetchInvoiceSettings: $error");
    } finally {
      isLoading.value = false;
    }
  }

  // Load settings from SharedPreferences (faster, offline access)
  Future<void> loadSettingsFromCache() async {
    try {
      upiPaymentEnabled.value = await SharedPreferencesHelper.getUpiPaymentEnabled();
      stampEnabled.value = await SharedPreferencesHelper.getStampEnabled();
      signatureEnabled.value = await SharedPreferencesHelper.getSignatureEnabled();
      qrCodeScannerEnabled.value = await SharedPreferencesHelper.getQrCodeScannerEnabled();

      upiId.value = await SharedPreferencesHelper.getUpiId() ?? '';
      stampImageUrl.value = await SharedPreferencesHelper.getStampImageUrl() ?? '';
      signatureImageUrl.value = await SharedPreferencesHelper.getSignatureImageUrl() ?? '';
      scannerImageUrl.value = await SharedPreferencesHelper.getScannerImageUrl() ?? '';

      log("✅ Invoice settings loaded from cache");
    } catch (error) {
      log("❌ Error loading settings from cache: $error");
    }
  }

  // Refresh settings
  Future<void> refreshSettings() async {
    await fetchInvoiceSettings();
  }

  // Check if any payment feature is enabled
  bool get hasPaymentInfo => upiPaymentEnabled.value && upiId.value.isNotEmpty;
  
  // Check if any image feature is enabled
  bool get hasStamp => stampEnabled.value && stampImageUrl.value.isNotEmpty;
  bool get hasSignature => signatureEnabled.value && signatureImageUrl.value.isNotEmpty;
  bool get hasQRScanner => qrCodeScannerEnabled.value && scannerImageUrl.value.isNotEmpty;
}