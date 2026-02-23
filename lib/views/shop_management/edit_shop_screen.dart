import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/shop_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/create_shop_model.dart';
import 'package:smartbecho/models/shop%20management%20models/my_shops_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/utils/helper/validator/image_validator.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class EditShopScreen extends StatelessWidget {
  final Shop shop;

  EditShopScreen({Key? key, required this.shop}) : super(key: key);

  final ShopManagementController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Pre-fill controllers with existing data
  late final shopNameController = TextEditingController(
    text: shop.shopStoreName,
  );
  late final gstController = TextEditingController(text: shop.gstnumber ?? '');
  late final addressLabelController = TextEditingController(
    text: shop.shopAddress.label ?? 'Shop Address',
  );
  late final addressLine1Controller = TextEditingController(
    text: shop.shopAddress.addressLine1,
  );
  late final addressLine2Controller = TextEditingController(
    text: shop.shopAddress.addressLine2,
  );
  late final cityController = TextEditingController(
    text: shop.shopAddress.city,
  );
  late final stateController = TextEditingController(
    text: shop.shopAddress.state,
  );
  late final pincodeController = TextEditingController(
    text: shop.shopAddress.pincode,
  );
  late final countryController = TextEditingController(
    text: shop.shopAddress.country,
  );

  // Social media controllers
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();
  final linkedinController = TextEditingController();

  final selectedImage = Rx<File?>(null);
  final existingImageUrl = Rx<String?>(null);
  final RxBool isImageLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  EditShopScreen._internal({required this.shop}) {
    // Pre-fill social media links
    existingImageUrl.value = shop.profilePhotoUrl;

    for (var link in shop.socialMediaLinks) {
      String platform = (link['platform'] ?? '').toString().toLowerCase();
      String url = link['url'] ?? '';

      if (platform == 'facebook') {
        facebookController.text = url;
      } else if (platform == 'instagram') {
        instagramController.text = url;
      } else if (platform == 'twitter') {
        twitterController.text = url;
      } else if (platform == 'linkedin') {
        linkedinController.text = url;
      }
    }
  }

  // factory EditShopScreen({required Shop shop}) {
  //   return EditShopScreen._internal(shop: shop);
  // }

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

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // Build social media links list
      List<SocialMediaLink> socialLinks = [];

      if (facebookController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'Facebook', url: facebookController.text),
        );
      }

      if (instagramController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'Instagram', url: instagramController.text),
        );
      }

      if (twitterController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'Twitter', url: twitterController.text),
        );
      }

      if (linkedinController.text.isNotEmpty) {
        socialLinks.add(
          SocialMediaLink(platform: 'LinkedIn', url: linkedinController.text),
        );
      }

      final shopData = CreateShopModel(
        email: '', // Not needed for update
        password: '', // Not needed for update
        phone: '', // Not needed for update
        adhaarNumber: '', // Not needed for update
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

      controller.updateShop(
        shopId: shop.id.toString(),
        shopData: shopData,
        shopImage: selectedImage.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Shop'), elevation: 0),
      body: Obx(
        () =>
            controller.updateShopLoading.value == true
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
                                  onTap:
                                      isImageLoading.value ? null : pickImage,
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
                                            : existingImageUrl.value != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                existingImageUrl.value!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return _placeholder();
                                                },
                                              ),
                                            )
                                            : _placeholder(),
                                  ),
                                ),
                              ),

                              // Obx(
                              //   () => GestureDetector(
                              //     onTap: pickImage,
                              //     child: Container(
                              //       height: 150,
                              //       width: 150,
                              //       decoration: BoxDecoration(
                              //         color: Colors.grey[200],
                              //         border: Border.all(
                              //           color: Colors.grey[400]!,
                              //           width: 2,
                              //         ),
                              //         borderRadius: BorderRadius.circular(12),
                              //       ),
                              //       child:
                              //           selectedImage.value != null
                              //               ? ClipRRect(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10),
                              //                 child: Image.file(
                              //                   selectedImage.value!,
                              //                   fit: BoxFit.cover,
                              //                 ),
                              //               )
                              //               : existingImageUrl.value != null
                              //               ? ClipRRect(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10),
                              //                 child: Image.network(
                              //                   existingImageUrl.value!,
                              //                   fit: BoxFit.cover,
                              //                   errorBuilder: (
                              //                     context,
                              //                     error,
                              //                     stackTrace,
                              //                   ) {
                              //                     return Column(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment
                              //                               .center,
                              //                       children: [
                              //                         Icon(
                              //                           Icons.add_a_photo,
                              //                           size: 50,
                              //                           color: Colors.grey[600],
                              //                         ),
                              //                         SizedBox(height: 8),
                              //                         Text(
                              //                           'Change Image',
                              //                           style: TextStyle(
                              //                             color:
                              //                                 Colors.grey[600],
                              //                             fontSize: 12,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     );
                              //                   },
                              //                 ),
                              //               )
                              //               : Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment.center,
                              //                 children: [
                              //                   Icon(
                              //                     Icons.add_a_photo,
                              //                     size: 50,
                              //                     color: Colors.grey[600],
                              //                   ),
                              //                   SizedBox(height: 8),
                              //                   Text(
                              //                     'Add Shop Image',
                              //                     style: TextStyle(
                              //                       color: Colors.grey[600],
                              //                       fontSize: 12,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to change shop image',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
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
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'GST Number (Optional)',
                          controller: gstController,
                          hintText: 'Enter GST number',
                          textCapitalization: TextCapitalization.characters,
                          validator: ValidatorHelper.validateGSTNumber,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 24),

                        // Shop Address Section
                        _buildSectionHeader('Shop Address'),
                        SizedBox(height: 12),
                        buildStyledTextField(
                          labelText: 'Address Label',
                          controller: addressLabelController,
                          hintText: 'e.g., Shop Address, Main Store',
                          validator: ValidatorHelper.validateAddressLabel,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Address Line 1',
                          controller: addressLine1Controller,
                          hintText: 'Street address, building name',
                          validator: ValidatorHelper.validateAddressLine1,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'Address Line 2',
                          controller: addressLine2Controller,
                          hintText: 'Area, landmark',
                          validator: ValidatorHelper.validateAddressLine1,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'City',
                                controller: cityController,
                                hintText: 'Enter city',
                                validator: ValidatorHelper.validateCity,
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildStyledTextField(
                                labelText: 'State',
                                controller: stateController,
                                hintText: 'Enter state',
                                validator: ValidatorHelper.validateState,
                                keyboardType: TextInputType.name,
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
                                keyboardType: TextInputType.name,
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
                        SizedBox(height: 16),
                        buildStyledTextField(
                          labelText: 'LinkedIn URL',
                          controller: linkedinController,
                          hintText: 'https://linkedin.com/company/yourpage',
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
                              'Update Shop',
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

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          'Add Shop Image',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
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
