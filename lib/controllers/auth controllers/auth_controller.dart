import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/models/auth/gst%20model/gst_response_model.dart';
import 'package:smartbecho/models/auth/login_model.dart';
import 'package:smartbecho/models/auth/signup_model.dart';
import 'package:smartbecho/models/auth/signup_response_model.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/permission_storage.dart';
import 'package:smartbecho/models/permission%20handal%20models/permission_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_error_handler.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/cookie_extractor.dart';
import 'package:smartbecho/services/route_services.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/services/user_profile_service.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/utils/toasts.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/views/auth/forgot_password_otp.dart';

class AuthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Separate GlobalKeys for each form
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  // Multi-step signup
  final RxInt currentStep = 1.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool subscribeToNewsletter = false.obs;

  // Basic Information Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shopStoreNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController adhaarNumberController = TextEditingController();

  // Address Controllers
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();

  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController(
    text: 'India',
  );

  // Legacy controllers for backward compatibility
  final TextEditingController streetController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();

  // Social Media Links
  final RxList<Map<String, dynamic>> socialMediaLinks =
      <Map<String, dynamic>>[].obs;

  // Shop Images - ONLY ONE IMAGE ALLOWED
  final Rx<File?> shopImage = Rx<File?>(null);
  final Rx<File?> userProfilePhoto = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // Animation Controller
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Track if controller is disposed
  bool _isDisposed = false;

  // API service instance
  final ApiServices _apiService = ApiServices();

  // App config instance
  final AppConfig _config = AppConfig.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeDefaultValues();
    _config.printConfig();
  }

  @override
  void onReady() {
    super.onReady();
    resetAnimations();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );
  }

  void _initializeDefaultValues() {
    // Set default country
    countryController.text = 'India';

    // Initialize with empty social media links
    socialMediaLinks.clear();

    // Initialize with null shop image
    shopImage.value = null;
    userProfilePhoto.value = null;
  }

  void resetAnimations() {
    if (!_isDisposed &&
        (animationController.isCompleted || animationController.isDismissed)) {
      animationController.reset();
      animationController.forward();
    }
  }

  // Multi-step navigation methods
  void nextStep() {
    if (currentStep.value < 5) {
      if (_validateCurrentStep()) {
        currentStep.value++;
        resetAnimations();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
      resetAnimations();
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 1:
        return signupFormKey.currentState?.validate() ?? false;
      case 2:
        return addressFormKey.currentState?.validate() ?? false;
      case 3:
        return true; // Social media links are optional
      case 4:
        // BOTH shop image AND user profile photo are REQUIRED
        if (shopImage.value == null) {
          ToastHelper.error(message: 'Please select a shop image');

          return false;
        }
        if (userProfilePhoto.value == null) {
          ToastHelper.error(message: 'Please select a profile photo');

          return false;
        }
        return true;
      case 5:
        // Terms and conditions must be checked
        if (!agreeToTerms.value) {
          ToastHelper.error(message: 'Please agree to terms and conditions');

          return false;
        }
        return true;
      default:
        return false;
    }
  }

  // Social Media Links Methods
  void addSocialMediaLink() {
    if (socialMediaLinks.length < 5) {
      socialMediaLinks.add({
        'platform': 'facebook',
        'controller': TextEditingController(),
        'url': '',
      });
    }
  }

  void removeSocialMediaLink(Map<String, dynamic> link) {
    link['controller']?.dispose();
    socialMediaLinks.remove(link);
  }

  // Shop Image Methods - ONLY ONE IMAGE
  Future<void> addShopImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        shopImage.value = File(pickedFile.path);
      }
    } catch (e) {
      log('Failed to pick image: ${e.toString()}');
    }
  }

  void removeShopImage() {
    shopImage.value = null;
  }

  Future<void> addUserProfilePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        userProfilePhoto.value = File(pickedFile.path);
      }
    } catch (e) {
      log('Failed to pick profile photo: ${e.toString()}');
    }
  }

  void removeUserProfilePhoto() {
    userProfilePhoto.value = null;
  }

  // Navigation methods
  void goToLogin() {
    Get.offNamed(AppRoutes.login)!.then((_) {
      if (Get.isRegistered<AuthController>() && !_isDisposed) {
        clearControllers();
      }
    });
  }

  void goToSignup() {
    Get.toNamed('/signup')!.then((_) {
      if (Get.isRegistered<AuthController>() && !_isDisposed) {
        clearControllers();
      }
    });
  }

  void goToResetPassword() {
    if (emailController.text.isEmpty) {
      ToastHelper.error(message: 'Email is required');
    } else {
      Get.toNamed('/reset-password');
    }
  }

  void clearControllers() {
    try {
      if (!_isDisposed) {
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        nameController.clear();
        shopStoreNameController.clear();
        gstNumberController.clear();
        adhaarNumberController.clear();
        contactPersonController.clear();
        phoneNumberController.clear();
        panNumberController.clear();
        addressLine1Controller.clear();
        addressLine2Controller.clear();
        landmarkController.clear();
        cityController.clear();
        stateController.clear();
        pincodeController.clear();
        countryController.clear();
        streetController.clear();
        zipcodeController.clear();

        // Clear social media links
        for (var link in socialMediaLinks) {
          link['controller']?.dispose();
        }
        socialMediaLinks.clear();

        // Clear shop image
        shopImage.value = null;
        userProfilePhoto.value = null;

        // Reset step and checkboxes
        currentStep.value = 1;
        agreeToTerms.value = false;
        subscribeToNewsletter.value = false;
      }
    } catch (e) {
      print('Controllers already disposed: $e');
    }
  }

  void clearAndNavigateToLogin() {
    clearControllers();
    Get.offNamed('/login');
  }

  void clearAndNavigateToSignup() {
    clearControllers();
    Get.offNamed('/signup');
  }

  // Toggle methods
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number & special char';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateShopStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shop store name is required';
    }
    if (value.length < 2) {
      return 'Shop store name must be at least 2 characters';
    }
    return null;
  }

  // GST Number validation - OPTIONAL
  String? validateGSTNumber(String? value) {
    // GST optional hai
    if (value == null || value.isEmpty) {
      return null;
    }

    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
    );

    if (!gstRegex.hasMatch(value)) {
      return 'Please enter a valid GST number (e.g., 27ABCDE1234F1Z5)';
    }

    return null;
  }

  String? validateAdhaarNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    // Aadhaar number validation (12 digits)
    if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return 'Please enter a valid 12-digit Aadhaar number';
    }
    return null;
  }

  String? validateContactPerson(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact person name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove any spaces or special characters for validation
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address line 1 is required';
    }
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    if (value.length < 2) {
      return 'City must be at least 2 characters';
    }
    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    if (value.length < 2) {
      return 'State must be at least 2 characters';
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }
    if (value.length < 2) {
      return 'Country must be at least 2 characters';
    }
    return null;
  }

  // Legacy validation methods for backward compatibility
  String? validateStreet(String? value) {
    return validateAddressLine1(value);
  }

  String? validateZipcode(String? value) {
    return validatePincode(value);
  }

  // Auth methods
  // Login
  Future<void> login(BuildContext context) async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      Map<String, dynamic> loginParameters = {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.loginEndpoint,
        dictParameter: loginParameters,
        authToken: false,
        // showToast: true,
      );

      if (response != null) {
        // Check if response is successful (200)
        if (response.statusCode == 200) {
          try {
            await CookieExtractor.extractAndSaveJSessionId(response);
            LoginResponse loginResponse = LoginResponse.fromJson(response.data);

            if (loginResponse.isSuccess && loginResponse.payload != null) {
              String userToken = loginResponse.payload!.userToken;
              String refreshToken = loginResponse.payload!.refreshToken;
              String loginDate = loginResponse.payload!.loginDate;

              // Save JWT Token
              await SharedPreferencesHelper.setJwtToken(userToken);

              // 🔥 IMPORTANT: Save Refresh Token to Secure Storage
              await SecureStorageHelper.setRefreshToken(refreshToken);

              await SharedPreferencesHelper.setLoginDate(loginDate);
              await SharedPreferencesHelper.setIsLoggedIn(true);

              // Save username/email
              if (loginParameters.containsKey('email')) {
                await SharedPreferencesHelper.setUsername(
                  loginParameters['email'],
                );
              }

              // Optional: Save token expiry time (if your API provides it)
              // if (loginResponse.payload!.expiresIn != null) {
              //   int expiresInSeconds = loginResponse.payload!.expiresIn!;
              //   DateTime expiryTime = DateTime.now().add(Duration(seconds: expiresInSeconds));
              //   await SecureStorageHelper.setTokenExpiry(expiryTime);
              // }

              // ✅ Show CUSTOM success toast (not server message)
              if (context.mounted) {
                ToastHelper.success(message: 'Login Successful');
              }
              RouteService.toBottomNavigation();
              await _loadPermissionsAfterLogin();

              log("✅ Login successful - Tokens saved");
            } else {
              // Status 200 but login failed in response
              log("⚠️ Login failed - Invalid credentials or server error");
              if (context.mounted) {
                // Extract and show server error message
                String errorMessage = loginResponse.message ?? 'Login failed';
                ToastHelper.error(message: errorMessage);
              }
            }
          } catch (parseError) {
            // Handle JSON parsing or data extraction errors
            log('❌ Error parsing login response: $parseError');
            if (context.mounted) {
              ToastHelper.error(
                message: 'Login failed: Invalid response from server',
              );
            }
          }
        } else {
          ApiErrorHandler.handleResponse(response, showToast: true);
          log('⚠️ Login failed - Status Code: ${response.statusCode}');
        }
      }
    } on dio.DioException catch (e) {
      // ignore: use_build_context_synchronously
      ApiErrorHandler.handleError(e, showToast: true);
      log("error : ${e.toString()}");
      ToastHelper.error(message: e.toString());

      return;
    } catch (e) {
      ApiErrorHandler.handleError(e, showToast: true);
      ToastHelper.error(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPermissionsAfterLogin() async {
    try {
      log('📥 [AuthController] Loading permissions...');

      // ========================================================================
      // STEP 1: Fetch permissions from API
      // ========================================================================
      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.permissionsEndpoint,

        authToken: true,
      );

      if (response == null || response.statusCode != 200) {
        log('⚠️ [AuthController] Failed to fetch permissions');
        return;
      }

      log('✅ [AuthController] Permissions response received');

      // ========================================================================
      // STEP 2: Parse permission response
      // ========================================================================
      final permissionModel = PermissionResponseModel.fromJson(response.data);

      log(
        '📊 [AuthController] Features: ${permissionModel.payload?.features.length ?? 0}',
      );
      log(
        '📊 [AuthController] Sections: ${permissionModel.payload?.sectionPermissions.length ?? 0}',
      );

      // ========================================================================
      // STEP 3: Save to storage
      // ========================================================================
      await PermissionStorage().save(permissionModel);

      log('✅ [AuthController] Permissions saved to storage');

      // ========================================================================
      // STEP 4: Load into FeatureController
      // ========================================================================
      if (Get.isRegistered<FeatureController>()) {
        final controller = Get.find<FeatureController>();
        await controller.loadFromResponse(permissionModel);
        log('✅ [AuthController] Permissions loaded into controller');
        log('   ├─ Total features: ${controller.getAllFeatures().length}');
        log('   └─ Total sections: ${controller.getAllSections().length}');
      } else {
        log('⚠️ [AuthController] FeatureController not registered');
      }
    } catch (e) {
      log('⚠️ [AuthController] Permission loading error: $e');
      // Don't block login if permissions fail
    }
  }

  // AuthController class mein ye method add karo
  Future<void> loadPermissionsAfterLogin() async {
    try {
      // 1. Fetch permissions from API
      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.permissionsEndpoint,
        authToken: true, // JWT token use karega
      );

      if (response != null && response.statusCode == 200) {
        // 2. Parse and save to storage
        final permissionModel = PermissionResponseModel.fromJson(response.data);
        await PermissionStorage().save(permissionModel);

        // 3. Load into FeatureController
        if (Get.isRegistered<FeatureController>()) {
          await Get.find<FeatureController>().loadPermissions();
          log("✅ Permissions loaded successfully");
        }
      }
    } catch (e) {
      log("⚠️ Failed to load permissions: $e");
      // Don't block login if permissions fail
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await SharedPreferencesHelper.clearAll();
      await SecureStorageHelper.deleteJSessionId();
      RouteService.logout();
      ToastHelper.success(
        message: 'Success',
        description: 'Logged out successfully',
      );
    } catch (e) {
      ToastHelper.error(
        message: 'Error',
        description: 'Logout failed: ${e.toString()}',
      );
    }
  }

  //  ##########  GST API ############/

  // Add these to your existing AuthController class

  // Add these observables at the top with other RxBool declarations
  final RxBool isGstValidating = false.obs;
  final RxBool isGstValid = false.obs;
  final RxString gstValidationMessage = ''.obs;

  // GST API Key - Add this to your AppConfig or here
  final String _gstApiKey =
      'your-api-key-here'; // Replace with your actual API key

  // Add this method to validate and fetch GST details
  Future<void> validateAndFetchGstDetails(String gstNumber) async {
    // Clear previous validation state
    isGstValid.value = false;
    gstValidationMessage.value = '';

    // Check if GST number is valid format (15 characters)
    if (gstNumber.length != 15) {
      return; // Don't validate if not 15 characters
    }

    // Validate GST format using regex
    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
    );

    if (!gstRegex.hasMatch(gstNumber)) {
      gstValidationMessage.value = 'Invalid GST format';
      return;
    }

    try {
      isGstValidating.value = true;

      // API URL
      final String apiUrl = '${_config.gstValidationUrl}/$gstNumber';
      // 'http://sheet.gstincheck.co.in/check/$_gstApiKey/$gstNumber';

      // Make API call
      dio.Response? response = await _apiService.requestGetForApi(
        url: apiUrl,
        authToken: false,
      );

      if (response != null && response.statusCode == 200) {
        // Parse response
        GstResponseModel gstResponse = GstResponseModel.fromJson(response.data);

        if (gstResponse.flag && gstResponse.data != null) {
          // GST is valid
          isGstValid.value = true;
          gstValidationMessage.value = 'GST verified successfully';

          // Auto-fill address fields
          _autoFillFromGstData(gstResponse.data!);
          final pan = extractPanFromGst(gstNumber);
          panNumberController.text = pan;

          // Show success message
          ToastHelper.success(
            message: 'GST verified and address fields auto-filled',
          );
          log('GST verified and address fields auto-filled');
        } else {
          // GST not found or invalid
          isGstValid.value = false;
          gstValidationMessage.value = gstResponse.message;
          log('Invalid GST');
          ToastHelper.success(message: 'Invalid GST');
        }
      } else {
        gstValidationMessage.value = 'Failed to verify GST';
        log('Failed to verify GST');
      }
    } catch (e) {
      log('GST validation error: $e');
      gstValidationMessage.value = 'Error verifying GST';
      ToastHelper.warning(message: 'Failed to verify GST. Please try again.');
    } finally {
      isGstValidating.value = false;
    }
  }

  String extractPanFromGst(String gst) {
    return gst.substring(2, 12);
  }

  // Auto-fill address and other fields from GST data
  void _autoFillFromGstData(GstData gstData) {
    try {
      // Fill shop store name from trade name
      if (gstData.tradeNam.isNotEmpty && shopStoreNameController.text.isEmpty) {
        shopStoreNameController.text = gstData.tradeNam;
      }

      // Fill contact person name from legal name
      if (gstData.lgnm.isNotEmpty && contactPersonController.text.isEmpty) {
        contactPersonController.text = gstData.lgnm;
      }

      // Fill address fields if address data exists
      if (gstData.pradr?.addr != null) {
        final addr = gstData.pradr!.addr!;

        // Address Line 1: Building number + Building name + Street
        List<String> addressParts = [];
        if (addr.bno.isNotEmpty && addr.bno != '0') {
          addressParts.add(addr.bno);
        }
        if (addr.bnm.isNotEmpty) {
          addressParts.add(addr.bnm);
        }
        if (addr.st.isNotEmpty) {
          addressParts.add(addr.st);
        }

        if (addressParts.isNotEmpty && addressLine1Controller.text.isEmpty) {
          addressLine1Controller.text = addressParts.join(', ');
        }

        // Address Line 2: Floor number if available
        if (addr.flno.isNotEmpty && addressLine2Controller.text.isEmpty) {
          addressLine2Controller.text = 'Floor: ${addr.flno}';
        }

        // Landmark: Location
        if (addr.loc.isNotEmpty && landmarkController.text.isEmpty) {
          landmarkController.text = addr.loc;
        }

        // City
        if (addr.dst.isNotEmpty && cityController.text.isEmpty) {
          cityController.text = addr.dst;
        }

        // State
        if (addr.stcd.isNotEmpty && stateController.text.isEmpty) {
          stateController.text = addr.stcd;
        }

        // Pincode
        if (addr.pncd.isNotEmpty && pincodeController.text.isEmpty) {
          pincodeController.text = addr.pncd;
        }
      }

      log('✅ Auto-filled address from GST data');
    } catch (e) {
      log('❌ Error auto-filling from GST data: $e');
    }
  }

  // Optional: Method to clear GST validation state
  void clearGstValidation() {
    isGstValid.value = false;
    isGstValidating.value = false;
    gstValidationMessage.value = '';
  }

  //  ##########  GST API ############/

  Future<void> signup(BuildContext context) async {
    // 1️⃣ Terms check
    if (!agreeToTerms.value) {
      ToastCustom.errorToast(context, 'Please agree to terms and conditions');
      return;
    }

    try {
      isLoading.value = true;

      /// 2️⃣ Build REQUEST JSON (THIS IS MOST IMPORTANT)
      final Map<String, dynamic> requestJson = {
        "shopStoreName": shopStoreNameController.text.trim(),
        "email": emailController.text.trim(),
        // "name": nameController.text.trim(),
        "name": contactPersonController.text.trim(),
        "phone": phoneNumberController.text.trim(),
        "pan": panNumberController.text.trim(),
        "password": passwordController.text.trim(),
        // "status": 1,
        "adhaarNumber": adhaarNumberController.text.trim(),
        "shopGstNumber": gstNumberController.text.trim().toUpperCase(),
        "shopAddress": {
          "label": "Shop Address",
          "addressLine1": addressLine1Controller.text.trim(),
          "addressLine2": addressLine2Controller.text.trim(),
          "city": cityController.text.trim(),
          "state": stateController.text.trim(),
          "pincode": pincodeController.text.trim(),
          "country": countryController.text.trim(),
          // "landmark": landmarkController.text.trim(),
        },
        "socialMediaLinks":
            socialMediaLinks
                .where((e) => e['controller']?.text?.trim().isNotEmpty == true)
                .map(
                  (e) => {
                    "platform": e['platform'].toString().toLowerCase(),
                    "url": e['controller'].text.trim(),
                  },
                )
                .toList(),
      };

      /// 3️⃣ Create FormData
      final formData = dio.FormData();

      // /// 🔥 VERY IMPORTANT: backend expects this key
      formData.fields.add(MapEntry('request', jsonEncode(requestJson)));

      if (shopImage.value != null && await shopImage.value!.exists()) {
        try {
          String extension =
              shopImage.value!.path.split('.').last.toLowerCase();
          String fileName = 'shop_image.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') contentType = 'image/png';

          formData.files.add(
            MapEntry(
              'shopPhoto',
              await dio.MultipartFile.fromFile(
                shopImage.value!.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          print('Added image file: $fileName');
        } catch (fileError) {
          print('Error processing image file: $fileError');
        }
      }

      if (userProfilePhoto.value != null &&
          await userProfilePhoto.value!.exists()) {
        try {
          String extension =
              userProfilePhoto.value!.path.split('.').last.toLowerCase();
          String fileName = 'user_profile_photo.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') contentType = 'image/png';

          formData.files.add(
            MapEntry(
              'userProfilePhoto',
              await dio.MultipartFile.fromFile(
                userProfilePhoto.value!.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          print('✅ Added user profile photo: $fileName');
        } catch (fileError) {
          print('❌ Error processing user profile photo: $fileError');
        }
      }

      /// 6️⃣ Debug logs
      print('📦 Multipart request JSON: ${jsonEncode(requestJson)}');
      print('📁 Total files count: ${formData.files.length}');
      print('📋 Fields count: ${formData.fields.length}');

      // // /// 4️⃣ Add image (optional)
      // if (shopImage.value != null && await shopImage.value!.exists()) {
      //   formData.files.add(
      //     MapEntry(
      //       'shopPhoto',
      //       await dio.MultipartFile.fromFile(
      //         shopImage.value!.path,
      //         filename: 'shop_image.jpg',
      //       ),
      //     ),
      //   );
      // }

      /// 5️⃣ Debug logs
      print('Multipart request JSON: ${jsonEncode(requestJson)}');
      print('Files count: ${formData.files.length}');

      /// 6️⃣ API Call
      final dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.signupEndpoint,
        formData: formData,
        authToken: false,
        showToast: true,
      );

      // / 7️⃣ Handle response
      // if (response == null) {
      //   ToastCustom.errorToast(context, 'Network error. Please try again.');
      //   return;
      // }

      print('Response data: ${response}');

      if (response != null && response.statusCode == 200) {
        final responseData2 = SignupResponseModel.fromJson(response.data);
        final Map<String, dynamic> responseData =
            response.data is String ? jsonDecode(response.data) : response.data;

        if (responseData['email'] != null) {
          await SharedPreferencesHelper.setUsername(responseData['email']);
        }

        if (responseData['shopId'] != null) {
          await SharedPreferencesHelper.setShopId(responseData['shopId']);
        }

        ToastCustom.successToast(context, 'Account created successfully!');

        clearControllers();
        RouteService.backToLogin();
      } else {
        final Map<String, dynamic> errorData =
            response?.data is String
                ? jsonDecode(response?.data)
                : response?.data;

        ToastCustom.errorToast(
          context,
          errorData['message'] ?? 'Signup failed',
        );
      }
    } catch (e) {
      print('Signup exception: $e');

      String message = 'Signup failed';
      if (e is dio.DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      }

      ToastCustom.errorToast(context, message);
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(BuildContext context, String email) async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      bool isSuccess = await resetPasswordApi(email: email);
      if (isSuccess) {
        log("Please check email for OTP");
        ToastHelper.success(message: "Please check email for OTP");

        Get.toNamed(AppRoutes.forgotPasswordOtp, parameters: {"email": email});
      } else {
        ToastHelper.error(message: 'Please try again later');
        log('Please try again later');
      }
    } catch (e) {
      log('Reset failed: ${e.toString()}');
      ToastHelper.error(message: 'Reset failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password API
  Future<bool> resetPasswordApi({required String email}) async {
    try {
      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.resetPasswordUrl,
        authToken: false,
        dictParameter: {'email': email},
        showToast: true,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          final data =
              response.data is String
                  ? json.decode(response.data)
                  : response.data;

          if (data is Map<String, dynamic>) {
            String status = data['status'] ?? '';
            int statusCode = data['statusCode'] ?? 0;
            String message = data['message'] ?? '';

            if (status.toLowerCase() == 'success' && statusCode == 200) {
              log("✅ Reset password email sent successfully");
              log("Message: $message");
              return true;
            } else {
              log("❌ Reset password failed: $message");
              return false;
            }
          } else {
            log("❌ Unexpected response format in resetPasswordApi");
            return false;
          }
        } else {
          log(
            "❌ Reset password API failed with status code: ${response.statusCode}",
          );
          return false;
        }
      } else {
        log("❌ No response received from reset password API");
        return false;
      }
    } catch (error) {
      log("❌ Error in resetPasswordApi: $error");
      return false;
    }
  }

  @override
  void onClose() {
    _isDisposed = true;

    try {
      animationController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
      nameController.dispose();
      shopStoreNameController.dispose();
      gstNumberController.dispose();
      adhaarNumberController.dispose();
      contactPersonController.dispose();
      phoneNumberController.dispose();
      addressLine1Controller.dispose();
      addressLine2Controller.dispose();
      landmarkController.dispose();
      cityController.dispose();
      stateController.dispose();
      pincodeController.dispose();
      countryController.dispose();
      streetController.dispose();
      zipcodeController.dispose();

      // Dispose social media controllers
      for (var link in socialMediaLinks) {
        link['controller']?.dispose();
      }
    } catch (e) {
      print('Error disposing controllers: $e');
    }

    super.onClose();
  }
}
