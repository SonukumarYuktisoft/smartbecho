import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/common/app%20borders/dashed_border.dart';
import 'package:smartbecho/utils/helper/linkopener_helper.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Color(0xFF667eea),
          //     Color(0xFF764ba2),
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Obx(
            () => Column(
              children: [
                _buildHeader(controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: FadeTransition(
                      opacity: controller.fadeAnimation,
                      child: SlideTransition(
                        position: controller.slideAnimation,
                        child: _buildCurrentStep(controller, context),
                      ),
                    ),
                  ),
                ),
                _buildNavigationButtons(controller, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController controller) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Register Your Shop',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s get your business online in just a few steps',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryLight.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(controller),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AuthController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${controller.currentStep.value} of 5',
              style: TextStyle(
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            Text(
              '${(controller.currentStep.value * 20).toInt()}%',
              style: TextStyle(
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: controller.currentStep.value / 5.0,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(AuthController controller, BuildContext context) {
    switch (controller.currentStep.value) {
      case 1:
        return _buildBasicInformation(controller);
      case 2:
        return _buildShopAddress(controller);
      case 3:
        return _buildSocialMediaLinks(controller);
      case 4:
        return _buildShopImages(controller);
      case 5:
        return _buildVerificationAndAgreement(controller);
      default:
        return _buildBasicInformation(controller);
    }
  }

  Widget _buildBasicInformation(AuthController controller) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Basic Information'),
          const SizedBox(height: 24),
          buildStyledTextField(
            labelText: 'Shop Store Name *',
            controller: controller.shopStoreNameController,
            hintText: 'Enter Shop Store Name',
            prefixIcon: Icon(Icons.store_mall_directory_outlined),
            validator: ValidatorHelper.validateShopStoreName,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),
          buildStyledTextField(
            controller: controller.emailController,
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: ValidatorHelper.validateEmail,
            labelText: 'Email Address *',
          ),
          const SizedBox(height: 20),

          Obx(
            () => buildStyledTextField(
              controller: controller.passwordController,
              hintText: 'Enter Password',
              labelText: 'Password *',
              prefixIcon: Icon(Icons.lock_clock_outlined),
              keyboardType: TextInputType.visiblePassword,

              obscureText: controller.obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  // color: AppColors.primaryLight.withValues(alpha: 0.7),
                  color: Colors.grey,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: ValidatorHelper.validatePassword,
            ),
          ),
          const SizedBox(height: 20),
          // buildStyledTextField(
          //   controller: controller.gstNumberController,
          //   hintText: 'GST Number 27ABCDE1234F1Z5',
          //   prefixIcon: Icon(Icons.receipt_long_outlined),
          //   keyboardType: TextInputType.name,

          //   validator: ValidatorHelper.validateGSTNumber,
          //   digitsOnly: false,
          //   maxLength: 15,
          //   labelText: 'GST Number',
          //   onChanged: (value) {
          //     controller.gstNumberController.value = controller
          //         .gstNumberController
          //         .value
          //         .copyWith(
          //           text: value.toUpperCase(),
          //           selection: TextSelection.collapsed(offset: value.length),
          //         );
          //   },
          // ),

          // Replace your existing GST TextField in _buildBasicInformation with this:
          Obx(
            () => buildStyledTextField(
              controller: controller.gstNumberController,
              hintText: 'GST Number 27ABCDE1234F1Z5',
              prefixIcon: Icon(Icons.receipt_long_outlined),
              keyboardType: TextInputType.name,
              validator: (value) {
                // ✅ If empty or null - NO ERROR (because it's optional)
                if (value == null || value.isEmpty) {
                  return null;
                }

                // ❌ Check length first
                if (value.length != 15) {
                  return 'GST number must be 15 characters';
                }

                // ❌ Check format
                final gstRegex = RegExp(
                  r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                );
                if (!gstRegex.hasMatch(value)) {
                  return 'Please enter a valid GST number format';
                }

                // ❌ Check if GST is verified via API
                if (!controller.isGstValid.value &&
                    controller.gstValidationMessage.value.isNotEmpty) {
                  return 'GST number not registered or invalid';
                }

                // ✅ All validations passed
                return null;
              },
              // validator: ValidatorHelper.validateGSTNumber,
              digitsOnly: false,
              maxLength: 15,
              labelText: 'GST Number (Optional)',
              suffixIcon:
                  controller.isGstValidating.value
                      ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight,
                            ),
                          ),
                        ),
                      )
                      : controller.isGstValid.value
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : controller.gstValidationMessage.value.isNotEmpty
                      ? Icon(Icons.error, color: Colors.red)
                      : null,
              onChanged: (value) {
                // Convert to uppercase
                controller.gstNumberController.value = controller
                    .gstNumberController
                    .value
                    .copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );

                // Validate and fetch GST details when 15 characters are entered
                if (value.length == 15) {
                  controller.validateAndFetchGstDetails(value.toUpperCase());
                } else {
                  // Clear validation state if length changes
                  controller.clearGstValidation();
                }
              },
            ),
          ),

          // Add validation message below the field
          const SizedBox(height: 8),
          Obx(() {
            if (controller.gstValidationMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    controller.isGstValid.value
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      controller.isGstValid.value
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.isGstValid.value
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color:
                        controller.isGstValid.value
                            ? Colors.green
                            : Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.gstValidationMessage.value,
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Optional: Add info text about auto-fill
          Obx(() {
            if (controller.isGstValid.value) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Address fields have been auto-filled from GST data. You can modify them if needed.',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 20),
          buildStyledTextField(
            controller: controller.adhaarNumberController,
            hintText: 'Enter Aadhaar Number',
            labelText: 'Aadhaar Number *',
            prefixIcon: Icon(Icons.credit_card_off_outlined),
            keyboardType: TextInputType.number,
            validator: ValidatorHelper.validateAdhaarNumber,

            digitsOnly: true,
            maxLength: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildShopAddress(AuthController controller) {
    return Form(
      key: controller.addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Shop Address'),
          const SizedBox(height: 24),
          buildStyledTextField(
            controller: controller.contactPersonController,
            labelText: 'Contact Person Name *',
            hintText: 'Enter Person Name',
            prefixIcon: Icon(Icons.person_2_outlined),
            validator: ValidatorHelper.validateName,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),
          buildStyledTextField(
            controller: controller.phoneNumberController,
            hintText: ' Phone Number',
            labelText: 'Contact Phone Number *',
            prefixIcon: Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            validator: ValidatorHelper.validatePhoneNumber,
            digitsOnly: true,
            maxLength: 10,
          ),
          buildStyledTextField(
            controller: controller.panNumberController,
            hintText: 'ABCDE1234F',
            labelText: 'PAN Number',
            prefixIcon: const Icon(Icons.receipt_long_outlined),
            validator: ValidatorHelper.validatePan,
            keyboardType: TextInputType.name,

            maxLength: 10,
            onChanged: (value) {
              controller.panNumberController.value = controller
                  .panNumberController
                  .value
                  .copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
            },
          ),
          const SizedBox(height: 20),

          buildStyledTextField(
            controller: controller.addressLine1Controller,
            hintText: 'Address Line 1',
            labelText: 'Address Line 1 *',
            prefixIcon: Icon(Icons.home_outlined),
            validator: ValidatorHelper.validateAddressLine1,
          ),
          const SizedBox(height: 20),
          buildStyledTextField(
            controller: controller.addressLine2Controller,
            hintText: 'Address Line 2',
            labelText: 'Address Line 2',
            prefixIcon: Icon(Icons.home_outlined),
          ),
          const SizedBox(height: 20),
          buildStyledTextField(
            controller: controller.landmarkController,
            hintText: 'landmark',
            labelText: 'landmark',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buildStyledTextField(
                  controller: controller.cityController,
                  hintText: 'Enter City',
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  keyboardType: TextInputType.name,

                  validator: ValidatorHelper.validateCity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildStyledTextField(
                  controller: controller.stateController,
                  hintText: 'Enter State',
                  labelText: 'State *',
                  prefixIcon: Icon(Icons.map_outlined),
                  keyboardType: TextInputType.name,

                  validator: ValidatorHelper.validateState,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buildStyledTextField(
                  controller: controller.pincodeController,
                  hintText: 'Enter Pincode',
                  labelText: 'Pincode *',
                  prefixIcon: Icon(Icons.local_post_office_outlined),

                  keyboardType: TextInputType.number,
                  validator: ValidatorHelper.validatePincode,
                  digitsOnly: true,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildStyledTextField(
                  controller: controller.countryController,
                  hintText: 'Enter Country',
                  labelText: 'Country *',
                  prefixIcon: Icon(Icons.public_outlined),

                  // validator: ValidatorHelper.validateCountry,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Social Media Links (Optional)'),
        const SizedBox(height: 16),
        Text(
          'Connect your social media profiles to boost your online presence',
          style: TextStyle(
            color: AppColors.primaryLight.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ...controller.socialMediaLinks
            .map((link) => _buildSocialMediaInput(controller, link))
            .toList(),
        const SizedBox(height: 16),
        _buildAddSocialMediaButton(controller),
      ],
    );
  }

  Widget _buildSocialMediaInput(
    AuthController controller,
    Map<String, dynamic> link,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: link['platform'],

              decoration: InputDecoration(
                filled: true,

                fillColor: AppColors.primaryLight.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: AppColors.backgroundDark),
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: 'facebook',
                  child: Row(
                    children: [
                      Icon(Icons.facebook, color: Color(0xFF4267B2), size: 16),
                      SizedBox(width: 8),
                      Text('Facebook'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'instagram',
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Color(0xFFE4405F),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('Instagram'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'twitter',
                  child: Row(
                    children: [
                      Icon(
                        Icons.alternate_email,
                        color: Color(0xFF1DA1F2),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('Twitter'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'linkedin',
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Color(0xFF0077B5), size: 16),
                      SizedBox(width: 8),
                      Text('LinkedIn'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'youtube',
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFFFF0000),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('YouTube'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                link['platform'] = value;
                controller.socialMediaLinks.refresh();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: link['controller'],
              style: TextStyle(color: AppColors.primaryLight),
              decoration: InputDecoration(
                hintText: 'Profile URL',
                hintStyle: TextStyle(
                  color: AppColors.primaryLight.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: AppColors.primaryLight.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => controller.removeSocialMediaLink(link),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSocialMediaButton(AuthController controller) {
    return GestureDetector(
      onTap:
          controller.socialMediaLinks.length < 5
              ? controller.addSocialMediaLink
              : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              controller.socialMediaLinks.length < 5
                  ? Color(0xFF4267B2)
                  : Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              //  color: AppColors.primaryLight,
              color: Colors.white,

              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Social Link (${controller.socialMediaLinks.length}/5)',
              style: TextStyle(
                // color: AppColors.primaryLight,
                color: Colors.white,

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // COMPLETE CODE: Add these methods to your SignupScreen class
  // ========================================

  // This method replaces your existing _buildShopImages method
  Widget _buildShopImages(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Upload Images'),
        const SizedBox(height: 16),
        Text(
          'Add images of your shop and your profile photo',
          style: TextStyle(
            color: AppColors.primaryLight.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),

        // ========================================
        // 1️⃣ SHOP IMAGE SECTION
        // ========================================
        const SizedBox(height: 24),
        Text(
          '1. Shop Image *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () =>
              controller.shopImage.value == null
                  ? GestureDetector(
                    onTap: controller.addShopImage,
                    child: CustomPaint(
                      painter: DashedBorder(
                        color: Colors.grey.shade600,
                        strokeWidth: 2,
                        dashWidth: 8,
                        dashSpace: 4,
                        borderRadius: 12,
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 64,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to add shop image *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Required',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : _buildShopImagePreview(controller),
        ),

        // Warning for shop image
        const SizedBox(height: 16),
        Obx(
          () =>
              controller.shopImage.value == null
                  ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please select a shop image to continue',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),

        // ========================================
        // 2️⃣ USER PROFILE PHOTO SECTION
        // ========================================
        const SizedBox(height: 32),
        Text(
          '2. Profile Photo *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () =>
              controller.userProfilePhoto.value == null
                  ? GestureDetector(
                    onTap: controller.addUserProfilePhoto,
                    child: CustomPaint(
                      painter: DashedBorder(
                        color: Colors.grey.shade600,
                        strokeWidth: 2,
                        dashWidth: 8,
                        dashSpace: 4,
                        borderRadius: 12,
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 64,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to add profile photo *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Required',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : _buildProfilePhotoPreview(controller),
        ),

        // Warning for profile photo
        const SizedBox(height: 16),
        Obx(
          () =>
              controller.userProfilePhoto.value == null
                  ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please select a profile photo to continue',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 13,
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

  // ========================================
  // ADD THIS NEW METHOD: Shop Image Preview
  // ========================================
  Widget _buildShopImagePreview(AuthController controller) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(controller.shopImage.value!, fit: BoxFit.cover),
            ),
          ),
          // Shop Label Badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.removeShopImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Change Button
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.addShopImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF4267B2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ADD THIS NEW METHOD: Profile Photo Preview
  // ========================================
  Widget _buildProfilePhotoPreview(AuthController controller) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                controller.userProfilePhoto.value!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Profile Label Badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.removeUserProfilePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Change Button
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.addUserProfilePhoto,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF4267B2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildShopImages(AuthController controller) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildStepTitle('Shop Image'),
  //       const SizedBox(height: 16),
  //       Text(
  //         'Add one image of your shop to help customers recognize your business',
  //         style: TextStyle(
  //           color: AppColors.primaryLight.withValues(alpha: 0.7),
  //           fontSize: 14,
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Obx(
  //         () =>
  //             controller.shopImage.value == null
  //                 ? GestureDetector(
  //                   onTap: controller.addShopImage,
  //                   child: CustomPaint(
  //                     painter: DashedBorder(
  //                       color: Colors.grey.shade600,
  //                       strokeWidth: 2,
  //                       dashWidth: 8,
  //                       dashSpace: 4,
  //                       borderRadius: 12,
  //                     ),
  //                     child: Container(
  //                       height: 200,
  //                       width: double.infinity,
  //                       decoration: BoxDecoration(
  //                         // color: AppColors.primaryLight.withValues(alpha: 0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Icon(
  //                             Icons.add_photo_alternate,
  //                             size: 64,

  //                             // color: AppColors.primaryLight.withValues(alpha: 0.6),
  //                           ),
  //                           const SizedBox(height: 16),
  //                           Text(
  //                             'Tap to add shop image *',
  //                             style: TextStyle(
  //                               // color: AppColors.primaryLight.withValues(alpha: 0.8),
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 8),
  //                           Text(
  //                             'Required',
  //                             style: TextStyle(
  //                               color: Colors.red,
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //                 : _buildImagePreview(controller),
  //       ),

  //       // Show warning if no image selected
  //       const SizedBox(height: 16),
  //       Obx(
  //         () =>
  //             controller.shopImage.value == null
  //                 ? Container(
  //                   padding: const EdgeInsets.all(12),
  //                   decoration: BoxDecoration(
  //                     color: Colors.orange.withValues(alpha: 0.2),
  //                     borderRadius: BorderRadius.circular(8),
  //                     border: Border.all(
  //                       color: Colors.orange.withValues(alpha: 0.5),
  //                     ),
  //                   ),
  //                   child: Row(
  //                     children: [
  //                       Icon(
  //                         Icons.warning_amber_rounded,
  //                         color: Colors.orange,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           'Please select a shop image to continue',
  //                           style: TextStyle(
  //                             color: AppColors.primaryLight,
  //                             fontSize: 13,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //                 : const SizedBox.shrink(),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildShopImages(AuthController controller) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildStepTitle('Shop Image'),
  //       const SizedBox(height: 16),
  //       Text(
  //         'Add one image of your shop to help customers recognize your business',
  //         style: TextStyle(
  //           color: AppColors.primaryLight.withValues(alpha: 0.7),
  //           fontSize: 14,
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Obx(
  //         () =>
  //             controller.shopImage.value == null
  //                 ? GestureDetector(
  //                   onTap: controller.addShopImage,
  //                   child: Container(
  //                     height: 200,
  //                     width: double.infinity,
  //                     decoration: BoxDecoration(
  //                       color: AppColors.primaryLight.withValues(alpha: 0.1),
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: AppColors.primaryLight.withValues(alpha: 0.3),
  //                         width: 2,
  //                         style: BorderStyle.solid,
  //                       ),
  //                     ),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.add_photo_alternate,
  //                           size: 64,
  //                           color: AppColors.primaryLight.withValues(
  //                             alpha: 0.6,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 16),
  //                         Text(
  //                           'Tap to add shop image',
  //                           style: TextStyle(
  //                             color: AppColors.primaryLight.withValues(
  //                               alpha: 0.8,
  //                             ),
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 )
  //                 : _buildImagePreview(controller),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildImagePreview(AuthController controller) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(controller.shopImage.value!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.removeShopImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.addShopImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF4267B2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: AppColors.primaryLight, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationAndAgreement(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Review & Confirm'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 16),
              _buildReviewItem(
                'Shop Name:',
                controller.shopStoreNameController.text,
              ),
              _buildReviewItem('Email:', controller.emailController.text),
              _buildReviewItem('Phone:', controller.phoneNumberController.text),
              _buildReviewItem(
                'Address:',
                '${controller.addressLine1Controller.text}, ${controller.cityController.text}',
              ),
              if (controller.gstNumberController.text.isNotEmpty)
                _buildReviewItem(
                  'GST Number:',
                  controller.gstNumberController.text,
                ),
              _buildReviewItem(
                'Aadhaar Number:',
                controller.adhaarNumberController.text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    controller.agreeToTerms.value
                        ? AppColors.primaryLight.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: CheckboxListTile(
              value: controller.agreeToTerms.value,
              onChanged:
                  (value) => controller.agreeToTerms.value = value ?? false,
              activeColor: AppColors.primaryLight,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              title: RichText(
                text: TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.8),
                  ),
                  children: [
                    /// Terms of Service
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              LinkOpenerHelper.open(
                                'https://www.smartbecho.in/terms-and-conditions',
                              );
                            },
                    ),

                    const TextSpan(text: ' and '),

                    /// Privacy Policy
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              LinkOpenerHelper.open(
                                'https://www.smartbecho.in/privacy-policy',
                              );
                            },
                    ),

                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    controller.subscribeToNewsletter.value
                        ? AppColors.primaryLight.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: CheckboxListTile(
              value: controller.subscribeToNewsletter.value,
              onChanged:
                  (value) =>
                      controller.subscribeToNewsletter.value = value ?? false,
              activeColor: AppColors.primaryLight,
              // checkColor: Color(0xFF667eea),
              checkColor: Colors.white,

              title: Text(
                'Subscribe to our newsletter for updates and tips',
                style: TextStyle(
                  color: AppColors.primaryLight.withValues(alpha: 0.8),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!controller.agreeToTerms.value)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please agree to terms and conditions to complete registration',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primaryLight.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,

    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isRequired = false,
    bool readOnly = false,

    /// 🔹 OPTIONAL controls
    bool digitsOnly = false,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          // color: AppColors.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        inputFormatters:
            digitsOnly
                ? [
                  FilteringTextInputFormatter.digitsOnly,
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength),
                ]
                : null,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText + (isRequired ? ' *' : ''),
          counterText: maxLength != null ? '' : null,
          hintStyle: TextStyle(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            // color: AppColors.primaryLight.withValues(alpha: 0.7),
            color: Colors.grey,

            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    AuthController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (controller.currentStep.value > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (controller.currentStep.value > 1) const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              bool isLastStep = controller.currentStep.value == 5;
              bool isButtonDisabled =
                  isLastStep && !controller.agreeToTerms.value;

              return Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient:
                      isButtonDisabled
                          ? LinearGradient(
                            colors: [
                              Colors.grey.withValues(alpha: 0.5),
                              Colors.grey.withValues(alpha: 0.7),
                            ],
                          )
                          : LinearGradient(
                            colors: AppColors.primaryGradientLight,
                          ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      isButtonDisabled
                          ? []
                          : [
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
                    borderRadius: BorderRadius.circular(12),
                    onTap:
                        (controller.isLoading.value || isButtonDisabled)
                            ? null
                            : () {
                              if (isLastStep) {
                                controller.signup(context);
                              } else {
                                controller.nextStep();
                              }
                            },
                    child: Center(
                      child:
                          controller.isLoading.value
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (isButtonDisabled)
                                    Icon(
                                      Icons.lock,
                                      color: AppColors.primaryLight,
                                      size: 20,
                                    ),
                                  if (isButtonDisabled)
                                    const SizedBox(width: 8),
                                  Text(
                                    isLastStep
                                        ? 'Complete \nRegistration'
                                        : 'Next',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isLastStep) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
