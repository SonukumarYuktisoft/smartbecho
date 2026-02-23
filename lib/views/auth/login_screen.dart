import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_ui_helper/app_ui_helper.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';
import 'package:smartbecho/views/auth/forgot_password_otp.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: FadeTransition(
            opacity: controller.fadeAnimation,
            child: SlideTransition(
              position: controller.slideAnimation,
              child: Column(
                children: [
                  Column(
                    children: [
                      AppUiHelper.appHeaderName(
                        subtitle: '"Boost your sales effortlessly."',
                      ),
                      const SizedBox(height: 50),
                      // Welcome Text
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      // Stack: Form on Left + Image on Right
                      Center(
                        child: Form(
                          key: controller.loginFormKey,
                          child: Column(
                            children: [
                              // Email Field
                              buildStyledTextField(
                                controller: controller.emailController,
                                hintText: 'Email',
                                labelText: '',
                                prefixIcon: Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                                validator: ValidatorHelper.validateEmail,
                              ),
                              const SizedBox(height: 11),

                              // Password Field
                              Obx(
                                () => buildStyledTextField(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: controller.passwordController,
                                  hintText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  labelText: '',
                                  obscureText: controller.obscurePassword.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                  validator: ValidatorHelper.validatePassword,
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 20),

                                  // Login Button
                                  _buildLoginButton(controller, context),
                                  const SizedBox(height: 6),

                                  // Forgot Password Button
                                  _buildForgotPasswordButton(controller),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Image.asset(
                    AppImagesString.loginImage,
                    width: 250,
                    height: 280,
                    fit: BoxFit.cover,
                  ),

                  _buildSignupPrompt(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthController controller, BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradientLight),
          // color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: controller.isLoading.value
                ? null
                : () => controller.login(context),
            child: Center(
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(AuthController controller) {
    return TextButton(
      onPressed: controller.goToResetPassword,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Forgot password?',
        style: TextStyle(
          color: AppColors.primaryLight.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSignupPrompt(AuthController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No account? ',
          style: TextStyle(
            color: AppColors.primaryLight.withValues(alpha: 0.8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: controller.goToSignup,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign up',
            style: TextStyle(
              color: AppColors.authColor2,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
