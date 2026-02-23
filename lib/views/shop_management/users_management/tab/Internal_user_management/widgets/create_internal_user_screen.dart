import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/Internal%20user%20management%20controller/Internal_user_management_controller.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/create_internal_user_model.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/shop_roles_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';
import 'package:smartbecho/utils/helper/Shimmer/shimmer_helper.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/utils/helper/validator/image_validator.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class CreateInternalUserScreen extends StatelessWidget {
  final String shopId;

  const CreateInternalUserScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final InternalUserManagementController internalUserController =
        Get.find<InternalUserManagementController>();
    final RoleManagementController roleController = Get.put(
      RoleManagementController(),
    );

    final _formKey = GlobalKey<FormState>();

    // Text Controllers
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController adhaarController = TextEditingController();

    // GetX observables
    final selectedRole = Rx<ShopRole?>(null);
    final profilePhoto = Rx<File?>(null);
    final RxBool isImageLoading = false.obs;

    final obscurePassword = true.obs;

    // Load shop roles on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      roleController.getShopRoles(shopId: shopId);
    });
    Future<void> pickImage() async {
      final picker = ImagePicker();

      Future<void> _handlePick(ImageSource source) async {
        final XFile? image = await picker.pickImage(source: source);
        if (image == null) return;

        isImageLoading.value = true;
        final file = File(image.path);

        final error = ImageValidator.validateImageSize(
          imageFile: file,
          maxSizeInMB: 2,
        );

        isImageLoading.value = false;

        if (error != null) {
          ToastHelper.error(message: error);
          return;
        }

        profilePhoto.value = file;
      }

      showModalBottomSheet(
        context: context,
        builder:
            (_) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _handlePick(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _handlePick(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
      );
    }

    Future<void> createUser() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (selectedRole.value == null) {
        Get.snackbar(
          'Error',
          'Please select a role',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      final userData = CreateInternalUserModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        name: nameController.text.trim(),
        adhaarNumber: adhaarController.text.trim(),
        roleId: selectedRole.value!.id,
        shopId: shopId,
      );

      await internalUserController.createInternalUser(
        userData: userData,
        profilePhoto: profilePhoto.value,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Create Internal User',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              Center(
                child: Column(
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                            image:
                                profilePhoto.value != null
                                    ? DecorationImage(
                                      image: FileImage(profilePhoto.value!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              profilePhoto.value == null
                                  ? const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: AppColors.primaryLight,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => TextButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(
                          profilePhoto.value == null
                              ? 'Add Photo'
                              : 'Change Photo',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Full Name *',
                controller: nameController,
                hintText: 'Enter full name',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                validator: ValidatorHelper.validateName,
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Email *',
                controller: emailController,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                textCapitalization: TextCapitalization.none,
                validator: ValidatorHelper.validateEmail,
              ),
              const SizedBox(height: 16),

              Obx(
                () => buildStyledTextField(
                  labelText: 'Password *',
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: obscurePassword.value,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () {
                      obscurePassword.value = !obscurePassword.value;
                    },
                  ),
                  validator: ValidatorHelper.validatePassword,
                ),
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Phone Number *',
                controller: phoneController,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                digitsOnly: true,
                maxLength: 10,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: ValidatorHelper.validatePhoneNumber,
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Aadhaar Number *',
                controller: adhaarController,
                hintText: 'Enter aadhaar number',
                keyboardType: TextInputType.number,
                digitsOnly: true,
                maxLength: 12,
                prefixIcon: const Icon(Icons.credit_card, size: 20),
                validator: ValidatorHelper.validateAdhaarNumber,
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              Obx(
                () =>
                    roleController.shopRolesLoading.value
                        ? ShimmerHelper.buildShimmerTextField()
                        : CommonDropdownSearch<ShopRole>(
                          items: roleController.shopRolesList,
                          labelText: 'Select Role *',
                          hintText: 'Choose a role',
                          prefixIcon: Icons.badge_outlined,
                          selectedItem: selectedRole.value,
                          itemAsString: (shopRole) => shopRole.name,
                          compareFn: (role1, role2) => role1.id == role2.id,
                          onChanged: (selectedShopRole) {
                            selectedRole.value = selectedShopRole;
                            if (selectedShopRole != null) {
                              print('═══════════════════════════════');
                              print('🏪 Role Selected');
                              print('═══════════════════════════════');
                              print('Role ID: ${selectedShopRole.id}');
                              print('Role Name: ${selectedShopRole.name}');
                              print('Is Global: ${selectedShopRole.isGlobal}');
                              print('═══════════════════════════════');
                            }
                          },
                        ),
              ),
              const SizedBox(height: 32),

              // Create Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        internalUserController.createUserLoading.value
                            ? null
                            : createUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        internalUserController.createUserLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Create User',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _imageShimmer() {
  return Container(
    height: 150,
    width: 150,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    ),
  );
}
