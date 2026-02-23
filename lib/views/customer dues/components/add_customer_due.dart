import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_due_operations_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/services/configs/theme_config.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/helper/Shimmer/shimmer_helper.dart';

class AddDuesPage extends StatelessWidget {
  const AddDuesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AddDuesController controller = Get.put(AddDuesController());
    final isDark = ThemeController().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: CustomAppBar(
        title: "Add Dues",
      
      ),
      body: Form(
        key: controller.addDueFormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Choose Customer Card
                _buildCustomerCard(controller, context, isDark),
                const SizedBox(height: 16),

                // Dues Information Card
                _buildDuesInformationCard(controller, context, isDark),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(controller, context, isDark),
                const SizedBox(height: 16),

                // Error Message
                _buildErrorMessage(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? const Color(0xFF14B8A6) : AppColors.primaryLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Add Dues',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(
    AddDuesController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Customer',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCustomerDropdown(controller, context, isDark),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.addCustomer),
                child: Text(
                  '+ Create',
                  style: TextStyle(
                    color:
                        isDark
                            ? const Color(0xFF14B8A6)
                            : AppColors.primaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown(
    AddDuesController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Obx(() {
      if (controller.isLoadingCustomers.value) {
        return ShimmerHelper.buildShimmerTextField();
      }
      return CommonDropdownSearch<Map<String, dynamic>>(
        items: controller.customers,
        selectedItem:
            controller.selectedCustomerId.value.isEmpty
                ? null
                : controller.customers.firstWhereOrNull(
                  (customer) =>
                      customer['id'].toString() ==
                      controller.selectedCustomerId.value,
                ),
        itemAsString: (customer) => customer['name'] ?? '',
        compareFn: (item1, item2) => item1['id'] == item2['id'],
        onChanged: (customer) {
          if (customer != null) {
            controller.onCustomerSelected(
              customer['id'].toString(),
              customer['name'],
            );
          }
        },
        labelText: '',
        hintText: 'Select Customer',
        enabled: !controller.isLoadingCustomers.value,
        showSearch: true,
        prefixIcon: Icons.person_outline,
        suffixIcon:
            controller.isLoadingCustomers.value
                ? Icons.hourglass_empty
                : Icons.arrow_drop_down,
        validator:
            (customer) =>
                controller.validateCustomer(customer?['id']?.toString()),
        autoValidateMode: AutovalidateMode.onUserInteraction,
      );
    });
  }


  Widget _buildDuesInformationCard(
    AddDuesController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dues Information',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Total Dues Amount Input
          buildStyledTextField(
            labelText: 'Total Dues Amount',
            controller: controller.totalDueController,
            hintText: 'Enter total due',
            keyboardType: TextInputType.number,
            validator: controller.validateTotalDue,
          ),
          const SizedBox(height: 16),

          // Total Paid Amount Input
          buildStyledTextField(
            labelText: 'Total Paid Amount',
            controller: controller.totalPaidController,
            hintText: 'Enter paid amount',
            keyboardType: TextInputType.number,
            validator: controller.validateTotalPaid,
          ),
          const SizedBox(height: 16),

          // Remaining Dues Display
          Obx(
            () => _buildInfoRow(
              'Remaining Dues',
              '₹ ${controller.remainingDueAmount.value.toStringAsFixed(2)}',
              isDark,
            ),
          ),
          const SizedBox(height: 24),

          // Payment Retrieval Date
          Text(
            'Payment Retrieval Date',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.selectPaymentDate(context),
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      controller.paymentDateController.text.isEmpty
                          ? null
                          : Border.all(
                            color:
                                isDark
                                    ? const Color(0xFF14B8A6)
                                    : AppColors.primaryLight,
                            width: 1,
                          ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color:
                          isDark
                              ? const Color(0xFF14B8A6)
                              : AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.selectedPaymentDate.value == null
                          ? 'MM/DD/YYYY'
                          : controller.paymentDateController.text,
                      style: TextStyle(
                        color:
                            controller.selectedPaymentDate.value == null
                                ? (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B))
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A)),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    AddDuesController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  controller.isAddingDue.value ? null : controller.cancelAddDue,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color:
                      isDark ? const Color(0xFF14B8A6) : AppColors.primaryLight,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      isDark ? const Color(0xFF14B8A6) : AppColors.primaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FeatureVisitor(
              featureKey: FeatureKeys.DUES.createDues,
              child: ElevatedButton(
                
                onPressed:
                    controller.isAddingDue.value ? null : controller.addDueEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? const Color(0xFF14B8A6) : AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child:
                    controller.isAddingDue.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AddDuesController controller) {
    return Obx(
      () =>
          controller.hasAddDueError.value
              ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.addDueErrorMessage.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
