import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/route_services.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:dio/dio.dart' as dio;

class OTPController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // API service instance
  final ApiServices _apiService = ApiServices();

  // App config instance
  final AppConfig _config = AppConfig.instance;

  // Animation Controllers
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // OTP Controllers and Focus Nodes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  // Password Controllers
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // Reactive Variables
  RxInt otpFocusIndex = 0.obs;
  RxBool isOTPComplete = false.obs;
  RxBool canResendOTP = false.obs;
  RxInt resendTimer = 30.obs;
  RxBool isLoading = false.obs;

  // Password visibility
  RxBool isNewPasswordObscure = true.obs;
  RxBool isConfirmPasswordObscure = true.obs;

  // Password validation
  RxString passwordError = ''.obs;
  RxBool isFormValid = false.obs;

  // Timer
  Timer? _timer;

  // Email
  String email = '';

  // Password getters
  String get newPassword => newPasswordController.text;
  String get confirmPassword => confirmPasswordController.text;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    // Initialize OTP controllers and focus nodes
    otpControllers = List.generate(6, (index) => TextEditingController());
    otpFocusNodes = List.generate(6, (index) => FocusNode());

    // Initialize password controllers
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Add listeners to controllers
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].addListener(_validateForm);
    }

    // Add listeners to password controllers
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);

    // Add focus listeners
    for (int i = 0; i < otpFocusNodes.length; i++) {
      otpFocusNodes[i].addListener(() {
        if (otpFocusNodes[i].hasFocus) {
          otpFocusIndex.value = i;
        }
      });
    }

    // Start animations and timer
    animationController.forward();
    _startResendTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    animationController.dispose();

    // for (var controller in otpControllers) {
    //   controller.dispose();
    // }
    // for (var node in otpFocusNodes) {
    //   node.dispose();
    // }

    // newPasswordController.dispose();
    // confirmPasswordController.dispose();

    super.onClose();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    // TODO: implement dispose
    super.dispose();
  }

  void setEmail(String userEmail) {
    email = userEmail;
  }

  void _startResendTimer() {
    canResendOTP.value = false;
    resendTimer.value = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendOTP.value = true;
        timer.cancel();
      }
    });
  }

  void _validateForm() {
    // Check if OTP is complete
    bool otpComplete = otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    isOTPComplete.value = otpComplete;

    // Validate passwords
    String newPass = newPasswordController.text;
    String confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      passwordError.value = '';
      isFormValid.value = false;
      return;
    }

    // Password validation rules
    if (newPass.length < 8) {
      passwordError.value = 'Password must be at least 8 characters long';
      isFormValid.value = false;
      return;
    }

    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(newPass)) {
      passwordError.value = 'Password must contain both letters and numbers';
      isFormValid.value = false;
      return;
    }

    if (newPass != confirmPass) {
      passwordError.value = 'Passwords do not match';
      isFormValid.value = false;
      return;
    }

    // All validations passed
    passwordError.value = '';
    isFormValid.value =
        otpComplete && newPass.isNotEmpty && confirmPass.isNotEmpty;
  }

  void onOTPChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        otpFocusIndex.value = index + 1;
        FocusScope.of(Get.context!).requestFocus(otpFocusNodes[index + 1]);
      } else {
        // Last field, remove focus
        FocusScope.of(Get.context!).unfocus();
      }
    } else {
      // Handle backspace - move to previous field if current is empty
      if (index > 0) {
        otpFocusIndex.value = index - 1;
        FocusScope.of(Get.context!).requestFocus(otpFocusNodes[index - 1]);
      }
    }
    _validateForm();
  }

  void onOTPFieldTap(int index) {
    otpFocusIndex.value = index;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordObscure.value = !isNewPasswordObscure.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

  void resendOTP() {
    // Clear all fields
    for (var controller in otpControllers) {
      controller.clear();
    }
    newPasswordController.clear();
    confirmPasswordController.clear();
    isOTPComplete.value = false;
    isFormValid.value = false;
    passwordError.value = '';

    // Focus first field
    otpFocusIndex.value = 0;
    FocusScope.of(Get.context!).requestFocus(otpFocusNodes[0]);

    // Restart timer
    _startResendTimer();

    // TODO: Add your resend OTP API call here
    // Example: await authService.resendOTP(email);

    Get.snackbar(
      'Code Sent',
      'A new verification code has been sent to $email',
      backgroundColor: Colors.green.withValues(alpha:0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  //verify otp reset password
  Future<void> verifyOTPresetPassword() async {
    if (!isFormValid.value) return;

    try {
      isLoading.value = true;

      String otp = otpControllers.map((controller) => controller.text).join();

      // Make API call to verify OTP and reset password
      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.resetPasswordOTPUrl,
        authToken: false,
        dictParameter: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;

        if (data is Map<String, dynamic>) {
          String status = data['status'] ?? '';
          String message = data['message'] ?? '';
          int statusCode = data['statusCode'] ?? 0;

          if (status.toLowerCase() == 'success' && statusCode == 200) {
            log("✅ OTP verified and password reset successfully");
            log("Message: $message");

            // Clear all stored data
            await SharedPreferencesHelper.clearAll();
            await SecureStorageHelper.deleteJSessionId();

            // Show success message
            Get.snackbar(
              'Success',
              message.isNotEmpty
                  ? message
                  : 'OTP verified and password reset successfully!',
              backgroundColor: Colors.green.withValues(alpha:0.8),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
            );

            // Navigate back to login screen
            RouteService.logout();
          } else {
            log("❌ OTP verification failed: $message");
            throw Exception(
              message.isNotEmpty ? message : 'OTP verification failed',
            );
          }
        } else {
          log("❌ Unexpected response format in verifyOTPresetPassword");
          throw Exception('Unexpected response format');
        }
      } else {
        log(
          "❌ OTP verification API failed with status code: ${response?.statusCode}",
        );
        throw Exception('Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      log("❌ Error in verifyOTPresetPassword: $e");
      Get.snackbar(
        'Error',
        e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Invalid OTP. Please try again.',
        backgroundColor: Colors.red.withValues(alpha:0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    newPasswordController.clear();
    confirmPasswordController.clear();
    isOTPComplete.value = false;
    isFormValid.value = false;
    passwordError.value = '';
    otpFocusIndex.value = 0;
    FocusScope.of(Get.context!).requestFocus(otpFocusNodes[0]);
  }
}
