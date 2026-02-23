import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/withdraw_history_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_back_button.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class AddWithdrawPage extends StatelessWidget {
  final WithdrawController controller = Get.find<WithdrawController>();

  AddWithdrawPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // appBar: _buildAppBar(),
      appBar: CustomAppBar(title: 'Add Withdraw'),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(),
                 _buildFormContent()
                 ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: customBackButton(isdark: true),
      ),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 45.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.money_off,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADD WITHDRAW',
                    style: AppStyles.custom(
                      color: const Color(0xFF1A1A1A),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Record withdrawal details',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha:0.2),
                ),
              ),
              child:  Icon(
                Icons.attach_money,
                color: AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdrawal Information',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Fill in the details below to record a withdrawal. All fields marked with * are required.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle('Withdrawal Details', Icons.account_balance_wallet),
            // const SizedBox(height: 16),

            // Date Field
            _buildDateField(),
            const SizedBox(height: 16),

            // Amount Field
            buildStyledTextField(
              labelText: 'Amount *',
              controller: controller.amountController,
              hintText: '0.00',
              prefixText: '₹ ',
              keyboardType: TextInputType.number,
              validator: controller.validateAmount,
              digitsOnly: true,
            ),
            const SizedBox(height: 16),

            // Withdrawn By Field
            buildStyledTextField(
              labelText: 'Withdrawn By *',
              controller: controller.withdrawnByController,
              hintText: 'Enter name of person withdrawing',
              validator: controller.validateRequired,
              keyboardType: TextInputType.name
            ),
            const SizedBox(height: 16),

            // Source Selection
            // In your form widget
controller.buildPaymentMethodDropdown(),
            const SizedBox(height: 16),

            // Purpose Field
            buildStyledTextField(
              labelText: 'Purpose *',
              controller: controller.purposeController,
              hintText: 'Enter purpose of withdrawal',
              validator: controller.validateRequired,
              
            ),
            const SizedBox(height: 16),

            // Notes Field
            buildStyledTextField(
              labelText: 'Notes',
              controller: controller.notesController,
              hintText: 'Enter additional notes (optional)',
              validator: ValidatorHelper.validateNote,
              keyboardType: TextInputType.multiline
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date *',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
          ),
          child: TextFormField(
            controller: controller.dateController,
            readOnly: true,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Select date',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Color(0xFF6B7280),
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: controller.validateRequired,
            onTap: () => controller.selectDate(Get.context!),
          ),
        ),
      ],
    );
  }



 

  Widget _buildActionButtons() {
    return Row(mainAxisAlignment:MainAxisAlignment.center ,
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: controller.resetForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF6B7280),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Reset',
                    style: AppStyles.custom(
                      weight: FontWeight.w600,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Obx(
            () => FeatureVisitor(
              featureKey: FeatureKeys.WITHDRAWAL.createWithdrawal,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isFormLoading.value
                      ? null
                      : controller.saveWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isFormLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Process Withdrawal',
                              style: AppStyles.custom(
                                weight: FontWeight.w600,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}