
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/controllers/profile/user_profile_controller.dart';
import 'package:smartbecho/models/profile/update_user_profile_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class UpdateUserProfileScreen extends StatefulWidget {
  const UpdateUserProfileScreen({super.key});

  @override
  State<UpdateUserProfileScreen> createState() =>
      _UpdateUserProfileScreenState();
}

class _UpdateUserProfileScreenState extends State<UpdateUserProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController nameController;

  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController adhaarController;
  late TextEditingController gstController;
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

  @override
  void initState() {
    super.initState();

    final user = controller.userProfile.value!;
    final address = user.userAddress;

    // Initialize controllers with existing data
    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone);
    adhaarController = TextEditingController(text: user.adhaarNumber ?? '');
    gstController = TextEditingController(text: user.gstnumber ?? '');

    // Initialize address controllers
    labelController = TextEditingController(text: address?.label ?? '');
    addressLine1Controller = TextEditingController(
      text: address?.addressLine1 ?? '',
    );
    addressLine2Controller = TextEditingController(
      text: address?.addressLine2 ?? '',
    );
    cityController = TextEditingController(text: address?.city ?? '');
    stateController = TextEditingController(text: address?.state ?? '');
    pincodeController = TextEditingController(text: address?.pincode ?? '');
    countryController = TextEditingController(text: address?.country ?? '');

    // Initialize notification preferences
    notifyByEmail = user.notifyByEmail;
    notifyBySms = user.notifyBySMS;
    notifyByWhatsApp = user.notifyByWhatsApp;
    status = user.status;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      setState(() {
                        _profilePhoto = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        _profilePhoto = File(image.path);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = UpdateUserProfileModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      adhaarNumber: adhaarController.text.trim(),
      gstNumber:
          gstController.text.trim().isEmpty ? null : gstController.text.trim(),
      status: status,
      notifyByEmail: notifyByEmail,
      notifyBySms: notifyBySms,
      notifyByWhatsApp: notifyByWhatsApp,
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

    await controller.updateUserProfile(
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
    gstController.dispose();
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
    final user = controller.userProfile.value!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
                                  : user.profilePhotoUrl != null
                                  ? DecorationImage(
                                    image: NetworkImage(user.profilePhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _profilePhoto == null &&
                                    user.profilePhotoUrl == null
                                ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primaryLight,
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

              // Personal Information
              const Text(
                'Personal Information',
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
                hintText: 'Enter Name',
                keyboardType: TextInputType.name,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                textCapitalization: TextCapitalization.none,
                validator: ValidatorHelper.validateName,
               autofillHints: const [AutofillHints.name],
              ),
              buildStyledTextField(
                labelText: 'Email *',
                controller: emailController,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                textCapitalization: TextCapitalization.none,
                validator: ValidatorHelper.validateEmail,
                readOnly: true,
                enabled: false
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
               autofillHints: const [AutofillHints.telephoneNumber],
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
                enabled: false
              ),
              // const SizedBox(height: 16),

              // buildStyledTextField(
              //   labelText: 'GST Number (Optional)',
              //   controller: gstController,
              //   hintText: 'Enter GST number',
              //   prefixIcon: const Icon(Icons.receipt_long, size: 20),
              //   textCapitalization: TextCapitalization.characters,
              //   validator: ValidatorHelper.validateGSTNumber,
              // ),
              const SizedBox(height: 16),

              // Status
              const Text(
                'Account Status',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address label';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Address Line 1 *',
                controller: addressLine1Controller,
                hintText: 'Enter address line 1',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address line 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Address Line 2',
                controller: addressLine2Controller,
                hintText: 'Enter address line 2',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pincode';
                        }
                        if (value.length != 6) {
                          return 'Pincode must be 6 digits';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
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
                        controller.updateUserLoading.value
                            ? null
                            : _updateProfile,
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
                              'Update Profile',
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
