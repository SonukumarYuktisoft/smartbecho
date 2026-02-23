import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/shop_management_controller.dart';
import 'package:smartbecho/models/auth/gst%20model/gst_response_model.dart';
import 'package:smartbecho/models/shop%20management%20models/create_shop_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/utils/helper/validator/image_validator.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class CreateAnotherShop extends StatelessWidget {
  final ShopManagementController controller = Get.find();
  final AppConfig _config = AppConfig.instance;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final adhaarController = TextEditingController();
  final shopNameController = TextEditingController();
  final gstController = TextEditingController();
  final addressLabelController = TextEditingController(text: 'Shop Address');
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController(text: 'India');
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();

  final obscurePassword = true.obs;
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  final selectedImage = Rx<File?>(null);
  final RxBool isImageLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    isImageLoading.value = true;

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      isImageLoading.value = false;
      return;
    }

    final file = File(image.path);

    final error = ImageValidator.validateImageSize(
      imageFile: file,
      maxSizeInMB: 2,
    );

    if (error != null) {
      isImageLoading.value = false;
      ToastHelper.error(message: error);
      return;
    }

    selectedImage.value = file;
    isImageLoading.value = false;
  }

  final RxBool isGstValidating = false.obs;
  final RxBool isGstValid = false.obs;
  final RxString gstValidationMessage = ''.obs;

  final String _gstApiKey = 'your-api-key-here';

  Future<void> validateAndFetchGstDetails(String gstNumber) async {
    isGstValid.value = false;
    gstValidationMessage.value = '';

    if (gstNumber.length != 15) {
      return;
    }

    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
    );

    if (!gstRegex.hasMatch(gstNumber)) {
      gstValidationMessage.value = 'Invalid GST format';
      return;
    }

    try {
      isGstValidating.value = true;

      final String apiUrl = '${_config.gstValidationUrl}/$gstNumber';
      // Use your ApiServices instance
      final ApiServices _apiService = ApiServices();

      dio.Response? response = await _apiService.requestGetForApi(
        url: apiUrl,
        authToken: false,
      );

      if (response != null && response.statusCode == 200) {
        GstResponseModel gstResponse = GstResponseModel.fromJson(response.data);

        if (gstResponse.flag && gstResponse.data != null) {
          isGstValid.value = true;
          gstValidationMessage.value = 'GST verified successfully';

          _autoFillFromGstData(gstResponse.data!);

          Get.snackbar(
            'Success',
            'GST verified and address fields auto-filled',
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          isGstValid.value = false;
          gstValidationMessage.value = gstResponse.message;

          Get.snackbar(
            'Invalid GST',
            gstResponse.message,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        gstValidationMessage.value = 'Failed to verify GST';
      }
    } catch (e) {
      print('GST validation error: $e');
      gstValidationMessage.value = 'Error verifying GST';

      Get.snackbar(
        'Error',
        'Failed to verify GST. Please try again.',
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isGstValidating.value = false;
    }
  }

  // ADD THIS METHOD - Auto-fill fields from GST data
  void _autoFillFromGstData(GstData gstData) {
    try {
      // Fill shop store name from trade name
      if (gstData.tradeNam.isNotEmpty && shopNameController.text.isEmpty) {
        shopNameController.text = gstData.tradeNam;
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

        // Address Line 2: Location
        if (addr.loc.isNotEmpty && addressLine2Controller.text.isEmpty) {
          addressLine2Controller.text = addr.loc;
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

      print('✅ Auto-filled address from GST data');
    } catch (e) {
      print('❌ Error auto-filling from GST data: $e');
    }
  }

  void clearGstValidation() {
    isGstValid.value = false;
    isGstValidating.value = false;
    gstValidationMessage.value = '';
  }

  // onGstChanged(String value) {
  //   if (value.length == 15 && isValidGst(value)) {
  //     final pan = extractPanFromGst(value);
  //     panController.text = pan;
  //   }
  // }
  String extractPanFromGst(String gst) {
    return gst.substring(2, 12);
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // Build social media links list
      List<SocialMediaLink> socialLinks = [];

      if (facebookController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'facebook', url: facebookController.text),
        );
      }

      if (instagramController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'instagram', url: instagramController.text),
        );
      }

      if (twitterController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'twitter', url: twitterController.text),
        );
      }

      final shopData = CreateShopModel(
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        adhaarNumber: adhaarController.text.trim(),
        shopStoreName: shopNameController.text.trim(),
        shopGstNumber: gstController.text.trim(),
        shopAddress: ShopAddressCreate(
          label: addressLabelController.text.trim(),
          addressLine1: addressLine1Controller.text.trim(),
          addressLine2: addressLine2Controller.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          country: countryController.text.trim(),
        ),
        socialMediaLinks: socialLinks,
      );

      controller.createShop(shopData: shopData, shopImage: selectedImage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Shop'), elevation: 0),
      body: Obx(
        () =>
            controller.createShopLoading.value
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker Section
                        Center(
                          child: Column(
                            children: [
                              Obx(
                                () => GestureDetector(
                                  onTap: pickImage,
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        isImageLoading.value
                                            ? _imageShimmer()
                                            : selectedImage.value != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                selectedImage.value!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_a_photo,
                                                  size: 50,
                                                  color: Colors.grey[600],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Add Shop Image',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload shop image',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Account Information Section
                        _buildSectionHeader('Account Information'),
                        SizedBox(height: 12),
                        buildStyledTextField(
                          labelText: 'Email',
                          controller: emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // buildStyledTextField(
                        //   labelText: 'Password',
                        //   controller: passwordController,
                        //   hintText: 'Enter your password',
                        //   obscureText: true,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Password is required';
                        //     }
                        //     if (value.length < 8) {
                        //       return 'Password must be at least 8 characters';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        Obx(
                          () => buildStyledTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'Password',
                            obscureText: obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                // color: AppColors.primaryLight.withValues(
                                //   alpha: 0.7,
                                // ),
                              ),
                              onPressed: togglePasswordVisibility,
                            ),
                            validator: ValidatorHelper.validatePassword,
                          ),
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Phone Number',
                          controller: phoneController,
                          hintText: 'Enter 10-digit phone number',
                          keyboardType: TextInputType.phone,
                          digitsOnly: true,
                          maxLength: 10,
                          validator: ValidatorHelper.validatePhoneNumber,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Aadhaar Number',
                          controller: adhaarController,
                          hintText: 'Enter 12-digit Aadhaar number',
                          keyboardType: TextInputType.number,
                          digitsOnly: true,
                          maxLength: 12,
                          validator: ValidatorHelper.validateAdhaarNumber,
                        ),
                        SizedBox(height: 24),

                        // Shop Information Section
                        _buildSectionHeader('Shop Information'),
                        SizedBox(height: 12),
                        buildStyledTextField(
                          labelText: 'Shop Store Name',
                          controller: shopNameController,
                          hintText: 'Enter shop name',
                          validator: ValidatorHelper.validateShopStoreName,
                        ),
                        SizedBox(height: 16),
                        // buildStyledTextField(
                        //   labelText: 'GST Number (Optional)',
                        //   controller: gstController,
                        //   hintText: 'Enter GST number',
                        //   textCapitalization: TextCapitalization.characters,
                        //   digitsOnly: false,
                        //   maxLength: 15,
                        //   validator: (value) {
                        //     if (value != null && value.length > 15) {
                        //       return 'GST number should not exceed 15 characters';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        // REPLACE THE EXISTING GST TextField WITH THIS:
                        Obx(
                          () => buildStyledTextField(
                            controller: gstController,
                            hintText: 'GST Number 27ABCDE1234F1Z5',
                            labelText: 'GST Number (Optional)',
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            digitsOnly: false,
                            maxLength: 15,
                            suffixIcon:
                                isGstValidating.value
                                    ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryLight,
                                              ),
                                        ),
                                      ),
                                    )
                                    : isGstValid.value
                                    ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : gstValidationMessage.value.isNotEmpty
                                    ? Icon(Icons.error, color: Colors.red)
                                    : null,
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
                              if (!isGstValid.value &&
                                  gstValidationMessage.value.isNotEmpty) {
                                return 'GST number not registered or invalid';
                              }

                              // ✅ All validations passed
                              return null;
                            },
                            onChanged: (value) {
                              // Convert to uppercase
                              final upperValue = value.toUpperCase();
                              gstController.value = gstController.value
                                  .copyWith(
                                    text: upperValue,
                                    selection: TextSelection.collapsed(
                                      offset: upperValue.length,
                                    ),
                                  );

                              // Validate when 15 characters
                              if (upperValue.length == 15) {
                                validateAndFetchGstDetails(upperValue);
                              } else {
                                clearGstValidation();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 8),

                        // ADD VALIDATION MESSAGE BELOW GST FIELD
                        Obx(() {
                          if (gstValidationMessage.value.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isGstValid.value
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isGstValid.value
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isGstValid.value
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color:
                                      isGstValid.value
                                          ? Colors.green
                                          : Colors.orange,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    gstValidationMessage.value,
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
                        SizedBox(height: 16),

                        // ADD AUTO-FILL INFO MESSAGE
                        Obx(() {
                          if (isGstValid.value) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
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
                        SizedBox(height: 24),

                        // Shop Address Section
                        _buildSectionHeader('Shop Address'),
                        SizedBox(height: 12),
                        buildStyledTextField(
                          labelText: 'Address Label',
                          controller: addressLabelController,
                          hintText: 'e.g., Shop Address, Main Store',
                          validator: ValidatorHelper.validateAddressLabel,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Address Line 1',
                          controller: addressLine1Controller,
                          hintText: 'Street address, building name',
                          validator: ValidatorHelper.validateAddressLine1,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Address Line 2',
                          controller: addressLine2Controller,
                          hintText: 'Area, landmark',
                          validator: ValidatorHelper.validateAddressLine2,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'State',
                                controller: stateController,
                                hintText: 'Enter state',
                                validator: ValidatorHelper.validateState,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'City',
                                controller: cityController,
                                hintText: 'Enter city',
                                validator: ValidatorHelper.validateCity,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'Pincode',
                                controller: pincodeController,
                                hintText: 'Enter pincode',
                                keyboardType: TextInputType.number,
                                digitsOnly: true,
                                maxLength: 6,
                                validator: ValidatorHelper.validatePincode,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'Country',
                                controller: countryController,
                                hintText: 'Enter country',
                                validator: ValidatorHelper.validateCountry,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Social Media Links Section
                        _buildSectionHeader('Social Media Links (Optional)'),
                        SizedBox(height: 12),
                        buildStyledTextField(
                          labelText: 'Facebook URL',
                          controller: facebookController,
                          hintText: 'https://facebook.com/yourpage',
                          keyboardType: TextInputType.url,
                          textCapitalization: TextCapitalization.none,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Instagram URL',
                          controller: instagramController,
                          hintText: 'https://instagram.com/yourpage',
                          keyboardType: TextInputType.url,
                          textCapitalization: TextCapitalization.none,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Twitter URL',
                          controller: twitterController,
                          hintText: 'https://twitter.com/yourpage',
                          keyboardType: TextInputType.url,
                          textCapitalization: TextCapitalization.none,
                        ),
                        SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Create Shop',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      ),
    );
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF374151),
      ),
    );
  }
}
