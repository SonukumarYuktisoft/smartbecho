import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/setting%20controllers/setting_controller.dart';
import 'package:smartbecho/controllers/setting%20controllers/widgets/invoice_template_selector.dart';
import 'package:smartbecho/services/configs/theme_config.dart';
import 'dart:io';

import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopSettingsController());
    final isDark = AppColors.isDarkMode(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
       appBar: CustomAppBar(
        title: 'Shop Settings',
        actionItem: [
          Obx(
            () => IconButton(
              icon:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),
                      )
                      : const Icon(Icons.refresh),
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () => controller.refreshData(),
            ),
          ),
        ],
       ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.accentColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading settings...',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Quantity Section
              _buildSectionHeader(context, 'Stock Management'),
              const SizedBox(height: 12),
              _buildStockQuantityCard(context, controller),
              const SizedBox(height: 24),
              // Add this in your ShopSettingsScreen build method, after Stock Quantity Section:

              // Invoice Template Section
              _buildSectionHeader(context, 'Invoice Template'),
              const SizedBox(height: 12),
              Obx(
                () => InvoiceTemplateSelector(
                  selectedTemplate: controller.selectedInvoiceTemplate.value,
                  onTemplateChanged: controller.onTemplateChanged,
                ),
              ),
              const SizedBox(height: 24),
              // Features Section
              _buildSectionHeader(context, 'Features'),
              const SizedBox(height: 12),
              _buildFeaturesCard(context, controller),
              const SizedBox(height: 24),

              // UPI Payment Section
              Obx(() {
                if (controller.upiPaymentEnabled.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'UPI Payment'),
                      const SizedBox(height: 12),
                      _buildUpiCard(context, controller),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Images Section
              Obx(() {
                bool showImages =
                    controller.qrCodeScannerEnabled.value ||
                    controller.stampEnabled.value ||
                    controller.signatureEnabled.value;

                if (showImages) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Images'),
                      const SizedBox(height: 12),
                      if (controller.qrCodeScannerEnabled.value)
                        _buildImageUploadCard(
                          context,
                          controller,
                          'QR Scanner Image',
                          Icons.qr_code_scanner,
                          controller.scannerImageFile,
                          controller.scannerImageUrl,
                          controller.pickScannerImage,
                          controller.removeScannerImage,
                        ),
                      if (controller.qrCodeScannerEnabled.value)
                        const SizedBox(height: 12),
                      if (controller.stampEnabled.value)
                        _buildImageUploadCard(
                          context,
                          controller,
                          'Shop Stamp',
                          Icons.approval,
                          controller.stampImageFile,
                          controller.stampImageUrl,
                          controller.pickStampImage,
                          controller.removeStampImage,
                        ),
                      if (controller.stampEnabled.value)
                        const SizedBox(height: 12),
                      if (controller.signatureEnabled.value)
                        _buildImageUploadCard(
                          context,
                          controller,
                          'Signature',
                          Icons.draw,
                          controller.signatureImageFile,
                          controller.signatureImageUrl,
                          controller.pickSignatureImage,
                          controller.removeSignatureImage,
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Save Button
              _buildSaveButton(context, controller),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStockQuantityCard(
    BuildContext context,
    ShopSettingsController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(
            context,
            controller: controller.lowStockQtyController,
            label: 'Low Stock Quantity',
            hint: 'Enter low stock alert quantity',
            icon: Icons.inventory_2_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context,
            controller: controller.criticalStockQtyController,
            label: 'Critical Stock Quantity',
            hint: 'Enter critical stock alert quantity',
            icon: Icons.warning_amber_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(
    BuildContext context,
    ShopSettingsController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(
            () => _buildToggleTile(
              context,
              title: 'QR Code Scanner',
              subtitle: 'Enable QR code scanning for products',
              icon: Icons.qr_code_scanner,
              value: controller.qrCodeScannerEnabled.value,
              onChanged: (val) => controller.qrCodeScannerEnabled.value = val,
            ),
          ),
          const Divider(height: 24),
          Obx(
            () => _buildToggleTile(
              context,
              title: 'UPI Payment',
              subtitle: 'Enable UPI payment option',
              icon: Icons.payment,
              value: controller.upiPaymentEnabled.value,
              onChanged: (val) => controller.upiPaymentEnabled.value = val,
            ),
          ),
          const Divider(height: 24),
          Obx(
            () => _buildToggleTile(
              context,
              title: 'Shop Stamp',
              subtitle: 'Add stamp to invoices',
              icon: Icons.approval,
              value: controller.stampEnabled.value,
              onChanged: (val) => controller.stampEnabled.value = val,
            ),
          ),
          const Divider(height: 24),
          Obx(
            () => _buildToggleTile(
              context,
              title: 'Signature',
              subtitle: 'Add signature to invoices',
              icon: Icons.draw,
              value: controller.signatureEnabled.value,
              onChanged: (val) => controller.signatureEnabled.value = val,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiCard(
    BuildContext context,
    ShopSettingsController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: _buildTextField(
        context,
        controller: controller.upiIdController,
        label: 'UPI ID',
        hint: 'Enter your UPI ID (e.g., yourname@upi)',
        icon: Icons.account_balance_wallet,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildImageUploadCard(
    BuildContext context,
    ShopSettingsController controller,
    String title,
    IconData icon,
    Rx<File?> imageFile,
    RxString imageUrl,
    VoidCallback onPick,
    VoidCallback onRemove,
  ) {
    return Obx(() {
      final hasLocalImage = imageFile.value != null;
      final hasServerImage = imageUrl.value.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accentColor(context), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasLocalImage || hasServerImage)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      hasLocalImage
                          ? Image.file(imageFile.value!, fit: BoxFit.contain)
                          : Image.network(
                            imageUrl.value,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: AppColors.textSecondary(context),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          ),
                ),
              ),
            if (hasLocalImage || hasServerImage) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.upload, size: 20),
                    label: Text(
                      hasLocalImage || hasServerImage
                          ? 'Change Image'
                          : 'Upload Image',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (hasLocalImage) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onRemove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.delete, size: 20),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary(context)),
            prefixIcon: Icon(icon, color: AppColors.accentColor(context)),
            filled: true,
            fillColor: AppColors.backgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accentColor(context),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accentColor(context), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentColor(context),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ShopSettingsController controller,
  ) {
    return Obx(() {
      final isSaving = controller.isSaving.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : () => controller.saveShopSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentColor(context),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child:
              isSaving
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        ),
      );
    });
  }
}
