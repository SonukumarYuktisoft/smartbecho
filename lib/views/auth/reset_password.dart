import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_ui_helper/app_ui_helper.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: CustomAppBar(title: 'Reset Password'),
      body: SafeArea(
        child: Column(
          children: [
                const SizedBox(height: 40),
            AppUiHelper.appHeaderName(),

            // buildCustomAppBar("Reset Password", isdark: true),
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
                          const SizedBox(height: 40),
                          _buildResetForm(controller),
                          const SizedBox(height: 32),
                          _buildResetButton(controller, context),
                          const SizedBox(height: 24),
                          _buildBackToLoginHint(),
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
            // color: AppColors.primaryLight.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.authColor2, width: 2),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Forgot ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Password?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.authColor2,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Text(
        //   'Forgot Password?',
        //   style: TextStyle(
        //     fontSize: 32,
        //     fontWeight: FontWeight.bold,
        //     color: AppColors.primaryLight,
        //     letterSpacing: -0.5,
        //   ),
        // ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'No worries! Enter your email address and we\'ll send you a secure link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimaryLight.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(AuthController controller) {
    return Form(
      key: controller.resetPasswordFormKey,
      child: buildStyledTextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: controller.validateEmail,
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email_outlined, size: 22),
        labelText: 'Email',
      ),
    );
  }

  Widget _buildResetButton(AuthController controller, BuildContext context) {
    return Obx(
      () => Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradientLight),
          // color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                () =>
                    controller.isLoading.value
                        ? null
                        : controller.resetPassword(
                          context,
                          controller.emailController.text,
                        ),
            child: Center(
              child:
                  controller.isLoading.value
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
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
                          Text(
                            'Sending...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,

                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Send Reset Link',
                            style: TextStyle(
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

  Widget _buildBackToLoginHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textPrimaryLight.withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Check your email for the reset link. It may take a few minutes to arrive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimaryLight.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
