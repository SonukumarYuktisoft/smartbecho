import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smartbecho/controllers/account%20management%20controller/pay_bill_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';

import 'package:smartbecho/utils/common%20file%20uploader/common_file_uploader.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_back_button.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class AddPayBillPage extends StatelessWidget {
  final PayBillsController controller = Get.put(PayBillsController());

  AddPayBillPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'Add Bill'),
      // appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(), 
                _buildFormContent()],
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
                Icons.receipt_long,
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
                    'ADD PAY BILL',
                    style: AppStyles.custom(
                      color: const Color(0xFF1A1A1A),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Record bill payment details',
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
              child: const Icon(
                Icons.payment,
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
                    'Payment Information',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Fill in the details below to record a bill payment',
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
      // margin: const EdgeInsets.all(8),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // _buildSectionTitle('Payment Details', Icons.payment),
            // const SizedBox(height: 16),

            // Date and Payment Mode Row
            Row(
              children: [
                Expanded(child: _buildDateField()),
                const SizedBox(width: 16),
                Expanded(child: _buildPaymentModeDropdown()),
              ],
            ),
            const SizedBox(height: 16),

            // Amount and Company Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Amount',
                    controller: controller.amountController,
                    hintText: '0.00',
                    prefixText: '₹ ',
                    keyboardType: TextInputType.number,
                    validator: controller.validateAmount,
                    digitsOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Distributor',
                    controller: controller.companyController,
                    hintText: 'Enter distributor name',
                    validator: controller.validateRequired,
                    keyboardType: TextInputType.name,

                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Paid To and Paid By Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Paid To Person',
                    controller: controller.paidToController,
                    hintText: 'Enter recipient name',
                    validator: controller.validateRequired,
                    keyboardType: TextInputType.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Paid By',
                    controller: controller.paidByController,
                    hintText: 'Enter payer name',
                    validator: controller.validateRequired,
                    keyboardType: TextInputType.name,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Purpose Dropdown
            _buildPurposeDropdown(),
            const SizedBox(height: 16),

            // Description Field
            buildStyledTextField(
              labelText: 'Description',
              controller: controller.notesController,
              hintText: 'Enter additional notes (optional)',
              keyboardType: TextInputType.multiline,
              validator:ValidatorHelper.validateDescription
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Upload Receipt', Icons.upload_file),
            const SizedBox(height: 16),

            // File Upload Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
              ),
              child: CommonFileUploadWidget(
                controller: controller.fileUploadController,
                title: 'Upload Receipt/Invoice',
                subtitle: 'Click to select JPG, PNG, or PDF file',
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                fileType: FileType.custom,
                isDarkTheme: false,
                primaryColor: AppColors.primaryLight,
                height: Get.height * 0.14,
                onFileSelected: (file) {
                  print('File selected: ${file.path}');
                },
                onFileRemoved: () {
                  print('File removed');
                },
              ),
            ),
            const SizedBox(height: 20),

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
          'Date',
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

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value:
                  controller.selectedFormPaymentMode.value.isEmpty
                      ? null
                      : controller.selectedFormPaymentMode.value,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              hint: const Text(
                'Select payment mode',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
              items:
                  controller.formPaymentModes.map((String mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(
                        mode,
                        style: const TextStyle(color: Color(0xFF1A1A1A)),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                controller.selectedFormPaymentMode.value = value ?? '';
              },
              validator: controller.validateDropdown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purpose',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value:
                  controller.selectedFormPurpose.value.isEmpty
                      ? null
                      : controller.selectedFormPurpose.value,
              isExpanded: true,
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              hint: const Text(
                'Select purpose',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
              items:
                  controller.formPurposes.map((String purpose) {
                    return DropdownMenuItem(
                      value: purpose,
                      child: Text(
                        purpose,
                        style: const TextStyle(color: Color(0xFF1A1A1A)),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                controller.selectedFormPurpose.value = value ?? '';
              },
              validator: controller.validateDropdown,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => FeatureVisitor(
              featureKey: FeatureKeys.PURCHASE_BILLS.createPurchaseBill,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      controller.isFormLoading.value
                          ? null
                          : controller.savePayBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      controller.isFormLoading.value
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
                              Icon(Icons.save, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Save Bill',
                                style: AppStyles.custom(
                                  weight: FontWeight.w600,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
        ),
        // const SizedBox(width: 8),
        // Expanded(
        //   child:  Container(
        //       height: 48,
        //       child: ElevatedButton(
        //         onPressed: controller.generateInvoice,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: const Color(0xFF10B981),
        //           foregroundColor: Colors.white,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           elevation: 0,
        //         ),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.receipt_long, size: 18),
        //             SizedBox(width: 8),
        //             Text(
        //               'Generate Invoice',
        //               style: AppStyles.custom(
        //                 weight: FontWeight.w600,
        //                 size: 14,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
            // ),
          // ),
        
      ],
    );
  }
}
