import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/helper/confirmation/range_check_helper.dart';

class InventoryCrudOperationController extends GetxController {
  @override
  void onClose() {
    quantityController.dispose();
    priceController.dispose();
    companyTextController.dispose();
    modelTextController.dispose();
    colorTextController.dispose();
    descriptionController.dispose();
    purchasedFromController.dispose();
    purchaseNotesController.dispose();
    quantityFocusNode.dispose();
    priceFocusNode.dispose();
    purchasePriceFocusNode.dispose();
    super.onClose();
  }

  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;

  // ADD MOBILE FORM CONTROLLERS AND VARIABLES
  final GlobalKey<FormState> addMobileFormKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController supplierDetailsController =
      TextEditingController();
  final TextEditingController companyTextController = TextEditingController();
  final TextEditingController modelTextController = TextEditingController();
  final TextEditingController colorTextController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController purchasedFromController = TextEditingController();
  final TextEditingController purchaseNotesController = TextEditingController();
  //  form focus nodes
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode priceFocusNode = FocusNode();
  final FocusNode purchasePriceFocusNode = FocusNode();

  // Form Values
  final RxString selectedCategory = ''.obs;
  final RxString selectedAddCompany = ''.obs;
  final RxString selectedAddModel = ''.obs;
  final RxString selectedAddRam = ''.obs;
  final RxString selectedAddStorage = ''.obs;
  final RxString selectedAddColor = ''.obs;
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<DateTime?> selectedPurchaseDate = Rx<DateTime?>(DateTime.now());

  // Form Loading States
  final RxBool isAddingMobile = false.obs;
  final RxBool hasAddMobileError = false.obs;
  final RxString addMobileErrorMessage = ''.obs;
  final RxBool isLoadingFilters = false.obs;
  final RxBool isLoadingModels = false.obs;
  final RxBool isLoadingCategories = false.obs;

  // API data for dropdowns
  final RxList<String> categories = <String>[].obs;
  final RxList<String> companies = <String>[].obs;
  final RxList<String> models = <String>[].obs;
  final RxList<String> ramOptions =
      <String>[
        "2GB",
        "3GB",
        "4GB",
        "6GB",
        "8GB",
        "12GB",
        "16GB",
        "24GB",
        "32GB",
      ].obs;
  final RxList<String> storageOptions =
      <String>["64GB", "128GB", "256GB", "512GB", "1024GB"].obs;
  final RxList<String> colorOptions = <String>[].obs;

  // Dropdown mode flags
  final RxBool isCompanyTypeable = false.obs;
  final RxBool isModelTypeable = false.obs;
  final RxBool isColorTypeable = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadInitialFilters();
    selectedPurchaseDate.value = DateTime.now();
    quantityConfirmationHelper(
      controller: quantityController,
      focusNode: quantityFocusNode,
    );
    priceConfirmationHelper(
      controller: priceController,
      focusNode: priceFocusNode,
    );

    priceConfirmationHelper(
      controller: purchasePriceController,
      focusNode: purchasePriceFocusNode,
    );
  }

  /// Load categories from API
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/inventory/item-types',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        categories.value = List<String>.from(response.data ?? []);
        log("✅ Categories loaded successfully");
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      log("❌ Error loading categories: $error");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Check if RAM/ROM fields should be shown
  bool get shouldShowRamRom {
    final category = selectedCategory.value.toUpperCase();
    final shouldShow = category == 'SMARTPHONE' || category == 'TABLET';
    log("🔍 shouldShowRamRom: $shouldShow (Category: $category)");
    return shouldShow;
  }

  /// Handle category selection
  void onCategoryChanged(String category) {
    selectedCategory.value = category;
    // Clear RAM/ROM if category doesn't need them
    if (!shouldShowRamRom) {
      selectedAddRam.value = '';
      selectedAddStorage.value = '';
    }
  }

  /// Load initial filter data (companies, RAM, storage, colors)
  Future<void> loadInitialFilters() async {
    try {
      isLoadingFilters.value = true;

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/mobiles/filters',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        // Update dropdown options
        companies.value = List<String>.from(data['companies'] ?? []);
        // ramOptions.value = sortStringList(
        //   RxList<String>.from(data['rams'] ?? ["2gb", "3gb", "4gb", "6gb", "8gb", "12gb", "16gb", "24gb", "32gb"]),
        // );
        // storageOptions.value = sortStringList(RxList<String>.from(data['roms'] ?? []));

        colorOptions.value = List<String>.from(data['colors'] ?? []);

        // Set typeable mode if no companies available
        isCompanyTypeable.value = companies.isEmpty;
        isColorTypeable.value = colorOptions.isEmpty;

        log("✅ Filters loaded successfully");
      } else {
        throw Exception('Failed to load filters');
      }
    } catch (error) {
      log("❌ Error loading filters: $error");
      // Enable typeable mode if API fails
      isCompanyTypeable.value = true;
      isModelTypeable.value = true;
      isColorTypeable.value = true;
    } finally {
      isLoadingFilters.value = false;
    }
  }

  //string num sort
  RxList<String> sortStringList(RxList<String> list) {
    final sorted = list.map(int.parse).toList()..sort();
    return sorted.map((e) => e.toString()).toList().obs;
  }

  /// Load models for selected company
  Future<void> loadModelsForCompany(String company) async {
    try {
      isLoadingModels.value = true;
      models.clear();
      selectedAddModel.value = '';
      modelTextController.clear();

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/mobiles/filters?company=${Uri.encodeComponent(company)}',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        models.value = List<String>.from(data['models'] ?? []);

        // Set typeable mode if no models available
        isModelTypeable.value = models.isEmpty;

        log("✅ Models loaded for company: $company");
      } else {
        throw Exception('Failed to load models for company: $company');
      }
    } catch (error) {
      log("❌ Error loading models: $error");
      // Enable typeable mode if API fails
      isModelTypeable.value = true;
    } finally {
      isLoadingModels.value = false;
    }
  }

  /// Get company brand color for UI theming
  Color getCompanyColor(String? company) {
    switch (company?.toLowerCase()) {
      case 'apple':
        return const Color(0xFF1D1D1F);
      case 'samsung':
        return const Color(0xFF1428A0);
      case 'google':
        return const Color(0xFF4285F4);
      case 'oneplus':
        return const Color(0xFFEB0028);
      case 'xiaomi':
        return const Color(0xFFFF6900);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Check if model selection is enabled
  bool get isModelSelectionEnabled => selectedAddCompany.value.isNotEmpty;

  /// Get formatted device name for display
  String get formattedDeviceName {
    String company =
        selectedAddCompany.value.isNotEmpty
            ? selectedAddCompany.value
            : companyTextController.text;
    String model =
        selectedAddModel.value.isNotEmpty
            ? selectedAddModel.value
            : modelTextController.text;

    if (company.isNotEmpty && model.isNotEmpty) {
      return '$company $model';
    }
    return 'Select Company & Model';
  }

  /// Get formatted device specs for display
  String get formattedDeviceSpecs {
    if (selectedAddRam.value.isNotEmpty &&
        selectedAddStorage.value.isNotEmpty) {
      return '${selectedAddRam.value} RAM • ${selectedAddStorage.value} Storage';
    }
    return 'RAM & Storage will appear here';
  }

  /// Handle company selection/input
  void onAddCompanyChanged(String company) {
    selectedAddCompany.value = company;
    selectedAddModel.value = '';
    modelTextController.clear();

    if (company.isNotEmpty) {
      loadModelsForCompany(company);
    } else {
      models.clear();
      isModelTypeable.value = false;
    }
  }

  /// Handle company text input
  void onCompanyTextChanged(String text) {
    selectedAddCompany.value = text;
    selectedAddModel.value = '';
    modelTextController.clear();

    if (text.isNotEmpty) {
      loadModelsForCompany(text);
    } else {
      models.clear();
      isModelTypeable.value = false;
    }
  }

  /// Handle model selection/input
  void onAddModelChanged(String model) {
    selectedAddModel.value = model;
  }

  /// Handle model text input
  void onModelTextChanged(String text) {
    selectedAddModel.value = text;
  }

  /// Handle RAM selection
  void onAddRamChanged(String ram) {
    selectedAddRam.value = ram;
  }

  /// Handle storage selection
  void onAddStorageChanged(String storage) {
    selectedAddStorage.value = storage;
  }

  /// Handle color selection
  void onAddColorChanged(String color) {
    selectedAddColor.value = color;
  }

  /// Handle color text input
  void onColorTextChanged(String text) {
    selectedAddColor.value = text;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addUserProfilePhoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void removeShopImage() {
    selectedImage.value = null;
  }

  void onImageSelected(File? image) {
    selectedImage.value = image;
  }

  /// Handle purchase date selection
  void onPurchaseDateChanged(DateTime? date) {
    selectedPurchaseDate.value = date;
  }

  /// Validate form fields
  String? validateCategory(String? value) {
    return value == null || value.isEmpty ? 'Please select a category' : null;
  }

  String? validateCompany(String? value) {
    String companyValue =
        isCompanyTypeable.value ? companyTextController.text : (value ?? '');
    return companyValue.isEmpty ? 'Please select or enter a company' : null;
  }

  String? validateModel(String? value) {
    String modelValue =
        isModelTypeable.value ? modelTextController.text : (value ?? '');
    return modelValue.isEmpty ? 'Please select or enter a model' : null;
  }

  String? validateRam(String? value) {
    if (!shouldShowRamRom) return null; // Skip validation if not needed
    return value == null || value.isEmpty ? 'Please select RAM' : null;
  }

  String? validateStorage(String? value) {
    if (!shouldShowRamRom) return null; // Skip validation if not needed
    return value == null || value.isEmpty ? 'Please select storage' : null;
  }

  String? validateColor(String? value) {
    String colorValue =
        isColorTypeable.value ? colorTextController.text : (value ?? '');
    return colorValue.isEmpty ? 'Please select or enter a color' : null;
  }

  String? validateSellingPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter selling price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter valid price';
    }
    return null;
  }

  String? validatePurchasePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter purchase price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter valid price';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter valid quantity';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product description';
    }
    return null;
  }

  String? validatePurchasedFrom(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter where purchased from';
    }
    return null;
  }

  /// Reset add mobile form
  void resetAddMobileForm() {
    addMobileFormKey.currentState?.reset();
    selectedCategory.value = '';
    selectedAddCompany.value = '';
    selectedAddModel.value = '';
    selectedAddRam.value = '';
    selectedAddStorage.value = '';
    selectedAddColor.value = '';
    selectedImage.value = null;
    selectedPurchaseDate.value = DateTime.now();
    quantityController.clear();
    priceController.clear();
    purchasePriceController.clear();
    supplierDetailsController.clear();
    companyTextController.clear();
    modelTextController.clear();
    colorTextController.clear();
    descriptionController.clear();
    purchasedFromController.clear();
    purchaseNotesController.clear();
    hasAddMobileError.value = false;
    addMobileErrorMessage.value = '';
    models.clear();
    isModelTypeable.value = false;
    isColorTypeable.value = false;
  }

  /// Format date to YYYY-MM-DD format for API
  String formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Add mobile to inventory with multipart file upload
  Future<void> addMobileToInventory() async {
    if (!addMobileFormKey.currentState!.validate()) {
      return;
    }

    try {
      isAddingMobile.value = true;
      hasAddMobileError.value = false;
      addMobileErrorMessage.value = '';

      // Get final values (from dropdown or text input)
      String finalCompany =
          selectedAddCompany.value.isNotEmpty
              ? selectedAddCompany.value
              : companyTextController.text;
      String finalModel =
          selectedAddModel.value.isNotEmpty
              ? selectedAddModel.value
              : modelTextController.text;
      String finalColor =
          selectedAddColor.value.isNotEmpty
              ? selectedAddColor.value
              : colorTextController.text;

      // Create FormData for multipart request
      Map<String, dynamic> formDataMap = {
        'model': finalModel,
        'color': finalColor,
        'sellingPrice': priceController.text,
        'purchasePrice': purchasePriceController.text,
        'qty': quantityController.text,
        'company': finalCompany,
        'description': descriptionController.text,
        'purchasedFrom': purchasedFromController.text,
        'purchaseDate': formatDateForApi(
          selectedPurchaseDate.value ?? DateTime.now(),
        ),
        'purchaseNotes': purchaseNotesController.text,
        'itemCategory': selectedCategory.value,
      };

      // Only add RAM and ROM if category is SMARTPHONE or TABLET
      if (shouldShowRamRom) {
        formDataMap['ram'] = selectedAddRam.value;
        formDataMap['rom'] = selectedAddStorage.value;
      }

      dio.FormData formData = dio.FormData.fromMap(formDataMap);

      // Add file if selected, otherwise send 'null' as string
      if (selectedImage.value != null) {
        String fileName =
            "${finalCompany}_${finalModel}_${finalColor}.${selectedImage.value!.path.split('.').last}";
        formData.files.add(
          MapEntry(
            'file',
            await dio.MultipartFile.fromFile(
              selectedImage.value!.path,
              filename: fileName,
            ),
          ),
        );
      } else {
        // Send 'null' as string when no file is selected
        formData.fields.add(const MapEntry('file', 'null'));
      }

      // Use the multipart API method
      dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.addInventoryItem,
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 200) {
        await Future.wait([refreshBills(), refreshInventory(), refreshDues(),refreshThisMonthStock()]);

        resetAddMobileForm();
        loadInitialFilters();
        gotoSellScreen();
      } else {
        String errorMessage = 'Failed to add product to inventory';
        if (response?.data != null) {
          errorMessage = response?.data['message'] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (error) {
      hasAddMobileError.value = true;
      addMobileErrorMessage.value = 'Error adding product: $error';
      log("❌ Error in addMobileToInventory: $error");
    } finally {
      isAddingMobile.value = false;
    }
  }

  Future<void> refreshBills() async {
    if (Get.isRegistered<BillHistoryController>()) {
      await Get.find<BillHistoryController>().refreshAll();
    }
  }

  Future<void> refreshInventory() async {
    if (Get.isRegistered<InventoryController>()) {
      await Get.find<InventoryController>().refreshData();
    }
  }

  Future<void> refreshDues() async {
    if (Get.isRegistered<CustomerDuesController>()) {
      await Get.find<CustomerDuesController>().refreshData();
    }
  }
Future<void> refreshThisMonthStock() async {
    if (Get.isRegistered<ThisMonthStockController>()) {
      await Get.find<ThisMonthStockController>().refreshData();
    }
  }
  void gotoSellScreen() async {
    appSuccessDialog(
      title: 'new item added',

      description: 'add new stock operation completed successfully',
      onPressed: () {
        final navCtrl = Get.find<BottomNavigationController>();
        navCtrl.setIndex(3);
        Get.back();
        Get.back();
      },
    );
  }

  /// Cancel add mobile form
  void cancelAddMobile() {
    resetAddMobileForm();
    Get.back();
  }
}
