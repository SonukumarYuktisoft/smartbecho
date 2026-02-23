import 'dart:developer';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/profile/user_profile_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class UserProfileService extends GetxService {
  static final String baseUrl = AppConfig.instance.baseUrl;
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  final RxBool isLoading = false.obs;
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  
  /// Fetch current user profile and save to SharedPreferences
  Future<bool> fetchAndSaveUserProfile() async {
    try {
      isLoading.value = true;
      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/users/current-user',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final responseData = ProfileResponse.fromJson(response.data);
        
        if (responseData.status == 'success') {
          final profile = responseData.payload;
          userProfile.value = profile;

          // Get first shop (primary shop)
          final userShop = profile.userShops.isNotEmpty ? profile.userShops.first : null;
          final shop = userShop?.shop;
          
          // Save user data to SharedPreferences
          await SharedPreferencesHelper.setUserId(profile.id.toString());
          await SharedPreferencesHelper.setEmail(profile.email);
          await SharedPreferencesHelper.setPhone(profile.phone);
          await SharedPreferencesHelper.setProfilePhotoUrl(profile.profilePhotoUrl ?? '');
          await SharedPreferencesHelper.setUserStatus(profile.status.toString());
          await SharedPreferencesHelper.setCreationDate(profile.creationDate ?? '');
          // await SharedPreferencesHelper.setGstNumber(profile.gstnumber ?? '');
          await SharedPreferencesHelper.setAdhaarNumber(profile.adhaarNumber ?? '');
          
          // Save notification preferences
          await SharedPreferencesHelper.setNotifyByEmail(profile.notifyByEmail);
          await SharedPreferencesHelper.setNotifyBySMS(profile.notifyBySMS);
          await SharedPreferencesHelper.setNotifyByWhatsApp(profile.notifyByWhatsApp);
          
          // Save shop data if available
          if (shop != null) {
            await SharedPreferencesHelper.setShopId(shop.id.toString());
            await SharedPreferencesHelper.setShopStoreName(shop.shopStoreName);
            
            // Save shop address if available
            if (shop.shopAddress != null) {
              final address = shop.shopAddress!;
              await SharedPreferencesHelper.setShopAddressId(address.id.toString());
              await SharedPreferencesHelper.setShopCity(address.city);
              await SharedPreferencesHelper.setShopState(address.state);
              await SharedPreferencesHelper.setShopCountry(address.country);
              await SharedPreferencesHelper.setShopPincode(address.pincode);
              await SharedPreferencesHelper.setShopAddressLabel(address.label ?? '');
            }
          }
          
          // Save user address if available
          if (profile.userAddress != null) {
            final userAddr = profile.userAddress!;
            // Save user address data if needed
            // await SharedPreferencesHelper.setUserAddressId(userAddr.id.toString());
            // Add more user address fields as needed
          }
          
          isLoading.value = false;
          return true;
        }
      } else if (response?.statusCode == 401) {
       
        log('Session Expired Please login again');
        await logout();
        isLoading.value = false;
        return false;
      }
      
     log('Failed to fetch user profile');
      isLoading.value = false;
      return false;
    } catch (e) {
      isLoading.value = false;
    
      log('An error occurred: ${e.toString()}');
      return false;
    }
  }
  
  /// Get user profile data from SharedPreferences
  Future<Map<String, dynamic>> getUserProfileData() async {
    return {
      'userId': await SharedPreferencesHelper.getUserId(),
      'shopId': await SharedPreferencesHelper.getShopId(),
      'shopStoreName': await SharedPreferencesHelper.getShopStoreName(),
      'email': await SharedPreferencesHelper.getEmail(),
      'phone': await SharedPreferencesHelper.getPhone(),
      'profilePhotoUrl': await SharedPreferencesHelper.getProfilePhotoUrl(),
      'gstNumber': await SharedPreferencesHelper.getGstNumber(),
      'adhaarNumber': await SharedPreferencesHelper.getAdhaarNumber(),
      'creationDate': await SharedPreferencesHelper.getCreationDate(),
      'status': await SharedPreferencesHelper.getUserStatus(),
      'notifyByEmail': await SharedPreferencesHelper.getNotifyByEmail(),
      'notifyBySMS': await SharedPreferencesHelper.getNotifyBySMS(),
      'notifyByWhatsApp': await SharedPreferencesHelper.getNotifyByWhatsApp(),
      'shopAddress': {
        'id': await SharedPreferencesHelper.getShopAddressId(),
        'city': await SharedPreferencesHelper.getShopCity(),
        'state': await SharedPreferencesHelper.getShopState(),
        'country': await SharedPreferencesHelper.getShopCountry(),
        'pincode': await SharedPreferencesHelper.getShopPincode(),
        'label': await SharedPreferencesHelper.getShopAddressLabel(),
      }
    };
  }
  
  /// Logout and clear user data
  Future<void> logout() async {
    await SharedPreferencesHelper.clearAll();
    userProfile.value = null;
    // Navigate to login screen
    // Get.offAllNamed('/login'); // Uncomment and adjust route as needed
  }
  
  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    return await SharedPreferencesHelper.getIsLoggedIn();
  }
  
  /// Get specific user info methods for convenience
  Future<String?> getShopName() async {
    return await SharedPreferencesHelper.getShopStoreName();
  }
  
  Future<String?> getUserEmail() async {
    return await SharedPreferencesHelper.getEmail();
  }
  
  Future<String?> getUserPhone() async {
    return await SharedPreferencesHelper.getPhone();
  }
  
  /// Get primary shop from current profile
  Shop? getPrimaryShop() {
    return userProfile.value?.primaryShop;
  }
  
  /// Get all active shops from current profile
  List<Shop> getActiveShops() {
    return userProfile.value?.activeShops ?? [];
  }
}