import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/Internal%20user%20management%20controller/Internal_user_management_controller.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_detail_model.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/update_internal_user_model.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/shop_roles_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';
import 'package:smartbecho/utils/helper/Shimmer/shimmer_helper.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/utils/helper/validator/image_validator.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class EditInternalUserScreen extends StatefulWidget {
  final InternalUserDetail userDetail;
  final String shopId;

  const EditInternalUserScreen({
    super.key,
    required this.userDetail,
    required this.shopId,
  });

  @override
  State<EditInternalUserScreen> createState() => _EditInternalUserScreenState();
}

class _EditInternalUserScreenState extends State<EditInternalUserScreen> {
  final InternalUserManagementController controller =
      Get.find<InternalUserManagementController>();
  final RoleManagementController roleController = Get.put(
    RoleManagementController(),
  );
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController adhaarController;
  late TextEditingController panController;
  late TextEditingController labelController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;
  late TextEditingController countryController;

  File? _profilePhoto;
  late bool notifyByEmail;
  late bool notifyBySms;
  late bool notifyByWhatsApp;
  late int status;

  final selectedRole = Rx<ShopRole?>(null);

  @override
  void initState() {
    super.initState();

    // Load shop roles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      roleController.getShopRoles(shopId: widget.shopId).then((_) {
        // After roles are loaded, pre-select the user's current role
        if (widget.userDetail.roleId != null) {
          final userRole = roleController.shopRolesList.firstWhereOrNull(
            (role) => role.id == widget.userDetail.roleId,
          );
          if (userRole != null) {
            selectedRole.value = userRole;
          }
        }
      });
    });

    // Initialize controllers with existing data from userDetail
    nameController = TextEditingController(text: widget.userDetail.name);
    emailController = TextEditingController(text: widget.userDetail.email);
    phoneController = TextEditingController(text: widget.userDetail.phone);
    adhaarController = TextEditingController(
      text: widget.userDetail.adhaarNumber ?? '',
    );
    panController = TextEditingController(text: widget.userDetail.pan ?? '');

    // Initialize address controllers - all data will be auto-filled
    labelController = TextEditingController(
      text: widget.userDetail.userAddress?.label ?? '',
    );
    addressLine1Controller = TextEditingController(
      text: widget.userDetail.userAddress?.addressLine1 ?? '',
    );
    addressLine2Controller = TextEditingController(
      text: widget.userDetail.userAddress?.addressLine2 ?? '',
    );
    cityController = TextEditingController(
      text: widget.userDetail.userAddress?.city ?? '',
    );
    stateController = TextEditingController(
      text: widget.userDetail.userAddress?.state ?? '',
    );
    pincodeController = TextEditingController(
      text: widget.userDetail.userAddress?.pincode ?? '',
    );
    countryController = TextEditingController(
      text: widget.userDetail.userAddress?.country ?? '',
    );

    // Initialize notification preferences
    notifyByEmail = widget.userDetail.notifyByEmail;
    notifyBySms = widget.userDetail.notifyBySMS;
    notifyByWhatsApp = widget.userDetail.notifyByWhatsApp;
    status = widget.userDetail.status;
  }
  final RxBool isImageLoading = false.obs;
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();

  Future<void> _handlePick(ImageSource source) async {
    Navigator.pop(context);

    isImageLoading.value = true;

    final XFile? image = await picker.pickImage(source: source);
    if (image == null) {
      isImageLoading.value = false;
      return;
    }

    final file = File(image.path);

    // ✅ SAME validator
    final error = ImageValidator.validateImageSize(
      imageFile: file,
      maxSizeInMB: 2,
    );

    if (error != null) {
      isImageLoading.value = false;
      ToastHelper.error(message: error);
      return;
    }

    setState(() {
      _profilePhoto = file;
    });

    isImageLoading.value = false;
  }

  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () => _handlePick(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => _handlePick(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _updateUser() async {
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

    final userData = UpdateInternalUserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      adhaarNumber: adhaarController.text.trim(),
      pan: panController.text.trim().isEmpty ? null : panController.text.trim(),
      status: status,
      notifyByEmail: notifyByEmail,
      notifyBySms: notifyBySms,
      notifyByWhatsApp: notifyByWhatsApp,
      roleId: selectedRole.value!.id,
      userAddress: UserAddressUpdate(
        label: labelController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        country: countryController.text.trim(),
      ),
    );

    await controller.updateInternalUser(
      userId: widget.userDetail.id,
      shopId: widget.shopId,
      userData: userData,
      profilePhoto: _profilePhoto,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    adhaarController.dispose();
    panController.dispose();
    labelController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit User',
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                          image:
                              _profilePhoto != null
                                  ? DecorationImage(
                                    image: FileImage(_profilePhoto!),
                                    fit: BoxFit.cover,
                                  )
                                  : widget.userDetail.profilePhotoUrl != null
                                  ? DecorationImage(
                                    image: NetworkImage(
                                      widget.userDetail.profilePhotoUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _profilePhoto == null &&
                                    widget.userDetail.profilePhotoUrl == null
                                ? Center(
                                  child: Text(
                                    widget.userDetail.name.isNotEmpty
                                        ? widget.userDetail.name[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Change Photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
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
                keyboardType: TextInputType.name,
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
                enabled: false,
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

              buildStyledTextField(
                labelText: 'PAN Number (Optional)',
                controller: panController,
                hintText: 'Enter PAN number',
                prefixIcon: const Icon(Icons.receipt_long, size: 20),
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.name,
                validator: ValidatorHelper.validatePan,
                digitsOnly: false,
                maxLength: 10,
                onChanged: (value) {
                  panController.value = panController.value.copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              Obx(
                () =>
                    roleController.shopRolesLoading.value
                        ?  ShimmerHelper.buildShimmerTextField()
                        
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
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a role';
                            } else {
                              return null;
                            }
                          },
                        ),
              ),
              const SizedBox(height: 16),

              // Status
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Active'),
                        value: 1,
                        groupValue: status,
                        activeColor: AppColors.primaryLight,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Inactive'),
                        value: 0,
                        groupValue: status,
                        activeColor: AppColors.primaryLight,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notification Preferences
              const Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Receive updates via email'),
                      value: notifyByEmail,
                      activeColor: AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() {
                          notifyByEmail = value;
                        });
                      },
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    SwitchListTile(
                      title: const Text('SMS Notifications'),
                      subtitle: const Text('Receive updates via SMS'),
                      value: notifyBySms,
                      activeColor: AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() {
                          notifyBySms = value;
                        });
                      },
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    SwitchListTile(
                      title: const Text('WhatsApp Notifications'),
                      subtitle: const Text('Receive updates via WhatsApp'),
                      value: notifyByWhatsApp,
                      activeColor: AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() {
                          notifyByWhatsApp = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address Information
              const Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Address Label *',
                controller: labelController,
                hintText: 'e.g., Home, Office',
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                validator: ValidatorHelper.validateAddressLabel,
               
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Address Line 1 *',
                controller: addressLine1Controller,
                hintText: 'Enter address line 1',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                validator: ValidatorHelper.validateAddressLine1,
              
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Address Line 2',
                controller: addressLine2Controller,
                hintText: 'Enter address line 2',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                             validator: ValidatorHelper.validateAddressLine2,

              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'City *',
                      controller: cityController,
                      hintText: 'Enter city',
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(Icons.location_city, size: 20),
                validator: ValidatorHelper.validateCity,

                   
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'State *',
                      controller: stateController,
                      hintText: 'Enter state',
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(Icons.map_outlined, size: 20),
                validator: ValidatorHelper.validateState,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'Pincode *',
                      controller: pincodeController,
                      hintText: 'Enter pincode',
                      keyboardType: TextInputType.number,
                      digitsOnly: true,
                      maxLength: 6,
                      prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                validator: ValidatorHelper.validatePincode,

                     
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'Country *',
                      controller: countryController,
                      hintText: 'Enter country',
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(Icons.public, size: 20),
                validator: ValidatorHelper.validateCountry,
                     
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Update Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        controller.updateUserLoading.value ? null : _updateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        controller.updateUserLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Update User',
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
