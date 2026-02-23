import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/inventory%20management/product_return_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/secure_storage_service.dart';

class ProductReturnController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables
  final RxList<ProductReturn> productReturns = <ProductReturn>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString selectedDistributor = ''.obs;
  final RxString selectedCompany = ''.obs;
  final TextEditingController searchQueryController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt pageSize = 10.obs;
  final RxInt totalElements = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Sort
  final RxString sortBy = 'returnDate'.obs;
  final RxString sortDir = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductReturns();
  }




 void setSelectedDistributor(String value) {
    selectedDistributor.value = value;
    fetchProductReturns();
 }
  Future<void> fetchProductReturns({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        currentPage.value = 0;
      }

      hasError.value = false;
      errorMessage.value = '';

      final jsessionId = await SecureStorageHelper.getJSessionId();
      if (jsessionId == null || jsessionId.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'No session found. Please login again.';
        return;
      }

      // Build query parameters
      Map<String, String> queryParams = {
        'page': currentPage.value.toString(),
        'size': pageSize.value.toString(),
        'sortBy': sortBy.value,
        'sortDir': sortDir.value,
      };

      // Add search filters
      if (searchQuery.value.trim().isNotEmpty) {
        // queryParams['distributor'] = searchQuery.value.trim();
        queryParams['keyword'] = searchQuery.value.trim();
      } else {
        if (selectedDistributor.value.isNotEmpty) {
          queryParams['distributor'] = selectedDistributor.value;
        }
        if (selectedCompany.value.isNotEmpty) {
          queryParams['company'] = selectedCompany.value;
        }
        if (startDateController.text.isNotEmpty) {
          queryParams['startDate'] = startDateController.text;
        }
         if (endDateController.text.isNotEmpty) {
          queryParams['endDate'] = endDateController.text;
        }
      }

      String apiUrl = _config.getProductReturns;
      String queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      if (queryString.isNotEmpty) {
        apiUrl += '?$queryString';
      }

      log("🌐 Fetching product returns: $apiUrl");

      final response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        if (data['status'] == 'success') {
          final returnResponse =
              ProductReturnResponse.fromJson(data['payload']);

          if (isLoadMore) {
            productReturns.addAll(returnResponse.returnItems);
          } else {
            productReturns.assignAll(returnResponse.returnItems);
          }

          totalElements.value = returnResponse.totalElements;
          totalPages.value = returnResponse.totalPages;
          hasMoreData.value = returnResponse.hasNext;

          log("✅ Loaded ${returnResponse.returnItems.length} returns");
        } else {
          hasError.value = true;
          errorMessage.value = data['message'] ?? 'Failed to fetch returns';
        }
      } else if (response?.statusCode == 401 ||
          response?.statusCode == 403) {
        hasError.value = true;
        errorMessage.value = 'Session expired. Please login again.';
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to fetch returns. Status: ${response?.statusCode}';
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error fetching product returns: $error");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;

    currentPage.value++;
    await fetchProductReturns(isLoadMore: true);
  }

  void search(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
    fetchProductReturns();
  }

  void clearSearch() {
    searchQuery.value = '';
    selectedDistributor.value = '';
    selectedCompany.value = '';
    currentPage.value = 0;
    searchQueryController.clear();
    fetchProductReturns();
  }
   
   bool hasActiveFilter() {
    return searchQuery.value.isNotEmpty ||
        selectedDistributor.value.isNotEmpty ||
        selectedCompany.value.isNotEmpty|| startDateController.text.isNotEmpty ||
        endDateController.text.isNotEmpty;
  }

  void refreshData() {
    currentPage.value = 0;
    fetchProductReturns();
  }
// Replace selectStartDate method (around line 179)
Future<void> selectStartDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: startDateController.text.isNotEmpty 
        ? DateTime.parse(startDateController.text)
        : DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    // Format: yyyy-MM-dd
    startDateController.text = picked.toIso8601String().split('T')[0];
    // Trigger UI update
    startDateController.notifyListeners();
  }
}

// Replace selectEndDate method (around line 201)
Future<void> selectEndDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: endDateController.text.isNotEmpty 
        ? DateTime.parse(endDateController.text)
        : DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    // Format: yyyy-MM-dd
    endDateController.text = picked.toIso8601String().split('T')[0];
    // Trigger UI update
    endDateController.notifyListeners();
  }
}
}

