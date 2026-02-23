import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/user_profile_service.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/debuggers.dart';

enum PaymentMode { fullPayment, partialPayment, emi }

class SalesCrudOperationController extends GetxController {
  @override
  void onClose() {
    // Dispose all controllers
    productDescriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    customerNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    payableAmountController.dispose();
    downPaymentController.dispose();
    paymentRetrievalDateController.dispose();
    monthlyEMIController.dispose();
    gstPercentageController.dispose();
    extraChargesController.dispose();
    accessoriesCostController.dispose();
    repairChargesController.dispose();
    totalDiscountController.dispose();
    pageController.dispose();
    super.onClose();
  }

  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;

  // Form Key
  final GlobalKey<FormState> salesFormKey = GlobalKey<FormState>();

  // Page Controller for steps
  final PageController pageController = PageController();

  // Current step
  final RxInt currentStep = 1.obs;

  // Step 1 Controllers - Product Details
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );

  final TextEditingController unitPriceController = TextEditingController();

  // Step 1 Controllers - Customer Details
  final GlobalKey<FormState> step1 = GlobalKey<FormState>();
  final GlobalKey<FormState> step2 = GlobalKey<FormState>();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  // Step 2 Controllers - Payment Details
  final TextEditingController payableAmountController = TextEditingController();
  final TextEditingController downPaymentController = TextEditingController();
  final TextEditingController paymentRetrievalDateController =
      TextEditingController();

  // selectedEMITenure

  final TextEditingController monthlyEMIController = TextEditingController();

  // Price Calculation Controllers
  final TextEditingController gstPercentageController = TextEditingController(
    text: '18',
  );
  final TextEditingController extraChargesController = TextEditingController(
    text: '0',
  );
  final TextEditingController accessoriesCostController = TextEditingController(
    text: '0',
  );
  final TextEditingController repairChargesController = TextEditingController(
    text: '0',
  );
  final TextEditingController totalDiscountController = TextEditingController(
    text: '0',
  );

  // Calculated Price Values
  final RxDouble baseAmount = 0.0.obs;
  final RxDouble amountWithoutGST = 0.0.obs;
  final RxDouble gstAmount = 0.0.obs;
  final RxDouble gstPercentage = 12.0.obs;
  final RxDouble totalPayableAmount = 0.0.obs;
  final RxDouble downPaymentAmount = 0.0.obs;
  final RxDouble remainingDuesAmount = 0.0.obs;
  final RxDouble retrievalAmount = 0.0.obs;
  final RxDouble monthlyEMI = 0.0.obs;
  // Form Values - Product Details
  final RxString selectedCategory = ''.obs;
  final RxString selectedCompany = ''.obs;
  final RxString selectedModel = ''.obs;
  final RxString selectedColor = ''.obs;
  final RxString selectedRam = ''.obs; // New RAM field
  final RxString selectedRom = ''.obs; // New ROM field
  final RxString selectedSource = ''.obs; // New Source field
  final RxString selectedEMITenure = ''.obs;
  final RxString selectedIMEINumbers = ''.obs;
  final RxString selectedpaymentRetrievalDate = ''.obs;

  // Form Values - Payment Details
  final Rx<PaymentMode> selectedPaymentMode = PaymentMode.fullPayment.obs;
  final RxString selectedPaymentMethod = ''.obs;

  // Loading States
  final RxBool isLoadingFilters = false.obs;
  final RxBool isLoadingCompanies = false.obs;
  final RxBool isLoadingModels = false.obs;
  final RxBool isLoadingCustomer = false.obs;
  final RxBool isProcessingSale = false.obs;

  // Customer states
  final RxBool customerFound = false.obs;
  Timer? _debounceTimer;

  // API data for dropdowns
  final RxList<String> categories = <String>[].obs;
  final RxList<String> companies = <String>[].obs;
  final RxList<String> models = <String>[].obs;
  final RxList<String> colorOptions = <String>[].obs;
  final RxList<String> ramOptions = <String>[].obs; // New RAM options
  final RxList<String> romOptions = <String>[].obs; // New ROM options
  final RxList<String> iMEINumbersOptiond = <String>[].obs;

  List get iMEINumbersOptiondList => iMEINumbersOptiond;
  // final RxList<String> paymentMethods =
  //     <String>['UPI', 'Cash', 'Card', 'Bank Transfer'].obs;
  final RxList<String> emiTenureOptions =
      <String>['3', '6', '9', '12', '18', '24'].obs;

  // Check if its from inventory page
  final RxBool isFromInventory = false.obs;
  InventoryItem? inventoryItem;
  @override
  void onInit() {
    super.onInit();
    checkGSTAvailability();
    // Check if we're coming from inventory page
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['fromInventory'] == true &&
          arguments['inventoryItem'] != null) {
        isFromInventory.value = true;
        inventoryItem = arguments['inventoryItem'] as InventoryItem;
        _prefillProductDetails();
      }
    }

    loadInitialFilters();

    // Listen to quantity and unit price changes for automatic calculation
    quantityController.addListener(calculatePrices);
    unitPriceController.addListener(calculatePrices);
    gstPercentageController.addListener(calculatePrices);

    calculateEMI();

    /// Auto refresh EMI on changes
    payableAmountController.addListener(calculateEMI);
    downPaymentController.addListener(calculateEMI);
    ever(selectedEMITenure, (_) => calculateEMI());
  }

  /// Check if RAM/ROM fields should be shown
  bool get shouldShowRamRomFields {
    final category = selectedCategory.value.toUpperCase();
    return category == 'SMARTPHONE' || category == 'TABLET';
  }

  /// Pre-fill product details from inventory item
  void _prefillProductDetails() {
    if (inventoryItem != null) {
      // Set the dropdown values
      selectedCategory.value = inventoryItem!.itemCategory;
      selectedCompany.value = inventoryItem!.company;
      selectedModel.value = inventoryItem!.model;
      selectedColor.value = inventoryItem!.color;

      // Set RAM and ROM if available
      if (inventoryItem!.ram != null && inventoryItem!.ram!.isNotEmpty) {
        selectedRam.value = inventoryItem!.ram!;
      }
      if (inventoryItem!.rom != null && inventoryItem!.rom!.isNotEmpty) {
        selectedRom.value = inventoryItem!.rom!;
      }
      if (inventoryItem!.imeiList != null &&
          inventoryItem!.imeiList!.isNotEmpty) {
        selectedIMEINumbers.value = inventoryItem!.imeiList!.first;
      }
      if (inventoryItem!.imeiList != null &&
          inventoryItem!.imeiList!.isNotEmpty) {
        iMEINumbersOptiond.value = inventoryItem!.imeiList!;
      }

      // Set text field values
      productDescriptionController.text = inventoryItem!.description ?? '';
      quantityController.text = '1'; // Default to 1 for selling
      unitPriceController.text = inventoryItem!.sellingPrice.toString();

      // Load companies and models for the selected category and company
      _loadDataForPrefilledItem();
    }
  }

  /// Load dropdown data for pre-filled item
  Future<void> _loadDataForPrefilledItem() async {
    try {
      // Load companies for the selected category
      if (selectedCategory.value.isNotEmpty) {
        await loadCompaniesForCategory(selectedCategory.value);

        // Load models for the selected company
        if (selectedCompany.value.isNotEmpty) {
          await loadModelsForCompany(selectedCompany.value);
        }
      }

      // Calculate initial prices
      calculatePrices();
    } catch (e) {
      log('Error loading data for pre-filled item: $e');
    }
  }

  /// Calculate prices based on inputs
  void calculatePrices() {
    try {
      // Get values with defaults
      double quantity = double.tryParse(quantityController.text) ?? 1.0;
      double unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;
      double gstPercent = double.tryParse(gstPercentageController.text) ?? 12.0;
      double extraCharges = double.tryParse(extraChargesController.text) ?? 0.0;
      double accessoriesCost =
          double.tryParse(accessoriesCostController.text) ?? 0.0;
      double repairCharges =
          double.tryParse(repairChargesController.text) ?? 0.0;
      double totalDiscount =
          double.tryParse(totalDiscountController.text) ?? 0.0;

      double downPaymentControllerValue =
          double.tryParse(downPaymentController.text) ?? 0.0;

      // Calculate base amount (quantity * unit price + extras - discount)
      // This is the total amount INCLUDING GST

      baseAmount.value =
          (quantity * unitPrice) +
          extraCharges +
          accessoriesCost +
          repairCharges -
          totalDiscount;

      // Total payable amount is same as base amount (total including GST)
      totalPayableAmount.value = baseAmount.value;

      // Calculate amount without GST using the formula:
      // Amount without GST = Total Amount / (1 + GST%/100)
      gstPercentage.value = gstPercent;
      amountWithoutGST.value = baseAmount.value / (1 + (gstPercent / 100));

      // Calculate GST amount
      gstAmount.value = baseAmount.value - amountWithoutGST.value;

      // Auto-update payable amount field for full payment
      if (selectedPaymentMode.value == PaymentMode.fullPayment) {
        payableAmountController.text = totalPayableAmount.value.toStringAsFixed(
          2,
        );
      }
    } catch (e) {
      log('Error calculating prices: $e');
    }
  }

  // Replace calculateEMI method (around line 290)
  void calculateEMI() {
    try {
      double payable = totalPayableAmount.value; // Use calculated total
      double down = double.tryParse(downPaymentController.text) ?? 0;
      int tenure = int.tryParse(selectedEMITenure.value) ?? 1;

      // Update observable values
      downPaymentAmount.value = down;
      remainingDuesAmount.value = payable - down;

      // Calculate monthly EMI
      double emi = (payable - down) / tenure;

      if (emi < 0) emi = 0;

      monthlyEMI.value = emi;
      monthlyEMIController.text = emi.toStringAsFixed(2);

      log(
        "✅ EMI Calculated: Payable=$payable, Down=$down, Tenure=$tenure, EMI=$emi",
      );
    } catch (e) {
      log("❌ Error calculating EMI: $e");
      monthlyEMI.value = 0;
      monthlyEMIController.text = "0.00";
    }
  }

  /// Load initial filter data (categories, colors, RAM, ROM, etc.)
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
        categories.value = List<String>.from(
          data['itemCategories'] ?? ['SMARTPHONE'],
        );
        ramOptions.value = List<String>.from(data['rams'] ?? []);
        romOptions.value = List<String>.from(data['roms'] ?? []);
        colorOptions.value = List<String>.from(data['colors'] ?? []);

        log("✅ Filters loaded successfully");

        // If we have pre-filled data and categories are loaded, ensure the values are available
        if (isFromInventory.value && inventoryItem != null) {
          if (!categories.contains(inventoryItem!.itemCategory)) {
            categories.add(inventoryItem!.itemCategory);
          }
          if (!colorOptions.contains(inventoryItem!.color)) {
            colorOptions.add(inventoryItem!.color);
          }
          // Add RAM and ROM if not present in options
          if (inventoryItem!.ram != null && inventoryItem!.ram!.isNotEmpty) {
            if (!ramOptions.contains(inventoryItem!.ram!)) {
              ramOptions.add(inventoryItem!.ram!);
            }
          }
          if (inventoryItem!.rom != null && inventoryItem!.rom!.isNotEmpty) {
            if (!romOptions.contains(inventoryItem!.rom!)) {
              romOptions.add(inventoryItem!.rom!);
            }
          }
        }
      } else {
        throw Exception('Failed to load filters');
      }
    } catch (error) {
      log("❌ Error loading filters: $error");
      // Set default values if API fails
      categories.value = ['SMARTPHONE'];
      ramOptions.value = [
        '1GB',
        '2GB',
        '3GB',
        '4GB',
        '6GB',
        '8GB',
        '12GB',
        '16GB',
      ];
      romOptions.value = [
        '8GB',
        '16GB',
        '32GB',
        '64GB',
        '128GB',
        '256GB',
        '512GB',
        '1TB',
      ];
    } finally {
      isLoadingFilters.value = false;
    }
  }

  /// Load companies for selected category
  Future<void> loadCompaniesForCategory(String category) async {
    try {
      isLoadingCompanies.value = true;

      // Don't clear if we're pre-filling from inventory
      if (!isFromInventory.value || selectedCompany.value.isEmpty) {
        companies.clear();
        selectedCompany.value = '';
        models.clear();
        selectedModel.value = '';
      }

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/mobiles/filters?category=${Uri.encodeComponent(category)}',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        companies.value = List<String>.from(data['companies'] ?? []);

        // If we have pre-filled data, ensure the company is available
        if (isFromInventory.value && inventoryItem != null) {
          if (!companies.contains(inventoryItem!.company)) {
            companies.add(inventoryItem!.company);
          }
        }

        log("✅ Companies loaded for category: $category");
      } else {
        throw Exception('Failed to load companies for category: $category');
      }
    } catch (error) {
      log("❌ Error loading companies: $error");
    } finally {
      isLoadingCompanies.value = false;
    }
  }

  /// Load models for selected company
  Future<void> loadModelsForCompany(String company) async {
    try {
      isLoadingModels.value = true;

      // Don't clear if we're pre-filling from inventory
      if (!isFromInventory.value || selectedModel.value.isEmpty) {
        models.clear();
        selectedModel.value = '';
      }

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/mobiles/filters?company=${Uri.encodeComponent(company)}',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        models.value = List<String>.from(data['models'] ?? []);

        // If we have pre-filled data, ensure the model is available
        if (isFromInventory.value && inventoryItem != null) {
          if (!models.contains(inventoryItem!.model)) {
            models.add(inventoryItem!.model);
          }
        }

        log("✅ Models loaded for company: $company");
      } else {
        throw Exception('Failed to load models for company: $company');
      }
    } catch (error) {
      log("❌ Error loading models: $error");
    } finally {
      isLoadingModels.value = false;
    }
  }

  /// Fetch customer details by phone number
  Future<void> fetchCustomerByPhone(String phone) async {
    if (phone.length < 10) return;

    try {
      isLoadingCustomer.value = true;
      customerFound.value = false;

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/customers/getCustomerByPhoneAndShop?phone=$phone',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'Success' && data['payload'] != null) {
          final customer = data['payload'];

          // Auto-fill customer details
          customerNameController.text = customer['name'] ?? '';
          emailController.text = customer['email'] ?? '';
          addressController.text = customer['defaultAddress'] ?? '';
          cityController.text = customer['location'] ?? '';
          stateController.text = customer['state'] ?? '';
          pincodeController.text = customer['pincode'] ?? '';

          customerFound.value = true;

          Get.snackbar(
            'Customer Found',
            'Customer details loaded automatically',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          log("✅ Customer found and details loaded");
        }
      }
    } catch (error) {
      log("❌ Error fetching customer: $error");
      customerFound.value = false;
    } finally {
      isLoadingCustomer.value = false;
    }
  }

  /// Handle category selection
  void onCategoryChanged(String category) {
    selectedCategory.value = category;
    selectedCompany.value = '';
    selectedModel.value = '';

    // Clear RAM and ROM when category changes
    if (!shouldShowRamRomFields) {
      selectedRam.value = '';
      selectedRom.value = '';
    }

    if (category.isNotEmpty) {
      loadCompaniesForCategory(category);
    } else {
      companies.clear();
      models.clear();
    }
  }

  // Add these properties at the top of your controller class
  final RxBool shouldShowGST = false.obs;
  final RxString shopGSTNumber = ''.obs;
  final RxString itemSource = ''.obs;

  // Add this method in your controller
  Future<void> checkGSTAvailability() async {
    try {
      // Get shop GST number from UserProfileService

      final userProfileService = Get.find<UserProfileService>();
      final shopData = Get.find<DashboardController>();
      final profileData = await userProfileService.getUserProfileData();

      // shopGSTNumber.value = profileData['gstNumber'] ?? '';
      shopGSTNumber.value = shopData.shopGSTNumber.value;

      // Get inventory item from arguments
      final InventoryItem item = Get.arguments['inventoryItem'];
      itemSource.value = item.source ?? '';

      // Show GST only if:
      // 1. Shop has GST number
      // 2. Item source is "OFFLINE"
      shouldShowGST.value =
          shopGSTNumber.value.isNotEmpty &&
          itemSource.value.toUpperCase() == 'OFFLINE';

      // If GST should not be shown, set GST percentage to 0
      if (!shouldShowGST.value) {
        gstPercentageController.text = '0';
        gstPercentage.value = 0.0;
      } else {
        // Set default GST if needed (e.g., 18%)
        if (gstPercentageController.text.isEmpty) {
          gstPercentageController.text = '18';
          gstPercentage.value = 18.0;
        }
      }

      calculatePrices();
    } catch (e) {
      log("❌ Error checking GST availability: $e");
      shouldShowGST.value = false;
      gstPercentageController.text = '0';
      gstPercentage.value = 0.0;
    }
  }

  /// Handle company selection
  void onCompanyChanged(String company) {
    selectedCompany.value = company;
    selectedModel.value = '';

    if (company.isNotEmpty) {
      loadModelsForCompany(company);
    } else {
      models.clear();
    }
  }

  /// Handle model selection
  void onModelChanged(String model) {
    selectedModel.value = model;
  }

  /// Handle color selection
  void onColorChanged(String color) {
    selectedColor.value = color;
  }

  /// Handle RAM selection
  void onRamChanged(String ram) {
    selectedRam.value = ram;
  }

  /// Handle ROM selection
  void onRomChanged(String rom) {
    selectedRom.value = rom;
  }

  //on change imei numbers
  void onIMEINumbersChanged(String imeiNumbers) {
    selectedIMEINumbers.value = imeiNumbers;
  }

  /// Handle quantity and unit price changes
  void onQuantityChanged(String value) {
    calculatePrices();
  }

  void onUnitPriceChanged(String value) {
    calculatePrices();
  }

  /// Handle payment mode selection
  void onPaymentModeChanged(PaymentMode mode) {
    selectedPaymentMode.value = mode;
    // Clear payment method when mode changes
    selectedPaymentMethod.value = '';
    payableAmountController.clear();
    downPaymentController.clear();
    paymentRetrievalDateController.clear();
    selectedEMITenure.value = '';
    monthlyEMIController.clear();

    // Recalculate prices
    calculatePrices();
  }

  /// Handle payment method selection
  void onPaymentMethodChanged(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Handle EMI tenure selection
  void onEMITenureChanged(String tenure) {
    selectedEMITenure.value = tenure;
  }

  /// Handle phone number input with debouncing
  void onPhoneNumberChanged(String phone) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (phone.length >= 10) {
        fetchCustomerByPhone(phone);
      }
    });
  }

  /// Select payment retrieval date
  Future<void> selectPaymentRetrievalDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      // Store in dd-MM-yyyy format for display
      paymentRetrievalDateController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";

      selectedpaymentRetrievalDate.value = paymentRetrievalDateController.text;
    }
  }

  /// Check if category is selected
  bool get isCategorySelected => selectedCategory.value.isNotEmpty;

  /// Check if company is selected
  bool get isCompanySelected => selectedCompany.value.isNotEmpty;

  /// Navigation methods
  void goToStep2() {
    if (step1.currentState!.validate()) {
      currentStep.value = 2;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToStep1() {
    currentStep.value = 1;
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Validate Step 1
  bool validateStep1() {
    // Validate product details
    if (selectedCategory.value.isEmpty) {
      Get.snackbar('Error', 'Please select a category');
      return false;
    }
    if (selectedCompany.value.isEmpty) {
      Get.snackbar('Error', 'Please select a company');
      return false;
    }
    if (selectedModel.value.isEmpty) {
      Get.snackbar('Error', 'Please select a model');
      return false;
    }
    if (selectedColor.value.isEmpty) {
      Get.snackbar('Error', 'Please select a color');
      return false;
    }

    // Validate RAM and ROM for smartphones and tablets
    if (shouldShowRamRomFields) {
      if (selectedRam.value.isEmpty) {
        Get.snackbar('Error', 'Please select RAM');
        return false;
      }
      if (selectedRom.value.isEmpty) {
        Get.snackbar('Error', 'Please select Storage (ROM)');
        return false;
      }
    }

    if (quantityController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter quantity');
      return false;
    }
    if (unitPriceController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter unit price');
      return false;
    }

    // Validate customer details
    if (customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter customer name');
      return false;
    }
    if (phoneNumberController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter phone number');
      return false;
    }
    if (addressController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter address');
      return false;
    }
    if (cityController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter city');
      return false;
    }
    if (stateController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter state');
      return false;
    }
    if (pincodeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter pincode');
      return false;
    }
    if (pincodeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter pincode');
      return false;
    }
    return true;
  }

  /// Complete sale
  Future<void> completeSale() async {
    if (!validateStep2()) return;

    try {
      isProcessingSale.value = true;

      // Prepare sale data according to API format
      Map<String, dynamic> saleData = {
        'shopName': AppConfig.shopName.value,
        'totalAmount': totalPayableAmount.value,
        'amountWithGst': totalPayableAmount.value,
        'amountWithoutGst': amountWithoutGST.value,
        'gstPercentage': num.parse(gstPercentageController.text),
        'isPaid': selectedPaymentMode.value == PaymentMode.fullPayment,
        'paymentMode': _getPaymentModeString(),
        'paymentMethod': selectedPaymentMethod.value.toUpperCase(),
        'downPayment': _getDownPaymentAmount(),
        'extraCharges': num.parse(extraChargesController.text),
        'accessoriesCost': num.parse(accessoriesCostController.text),
        'repairCharges': num.parse(repairChargesController.text),
        'totalDiscount': num.parse(totalDiscountController.text),
        'totalPayableAmount': totalPayableAmount.value,
        'paymentRetriableDate': _getPaymentRetriableDate(),

        // ✔️ CUSTOMER (Corrected)
        'customer': {
          'name': customerNameController.text,
          'primaryPhone': phoneNumberController.text,
          'primaryAddress': addressController.text,
          'email':
              emailController.text.isEmpty
                  ? null
                  : emailController.text, // FIXED
          'location': cityController.text,
          'state': stateController.text,
          'pincode': pincodeController.text,
        },

        // ✔️ ITEMS (Corrected to match Web JSON)
        'items': [
          {
            'itemCategory': selectedCategory.value,
            'model': selectedModel.value,
            'company': selectedCompany.value,
            'ram': selectedRam.value,
            'rom': selectedRom.value,
            'color': selectedColor.value,
            'quantity': int.parse(quantityController.text),
            'sellingPrice': num.parse(unitPriceController.text), // FIXED
            'source': "offline", // FIXED
            'imei': selectedIMEINumbers.value.toString(), // FIXED
          },
        ],
      };

      // ✔️ EMI block remains same
      if (_getPaymentModeString() == "EMI") {
        saleData['emi'] = {
          'monthlyEmi': num.parse(selectedEMITenure.value),
          'totalMonths': num.parse(monthlyEMIController.text),
        };
      }

      printMapWithTypesAll(saleData);

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/api/sales/create',
        dictParameter: saleData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        final responseData = response.data;
        Get.find<SalesManagementController>().refreshData();

        await Future.wait([
          refreshBills(),
          refreshInventory(),
          refreshDues(),
          refreshThisMonthStock(),
        ]);

        gotoSellScreen();

        // Get.snackbar(
        //   'Success',
        //   'Sale completed successfully! Invoice: ${responseData['invoiceNumber']}',
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: const Color(0xFF10B981),
        //   colorText: Colors.white,
        //   icon: const Icon(Icons.check_circle, color: Colors.white),
        //   margin: const EdgeInsets.all(16),
        //   borderRadius: 12,
        //   duration: const Duration(seconds: 4),
        // );

        resetForm();
      } else {
        throw Exception('Failed to complete sale: ${response?.statusCode}');
      }
    } catch (error) {
      log("❌ Error completing sale: $error");
      // Get.snackbar(
      //   'Error',
      //   'Failed to complete sale. Please try again.',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   icon: const Icon(Icons.error, color: Colors.white),
      //   margin: const EdgeInsets.all(16),
      //   borderRadius: 12,
      // );
    } finally {
      isProcessingSale.value = false;
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
      title: 'Sold Item',

      description: 'Sale completed successfully',
      onPressed: () {
        final navCtrl = Get.find<BottomNavigationController>();
        navCtrl.setIndex(3);
        Get.back();
        Get.back();
      },
    );
  }

  // Helper method to get payment mode string
  String _getPaymentModeString() {
    switch (selectedPaymentMode.value) {
      case PaymentMode.fullPayment:
        return 'FULL';
      case PaymentMode.partialPayment:
        return 'DUES';
      case PaymentMode.emi:
        return 'EMI';
    }
  }

  // Helper method to get down payment amount
  double _getDownPaymentAmount() {
    switch (selectedPaymentMode.value) {
      case PaymentMode.fullPayment:
        return totalPayableAmount.value;
      case PaymentMode.partialPayment:
      case PaymentMode.emi:
        return double.tryParse(downPaymentController.text) ?? 0.0;
    }
  }

  // Helper method to get payment retriable date
  String _getPaymentRetriableDate() {
    if (selectedPaymentMode.value == PaymentMode.partialPayment) {
      return convertDateFormat(paymentRetrievalDateController.text);
    }
    return '';
  }

  // /// Validate Step 2
  // bool validateStep2() {
  //   if (selectedPaymentMethod.value.isEmpty) {
  //     Get.snackbar('Error', 'Please select payment method');
  //     return false;
  //   }

  //   switch (selectedPaymentMode.value) {
  //     case PaymentMode.fullPayment:
  //       if (payableAmountController.text.isEmpty) {
  //         Get.snackbar('Error', 'Please enter payable amount');
  //         return false;
  //       }
  //       break;
  //     case PaymentMode.partialPayment:
  //       if (downPaymentController.text.isEmpty) {
  //         Get.snackbar('Error', 'Please enter down payment');
  //         return false;
  //       }
  //       if (paymentRetrievalDateController.text.isEmpty) {
  //         Get.snackbar('Error', 'Please select payment retrieval date');
  //         return false;
  //       }
  //       break;
  //     case PaymentMode.emi:
  //       if (downPaymentController.text.isEmpty) {
  //         Get.snackbar('Error', 'Please enter down payment');
  //         return false;
  //       }
  //       if (selectedEMITenure.value.isEmpty) {
  //         Get.snackbar('Error', 'Please select EMI tenure');
  //         return false;
  //       }
  //       if (monthlyEMIController.text.isEmpty) {
  //         Get.snackbar('Error', 'Please enter monthly EMI amount');
  //         return false;
  //       }
  //       break;
  //   }

  //   return true;
  // }
  validateStep2() {
    if (step2.currentState!.validate() == false) {
      return false;
    }

    return true;
  }

  /// Form validators
  String? validateCategory(String? value) {
    return value == null || value.isEmpty ? 'Please select a category' : null;
  }

  String? validateCompany(String? value) {
    return value == null || value.isEmpty ? 'Please select a company' : null;
  }

  String? validateModel(String? value) {
    return value == null || value.isEmpty ? 'Please select a model' : null;
  }

  String? validateColor(String? value) {
    return value == null || value.isEmpty ? 'Please select a color' : null;
  }

  String? validateIMEINumbers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter IMEI number';
    }
    if (value.length < 15) {
      return 'Please enter valid IMEI number';
    }
    return null;
  }

  String? validateRam(String? value) {
    return value == null || value.isEmpty
        ? 'Please select a Ram Varient'
        : null;
  }

  String? validateRom(String? value) {
    return value == null || value.isEmpty
        ? 'Please select a Rom Varient'
        : null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'Please enter valid quantity';
    }
    return null;
  }

  String? validateUnitPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter unit price';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter valid price';
    }
    return null;
  }

  String? validateE(String? value) {
    return value == null || value.isEmpty ? 'Please enter customer name' : null;
  }

  String? validateCustomerName(String? value) {
    return value == null || value.isEmpty ? 'Please enter customer name' : null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length < 10) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'Please enter valid email';
      }
    }
    return null;
  }

  String? validateAddress(String? value) {
    return value == null || value.isEmpty ? 'Please enter address' : null;
  }

  String? validateCity(String? value) {
    return value == null || value.isEmpty ? 'Please enter city' : null;
  }

  String? validateState(String? value) {
    return value == null || value.isEmpty ? 'Please enter state' : null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pincode';
    }
    if (value.length != 6) {
      return 'Please enter valid pincode';
    }
    return null;
  }

  String? validatePaymentMethod(String? value) {
    return value == null || value.isEmpty
        ? 'Please select payment method'
        : null;
  }

  String? validatePayableAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter payable amount';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter valid amount';
    }
    return null;
  }

  String? validateDownPayment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter down payment';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter valid amount';
    }
    if (double.parse(value) > totalPayableAmount.value) {
      return 'Down payment cannot exceed payable amount';
    }
    return null;
  }

  String? validatePaymentRetrievalDate(String? value) {
    return value == null || value.isEmpty ? 'Please select date' : null;
  }

  String? validateEMITenure(String? value) {
    return value == null || value.isEmpty ? 'Please select EMI tenure' : null;
  }

  String? validateMonthlyEMI(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter monthly EMI';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter valid amount';
    }
    return null;
  }

  /// Reset form
  void resetForm() {
    salesFormKey.currentState?.reset();

    // Reset step
    currentStep.value = 1;

    // Reset product details
    selectedCategory.value = '';
    selectedCompany.value = '';
    selectedModel.value = '';
    selectedRam.value = '';
    selectedRom.value = '';
    selectedColor.value = '';
    productDescriptionController.clear();
    quantityController.text = '1';
    unitPriceController.clear();

    // Reset customer details
    customerNameController.clear();
    phoneNumberController.clear();
    emailController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    customerFound.value = false;

    // Reset payment details
    selectedPaymentMode.value = PaymentMode.fullPayment;
    selectedPaymentMethod.value = '';
    payableAmountController.clear();
    downPaymentController.clear();
    paymentRetrievalDateController.clear();
    selectedEMITenure.value = '';
    monthlyEMIController.clear();

    // Reset price calculation fields
    gstPercentageController.text = '18';
    extraChargesController.text = '0';
    accessoriesCostController.text = '0';
    repairChargesController.text = '0';
    totalDiscountController.text = '0';

    // Reset calculated values
    baseAmount.value = 0.0;
    amountWithoutGST.value = 0.0;
    gstAmount.value = 0.0;
    gstPercentage.value = 12.0;
    totalPayableAmount.value = 0.0;

    // Reset dropdown lists
    companies.clear();
    models.clear();
    ramOptions.clear();
    romOptions.clear();

    // Reset inventory state
    isFromInventory.value = false;
    inventoryItem = null;

    // Reset page controller
    pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
