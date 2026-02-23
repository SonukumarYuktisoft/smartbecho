import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/models/hsncode_models/hsn_code_model.dart';
import 'package:smartbecho/views/hsn-code/hsn_code_screen.dart';

class HsnCodeController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isTableView = true.obs;
  RxList<HsnCodeModel> hsnCodes = <HsnCodeModel>[].obs;
  RxList<String> itemCategories = <String>[].obs;
  RxString searchQuery = ''.obs;
  RxInt currentPage = 0.obs;
  RxInt totalPages = 1.obs;
  RxInt totalElements = 0.obs;
  RxString errorMessage = ''.obs;
  RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHsnCodes();
    fetchItemCategories();
  }

  String get itemTypesUrl =>
      '${_config.baseUrl}/inventory/item-types';
  String get hsnCodeUrl =>
      '${_config.baseUrl}/api/hsn-codes?';
  String get hsnCodeByIdUrl =>
      '${_config.baseUrl}/api/hsn-codes';
  String get addHsnCodeAddUrl =>
      '${_config.baseUrl}/api/hsn-codes';
  String get hsnCodeUpdateUrl =>
      '${_config.baseUrl}/api/hsn-codes/';
  String get hsnCodeDeleteUrl =>
      '${_config.baseUrl}/api/hsn-codes/';

  Future<void> fetchItemCategories() async {
    try {
      isLoading.value = true;
      dio.Response? response = await _apiService.requestGetForApi(
        authToken: true,
        url: itemTypesUrl,
        dictParameter: {},
      );

      if (response != null && response.statusCode == 200) {
        List<dynamic> data = response.data;
        itemCategories.value = data.cast<String>();
      }
    } catch (e) {
      print('Error fetching item categories: $e');
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> fetchHsnCodes({int page = 0, String? search, bool append = false}) async {
    try {

      // If not appending (fresh load), show main loading indicator
      if (!append) {
        isLoading.value = true;
        currentPage.value = 0;
        hasMoreData.value = true;
      }

      Map<String, dynamic> params = {
        'page': page,
        'size': 20,
        'sortBy': 'id',
        'sortDir': 'asc',
      };

      if (search != null && search.isNotEmpty) {
        params['searchTerm'] = searchQuery;
      }

      dio.Response? response = await _apiService.requestGetForApi(
        authToken: true,
        url: hsnCodeUrl,
        dictParameter: params,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        if (data['status'] == 'Success') {
          Map<String, dynamic> payload = data['payload'];
          List<dynamic> content = payload['content'];

          List<HsnCodeModel> newCodes =
              content.map((e) => HsnCodeModel.fromJson(e)).toList();

          if (append) {
            // Append to existing list
            // hsnCodes.addAll(newCodes);
            // ignore: invalid_use_of_protected_member
            hsnCodes.addAll(newCodes);

            print('Append mode : $hsnCodes');
          } else {
            // Replace list
            hsnCodes.value = newCodes;
          }

          currentPage.value = payload['number'];
          totalPages.value = payload['totalPages'];
          totalElements.value = payload['totalElements'];

          // Check if there's more data to load
          hasMoreData.value = currentPage.value < totalPages.value - 1;
        }
      }
    } catch (e) {
      print('Error fetching HSN codes: $e');
      Get.snackbar('Error', 'Failed to load HSN codes');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more data for lazy loading
  Future<void> loadMoreHsnCodes() async {
    // Don't load if already loading or no more data
    if (isLoadingMore.value || !hasMoreData.value || isLoading.value) {
      return;
    }

    isLoadingMore.value = true;
    int nextPage = currentPage.value + 1;
    
    await fetchHsnCodes(
      page: nextPage,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      append: true,
    );
  }

  // Refresh data (pull to refresh or manual refresh)
  Future<void> refreshHsnCodes() async {
    currentPage.value = 0;
    hasMoreData.value = true;
    await fetchHsnCodes(
      page: 0,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      append: false,
    );
  }

  Future<void> addHsnCode(Map<String, dynamic> hsnCodeData) async {
    try {
      isLoading.value = true;
      dio.Response? response = await _apiService.requestPostForApi(
        authToken: true,
        url: addHsnCodeAddUrl,
        dictParameter: hsnCodeData,
      );

      if (response != null && response.statusCode == 201) {
        snackBar(
          title: 'Success',
          message: 'HSN Code added successfully',
          color: AppColors.successDark,
          messageColor: Colors.white,
          icon: Icons.check_circle,
        );
        refreshHsnCodes();
        Get.offAll(() => HsnCodeScreen());
      } else {
        errorMessage.value = response!.data['message'];
        print(response);

        snackBar(
          title: 'Error',
          message: errorMessage.value,
          color: AppColors.warningDark,
          icon: Icons.error,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Error adding HSN code: $e');

      snackBar(
        title: 'Error',
        message: 'Failed to add HSN code',
        color: AppColors.errorDark,
        messageColor: Colors.white,
        icon: Icons.error,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateHsnCode(
    String id,
    Map<String, dynamic> hsnCodeData,
  ) async {
    try {
      isLoading.value = true;
      dio.Response? response = await _apiService.requestPutForApi(
        authToken: true,
        url: '$hsnCodeUpdateUrl$id',
        dictParameter: hsnCodeData,
      );

      if (response != null && response.statusCode == 200) {
        snackBar(
          title: 'Success',
          message: 'HSN Code updated successfully',
          color: AppColors.successDark,
          messageColor: Colors.white,
          icon: Icons.check_circle,
        );
        refreshHsnCodes();
        Get.back();
      } else {
        errorMessage.value = response!.data['message'];
        snackBar(
          title: 'Error',
          message: errorMessage.value,
          color: AppColors.warningDark,
          icon: Icons.error,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Error updating HSN code: $e');
      Get.snackbar('Error', 'Failed to update HSN code');
      snackBar(
        title: 'Error',
        message: 'Failed to update HSN code',
        color: AppColors.errorDark,
        messageColor: Colors.white,
        icon: Icons.error,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHsnCode(String id) async {
    try {
      isLoading.value = true;
      dio.Response? response = await _apiService.requestDeleteForApi(
        authToken: true,
        url: '$hsnCodeDeleteUrl$id',
        dictParameter: {},
      );

      if (response != null && response.statusCode == 200) {
        snackBar(
          title: 'Success',
          message: 'HSN Code deleted successfully',
          color: AppColors.successDark,
          messageColor: Colors.white,
          icon: Icons.check_circle,
        );
        refreshHsnCodes();
      } else {
        errorMessage.value = response!.data['message'];
        snackBar(
          title: 'Error',
          message: errorMessage.value,
          color: AppColors.warningDark,
          icon: Icons.error,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Error deleting HSN code: $e');

      snackBar(
        title: 'Error',
        message: 'Failed to delete HSN code',
        color: AppColors.errorDark,
        icon: Icons.error,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    isTableView.value = !isTableView.value;
  }

  void searchHsnCodes(String query) {
    searchQuery.value = query;
    refreshHsnCodes();
  }

  void snackBar({
    required String title,
    required String message,
    Color? color,
    Color? messageColor = Colors.white,
    IconData? icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      icon: Icon(icon),
      message,
      backgroundColor: color,
      colorText: messageColor,
      duration: duration ?? Duration(seconds: 4),
    );
  }
RxBool isAutoGenerating = false.obs;
  
  Future<void> autoGenerate() async {
    try {
      isAutoGenerating.value = true;
      
      dio.Response? response = await _apiService.requestPostForApi(
        authToken: true,
        url: '${_config.baseUrl}/api/hsn-codes/auto-generate', dictParameter: {},
      );

      if (response != null && response.statusCode == 200) {
        appSuccessDialog();
        fetchHsnCodes();
        refreshHsnCodes();
      }
    } catch (e) {
      print('Error fetching HSN codes: $e');
      Get.snackbar('Error', 'Failed to load HSN codes');
    } finally {
      isAutoGenerating.value = false;
    }
  }

}