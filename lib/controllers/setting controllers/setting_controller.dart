import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/models/settings%20model/user_settings_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import 'package:smartbecho/services/shared_preferences_services.dart';

class ShopSettingsController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final ImagePicker _picker = ImagePicker();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Text controllers
  final TextEditingController lowStockQtyController = TextEditingController();
  final TextEditingController criticalStockQtyController = TextEditingController();
  final TextEditingController upiIdController = TextEditingController();

  // Template selection
  final RxString selectedInvoiceTemplate = 'TEMPLATE_001'.obs;

  // Toggle states
  final RxBool qrCodeScannerEnabled = false.obs;
  final RxBool upiPaymentEnabled = false.obs;
  final RxBool stampEnabled = false.obs;
  final RxBool signatureEnabled = false.obs;

  // Image file paths
  final Rx<File?> stampImageFile = Rx<File?>(null);
  final Rx<File?> signatureImageFile = Rx<File?>(null);
  final Rx<File?> scannerImageFile = Rx<File?>(null);

  // Image URLs from server
  final RxString stampImageUrl = ''.obs;
  final RxString signatureImageUrl = ''.obs;
  final RxString scannerImageUrl = ''.obs;

  // Shop settings model
  Rx<ShopSettingsModel?> shopSettings = Rx<ShopSettingsModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchShopSettings();
  }

  @override
  void onClose() {
    lowStockQtyController.dispose();
    criticalStockQtyController.dispose();
    upiIdController.dispose();
    super.onClose();
  }

  // Fetch shop settings from API
  Future<void> fetchShopSettings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      const url = 'https://backend-production-91e4.up.railway.app/api/shop-settings';

      log("📡 Fetching shop settings...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: url,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final shopSettingsResponse = ShopSettingsResponse.fromJson(response.data);
        
        if (shopSettingsResponse.payload != null) {
          shopSettings.value = shopSettingsResponse.payload;
          
          // Populate form fields
          lowStockQtyController.text = shopSettingsResponse.payload!.lowStockQty?.toString() ?? '10';
          criticalStockQtyController.text = shopSettingsResponse.payload!.criticalStockQty?.toString() ?? '5';
          upiIdController.text = shopSettingsResponse.payload!.upiId ?? '';

          // Set invoice template
          selectedInvoiceTemplate.value = shopSettingsResponse.payload!.invoiceTemplateNo ?? 'TEMPLATE_001';

          // Set toggle states
          qrCodeScannerEnabled.value = shopSettingsResponse.payload!.qrCodeScannerEnabled ?? false;
          upiPaymentEnabled.value = shopSettingsResponse.payload!.upiPaymentEnabled ?? false;
          stampEnabled.value = shopSettingsResponse.payload!.stampEnabled ?? false;
          signatureEnabled.value = shopSettingsResponse.payload!.signatureEnabled ?? false;

          // Set image URLs
          stampImageUrl.value = shopSettingsResponse.payload!.shopStampImageUrl ?? '';
          signatureImageUrl.value = shopSettingsResponse.payload!.shopSignatureImageUrl ?? '';
          scannerImageUrl.value = shopSettingsResponse.payload!.scannerImageUrl ?? '';

          // Save to SharedPreferences
          await _saveToSharedPreferences(shopSettingsResponse.payload!);

          log("✅ Shop settings loaded successfully");
          log("📄 Invoice Template: ${selectedInvoiceTemplate.value}");
        }
      } else {
        throw Exception('Failed to load shop settings');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error in fetchShopSettings: $error");

    } finally {
      isLoading.value = false;
    }
  }

  // Save shop settings to API
  Future<void> saveShopSettings() async {
    try {
      // Validation
      if (lowStockQtyController.text.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter low stock quantity',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      if (criticalStockQtyController.text.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter critical stock quantity',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      if (upiPaymentEnabled.value && upiIdController.text.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter UPI ID when UPI payment is enabled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      isSaving.value = true;
      hasError.value = false;
      errorMessage.value = '';

      const url = 'https://backend-production-91e4.up.railway.app/api/shop-settings';

      log("💾 Saving shop settings...");
      log("📄 Selected Template: ${selectedInvoiceTemplate.value}");

      // Create FormData
      dio.FormData formData = dio.FormData.fromMap({
        'invoiceTemplateNo': selectedInvoiceTemplate.value,
        'lowStockQty': lowStockQtyController.text,
        'criticalStockQty': criticalStockQtyController.text,
        'qrCodeScannerEnabled': qrCodeScannerEnabled.value.toString(),
        'upiPaymentEnabled': upiPaymentEnabled.value.toString(),
        'stampEnabled': stampEnabled.value.toString(),
        'signatureEnabled': signatureEnabled.value.toString(),
        'upiId': upiIdController.text,
      });

      // Add stamp image if selected
      if (stampImageFile.value != null) {
        formData.files.add(MapEntry(
          'stampImage',
          await dio.MultipartFile.fromFile(
            stampImageFile.value!.path,
            filename: 'stamp_${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        ));
      }

      // Add signature image if selected
      if (signatureImageFile.value != null) {
        formData.files.add(MapEntry(
          'signatureImage',
          await dio.MultipartFile.fromFile(
            signatureImageFile.value!.path,
            filename: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        ));
      }

      // Add scanner image if selected
      if (scannerImageFile.value != null) {
        formData.files.add(MapEntry(
          'scannerImage',
          await dio.MultipartFile.fromFile(
            scannerImageFile.value!.path,
            filename: 'scanner_${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        ));
      }

      dio.Response? response = await _apiService.requestPutForApi(
        url: url,
        authToken: true,
        formData: formData,
      );

      if (response != null && response.statusCode == 200) {
        final shopSettingsResponse = ShopSettingsResponse.fromJson(response.data);
        
        if (shopSettingsResponse.payload != null) {
          shopSettings.value = shopSettingsResponse.payload;
          
          // Update template selection
          selectedInvoiceTemplate.value = shopSettingsResponse.payload!.invoiceTemplateNo ?? 'TEMPLATE_001';
          
          // Update image URLs
          stampImageUrl.value = shopSettingsResponse.payload!.shopStampImageUrl ?? '';
          signatureImageUrl.value = shopSettingsResponse.payload!.shopSignatureImageUrl ?? '';
          scannerImageUrl.value = shopSettingsResponse.payload!.scannerImageUrl ?? '';

          // Clear selected files
          stampImageFile.value = null;
          signatureImageFile.value = null;
          scannerImageFile.value = null;

          // Save to SharedPreferences
          await _saveToSharedPreferences(shopSettingsResponse.payload!);

          log("✅ Shop settings saved successfully");

          Get.snackbar(
            'Success',
            'Settings saved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('Failed to save shop settings');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error in saveShopSettings: $error");

      Get.snackbar(
        'Error',
        'Failed to save settings: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Template selection handler
  void onTemplateChanged(String templateNo) {
    selectedInvoiceTemplate.value = templateNo;
    log("📄 Template changed to: $templateNo");
  }

  // Save settings to SharedPreferences
  Future<void> _saveToSharedPreferences(ShopSettingsModel settings) async {
    try {
      await SharedPreferencesHelper.setLowStockQty(settings.lowStockQty ?? 10);
      await SharedPreferencesHelper.setCriticalStockQty(settings.criticalStockQty ?? 5);
      await SharedPreferencesHelper.setQrCodeScannerEnabled(settings.qrCodeScannerEnabled ?? false);
      await SharedPreferencesHelper.setUpiPaymentEnabled(settings.upiPaymentEnabled ?? false);
      await SharedPreferencesHelper.setStampEnabled(settings.stampEnabled ?? false);
      await SharedPreferencesHelper.setSignatureEnabled(settings.signatureEnabled ?? false);
      await SharedPreferencesHelper.setStampImageUrl(settings.shopStampImageUrl ?? '');
      await SharedPreferencesHelper.setSignatureImageUrl(settings.shopSignatureImageUrl ?? '');
      await SharedPreferencesHelper.setScannerImageUrl(settings.scannerImageUrl ?? '');
      await SharedPreferencesHelper.setUpiId(settings.upiId ?? '');
      
      log("💾 Settings saved to SharedPreferences");
    } catch (error) {
      log("❌ Error saving to SharedPreferences: $error");
    }
  }

  // Image picker methods
  Future<void> pickStampImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        stampImageFile.value = File(image.path);
        log("✅ Stamp image selected: ${image.path}");
      }
    } catch (error) {
      log("❌ Error picking stamp image: $error");
      Get.snackbar(
        'Error',
        'Failed to pick image: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickSignatureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        signatureImageFile.value = File(image.path);
        log("✅ Signature image selected: ${image.path}");
      }
    } catch (error) {
      log("❌ Error picking signature image: $error");
      Get.snackbar(
        'Error',
        'Failed to pick image: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickScannerImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        scannerImageFile.value = File(image.path);
        log("✅ Scanner image selected: ${image.path}");
      }
    } catch (error) {
      log("❌ Error picking scanner image: $error");
      Get.snackbar(
        'Error',
        'Failed to pick image: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // Remove image methods
  void removeStampImage() {
    stampImageFile.value = null;
  }

  void removeSignatureImage() {
    signatureImageFile.value = null;
  }

  void removeScannerImage() {
    scannerImageFile.value = null;
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchShopSettings();
  }
}