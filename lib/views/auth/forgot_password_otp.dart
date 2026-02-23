import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/otp_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_ui_helper/app_ui_helper.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller and set email
    final OTPController controller = Get.put(OTPController());
    controller.setEmail(Get.parameters['email']!);

    return Scaffold(
      // appBar: CustomAppBar(title: 'Reset Password'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // buildCustomAppBar("Reset Password", isdark: false),
            AppUiHelper.appHeaderName(),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: SlideTransition(
                      position: controller.slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderSection(),
                          const SizedBox(height: 10),
                          _buildOTPInputSection(controller),
                          const SizedBox(height: 20),
                          _buildPasswordSection(controller),
                          const SizedBox(height: 15),
                          _buildVerifyButton(controller),
                          _buildResendSection(controller),
                          const SizedBox(height: 14),
                          _buildHelpHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            // color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.authColor2, width: 2),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 40,
            color: AppColors.primaryLight,
          ),
        ),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Enter the OTP sent to '),
                TextSpan(
                  text: Get.parameters['email'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInputSection(OTPController controller) {
    return Column(
      children: [
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => _buildOTPBox(controller, index),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPBox(OTPController controller, int index) {
    return Obx(
      () => Container(
        width: 45,
        height: 55,
        decoration: BoxDecoration(
          // color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                controller.otpFocusIndex.value == index
                    ? AppColors.primaryLight
                    : controller.otpControllers[index].text.isNotEmpty
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.8)
                    : AppColors.primaryLight.withValues(alpha: 0.3),
            width: controller.otpFocusIndex.value == index ? 2 : 1.5,
          ),
          boxShadow:
              controller.otpFocusIndex.value == index
                  ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: TextFormField(
          controller: controller.otpControllers[index],
          focusNode: controller.otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => controller.onOTPChanged(value, index),
          onTap: () => controller.onOTPFieldTap(index),
        ),
      ),
    );
  }

  Widget _buildPasswordSection(OTPController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return buildStyledTextField(
            labelText: 'New Password',
            hintText: 'Enter new password',
            controller: controller.newPasswordController,
            obscureText: controller.isNewPasswordObscure.value,
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isNewPasswordObscure.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.toggleNewPasswordVisibility,
            ),
          );
        }),
        const SizedBox(height: 12),

        Obx(() {
          return buildStyledTextField(
            labelText: 'Confirm Password',
            hintText: 'Confirm new password',

            controller: controller.confirmPasswordController,
            obscureText: controller.isConfirmPasswordObscure.value,
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordObscure.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          );
        }),
        // const Text(
        //   'New Password',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.primaryLight,
        //     letterSpacing: 0.5,
        //   ),
        // ),
        // _buildPasswordField(
        //   controller: controller.newPasswordController,
        //   hintText: 'Enter new password',
        //   obscureText: controller.isNewPasswordObscure,
        //   onToggleVisibility: controller.toggleNewPasswordVisibility,
        // ),
        // const SizedBox(height: 20),
        // const Text(
        //   'Confirm Password',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.primaryLight,
        //     letterSpacing: 0.5,
        //   ),
        // ),
        // const SizedBox(height: 12),
        // _buildPasswordField(
        //   controller: controller.confirmPasswordController,
        //   hintText: 'Confirm new password',
        //   obscureText: controller.isConfirmPasswordObscure,
        //   onToggleVisibility: controller.toggleConfirmPasswordVisibility,
        // ),
        const SizedBox(height: 8),
        Obx(
          () =>
              controller.passwordError.value.isNotEmpty
                  ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.passwordError.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required RxBool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText.value,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.primaryLight.withValues(alpha: 0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.primaryLight.withValues(alpha: 0.7),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primaryLight.withValues(alpha: 0.7),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(OTPController controller) {
    return Obx(
      () => Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                controller.isFormValid.value
                    ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                    : AppColors.primaryGradientLight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              controller.isFormValid.value
                  ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                controller.isLoading.value || !controller.isFormValid.value
                    ? null
                    : () => controller.verifyOTPresetPassword(),
            child: Center(
              child:
                  controller.isLoading.value
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.backgroundLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Resetting Password...',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            // color: AppColors.primaryLight,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              // color: AppColors.primaryLight,
                              color: Colors.white,

                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(OTPController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
          //   // color: AppColors.primaryLight.withValues(alpha: 0.2),
          //   color: AppColors.primaryLight,
          //   width: 1,
          // ),
        ),
        child: Column(
          children: [
            Text(
              'Didn\'t receive the code?',
              style: TextStyle(
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            controller.canResendOTP.value
                ? GestureDetector(
                  onTap: () => controller.resendOTP(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                : Text(
                  'Resend in ${controller.resendTimer.value}s',
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color: AppColors.primaryLight.withValues(alpha: 0.2),
        //   width: 1,
        // ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryLight.withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Password must be at least 8 characters long with letters and numbers.',
              style: TextStyle(
                color: AppColors.backgroundDark.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
