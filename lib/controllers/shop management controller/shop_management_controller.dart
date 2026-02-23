import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/state_manager.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/my_shops_model.dart';
import 'package:smartbecho/models/shop%20management%20models/create_shop_model.dart';
import 'package:smartbecho/models/shop%20management%20models/switchshop_response_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';

class ShopManagementController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  @override
  void onInit() {
    getMyShops();
    super.onInit();
  }

  // Rx variables for managing UI states and data
  var myShopsLoading = false.obs;
  var myShopsList = <Shop>[].obs;
  var createShopLoading = false.obs;

  var errorMessage = ''.obs;
  // Fetch my shops from API
  Future<void> getMyShops() async {
    try {
      myShopsLoading.value = true;

      log("Fetching MyShops...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getMyShops,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final statsResponse = MyShopsModel.fromJson(response.data);

        if (statsResponse.status == "SUCCESS") {
          myShopsList.value = statsResponse.payload;
          errorMessage.value = statsResponse.message;
          log(
            "✅ MyShops loaded successfully: ${myShopsList.length} shops found",
          );
        } else {
          throw Exception(statsResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error in MyShops: $error");
    } finally {
      myShopsLoading.value = false;
    }
  }

  // Create new shop with image
  Future<void> createShop({
    required CreateShopModel shopData,
    File? shopImage,
  }) async {
    try {
      createShopLoading.value = true;

      log("Creating new shop...");

      // Prepare form data
      dio.FormData formData = dio.FormData();

      // Add shop data as JSON string
      formData.fields.add(MapEntry('request', jsonEncode(shopData.toJson())));

      log("Shop data added to form");

      // Add image file if provided
      if (shopImage != null && await shopImage.exists()) {
        try {
          String extension = shopImage.path.split('.').last.toLowerCase();
          String fileName = 'shop_image.$extension';

          // Determine content type based on extension
          String contentType = 'image/jpeg';
          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          }

          // Add file to form data with field name 'file' (as per your original API structure)
          formData.files.add(
            MapEntry(
              'shopPhoto', // Changed from 'userProfilePhoto' to 'file'
              await dio.MultipartFile.fromFile(
                shopImage.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          log('✅ Image file added: $fileName (${contentType})');
        } catch (fileError) {
          log('❌ Error processing image file: $fileError');
        }
      } else {
        log('ℹ️ No image file provided or file does not exist');
      }

      log("Sending request to: ${_config.createAnotherShop}");
      log("FormData fields: ${formData.fields.length}");
      log("FormData files: ${formData.files.length}");

      dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.createAnotherShop,
        formData: formData,
        authToken: true,
        showToast: true,
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Shop created successfully");


        // Refresh the shops list
        await getMyShops();

        // Navigate back or to shops list
        Get.back();
      } else {
        String errorMessage = 'Failed to create shop';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error creating shop: $error");

      String errorMessage = 'Failed to create shop';

      if (error is dio.DioException) {
        if (error.response?.data != null) {
          if (error.response!.data is Map &&
              error.response!.data.containsKey('message')) {
            errorMessage = error.response!.data['message'];
          } else {
            errorMessage = error.response!.data.toString();
          }
        } else if (error.message != null) {
          errorMessage = error.message!;
        }
      } else {
        errorMessage = error.toString();
      }

    } finally {
      createShopLoading.value = false;
    }
  }

  var updateShopLoading = false.obs;

  // Update shop method
  Future<void> updateShopWithJson({
    required String shopId,
    required CreateShopModel shopData,
    File? shopImage,
  }) async {
    try {
      updateShopLoading.value = true;

      log("Updating shop...");

      // Prepare update data (exclude email, password, phone, adhaarNumber)
      Map<String, dynamic> updateData = {
        'shopStoreName': shopData.shopStoreName,
        'gstNumber': shopData.shopGstNumber,
        'shopAddress': shopData.shopAddress.toJson(),
        'socialMediaLinks':
            shopData.socialMediaLinks.map((e) => e.toJson()).toList(),
      };

      // Prepare form data

      log("Sending update request to: ${_config.updateShop}?shopId=$shopId");

      dio.Response? response = await _apiService.requestPatchForApi(
        url: '${_config.updateShop}?shopId=$shopId',
        dictParameter: updateData,
        authToken: true,
        showToast: true,

      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Shop updated successfully");

       
        // Refresh the shops list
        await getMyShops();

        // Navigate back twice (from edit screen and detail screen)
        Get.back();
        Get.back();
      } else {
        String errorMessage = 'Failed to update shop';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error creating shop: $error");

      String errorMessage = 'Failed to create shop';

      if (error is dio.DioException) {
        if (error.response?.data != null) {
          if (error.response!.data is Map &&
              error.response!.data.containsKey('message')) {
            errorMessage = error.response!.data['message'];
          } else {
            errorMessage = error.response!.data.toString();
          }
        } else if (error.message != null) {
          errorMessage = error.message!;
        }
      } else {
        errorMessage = error.toString();
      }

    
      updateShopLoading.value = false;
    } finally {
      updateShopLoading.value = false;
    }
  }
  // Add this to your ShopManagementController

  // var updateShopLoading = false.obs;

  // Update shop method
  Future<void> updateShop({
    required String shopId,
    required CreateShopModel shopData,
    File? shopImage,
  }) async {
    try {
      updateShopLoading.value = true;

      log("Updating shop...");

      // Prepare update data (exclude email, password, phone, adhaarNumber)
      Map<String, dynamic> updateData = {
        'shopStoreName': shopData.shopStoreName,
        'gstNumber': shopData.shopGstNumber,
        'shopAddress': shopData.shopAddress.toJson(),
        'socialMediaLinks':
            shopData.socialMediaLinks.map((e) => e.toJson()).toList(),
      };

      // Prepare form data
      dio.FormData formData = dio.FormData();
      formData.fields.add(MapEntry('request', jsonEncode(updateData)));

      log("Update data: ${jsonEncode(updateData)}");

      // Add image file if provided
      if (shopImage != null && await shopImage.exists()) {
        try {
          String extension = shopImage.path.split('.').last.toLowerCase();
          String fileName = 'shop_image.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          }

          formData.files.add(
            MapEntry(
              'shopPhoto',
              await dio.MultipartFile.fromFile(
                shopImage.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          log('✅ Image file added: $fileName (${contentType})');
        } catch (fileError) {
          log('❌ Error processing image file: $fileError');
        }
      }

      log("Sending update request to: ${_config.updateShop}?shopId=$shopId");

      dio.Response? response = await _apiService.requestMultipartApi(
        url: '${_config.updateShop}?shopId=$shopId',
        method: 'put',
        formData: formData,
        authToken: true,
        showToast: true,

      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Shop updated successfully");

        // Refresh the shops list
        await getMyShops();
        await Get.find<DashboardController>().loadCurrentShopFromAPI();

        // Navigate back twice (from edit screen and detail screen)
        Get.back();
        Get.back();
      } else {
        String errorMessage = 'Failed to update shop';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error creating shop: $error");

      String errorMessage = 'Failed to create shop';

      if (error is dio.DioException) {
        if (error.response?.data != null) {
          if (error.response!.data is Map &&
              error.response!.data.containsKey('message')) {
            errorMessage = error.response!.data['message'];
          } else {
            errorMessage = error.response!.data.toString();
          }
        } else if (error.message != null) {
          errorMessage = error.message!;
        }
      } else {
        errorMessage = error.toString();
      }

    
      updateShopLoading.value = false;
    } finally {
      updateShopLoading.value = false;
    }
  }

  // Update the toggleShopSelection to store numeric id
  var selectedShopNumericId = Rx<int?>(null);
  var selectedShopStringId = Rx<String?>(null);
  var switchShopLoading = false.obs;

  // Toggle shop selection
  void toggleShopSelection(Shop shop) {
    if (selectedShopNumericId.value == shop.id) {
      // Unselect if already selected
      selectedShopNumericId.value = null;
      selectedShopStringId.value = null;
      log("Shop unselected");
    } else {
      // Select new shop
      selectedShopNumericId.value = shop.id; // Store numeric id
      selectedShopStringId.value = shop.shopId; // Store string id for display
      log("Shop selected - Numeric ID: ${shop.id}, String ID: ${shop.shopId}");
    }
  }

  // Switch shop method with token update
  Future<void> switchShop() async {
    if (selectedShopNumericId.value == null) {
      log("❌ No shop selected");
      return;
    }

    try {
      switchShopLoading.value = true;

      log("Switching to shop ID: ${selectedShopNumericId.value}");

      Map<String, dynamic> requestBody = {
        'shopId': selectedShopNumericId.value,
      };

      log("Request body: ${jsonEncode(requestBody)}");

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.switchShop,
        dictParameter: requestBody,
        authToken: true,
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        // Parse the response
        final switchResponse = SwitchShopResponseModel.fromJson(response.data);

        if (switchResponse.status == "SUCCESS") {
          String userToken = switchResponse.payload.accessToken;
          String refreshToken = switchResponse.payload.refreshToken;
          String shopId = switchResponse.payload.userShop.id.toString();
          String shopStoreName =
              switchResponse.payload.userShop.shop.shopStoreName;

          // Save JWT Token
          await SharedPreferencesHelper.setJwtToken(userToken);

          // 🔥 IMPORTANT: Save Refresh Token to Secure Storage
          await SecureStorageHelper.setRefreshToken(refreshToken);

          await SharedPreferencesHelper.setIsLoggedIn(true);

          await SharedPreferencesHelper.setShopId(
            selectedShopNumericId.value.toString(),
          );
          await SharedPreferencesHelper.setShopStoreName(shopStoreName);

          // Get.find<DashboardController>().fetchAllDashboardData();
          final profileImage =
              switchResponse?.payload.userShop.shop.profilePhotoUrl;

          if (profileImage != null) {
            Get.find<DashboardController>().updateProfilePhoto(
              shopId: selectedShopNumericId.value.toString(),
              url: profileImage,
            );
          }

          Get.off(BottomNavigationScreen());

          log("✅ Shop switched successfully");

          // Update current active shop

          log("✅ New tokens saved");
          log(
            "Access Token: ${switchResponse.payload.accessToken.substring(0, 50)}...",
          );
          log(
            "Active Shop: ${switchResponse.payload.userShop.shop.shopStoreName}",
          );
          log("Is Owner: ${switchResponse.payload.userShop.isOwner}");

          ToastHelper.success(
            message:
                'Switched to ${switchResponse.payload.userShop.shop.shopStoreName}',
          );
          // Get.snackbar(
          //   'Success',
          //   'Switched to ${switchResponse.payload.userShop.shop.shopStoreName}',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.green.withValues(alpha: 0.8),
          //   colorText: Colors.white,
          //   duration: Duration(seconds: 3),
          // );

          // Clear selection after successful switch
          selectedShopNumericId.value = null;
          selectedShopStringId.value = null;

          // Refresh shops list to get updated data
          await getMyShops();
        } else {
          throw Exception(switchResponse.message);
        }
      } else {
        String errorMessage = 'Failed to switch shop';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error switching shop: $error");

      String errorMessage = 'Failed to switch shop';

      if (error is dio.DioException) {
        if (error.response?.data != null) {
          if (error.response!.data is Map &&
              error.response!.data.containsKey('message')) {
            errorMessage = error.response!.data['message'];
          } else {
            errorMessage = error.response!.data.toString();
          }
        } else if (error.message != null) {
          errorMessage = error.message!;
        }
      } else {
        errorMessage = error.toString();
      }

      // Get.snackbar(
      //   'Error',
      //   errorMessage,
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.withValues(alpha: 0.8),
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 3),
      // );
    } finally {
      switchShopLoading.value = false;
    }
  }
}
