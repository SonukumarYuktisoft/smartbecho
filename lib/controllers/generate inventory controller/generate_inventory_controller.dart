import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class GenerateInventoryController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  
  // Loading states
  final RxBool isGenerating = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Generated link
  final RxString generatedLink = ''.obs;
  final RxBool hasGeneratedLink = false.obs;
  
  // API endpoint
  
  @override
  void onInit() {
    super.onInit();
    log("GenerateInventoryController initialized");
  }
  
  /// Generate inventory link by calling the API
  Future<void> generateInventoryLink() async {
    try {
      isGenerating.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      log("Generating inventory link...");
      
      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/generate',
        authToken: true,
      );
      
      if (response != null && response.statusCode == 200) {
        // Assuming the response contains the link as plain text
        String link = response.data.toString().trim();
        
        if (link.isNotEmpty) {
          generatedLink.value = link;
          hasGeneratedLink.value = true;
          
          log("Inventory link generated successfully: $link");
          
          // Show success message
          Get.snackbar(
            'Success',
            'Inventory link generated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha:0.8),
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          throw Exception('Empty link received from server');
        }
      } else {
        throw Exception('Failed to generate link. Status: ${response?.statusCode}');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = error.toString();
      
      log("❌ Error in generateInventoryLink: $error");
      
      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to generate inventory link: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isGenerating.value = false;
    }
  }
  
  /// Share the generated link using share_plus package
  Future<void> shareInventoryLink() async {
    if (!hasGeneratedLink.value || generatedLink.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No link to share. Please generate a link first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha:0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      await Share.share(
        generatedLink.value,
        subject: 'My Inventory Link',
      );
      
      log("Inventory link shared successfully");
    } catch (error) {
      log("❌ Error sharing link: $error");
      
      Get.snackbar(
        'Error',
        'Failed to share link: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.8),
        colorText: Colors.white,
      );
    }
  }
  
  /// Copy link to clipboard
  Future<void> copyLinkToClipboard() async {
    if (!hasGeneratedLink.value || generatedLink.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No link to copy. Please generate a link first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha:0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      await Clipboard.setData(ClipboardData(text: generatedLink.value));
      
      Get.snackbar(
        'Success',
        'Link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha:0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      
      log("Link copied to clipboard successfully");
    } catch (error) {
      log("❌ Error copying link: $error");
      
      Get.snackbar(
        'Error',
        'Failed to copy link: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.8),
        colorText: Colors.white,
      );
    }
  }
  
  /// Reset the generated link
  void resetLink() {
    generatedLink.value = '';
    hasGeneratedLink.value = false;
    hasError.value = false;
    errorMessage.value = '';
  }
  
  /// Refresh and generate new link
  Future<void> refreshLink() async {
    resetLink();
    await generateInventoryLink();
  }
}