import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';

class AddNewStockOperationController extends GetxController {
  final GlobalKey<FormState> addBillFormKey = GlobalKey<FormState>();
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Arguments from previous page
  bool? hasGstNumber;
  String? dateFromPrevPage;

  // Bill Details
  final companyNameController = TextEditingController();
  final amountController = TextEditingController();
  final withoutGstController = TextEditingController();
  final totalGstAmountController = TextEditingController();
  final dateController = TextEditingController();

  // Observable variables
  var isPaid = false.obs;
  var isAddingBill = false.obs;
  var hasAddBillError = false.obs;
  var addBillErrorMessage = ''.obs;

  // File upload variables
  var selectedFile = Rx<File?>(null);
  var fileName = ''.obs;
  var isFileUploading = false.obs;

  // Items list
  var billItems = <BillItem>[].obs;

  // Category management
  var categories = <String>[].obs;
  var isLoadingCategories = false.obs;

  // Flag to prevent circular calculation updates
  var _isCalculating = false;

  @override
  void onInit() {
    super.onInit();

    // Get arguments from previous page
    final args = Get.arguments;
    if (args != null) {
      hasGstNumber = args['hasGstNumber'] ?? false;
      dateFromPrevPage = args['date'];
    }

    fetchCategories();
    _initializeCalculation();
  }

  void _initializeCalculation() {
    totalGstAmountController.text = '0';
    withoutGstController.text = '0';
    amountController.text = '0';
    dateController.text =
        dateFromPrevPage ?? DateTime.now().toString().split(' ')[0];
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/inventory/item-types',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        List<dynamic> categoryData = response.data;
        categories.value = categoryData.map((e) => e.toString()).toList();
      }
    } catch (e) {
      log('Error fetching categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch filter suggestions based on category
  Future<Map<String, dynamic>> fetchFilterSuggestions(String category) async {
    try {
      log('Fetching filter suggestions for category: $category');

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/mobiles/filters?itemCategory=$category',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        log('Filter API Response: ${response.data}');

        // Extract lists with null safety
        final data = response.data as Map<String, dynamic>;

        return {
          'companies':
              (data['companies'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'models':
              (data['models'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'rams':
              (data['rams'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'roms':
              (data['roms'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'colors':
              (data['colors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        };
      } else {
        log('Failed to fetch filter suggestions: ${response?.statusCode}');
      }
    } catch (e) {
      log('Error fetching filter suggestions: $e');
    }
    return {
      'companies': <String>[],
      'models': <String>[],
      'rams': <String>[],
      'roms': <String>[],
      'colors': <String>[],
    };
  }

  // Fetch GST percentage for category
  Future<double> fetchGstPercentage(String category) async {
    try {
      log('Fetching GST percentage for category: $category');

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/hsn-codes/category/$category/first',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        log('GST API Response: ${response.data}');

        final data = response.data as Map<String, dynamic>;
        final payload = data['payload'] as Map<String, dynamic>?;

        if (payload != null && payload.containsKey('gstPercentage')) {
          final gstValue = payload['gstPercentage'];
          return (gstValue is int) ? gstValue.toDouble() : (gstValue as double);
        }
      } else {
        log('Failed to fetch GST percentage: ${response?.statusCode}');
      }
    } catch (e) {
      log('Error fetching GST percentage: $e');
    }
    return 0.0;
  }

  // Validation methods
  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Distributor name is required';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter valid amount';
    }
    return null;
  }

  // File picker method
  Future<void> pickFile() async {
    try {
      isFileUploading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        fileName.value = result.files.single.name;

        Get.snackbar(
          'Success',
          'File selected: ${result.files.single.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isFileUploading.value = false;
    }
  }

  void removeFile() {
    selectedFile.value = null;
    fileName.value = '';
  }

  // Calculate item totals
  void calculateItemTotals(int index) {
    if (index < 0 || index >= billItems.length) return;

    BillItem item = billItems[index];

    double unitPrice = double.tryParse(item.unitPrice.value) ?? 0;
    int qty = int.tryParse(item.qty.value) ?? 0;
    double discount = double.tryParse(item.discountPercentage.value) ?? 0;

    // Calculate without GST amount
    double subtotal = unitPrice * qty;
    double discountAmount = subtotal * (discount / 100);
    double withoutGstAmount = subtotal - discountAmount;

    item.withoutGstAmountController.text = withoutGstAmount.toStringAsFixed(2);
    item.withoutGstAmount.value = withoutGstAmount.toString();

    // Calculate with GST if applicable
    if (hasGstNumber! && item.gstPercentage.value > 0) {
      double gstAmount = withoutGstAmount * (item.gstPercentage.value / 100);
      double withGstAmount = withoutGstAmount + gstAmount;

      item.withGstAmountController.text = withGstAmount.toStringAsFixed(2);
      item.withGstAmount.value = withGstAmount.toString();
    } else {
      item.withGstAmountController.text = withoutGstAmount.toStringAsFixed(2);
      item.withGstAmount.value = withoutGstAmount.toString();
    }

    // Recalculate totals
    calculateTotals();
  }

  // Calculate bill totals
  void calculateTotals() {
    double totalWithoutGst = 0;
    double totalWithGst = 0;
    double totalGst = 0;

    for (var item in billItems) {
      totalWithoutGst += double.tryParse(item.withoutGstAmount.value) ?? 0;
      totalWithGst += double.tryParse(item.withGstAmount.value) ?? 0;
    }

    totalGst = totalWithGst - totalWithoutGst;

    withoutGstController.text = totalWithoutGst.toStringAsFixed(2);
    amountController.text = totalWithGst.toStringAsFixed(2);
    totalGstAmountController.text = totalGst.toStringAsFixed(2);
  }

  void addBillToSystem() async {
    if (addBillFormKey.currentState!.validate()) {
      if (billItems.isEmpty) {
        hasAddBillError.value = true;
        addBillErrorMessage.value = 'Please add at least one item';
        return;
      }

      // Validate items
      for (int i = 0; i < billItems.length; i++) {
        BillItem item = billItems[i];
        if (item.category.value.isEmpty ||
            item.company.value.isEmpty ||
            item.model.value.isEmpty ||
            item.unitPrice.value.isEmpty ||
            item.qty.value.isEmpty ||
            item.color.value.isEmpty) {
          hasAddBillError.value = true;
          addBillErrorMessage.value =
              'Please fill all required fields for Item ${i + 1}';
          return;
        }

        if ((item.category.value == 'SMARTPHONE' ||
                item.category.value == 'TABLET') &&
            (item.ram.value.isEmpty || item.rom.value.isEmpty)) {
          hasAddBillError.value = true;
          addBillErrorMessage.value =
              'Please fill RAM and ROM for Item ${i + 1}';
          return;
        }

        // NEW: Validate IMEIs only for SMARTPHONE/TABLET
        if (item.category.value == 'SMARTPHONE' ||
            item.category.value == 'TABLET') {
          if (!_validateItemImeis(item, i)) {
            return; // Error message already set in _validateItemImeis
          }
        }
      }

      isAddingBill.value = true;
      hasAddBillError.value = false;

      try {
        await _sendBillToAPI();
      } catch (e) {
        isAddingBill.value = false;
        hasAddBillError.value = true;
        addBillErrorMessage.value = 'Failed to create bill: ${e.toString()}';
        log('Error creating bill: $e');
      }
    }
  }

  // IMEI validation method (only for SMARTPHONE/TABLET, IMEIs optional)
  bool _validateItemImeis(BillItem item, int itemIndex) {
    // Get valid IMEIs (non-empty, trimmed)
    List<String> validImeis =
        item.imeiList
            .map((imei) => imei.trim())
            .where((imei) => imei.isNotEmpty)
            .toList();

    // If no IMEIs entered, that's fine - skip validation
    if (validImeis.isEmpty) {
      return true;
    }

    // Check for duplicate IMEIs within the item
    Set<String> uniqueImeis = validImeis.toSet();
    if (uniqueImeis.length != validImeis.length) {
      hasAddBillError.value = true;
      addBillErrorMessage.value =
          'Item ${itemIndex + 1}: Duplicate IMEIs found. Each IMEI must be unique';
      return false;
    }

    // Check for duplicate IMEIs across all SMARTPHONE/TABLET items
    for (int j = 0; j < billItems.length; j++) {
      if (j == itemIndex) continue; // Skip current item

      BillItem otherItem = billItems[j];

      // Only check against other SMARTPHONE/TABLET items
      if (otherItem.category.value != 'SMARTPHONE' &&
          otherItem.category.value != 'TABLET') {
        continue;
      }

      List<String> otherItemImeis =
          otherItem.imeiList
              .map((imei) => imei.trim())
              .where((imei) => imei.isNotEmpty)
              .toList();

      // Check if any IMEI exists in another item
      for (String imei in validImeis) {
        if (otherItemImeis.contains(imei)) {
          hasAddBillError.value = true;
          addBillErrorMessage.value =
              'IMEI "$imei" is duplicated across multiple items';
          return false;
        }
      }
    }

    return true;
  }

  Map<String, dynamic> _prepareBillData() {
    List<Map<String, dynamic>> itemsArray =
        billItems.map((item) {
          Map<String, dynamic> itemData = {
            "itemCategory": item.category.value,
            "company": item.company.value,
            "model": item.model.value,
            "color": item.color.value,
            "sellingPrice": item.sellingPrice.value,
            "qty": item.qty.value,
            "description":
                item.description.value.isEmpty ? "" : item.description.value,
            "withoutGstAmount":
                double.tryParse(item.withoutGstAmount.value) ?? 0,
            "withGstAmount": double.tryParse(item.withGstAmount.value) ?? 0,
            "hsnCode": item.hsnCode.value,
          };

          if (item.category.value == "SMARTPHONE" ||
              item.category.value == 'TABLET') {
            // Clean user input before sending to API
            itemData["ram"] = extractNumber(item.ram.value);
            itemData["rom"] = extractNumber(item.rom.value);

            // IMEI cleaning
            List<String> validImeis =
                item.imeiList
                    .map((imei) => imei.trim())
                    .where((imei) => imei.isNotEmpty)
                    .toList();

            if (validImeis.isNotEmpty) {
              itemData["colorImeiMapping"] = jsonEncode({
                item.color.value: validImeis,
              });
            }
          }

          return itemData;
        }).toList();

    return {
      "companyName": companyNameController.text.trim(),
      "isPaid": isPaid.value,
      "amount": double.tryParse(amountController.text.trim()) ?? 0,
      "withoutGst": double.tryParse(withoutGstController.text.trim()) ?? 0,
      "totalGstAmount":
          double.tryParse(totalGstAmountController.text.trim()) ?? 0,
      "dues":
          isPaid.value
              ? 0
              : (double.tryParse(amountController.text.trim()) ?? 0),
      "date": dateController.text.trim(),
      "items": itemsArray,
    };
  }

  int extractNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? 0 : int.parse(cleaned);
  }

  Future<void> _sendBillToAPI() async {
    try {
      isAddingBill.value = true;

      Map<String, dynamic> billData = _prepareBillData();
      String billJsonString = jsonEncode(billData);

      log('=== SENDING BILL DATA ===');
      log(billJsonString);
      log('========================');

      Map<String, dynamic> formDataMap = {'bill': billJsonString};

      if (selectedFile.value != null) {
        formDataMap['file'] = await dio.MultipartFile.fromFile(
          selectedFile.value!.path,
          filename: fileName.value,
        );
      }

      dio.FormData formData = dio.FormData.fromMap(formDataMap);

      dio.Response? response = await _apiService.requestMultipartApi(
        url: '${_config.baseUrl}/api/purchase-bills',
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        // Get.find<BottomNavigationController>().setIndex(3);
        await Future.wait([refreshBills(), refreshInventory(), refreshDues(),refreshThisMonthStock()]);

        // Get.snackbar(
        //   'Success',
        //   'Purchase Bill created successfully!',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 3),
        // );

        _clearForm();
        gotoSellScreen();
      } else {
        throw Exception('API Error: ${response?.statusCode}');
      }
    } catch (e) {
      isAddingBill.value = false;
      throw Exception('Failed to create bill: ${e.toString()}');
    } finally {
      isAddingBill.value = false;
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

      description: 'add new stock completed successfully',
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  void _clearForm() {
    companyNameController.clear();
    amountController.clear();
    withoutGstController.clear();
    totalGstAmountController.clear();
    dateController.clear();

    isPaid.value = false;
    hasAddBillError.value = false;
    addBillErrorMessage.value = '';

    selectedFile.value = null;
    fileName.value = '';

    for (var item in billItems) {
      item.dispose();
    }
    billItems.clear();

    _initializeCalculation();
  }

  void cancelAddBill() {
    Get.back();
  }

  void addNewItem() {
    billItems.add(BillItem(controller: this, hasGstNumber: hasGstNumber!));
  }

  void removeItem(int index) {
    if (index >= 0 && index < billItems.length) {
      billItems[index].dispose();
      billItems.removeAt(index);
      calculateTotals();
    }
  }

  @override
  void onClose() {
    companyNameController.dispose();
    amountController.dispose();
    withoutGstController.dispose();
    totalGstAmountController.dispose();
    dateController.dispose();

    for (var item in billItems) {
      item.dispose();
    }

    super.onClose();
  }
}

class BillItem {
  final AddNewStockOperationController controller;
  final bool hasGstNumber;

  RxString category = ''.obs;
  RxString company = ''.obs;
  RxString model = ''.obs;
  RxString ram = ''.obs;
  RxString rom = ''.obs;
  RxString color = ''.obs;
  RxString unitPrice = ''.obs;
  RxString qty = ''.obs;
  RxString discountPercentage = ''.obs;
  RxString withoutGstAmount = ''.obs;
  RxString withGstAmount = ''.obs;
  RxString sellingPrice = ''.obs;
  RxString description = ''.obs;
  RxString hsnCode = ''.obs;
  RxDouble gstPercentage = 0.0.obs;

  // IMEI fields
  RxList<String> imeiList = <String>[].obs;
  List<TextEditingController> imeiControllers = [];

  // Filter suggestions
  RxList<String> companySuggestions = <String>[].obs;
  RxList<String> modelSuggestions = <String>[].obs;
  RxList<String> ramSuggestions = <String>[].obs;
  RxList<String> romSuggestions = <String>[].obs;
  RxList<String> colorSuggestions = <String>[].obs;
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

  final RxString selectedAddRam = ''.obs;
  final RxString selectedAddStorage = ''.obs;

  /// Handle RAM selection
  void onAddRamChanged(String ram) {
    selectedAddRam.value = ram;
    selectedAddRam.value = ramController.text;
    ;
  }

  /// Handle storage selection
  void onAddStorageChanged(String storage) {
    selectedAddStorage.value = storage;
    selectedAddStorage.value = romController.text;
  }

  late TextEditingController companyController;
  late TextEditingController modelController;
  late TextEditingController ramController;
  late TextEditingController romController;
  late TextEditingController colorController;
  late TextEditingController unitPriceController;
  late TextEditingController qtyController;
  late TextEditingController discountController;
  late TextEditingController gstPercentageController;
  late TextEditingController withoutGstAmountController;
  late TextEditingController withGstAmountController;
  late TextEditingController sellingPriceController;
  late TextEditingController descriptionController;

  BillItem({required this.controller, required this.hasGstNumber}) {
    companyController = TextEditingController();
    modelController = TextEditingController();
    ramController = TextEditingController();
    romController = TextEditingController();
    colorController = TextEditingController();
    unitPriceController = TextEditingController();
    qtyController = TextEditingController();
    discountController = TextEditingController();
    gstPercentageController = TextEditingController();
    withoutGstAmountController = TextEditingController();
    withGstAmountController = TextEditingController();
    sellingPriceController = TextEditingController();
    descriptionController = TextEditingController();

    qty.value = '0';
    qtyController.text = '0';
    discountPercentage.value = '0';
    discountController.text = '0';

    _setupListeners();
  }

  void _setupListeners() {
    // Listen to category changes to fetch GST and filters
    category.listen((cat) async {
      if (cat.isNotEmpty) {
        log('Category changed to: $cat');

        // Fetch filter suggestions
        Map<String, dynamic> filters = await controller.fetchFilterSuggestions(
          cat,
        );
        companySuggestions.value = filters['companies'] ?? [];
        modelSuggestions.value = filters['models'] ?? [];
        ramSuggestions.value = filters['rams'] ?? [];
        romSuggestions.value = filters['roms'] ?? [];
        colorSuggestions.value = filters['colors'] ?? [];

        log(
          'Suggestions loaded - Companies: ${companySuggestions.length}, Models: ${modelSuggestions.length}',
        );

        // Fetch GST percentage if user has GST number
        if (hasGstNumber) {
          try {
            dio.Response?
            gstResponse = await controller._apiService.requestGetForApi(
              url:
                  '${controller._config.baseUrl}/api/hsn-codes/category/$cat/first',
              authToken: true,
            );

            if (gstResponse != null && gstResponse.statusCode == 200) {
              final data = gstResponse.data as Map<String, dynamic>;
              final payload = data['payload'] as Map<String, dynamic>?;

              if (payload != null) {
                // Get GST percentage
                final gstValue = payload['gstPercentage'];
                gstPercentage.value =
                    (gstValue is int)
                        ? gstValue.toDouble()
                        : (gstValue as double? ?? 0.0);
                gstPercentageController.text = gstPercentage.value.toString();

                // Get HSN code
                hsnCode.value = payload['hsnCode']?.toString() ?? '';

                log(
                  'GST Percentage: ${gstPercentage.value}, HSN Code: ${hsnCode.value}',
                );
              }
            }
          } catch (e) {
            log('Error fetching GST data: $e');
          }
        }
      }
    });

    // Listen to quantity changes to update IMEI fields
    // Only create IMEI fields if category is SMARTPHONE or TABLET
    qty.listen((q) {
      if (category.value == 'SMARTPHONE' || category.value == 'TABLET') {
        int quantity = int.tryParse(q) ?? 0;
        _updateImeiFields(quantity);
      } else {
        // Clear IMEI fields for non-smartphone/tablet items
        _clearImeiFields();
      }
    });
  }

  void _updateImeiFields(int quantity) {
    // Clear existing IMEI controllers
    for (var ctrl in imeiControllers) {
      ctrl.dispose();
    }
    imeiControllers.clear();
    imeiList.clear();

    // Create new IMEI controllers based on quantity
    for (int i = 0; i < quantity; i++) {
      TextEditingController ctrl = TextEditingController();
      imeiControllers.add(ctrl);
      imeiList.add('');

      // Capture the index in a local variable to avoid closure issues
      final index = i;

      // Listen to changes
      ctrl.addListener(() {
        if (index < imeiList.length) {
          imeiList[index] = ctrl.text.trim(); // Trim whitespace
        }
      });
    }
  }

  // Clear IMEI fields when category changes to non-smartphone/tablet
  void _clearImeiFields() {
    for (var ctrl in imeiControllers) {
      ctrl.dispose();
    }
    imeiControllers.clear();
    imeiList.clear();
  }

  void dispose() {
    companyController.dispose();
    modelController.dispose();
    ramController.dispose();
    romController.dispose();
    colorController.dispose();
    unitPriceController.dispose();
    qtyController.dispose();
    discountController.dispose();
    gstPercentageController.dispose();
    withoutGstAmountController.dispose();
    withGstAmountController.dispose();
    sellingPriceController.dispose();
    descriptionController.dispose();

    for (var ctrl in imeiControllers) {
      ctrl.dispose();
    }
  }
}
