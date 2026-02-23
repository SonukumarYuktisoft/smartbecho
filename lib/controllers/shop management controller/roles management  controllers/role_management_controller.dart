import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/state_manager.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/roles_model.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/shop_roles_model.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/create_role_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class RoleManagementController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  @override
  void onInit() {
    getAllRoles();
    super.onInit();
  }

  // Rx variables for managing UI states and data
  var allRolesLoading = false.obs;
  var allRolesList = <Role>[].obs;
  
  var shopRolesLoading = false.obs;
  var shopRolesList = <ShopRole>[].obs;
  var selectedShopId = Rx<String?>(null);

  var createRoleLoading = false.obs;
  

  // Fetch all global roles from API
  Future<void> getAllRoles() async {
    try {
      allRolesLoading.value = true;

      log("Fetching all roles...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getAllRoles,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final rolesResponse = RolesModel.fromJson(response.data);

        if (rolesResponse.status == "SUCCESS") {
          allRolesList.value = rolesResponse.payload;
          log(
            "✅ All roles loaded successfully: ${allRolesList.length} roles found",
          );
        } else {
          throw Exception(rolesResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error in getAllRoles: $error");
      
    } finally {
      allRolesLoading.value = false;
    }
  }

  // Fetch shop-specific roles from API
  Future<void> getShopRoles({required String shopId}) async {
    try {
      shopRolesLoading.value = true;
      selectedShopId.value = shopId;

      log("Fetching shop roles for shopId: $shopId");

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.getShopRoles}/$shopId',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final shopRolesResponse = ShopRolesModel.fromJson(response.data);

        if (shopRolesResponse.status == "SUCCESS") {
          shopRolesList.value = shopRolesResponse.payload;
          log(
            "✅ Shop roles loaded successfully: ${shopRolesList.length} roles found for shop $shopId",
          );
        } else {
          throw Exception(shopRolesResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      log("❌ Error in getShopRoles: $error");
     
    } finally {
      shopRolesLoading.value = false;
    }
  }

  // Create new role
  Future<void> createRole({
    required CreateRoleModel roleData,
  }) async {
    try {
      createRoleLoading.value = true;

      log("Creating new role...");

      Map<String, dynamic> requestBody = {
        'shopId':roleData.shopId,
        'roleName': roleData.roleName,
        'permissions': roleData.permissions,
      };

      log("Request body: ${jsonEncode(requestBody)}");

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.createRole,
        dictParameter: requestBody,
        authToken: true,
        
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Role created successfully");

        Get.snackbar(
          'Success',
          'Role created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh the roles list
        await getAllRoles();

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
        duration: const Duration(seconds: 4),
      );
    } finally {
      createRoleLoading.value = false;
    }
  }

  // Get role by ID from all roles list
  Role? getRoleById(int roleId) {
    try {
      return allRolesList.firstWhere((role) => role.id == roleId);
    } catch (e) {
      log("❌ Role with ID $roleId not found");
      return null;
    }
  }

  // Get shop role by ID from shop roles list
  ShopRole? getShopRoleById(int roleId) {
    try {
      return shopRolesList.firstWhere((role) => role.id == roleId);
    } catch (e) {
      log("❌ Shop role with ID $roleId not found");
      return null;
    }
  }

  // Check if user has specific permission
  bool hasPermission(int roleId, String permission) {
    try {
      final role = getRoleById(roleId);
      if (role != null && role.permissions != null) {
        return role.permissions!.contains(permission);
      }
      return false;
    } catch (e) {
      log("❌ Error checking permission: $e");
      return false;
    }
  }

  // Get all permissions for a specific role
  List<String> getRolePermissions(int roleId) {
    try {
      final role = getRoleById(roleId);
      return role?.permissions ?? [];
    } catch (e) {
      log("❌ Error getting role permissions: $e");
      return [];
    }
  }

  // Filter roles by name
  List<Role> searchRoles(String query) {
    try {
      if (query.isEmpty) {
        return allRolesList;
      }
      return allRolesList
          .where((role) =>
              role.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      log("❌ Error searching roles: $e");
      return [];
    }
  }

  // Filter shop roles by name
  List<ShopRole> searchShopRoles(String query) {
    try {
      if (query.isEmpty) {
        return shopRolesList;
      }
      return shopRolesList
          .where((role) =>
              role.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      log("❌ Error searching shop roles: $e");
      return [];
    }
  }

  // Clear shop roles selection
  void clearShopRoles() {
    shopRolesList.clear();
    selectedShopId.value = null;
    log("✅ Shop roles cleared");
  }
}