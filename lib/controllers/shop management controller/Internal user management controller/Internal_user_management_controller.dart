import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/create_internal_user_model.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_model.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_detail_model.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/update_internal_user_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class InternalUserManagementController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  @override
  void onInit() {
    super.onInit();
  }

  // Rx variables for managing UI states and data
  var internalUsersLoading = false.obs;
  var internalUsersList = <InternalUser>[].obs;
  var createUserLoading = false.obs;
  var updateUserLoading = false.obs;
  var userDetailLoading = false.obs;
  var userDetail = Rxn<InternalUserDetail>();

  // Fetch internal user by ID
  Future<InternalUserDetail?> getInternalUserById({
    required int userId,
    required String shopId,
  }) async {
    try {
      userDetailLoading.value = true;

      log("Fetching Internal User details for ID: $userId, Shop: $shopId");

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/users/internal-user/$userId?shopId=$shopId',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final userResponse = InternalUserDetailResponse.fromJson(response.data);

        if (userResponse.status == "SUCCESS") {
          userDetail.value = userResponse.payload;
          log("✅ Internal User details loaded successfully");
          return userResponse.payload;
        } else {
          throw Exception(userResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error fetching Internal User details: $error");
    
      return null;
    } finally {
      userDetailLoading.value = false;
    }
  }

  // Fetch internal users for a specific shop
  Future<void> getInternalUsers(shopId) async {
    try {
      internalUsersLoading.value = true;

      log("Fetching Internal Users for shop ID: $shopId");

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.getInternalUsers}/$shopId',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final usersResponse = InternalUsersModel.fromJson(response.data);

        if (usersResponse.status == "SUCCESS") {
          internalUsersList.value = usersResponse.payload;
          log(
            "✅ Internal Users loaded successfully: ${internalUsersList.length} users found",
          );
        } else {
          throw Exception(usersResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error fetching Internal Users: $error");
      
    } finally {
      internalUsersLoading.value = false;
    }
  }

  // Create new internal user with profile photo
  Future<void> createInternalUser({
    required CreateInternalUserModel userData,
    File? profilePhoto,
  }) async {
    try {
      createUserLoading.value = true;

      log("Creating new internal user...");

      // Prepare form data
      dio.FormData formData = dio.FormData();

      // Add user data as JSON string
      formData.fields.add(MapEntry('request', jsonEncode(userData.toJson())));

      log("User data added to form");
      log("User data: ${jsonEncode(userData.toJson())}");

      // Add profile photo if provided
      if (profilePhoto != null && await profilePhoto.exists()) {
        try {
          String extension = profilePhoto.path.split('.').last.toLowerCase();
          String fileName = 'profile_photo.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          }

          formData.files.add(
            MapEntry(
              'profilePhoto',
              await dio.MultipartFile.fromFile(
                profilePhoto.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          log('✅ Profile photo added: $fileName ($contentType)');
        } catch (fileError) {
          log('❌ Error processing profile photo: $fileError');
        }
      } else {
        log('ℹ️ No profile photo provided');
      }

      log("Sending request to: ${_config.createInternalUser}");

      dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.createInternalUser,
        formData: formData,
        authToken: true,
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Internal user created successfully");

        Get.snackbar(
          'Success',
          'Internal user created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Refresh the users list
        await getInternalUsers(userData.shopId);

        // Navigate back
        Get.back();
      } else {
        String errorMessage = 'Failed to create internal user';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error creating internal user: $error");

      String errorMessage = 'Failed to create internal user';

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

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      createUserLoading.value = false;
    }
  }

  // Update internal user with profile photo
  Future<void> updateInternalUser({
    required int userId,
    required String shopId,
    required UpdateInternalUserModel userData,
    File? profilePhoto,
  }) async {
    try {
      updateUserLoading.value = true;

      log("Updating internal user ID: $userId");

      // Prepare form data
      dio.FormData formData = dio.FormData();

      // Add user data as JSON string
      formData.fields.add(MapEntry('request', jsonEncode(userData.toJson())));

      log("Update data: ${jsonEncode(userData.toJson())}");

      // Add profile photo if provided
      if (profilePhoto != null && await profilePhoto.exists()) {
        try {
          String extension = profilePhoto.path.split('.').last.toLowerCase();
          String fileName = 'profile_photo.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          }

          formData.files.add(
            MapEntry(
              'profilePhoto',
              await dio.MultipartFile.fromFile(
                profilePhoto.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          log('✅ Profile photo added: $fileName ($contentType)');
        } catch (fileError) {
          log('❌ Error processing profile photo: $fileError');
        }
      }

      log("Sending update request to: ${_config.updateInternalUser}/$shopId");

      dio.Response? response = await _apiService.requestMultipartApi(
        url: '${_config.baseUrl}/users/internal-user/$userId?shopId=$shopId',

        method: 'put',
        formData: formData,
        authToken: true,
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Internal user updated successfully");

        Get.snackbar(
          'Success',
          'Internal user updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Refresh the users list
        await getInternalUsers(shopId);

        // Navigate back twice (from edit screen and detail screen)
        Get.back();
        Get.back();
      } else {
        String errorMessage = 'Failed to update internal user';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error updating internal user: $error");

      String errorMessage = 'Failed to update internal user';

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

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      updateUserLoading.value = false;
    }
  }
}
