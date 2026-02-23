import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class PermissionManagementController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  @override
  void onInit() {
    super.onInit();
    getAllPermissions();
  }

  // Rx variables for managing UI states and data
  var permissionsLoading = false.obs;
  var createRoleLoading = false.obs;
  var permissionSections = <String, List<String>>{}.obs;
  var selectedPermissions = <String>[].obs;
  var selectedTabIndex = 1.obs; // Default to Admin tab

  // Fetch all permissions with sections
  Future<void> getAllPermissions() async {
    try {
      permissionsLoading.value = true;

      log("Fetching all permissions with sections");

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getAllPermissions,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == "SUCCESS") {
          // Parse sections from payload
          Map<String, dynamic> sections = data['payload']['sections'];
          
          permissionSections.clear();
          sections.forEach((sectionName, permissions) {
            permissionSections[sectionName] = List<String>.from(permissions);
          });

          log("✅ Permissions loaded: ${data['payload']['totalSections']} sections, ${data['payload']['totalPermissions']} permissions");
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error fetching permissions: $error");
     
    } finally {
      permissionsLoading.value = false;
    }
  }

  // Toggle permission selection
  void togglePermission(String permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }

  // Toggle all permissions in a section
  void toggleSectionPermissions(String sectionName, bool selectAll) {
    final permissions = permissionSections[sectionName] ?? [];
    
    if (selectAll) {
      for (var permission in permissions) {
        if (!selectedPermissions.contains(permission)) {
          selectedPermissions.add(permission);
        }
      }
    } else {
      selectedPermissions.removeWhere((p) => permissions.contains(p));
    }
  }

  // Check if all permissions in a section are selected
  bool isSectionFullySelected(String sectionName) {
    final permissions = permissionSections[sectionName] ?? [];
    if (permissions.isEmpty) return false;
    
    return permissions.every((p) => selectedPermissions.contains(p));
  }

  // Get selected permissions count for a section
  int getSectionSelectedCount(String sectionName) {
    final permissions = permissionSections[sectionName] ?? [];
    return permissions.where((p) => selectedPermissions.contains(p)).length;
  }

  // Create role with selected permissions
  Future<void> createRole({
    required String roleName,
    required String shopId,
  }) async {
    try {
      if (roleName.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a role name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      if (selectedPermissions.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one permission',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      createRoleLoading.value = true;

      log("Creating role: $roleName with ${selectedPermissions.length} permissions");

      final requestData = {
        "roleName": roleName,
        "shopId": shopId,
        "permissions": selectedPermissions.toList(),
      };

      log("Request data: ${jsonEncode(requestData)}");

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.createRole, // Make sure this endpoint exists in AppConfig
        authToken: true,
        dictParameter: requestData,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Role created successfully");

        Get.snackbar(
          'Success',
          'Role "$roleName" created successfully with ${selectedPermissions.length} permissions!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Clear selections
        selectedPermissions.clear();
        selectedTabIndex.value = 1;

        // Navigate back
        Get.back();
      } else {
        String errorMessage = 'Failed to create role';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error creating role: $error");

      String errorMessage = 'Failed to create role';

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
      createRoleLoading.value = false;
    }
  }

  // Clear all selections
  void clearSelections() {
    selectedPermissions.clear();
    selectedTabIndex.value = 1;
  }
}