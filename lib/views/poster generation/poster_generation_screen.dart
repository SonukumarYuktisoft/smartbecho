import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartbecho/controllers/poster%20generation%20controller/poster_generation_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class PosterGenerationScreen extends StatelessWidget {
  PosterGenerationScreen({Key? key}) : super(key: key);
  
  final controller = Get.put(PosterController());
  final GlobalKey posterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
       appBar: CustomAppBar(title: 'Create Poster',
      actionItem: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.getTextPrimary(context)),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
        ),
      // appBar: AppBar(
      //   title: Text(
      //     'Create Poster',
      //     style: TextStyle(
      //       color: AppColors.getTextPrimary(context),
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.settings_outlined, color: AppColors.getTextPrimary(context)),
      //       onPressed: () => _showSettingsDialog(context),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Preview
              _buildPosterPreview(context, isDark),
              
              const SizedBox(height: 20),
              
              // Template Selection
              _buildTemplateSection(context, isDark),
              
              const SizedBox(height: 20),
              
              // Overlay Position Selection
              _buildOverlayPositionSection(context, isDark),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              _buildActionButtons(context, isDark),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterPreview(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RepaintBoundary(
          key: posterKey,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image (Template or Custom)
                _buildBackgroundImage(),
                
                // Shop Details Overlay - wrapped in its own Obx
                _buildShopDetailsOverlay(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Obx(() {
      // Priority 1: Custom uploaded image
      if (controller.customImage.value != null) {
        return Image.file(
          controller.customImage.value!,
          fit: BoxFit.cover,
        );
      } 
      // Priority 2: Selected template from assets
      else if (controller.selectedTemplateIndex.value >= 0 && 
               controller.templates.isNotEmpty) {
        return Image.asset(
          controller.templates[controller.selectedTemplateIndex.value],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If template image fails to load, show placeholder
            return _buildPlaceholder();
          },
        );
      } 
      // Priority 3: Placeholder gradient
      else {
        return _buildPlaceholder();
      }
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFFA29BFE),
            Color(0xFF00CEC9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Template or Upload Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopDetailsOverlay(BuildContext context, bool isDark) {
    return Obx(() {
      return Align(
        alignment: controller.getOverlayAlignment(),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shop Logo
             (controller.shopImage==null||controller.shopImage=="")? SizedBox.shrink(): Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 3),
                  image: DecorationImage(image: NetworkImage( controller.shopImage.value),fit: BoxFit.fill)
                ),
                
              ),
              const SizedBox(width: 16),
              // Shop Details
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.shopName.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.shopPhone.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      controller.shopEmail.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      controller.shopAddress.value,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTemplateSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Templates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              TextButton.icon(
                onPressed: controller.pickImageFromGallery,
                icon: Icon(
                  Icons.upload_file,
                  color: AppColors.primaryLight,
                ),
                label: Text(
                  'Upload Custom',
                  style: TextStyle(color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.templates.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final isSelected = controller.selectedTemplateIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    controller.selectTemplate(index);
                    controller.clearCustomImage();
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.getBorderColor(context),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Template thumbnail image
                          Image.asset(
                            controller.templates[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback gradient if image fails to load
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6C5CE7).withOpacity(0.8),
                                      Color(0xFFA29BFE).withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Semi-transparent overlay with text
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Template\n${index + 1}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayPositionSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overlay Position',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.overlayPositions.map((position) {
              return Obx(() {
                final isSelected = controller.overlayPosition.value == position;
                return GestureDetector(
                  onTap: () => controller.changeOverlayPosition(position),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.getBorderColor(context),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      controller.getOverlayPositionLabel(position),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.getTextPrimary(context),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Download Button
          Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isGeneratingPoster.value
                    ? null
                    : () => _downloadPoster(context),
                icon: controller.isGeneratingPoster.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  controller.isGeneratingPoster.value ? 'Generating...' : 'Download',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Share Button
          Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isGeneratingPoster.value
                    ? null
                    : () => _sharePoster(context),
                icon: controller.isGeneratingPoster.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.share_rounded),
                label: Text(
                  controller.isGeneratingPoster.value ? 'Preparing...' : 'Share',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00CEC9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final nameController = TextEditingController(text: controller.shopName.value);
    final phoneController = TextEditingController(text: controller.shopPhone.value);
    final emailController = TextEditingController(text: controller.shopEmail.value);
    final addressController = TextEditingController(text: controller.shopAddress.value);
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.secondaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shop Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Update your business information',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Form Fields
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildDialogTextField(
                        context: context,
                        controller: nameController,
                        label: 'Shop Name',
                        icon: Icons.business_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        context: context,
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        context: context,
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        context: context,
                        controller: addressController,
                        label: 'Address',
                        icon: Icons.location_on_rounded,
                        isDark: isDark,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.shopName.value = nameController.text;
                            controller.shopPhone.value = phoneController.text;
                            controller.shopEmail.value = emailController.text;
                            controller.shopAddress.value = addressController.text;
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Shop details updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.successLight,
                              colorText: Colors.white,
                              icon: Icon(Icons.check_circle, color: Colors.white),
                              duration: Duration(seconds: 2),
                            );
                          },
                          icon: Icon(Icons.check_circle_rounded),
                          label: Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryLight,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _downloadPoster(BuildContext context) async {
    try {
      controller.isGeneratingPoster.value = true;

      // Check if gallery access is granted
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          Get.snackbar(
            'Permission Denied',
            'Gallery access is required to save the poster',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorLight,
            colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white),
          );
          controller.isGeneratingPoster.value = false;
          return;
        }
      }

      // Capture the poster as image
      RenderRepaintBoundary boundary = posterKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory first
      final tempDir = await getTemporaryDirectory();
      final fileName = 'poster_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Save to gallery using Gal
      await Gal.putImage(filePath, album: 'SmartBecho Posters');

      controller.isGeneratingPoster.value = false;

      Get.snackbar(
        'Success',
        'Poster saved to gallery successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successLight,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
      );

      // Optional: Delete temp file after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      controller.isGeneratingPoster.value = false;
      Get.snackbar(
        'Error',
        'Failed to download poster: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorLight,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> _sharePoster(BuildContext context) async {
    try {
      controller.isGeneratingPoster.value = true;

      // Capture the poster as image
      RenderRepaintBoundary boundary = posterKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'poster_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      controller.isGeneratingPoster.value = false;

      // Share the image file
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: '${controller.shopName.value} - Festival Poster\n${controller.shopPhone.value}',
        subject: 'Check out this poster!',
      );

      // Clean up the temporary file after sharing
      if (result.status == ShareResultStatus.success) {
        Get.snackbar(
          'Success',
          'Poster shared successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successLight,
          colorText: Colors.white,
          icon: Icon(Icons.check_circle, color: Colors.white),
          duration: Duration(seconds: 2),
        );
      }

      // Delete temp file after a delay
      Future.delayed(Duration(seconds: 3), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      controller.isGeneratingPoster.value = false;
      Get.snackbar(
        'Error',
        'Failed to share poster: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorLight,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }
}