import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'dart:io';
import 'package:smartbecho/services/configs/theme_config.dart';

class PosterController extends GetxController {
  @override
  void onInit() {
    initShopDeails();
    // TODO: implement onInit
    super.onInit();
  }
  // Observable variables - these trigger UI updates when changed
  final selectedTemplateIndex = 0.obs;
  final overlayPosition = 'bottom'.obs;
  final Rx<File?> customImage = Rx<File?>(null);
  final isGeneratingPoster = false.obs;
  // In your PosterController class
final GlobalKey posterKey = GlobalKey();
  // Shop details - observable so they update in real-time
  RxString shopName = ''.obs;
  RxString shopPhone = ''.obs;
  RxString shopEmail = ''.obs;
  RxString shopAddress = ''.obs;
  RxString shopImage = ''.obs;



 void initShopDeails()async{
    shopName.value = AppConfig.shopName.value.isNotEmpty
                                ? AppConfig.shopName.value
                                : "Smart Becho";
    shopPhone.value = await SharedPreferencesHelper.getPhone()??"not set";
    shopEmail.value = await SharedPreferencesHelper.getEmail()??"not set";
    shopAddress.value = await SharedPreferencesHelper.getShopAddressLabel()??"not set";
    shopImage.value=await SharedPreferencesHelper.getProfilePhotoUrl()??"";
  }

  // Static lists - these don't need to be reactive
  final List<String> templates = [
    'assets/diwali-festival-poster.jpg',
    'assets/christmas-poster.jpg',
    'assets/discount-offer-poster.jpg',
    'assets/independence-day-poster.jpg',
  ];

  final List<String> overlayPositions = [
    'top',
    'center',
    'bottom',
    'topLeft',
    'topRight',
    'bottomLeft',
    'bottomRight',
  ];

  // Method to select a template
  void selectTemplate(int index) {
    selectedTemplateIndex.value = index;
  }

  // Method to change overlay position
  void changeOverlayPosition(String position) {
    overlayPosition.value = position;
  }

  // Method to pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (image != null) {
        customImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to clear custom image
  void clearCustomImage() {
    customImage.value = null;
  }

  // Helper method to get alignment based on position
  AlignmentGeometry getOverlayAlignment() {
    switch (overlayPosition.value) {
      case 'top':
        return Alignment.topCenter;
      case 'center':
        return Alignment.center;
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'bottom':
      default:
        return Alignment.bottomCenter;
    }
  }

  // Helper method to get user-friendly label
  String getOverlayPositionLabel(String position) {
    switch (position) {
      case 'top':
        return 'Top';
      case 'center':
        return 'Center';
      case 'topLeft':
        return 'Top Left';
      case 'topRight':
        return 'Top Right';
      case 'bottomLeft':
        return 'Bottom Left';
      case 'bottomRight':
        return 'Bottom Right';
      case 'bottom':
      default:
        return 'Bottom';
    }
  }
}
