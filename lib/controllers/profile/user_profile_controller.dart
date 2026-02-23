// controllers/profile/user_profile_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/models/profile/user_profile_model.dart';
import 'package:smartbecho/models/profile/update_user_profile_model.dart';
import 'dart:developer';
import 'package:smartbecho/services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/route_services.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class ProfileController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Loading and error states
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isUploadingPhoto = false.obs;
  final updateUserLoading = false.obs;

  // Profile response data
  ProfileResponse? profileResponse;
  final userProfile = Rxn<UserProfile>();
  final userId = ''.obs;
  final notifyByEmail = false.obs;
  final notifyBySMS = false.obs;
  final notifyByWhatsApp = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // Load user profile from API
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      log("Fetching user profile...");

      final response = await _apiService.requestGetForApi(
        url: _config.profile,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        profileResponse = ProfileResponse.fromJson(response.data);
        userProfile.value = profileResponse!.payload;
        final profilePhotoUrl = userProfile.value!.profilePhotoUrl;
        userId.value = userProfile.value!.id.toString();
        if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
          Get.find<DashboardController>().updateProfilePhoto(
            userId: userProfile.value!.id.toString(),
            url: profilePhotoUrl,
          );
        }

        log("✅ User profile loaded successfully");
        log("User ID: ${userProfile.value!.id}");
        log("Email: ${userProfile.value!.email}");
        log("Phone: ${userProfile.value!.phone}");
      } else {
        throw Exception(
          'Failed to load profile. Status: ${response?.statusCode}',
        );
      }
    } catch (error) {
      log("❌ Error loading user profile: $error");
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile with profile photo
  Future<void> updateUserProfile({
    required UpdateUserProfileModel userData,
    File? profilePhoto,
  }) async {
    try {
      updateUserLoading.value = true;

      log("Updating user profile...");

      // Prepare form data
      dio.FormData formData = dio.FormData();

      // Add user data as JSON string
      formData.fields.add(MapEntry('user', jsonEncode(userData.toJson())));

      log("User data: ${jsonEncode(userData.toJson())}");

      // Add profile photo if provided
      if (profilePhoto != null && await profilePhoto.exists()) {
        try {
          String extension = profilePhoto.path.split('.').last.toLowerCase();
          String fileName = 'profile_photo.$extension';

          String contentType = 'image/jpeg';
          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          }

          formData.files.add(
            MapEntry(
              'profilePhoto',
              await dio.MultipartFile.fromFile(
                profilePhoto.path,
                filename: fileName,
                contentType: dio.DioMediaType.parse(contentType),
              ),
            ),
          );

          log('✅ Profile photo added: $fileName ($contentType)');
        } catch (fileError) {
          log('❌ Error processing profile photo: $fileError');
        }
      } else {
        log('ℹ️ No profile photo provided');
      }

      log("Sending update request to: ${_config.updateProfile}");

      dio.Response? response = await _apiService.requestMultipartApi(
        url: '${_config.baseUrl}/users/update/$userId',
        method: 'put',
        formData: formData,
        authToken: true,
        showToast: true,
      );

      log("Response Status: ${response?.statusCode}");
      log("Response Data: ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ User profile updated successfully");

        // Refresh the profile
        await loadUserProfile();

        // Navigate back
        Get.back();
      } else {
        String errorMessage = 'Failed to update profile';

        if (response?.data != null) {
          if (response!.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      log("❌ Error updating user profile: $error");
    } finally {
      updateUserLoading.value = false;
    }
  }

  // Upload profile photo only
  Future<void> uploadProfilePhoto() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        log('No image selected');
        return;
      }

      isUploadingPhoto.value = true;

      final imageFile = File(pickedFile.path);
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: pickedFile.name,
        ),
      });

      log('Uploading profile photo to: ${_config.updateProfilePhoto}');

      final response = await _apiService.requestPutForApi(
        url: _config.updateProfilePhoto,
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 200) {
        profileResponse = ProfileResponse.fromJson(response.data);
        userProfile.value = profileResponse!.payload;

        log('✅ Profile photo uploaded successfully');

        await loadUserProfile();
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      log('❌ Error uploading profile photo: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Logout handler
  Future<void> logout() async {
    log("🚪 Logging out user due to session expiry...");

    try {
      await SharedPreferencesHelper.clearAll();
      await SecureStorageHelper.clearAll();

      RouteService.toLogin();

      log("✅ User logged out successfully");
    } catch (e) {
      log("❌ Logout error: $e");
    }
  }
}














// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:smartbecho/controllers/dashboard_controller.dart';
// import 'package:smartbecho/models/profile/user_profile_model.dart';
// import 'dart:developer';
// import 'dart:io';
// import 'package:smartbecho/services/api_services.dart';
// import 'package:smartbecho/services/app_config.dart';
// import 'package:smartbecho/services/shared_preferences_services.dart';
// import 'package:smartbecho/utils/common_profile_button.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileController extends GetxController {
//   final ApiServices _apiService = ApiServices();
//   final AppConfig _config = AppConfig.instance;
//   final ImagePicker _imagePicker = ImagePicker();

//   // Loading and error states
//   final isLoading = false.obs;
//   final hasError = false.obs;
//   final errorMessage = ''.obs;
//   final isUploadingPhoto = false.obs;

//   // Profile response data
//   ProfileResponse? profileResponse;
//   Shop? get currentShop => profileResponse?.payload.primaryShop;

//   // Observable profile data
//   final isEditing = false.obs;
//   final shopName = ''.obs;
//   final shopId = ''.obs;
//   final emailAddress = ''.obs;
//   final shopAddress = ''.obs;
//   final nearLandmark = ''.obs;
//   final city = ''.obs;
//   final state = ''.obs;
//   final pinCode = ''.obs;
//   final phoneNumber = ''.obs;
//   final accountStatus = ''.obs;
//   final memberSince = ''.obs;
//   final passwordStatus = ''.obs;
//   final userId = ''.obs;
//   final gstNumber = ''.obs;
//   final adhaarNumber = ''.obs;
  
//   final country = ''.obs;
//   final profilePhotoUrl = ''.obs;

//   // Social media
//   final socialMediaLinks = <SocialMediaLink>[].obs;
//   final facebookUrl = ''.obs;
//   final instagramUrl = ''.obs;
//   final websiteUrl = ''.obs;

//   // Notification preferences
//   final notifyByEmail = false.obs;
//   final notifyBySMS = false.obs;
//   final notifyByWhatsApp = false.obs;

//   // Text editing controllers
//   final shopNameController = TextEditingController();
//   final gstNumberController = TextEditingController();
//   final adhaarNumberController = TextEditingController();
//   final phoneNumberController = TextEditingController();
//   final cityController = TextEditingController();
//   final stateController = TextEditingController();
//   final pinCodeController = TextEditingController();
//   final countryController = TextEditingController();
//   final facebookUrlController = TextEditingController();
//   final instagramUrlController = TextEditingController();
//   final websiteUrlController = TextEditingController();

//   // Computed properties
//   String get fullAddress {
//     final parts = <String>[];

//     if (shopAddress.value.isNotEmpty && shopAddress.value != 'N/A') {
//       parts.add(shopAddress.value);
//     }
//     if (nearLandmark.value.isNotEmpty &&
//         nearLandmark.value != 'Near Landmark') {
//       parts.add(nearLandmark.value);
//     }

//     final cityState = '${city.value}, ${state.value}';
//     if (cityState != ', ') parts.add(cityState);

//     if (pinCode.value.isNotEmpty && pinCode.value != '000000') {
//       parts.add(pinCode.value);
//     }

//     return parts.join(', ');
//   }

//   String get formattedMemberSince {
//     final creationDate = profileResponse?.payload.creationDate;
//     if (creationDate != null) {
//       try {
//         final parts = creationDate.split('-');
//         if (parts.length == 3) {
//           return '${parts[2]}/${parts[1]}/${parts[0]}';
//         }
//       } catch (e) {
//         log('Error parsing creation date: $e');
//       }
//     }
//     return memberSince.value;
//   }

//   String get formattedPasswordUpdated {
//     final lastLoginTime = profileResponse?.payload.lastLoginTime;
//     if (lastLoginTime != null) {
//       try {
//         final dateTime = DateTime.parse(lastLoginTime);
//         return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
//       } catch (e) {
//         log('Error parsing last login time: $e');
//       }
//     }
//     return 'Not updated';
//   }

//   String get profileInitials {
//     if (shopName.value.isEmpty) return 'U';

//     final words = shopName.value.trim().split(' ');
//     if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
//       return '${words[0][0]}${words[1][0]}'.toUpperCase();
//     }
//     if (words.isNotEmpty && words[0].isNotEmpty) {
//       return words[0][0].toUpperCase();
//     }
//     return 'U';
//   }

//   String get shopID => shopId.value;

//   @override
//   void onInit() {
//     super.onInit();
//     loadProfileFromApi();
//   }

//   @override
//   void onClose() {
//     _disposeControllers();
//     super.onClose();
//   }

//   void _disposeControllers() {
//     shopNameController.dispose();
//     gstNumberController.dispose();
//     adhaarNumberController.dispose();
//     phoneNumberController.dispose();
//     cityController.dispose();
//     stateController.dispose();
//     pinCodeController.dispose();
//     countryController.dispose();
//     facebookUrlController.dispose();
//     instagramUrlController.dispose();
//     websiteUrlController.dispose();
//   }

//   // Load profile data from API
//   Future<void> loadProfileFromApi() async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;
//       errorMessage.value = '';

//       final response = await _apiService.requestGetForApi(
//         url: _config.profile,
//         authToken: true,
//       );

//       if (response != null && response.statusCode == 200) {
//         profileResponse = ProfileResponse.fromJson(response.data);
//         _updateProfileData(profileResponse!.payload);
//       } else {
//         _handleError('Failed to load profile. Status: ${response?.statusCode}');
//       }
//     } catch (e) {
//       _handleError('Error loading profile: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _handleError(String message) {
//     hasError.value = true;
//     errorMessage.value = message;
//     log(message);
//   }

//   // Update observable variables with API data
//   void _updateProfileData(UserProfile profile) {
//     // Get primary shop (first shop where user is owner, or first active shop)
//     final shop = profile.primaryShop;

//     // Basic user info
//     emailAddress.value = profile.email;
//     phoneNumber.value = profile.phone;
//     userId.value = '#${profile.id}';
//     adhaarNumber.value = profile.adhaarNumber ?? '';
//     profilePhotoUrl.value = profile.profilePhotoUrl ?? '';

//     // User-level notification preferences
//     notifyByEmail.value = profile.notifyByEmail;
//     notifyBySMS.value = profile.notifyBySMS;
//     notifyByWhatsApp.value = profile.notifyByWhatsApp;

//     //

//     if (profile.gstnumber != null) {
//       gstNumber.value = profile.gstnumber ?? '';
//     }
//     if (profile.adhaarNumber != null) {
//       adhaarNumber.value = profile.adhaarNumber ?? '';
//     }

//     // Shop-specific info
//     if (shop != null) {
//       shopName.value = shop.shopStoreName;
//       shopId.value = shop.shopId;
//       // gstNumber.value = shop.gstnumber ?? '';

//       // Shop address
//       if (profile.userAddress != null) {
//         final address = profile.userAddress!;

//         final addressParts = <String>[];
//         if (address.addressLine1?.isNotEmpty ?? false) {
//           addressParts.add(address.addressLine1!);
//         }
//         if (address.addressLine2?.isNotEmpty ?? false) {
//           addressParts.add(address.addressLine2!);
//         }

//         shopAddress.value = addressParts.join(', ');
//         nearLandmark.value = address.landmark ?? '';
//         city.value = address.city;
//         state.value = address.state;
//         pinCode.value = address.pincode;
//         country.value = address.country;
//       }

//       // Shop social media
//       socialMediaLinks.assignAll(shop.socialMediaLinks);
//       facebookUrl.value = _getSocialMediaLink('Facebook');
//       instagramUrl.value = _getSocialMediaLink('Instagram');
//       websiteUrl.value = _getSocialMediaLink('Website');
//     }

//     // Update status and dates
//     accountStatus.value = profile.status == 1 ? 'Active' : 'Inactive';
//     memberSince.value = formattedMemberSince;

//     // Sync controllers only when not editing
//     if (!isEditing.value) {
//       _syncControllersWithData();
//     }
//   }

//   void _syncControllersWithData() {
//     shopNameController.text = shopName.value;
//     gstNumberController.text = gstNumber.value;
//     adhaarNumberController.text = adhaarNumber.value;
//     phoneNumberController.text = phoneNumber.value;
//     cityController.text = city.value;
//     stateController.text = state.value;
//     pinCodeController.text = pinCode.value;
//     countryController.text = country.value;
//     facebookUrlController.text = facebookUrl.value;
//     instagramUrlController.text = instagramUrl.value;
//     websiteUrlController.text = websiteUrl.value;
//   }

//   // Save profile changes to API
//   Future<void> saveProfile() async {
//     try {
//       isLoading.value = true;

//       if (profileResponse == null || currentShop == null) {
//         throw Exception('Profile data not loaded');
//       }

//       // Update observable values from controllers
//       _updateValuesFromControllers();

//       // Prepare shop update data
//       final shopUpdateData = {
//         'id': currentShop!.id,
//         'shopId': currentShop!.shopId,
//         'shopStoreName': shopName.value,
//         'shopAddress': {
//           'id': currentShop!.shopAddress?.id ?? 0,
//           'label': currentShop!.shopAddress?.label,
//           'addressLine1': shopAddress.value.split(', ').first,
//           'addressLine2':
//               shopAddress.value.split(', ').length > 1
//                   ? shopAddress.value.split(', ').skip(1).join(', ')
//                   : null,
//           'landmark': nearLandmark.value.isNotEmpty ? nearLandmark.value : null,
//           'city': city.value,
//           'state': state.value,
//           'country': country.value,
//           'pincode': pinCode.value,
//         },
//         'socialMediaLinks': _buildSocialMediaLinks(),
//         'profilePhotoUrl':
//             profilePhotoUrl.value.isNotEmpty ? profilePhotoUrl.value : null,
//         'gstnumber': gstNumber.value.isNotEmpty ? gstNumber.value : null,
//         'isActive': currentShop!.isActive,
//       };

//       // Build update URL - assuming the endpoint is for shop updates
//       String updateUrl = _config.updateProfile;
//       if (updateUrl.contains('{id}')) {
//         updateUrl = updateUrl.replaceAll('{id}', currentShop!.id.toString());
//       } else if (!updateUrl.endsWith('/${currentShop!.id}')) {
//         updateUrl = '$updateUrl/${currentShop!.id}';
//       }

//       log('Update URL: $updateUrl');
//       log('Update Data: $shopUpdateData');

//       final response = await _apiService.requestPutForApi(
//         url: updateUrl,
//         dictParameter: shopUpdateData,
//         authToken: true,
//       );

//       if (response != null && response.statusCode == 200) {
//         isEditing.value = false;
//         _showSuccessSnackbar('Profile updated successfully');
//         await loadProfileFromApi();
//       } else {
//         _showErrorSnackbar(
//           'Failed to update profile. Status: ${response?.statusCode}',
//         );
//       }
//     } catch (e) {
//       log('Error saving profile: $e');
//       _showErrorSnackbar('Error updating profile: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _updateValuesFromControllers() {
//     shopName.value = shopNameController.text;
//     gstNumber.value = gstNumberController.text;
//     adhaarNumber.value = adhaarNumberController.text;
//     phoneNumber.value = phoneNumberController.text;
//     city.value = cityController.text;
//     state.value = stateController.text;
//     pinCode.value = pinCodeController.text;
//     country.value = countryController.text;
//     facebookUrl.value = facebookUrlController.text;
//     instagramUrl.value = instagramUrlController.text;
//     websiteUrl.value = websiteUrlController.text;
//   }

//   List<Map<String, dynamic>> _buildSocialMediaLinks() {
//     final links = <Map<String, dynamic>>[];

//     if (facebookUrl.value.isNotEmpty) {
//       links.add({
//         'id': _getSocialMediaId('Facebook'),
//         'platform': 'Facebook',
//         'url': facebookUrl.value,
//       });
//     }
//     if (instagramUrl.value.isNotEmpty) {
//       links.add({
//         'id': _getSocialMediaId('Instagram'),
//         'platform': 'Instagram',
//         'url': instagramUrl.value,
//       });
//     }
//     if (websiteUrl.value.isNotEmpty) {
//       links.add({
//         'id': _getSocialMediaId('Website'),
//         'platform': 'Website',
//         'url': websiteUrl.value,
//       });
//     }

//     return links;
//   }

//   int _getSocialMediaId(String platform) {
//     final link = socialMediaLinks.firstWhereOrNull(
//       (link) => link.platform.toLowerCase() == platform.toLowerCase(),
//     );
//     return link?.id ?? 0;
//   }

//   // Toggle edit mode
//   void toggleEditMode() {
//     isEditing.value = !isEditing.value;
//     if (isEditing.value) {
//       _syncControllersWithData();
//     }
//   }

//   // Cancel editing
//   void cancelEdit() {
//     isEditing.value = false;
//     if (profileResponse != null) {
//       _updateProfileData(profileResponse!.payload);
//     }
//   }

//   // Upload profile photo
//   Future<void> uploadProfilePhoto() async {
//     try {
//       final source = await _showImageSourceDialog();
//       if (source == null) return;

//       final pickedFile = await _imagePicker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (pickedFile == null) {
//         log('No image selected');
//         return;
//       }

//       isUploadingPhoto.value = true;

//       final imageFile = File(pickedFile.path);
//       final formData = dio.FormData.fromMap({
//         'file': await dio.MultipartFile.fromFile(
//           imageFile.path,
//           filename: pickedFile.name,
//         ),
//       });

//       log('Uploading profile photo to: ${_config.updateProfilePhoto}');

//       final response = await _apiService.requestPutForApi(
//         url: _config.updateProfilePhoto,
//         formData: formData,
//         authToken: true,
//       );

//       if (response != null && response.statusCode == 200) {
//         profileResponse = ProfileResponse.fromJson(response.data);
//         profilePhotoUrl.value = profileResponse?.payload.profilePhotoUrl ?? '';
//         final profileImage = profileResponse?.payload.profilePhotoUrl;
//         final shopId = profileResponse?.payload.userShops[0].shop.id;

//         if (profileImage != null) {
//           Get.find<DashboardController>().updateProfilePhoto(
//             shopId: shopId.toString(),
//             url: profileImage,
//           );
//         }

//         log('Profile photo updated: ${profilePhotoUrl.value}');
//         _showSuccessSnackbar(
//           'Profile photo uploaded successfully',
//           icon: Icons.check_circle,
//         );

//         await loadProfileFromApi();
//       } else {
//         final errorMsg = _extractErrorMessage(response);
//         _showErrorSnackbar(errorMsg, icon: Icons.error);
//         log('Upload failed with status: ${response?.statusCode}');
//       }
//     } catch (e) {
//       log('Error uploading profile photo: $e');
//       _showErrorSnackbar('Error uploading photo: $e', icon: Icons.error);
//     } finally {
//       isUploadingPhoto.value = false;
//     }
//   }

//   Future<ImageSource?> _showImageSourceDialog() async {
//     return await Get.dialog<ImageSource>(
//       AlertDialog(
//         title: const Text('Choose Image Source'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Camera'),
//               onTap: () => Get.back(result: ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Gallery'),
//               onTap: () => Get.back(result: ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _extractErrorMessage(dio.Response? response) {
//     if (response?.data != null && response!.data is Map) {
//       return response.data['message'] ?? 'Failed to upload photo';
//     }
//     return 'Failed to upload photo. Status: ${response?.statusCode}';
//   }

//   // Remove profile photo
//   void removeProfilePhoto() {
//     profilePhotoUrl.value = '';
//     _showSuccessSnackbar('Profile photo removed');
//   }

//   // Open URL
//   Future<void> openUrl(String url) async {
//     if (url.isEmpty) return;

//     try {
//       final uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorSnackbar('Could not open URL: $url');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Invalid URL: $url');
//     }
//   }

//   // Share profile
//   void shareProfile() {
//     _showInfoSnackbar('Share profile functionality would be implemented here');
//     // TODO: Implement sharing logic using share_plus package
//   }

//   // Download profile
//   void downloadProfile() {
//     _showInfoSnackbar(
//       'Download profile functionality would be implemented here',
//     );
//     // TODO: Implement download logic (generate PDF or export data)
//   }

//   // Show delete account dialog
//   void showDeleteAccountDialog() {
//     Get.defaultDialog(
//       title: 'Delete Account',
//       middleText:
//           'Are you sure you want to delete your account? This action cannot be undone.',
//       textConfirm: 'Delete',
//       textCancel: 'Cancel',
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.red,
//       onConfirm: () {
//         _showErrorSnackbar(
//           'Account deletion functionality would be implemented here',
//         );
//         Get.back();
//         // TODO: Implement account deletion API call
//       },
//     );
//   }

//   // Change password
//   void changePassword() {
//     _showInfoSnackbar(
//       'Change password functionality would be implemented here',
//     );
//     // TODO: Navigate to change password screen
//   }

//   // Refresh profile data
//   Future<void> refreshProfile() async {
//     await loadProfileFromApi();
//   }

//   // Get social media link by platform
//   String _getSocialMediaLink(String platform) {
//     final link = socialMediaLinks.firstWhereOrNull(
//       (link) => link.platform.toLowerCase() == platform.toLowerCase(),
//     );
//     return link?.url ?? '';
//   }

//   // Snackbar helpers
//   void _showSuccessSnackbar(String message, {IconData? icon}) {
//     Get.snackbar(
//       'Success',
//       message,
//       backgroundColor: const Color(0xFF51CF66),
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(seconds: 2),
//       icon: icon != null ? Icon(icon, color: Colors.white) : null,
//     );
//   }

//   void _showErrorSnackbar(String message, {IconData? icon}) {
//     Get.snackbar(
//       'Error',
//       message,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(seconds: 3),
//       icon: icon != null ? Icon(icon, color: Colors.white) : null,
//     );
//   }

//   void _showInfoSnackbar(String message) {
//     Get.snackbar(
//       'Info',
//       message,
//       backgroundColor: const Color(0xFFFF9500),
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );
//   }
// }
