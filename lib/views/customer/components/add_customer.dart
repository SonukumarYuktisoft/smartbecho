import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_opeartions_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/image_uploader_widget.dart';
import 'package:smartbecho/utils/custom_back_button.dart';
import 'package:smartbecho/utils/app_styles.dart';

class AddCustomerForm extends StatelessWidget {
  const AddCustomerForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get or create the controller instance
    final CustomerOperationsController controller = Get.find<CustomerOperationsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'Add Customer'),
      body: Form(
        key: controller.addCustomerFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(controller),
              _buildFormContent(controller),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CustomerOperationsController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: customBackButton(isdark: true),
      ),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 45.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADD NEW CUSTOMER',
                    style: AppStyles.custom(
                      color: const Color(0xFF1A1A1A),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Fill details to add customer',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader(CustomerOperationsController controller) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha:0.2),
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color:AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.customerNameController.text.isEmpty
                          ? 'Customer Name'
                          : controller.customerNameController.text,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.primaryPhoneController.text.isEmpty
                          ? 'Phone Number'
                          : controller.primaryPhoneController.text,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.locationController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    controller.locationController.text,
                    style: const TextStyle(
                      color:AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }

  Widget _buildFormContent(CustomerOperationsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Customer Information', Icons.person),
            const SizedBox(height: 16),

            // Customer Name Field
            buildStyledTextField(
              labelText: 'Customer Name',
              controller: controller.customerNameController,
              hintText: 'Enter customer name',
              validator: controller.validateCustomerName,
              onChanged: (value) {
                // Trigger UI update for header
                controller.customerNameController.notifyListeners();
              },
            ),
            const SizedBox(height: 16),

            // Primary Phone Field
            buildStyledTextField(
              labelText: 'Primary Phone Number',
              controller: controller.primaryPhoneController,
              hintText: 'Enter phone number',
              keyboardType: TextInputType.phone,
              validator: controller.validatePrimaryPhone,
              digitsOnly: true,
              maxLength: 10,
              onChanged: (value) {
                controller.primaryPhoneController.notifyListeners();
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            buildStyledTextField(
              labelText: 'Email (Optional)',
              controller: controller.emailController,
              hintText: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 16),

            // Location and Address Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Location',
                    controller: controller.locationController,
                    hintText: 'Enter location',
                    validator: controller.validateLocation,
                    onChanged: (value) {
                      // Trigger UI update for header
                      controller.locationController.notifyListeners();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Primary Address',
                    controller: controller.primaryAddressController,
                    hintText: 'Enter address',
                    validator: controller.validatePrimaryAddress,
                  ),
                ),
              ],
            ),
             Obx(
              () => buildStyledDropdown(
                labelText: 'State',
                hintText: 'Select State',
                value:
                    controller.selectedStates.value.isEmpty
                        ? null
                        : controller.selectedStates.value,
                items: controller.statesList,
                onChanged: (value) => controller.onSelectState(value ?? ''),
                // validator: controller.validateIMEINumbers,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Customer Image', Icons.image),
            const SizedBox(height: 16),

            // Image Upload
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
              ),
              child: ImageUploadWidget(
                labelText: 'Customer Photo',
                uploadText: 'Upload Photo',
                onImageSelected: controller.onCustomerImageSelected,
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: controller.isAddingCustomer.value
                            ? null
                            : controller.cancelAddCustomer,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.withValues(alpha:0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isAddingCustomer.value
                            ? null
                            : controller.addCustomer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isAddingCustomer.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Add Customer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
            ),

            // Error Message Display
            Obx(
              () => controller.hasAddCustomerError.value
                  ? Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha:0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.addCustomerErrorMessage.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}