import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/add_mobile_sales_controller.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/services/payment_types.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_back_button.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class MobileSalesForm extends StatelessWidget {
  const MobileSalesForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SalesCrudOperationController controller =
        Get.isRegistered<SalesCrudOperationController>()
            ? Get.find<SalesCrudOperationController>()
            : Get.put(SalesCrudOperationController());
    final InventoryItem item = Get.arguments['inventoryItem'];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'Sales Form'),
      // appBar: _buildAppBar(controller),
      body: Form(
        key: controller.salesFormKey,
        child: Column(
          children: [
            _buildStepIndicator(controller),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SafeArea(child: _buildStep1(controller, item)),
                  SafeArea(child: _buildStep2(controller)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SalesCrudOperationController controller) {
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
              child: const Icon(Icons.sell, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOBILE SALES FORM',
                    style: AppStyles.custom(
                      color: const Color(0xFF1A1A1A),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Complete the sale process',
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

  Widget _buildStepIndicator(SalesCrudOperationController controller) {
    return Obx(
      () => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildStepCircle(1, controller.currentStep.value >= 1, true),
            Expanded(
              child: Container(
                height: 2,
                color:
                    controller.currentStep.value >= 2
                        ? AppColors.primaryLight
                        : Colors.grey.shade300,
              ),
            ),
            _buildStepCircle(2, controller.currentStep.value >= 2, false),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive, bool isFirst) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryLight : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isFirst ? 'Product & Customer Details' : 'Payment & Pricing',
          style: TextStyle(
            color: isActive ? AppColors.primaryLight : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(
    SalesCrudOperationController controller,
    InventoryItem item,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: controller.step1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductDetailsSection(controller, item),
            _buildCustomerDetailsSection(controller),
            _buildStep1Navigation(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(SalesCrudOperationController controller) {
    return SingleChildScrollView(
      child: Form(
        key: controller.step2,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentSection(controller),
            _buildStep2Navigation(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection(
    SalesCrudOperationController controller,
    InventoryItem item,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
            _buildSectionTitle('Product Details', Icons.phone_android),
            const SizedBox(height: 16),

            // Category Dropdown
            Obx(() {
              if (controller.isLoadingFilters.value) {
                return buildShimmerTextField();
              }

              return IgnorePointer(
                ignoring: true,
                child: buildStyledDropdown(
                  labelText: 'Category *',
                  hintText: 'Select Category',
                  value:
                      controller.selectedCategory.value.isEmpty
                          ? null
                          : controller.selectedCategory.value,
                  items: controller.categories,
                  onChanged:
                      (value) => controller.onCategoryChanged(value ?? ''),
                  validator: controller.validateCategory,
                ),
              );
            }),
            const SizedBox(height: 16),

            // Company Dropdown
            Obx(() {
              if (controller.isLoadingCompanies.value) {
                return buildShimmerTextField();
              }

              bool isEnabled = controller.isCategorySelected;

              return IgnorePointer(
                ignoring: true,
                child: buildStyledDropdown(
                  labelText: 'Company *',
                  hintText:
                      isEnabled
                          ? 'Select Company'
                          : 'Please select category first',
                  value:
                      controller.selectedCompany.value.isEmpty
                          ? null
                          : controller.selectedCompany.value,
                  items: controller.companies,
                  enabled: isEnabled,
                  onChanged:
                      (value) => controller.onCompanyChanged(value ?? ''),
                  validator: controller.validateCompany,
                ),
              );
            }),
            const SizedBox(height: 16),

            // Model Dropdown
            Obx(() {
              if (controller.isLoadingModels.value) {
                return buildShimmerTextField();
              }

              bool isEnabled = controller.isCompanySelected;

              return IgnorePointer(
                ignoring: true,
                child: buildStyledDropdown(
                  labelText: 'Model *',
                  hintText:
                      isEnabled
                          ? 'Select Model'
                          : 'Please select company first',
                  value:
                      controller.selectedModel.value.isEmpty
                          ? null
                          : controller.selectedModel.value,
                  items: controller.models,
                  enabled: isEnabled,
                  onChanged: (value) => controller.onModelChanged(value ?? ''),
                  validator: controller.validateModel,
                ),
              );
            }),
            const SizedBox(height: 16),

            // RAM and ROM Fields (only for SMARTPHONE and TABLET)
            Obx(() {
              bool shouldShowRamRom = controller.shouldShowRamRomFields;
              if (!shouldShowRamRom) return const SizedBox.shrink();

              return Column(
                children: [
                  Row(
                    children: [
                      // RAM Dropdown
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: buildStyledDropdown(
                            labelText: 'RAM (GB) *',
                            hintText: 'Select RAM',
                            value:
                                controller.selectedRam.value.isEmpty
                                    ? null
                                    : controller.selectedRam.value,
                            items: controller.ramOptions,
                            onChanged:
                                (value) => controller.onRamChanged(value ?? ''),
                            validator: controller.validateRam,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // ROM Dropdown
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: buildStyledDropdown(
                            labelText: 'Storage (ROM) (GB) *',
                            hintText: 'Select Storage',
                            value:
                                controller.selectedRom.value.isEmpty
                                    ? null
                                    : controller.selectedRom.value,
                            items: controller.romOptions,
                            onChanged:
                                (value) => controller.onRomChanged(value ?? ''),
                            validator: controller.validateRom,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Product Description
            buildStyledTextField(
              labelText: 'Product Description',
              controller: controller.productDescriptionController,
              hintText: 'Enter product description',
              // maxLines: 3,
              validator: ValidatorHelper.validateDescription,
            ),
            const SizedBox(height: 16),

            // Color Dropdown
            Obx(
              () => IgnorePointer(
                ignoring: true,
                child: buildStyledDropdown(
                  labelText: 'Color *',
                  hintText: 'Select Color',
                  value:
                      controller.selectedColor.value.isEmpty
                          ? null
                          : controller.selectedColor.value,
                  items: controller.colorOptions,
                  onChanged: (value) => controller.onColorChanged(value ?? ''),
                  validator: controller.validateColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity and Unit Price Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Quantity *',
                    controller: controller.quantityController,
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    validator: controller.validateQuantity,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      MaxValueInputFormatter(
                        item.quantity,
                      ), // 👈 pass max quantity
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Unit Price (₹) *',
                    controller: controller.unitPriceController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: controller.validateUnitPrice,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // buildStyledTextField(
            //   labelText: 'IMEI Numbers (Optional)',
            //   controller: controller.customerNameController,
            //   hintText: 'Enter IMEI numbers separated by commas',
            //   validator: controller.validateCustomerName,

            // ),
            //
            // Color Dropdown
            // IMEI Numbers Field
            if (controller.iMEINumbersOptiond.isNotEmpty) ...[
              Obx(
                () => buildStyledDropdown(
                  labelText: 'IMEI Numbers',
                  hintText: 'Select IMEI Number',
                  value:
                      controller.selectedColor.value.isEmpty
                          ? null
                          : controller.selectedIMEINumbers.value,
                  items: controller.iMEINumbersOptiond,
                  onChanged:
                      (value) => controller.onIMEINumbersChanged(value ?? ''),
                  // validator: controller.validateIMEINumbers,
                ),
              ),
            ],
            // Obx(
            //   () => buildStyledDropdown(
            //     labelText: 'IMEI Numbers',
            //     hintText: 'Select IMEI Number',
            //     value:
            //         controller.selectedColor.value.isEmpty
            //             ? null
            //             : controller.selectedIMEINumbers.value,
            //     items: controller.iMEINumbersOptiond,
            //     onChanged: (value) => controller.onIMEINumbersChanged(value ?? ''),
            //     // validator: controller.validateIMEINumbers,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetailsSection(SalesCrudOperationController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
            _buildSectionTitle('Customer Details', Icons.person),
            const SizedBox(height: 16),

            // Customer Name
            buildStyledTextField(
              labelText: 'Customer Name *',
              controller: controller.customerNameController,
              hintText: 'Enter customer name',
              validator: controller.validateCustomerName,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),

            // Phone Number with auto-fetch
            Obx(
              () => buildStyledTextField(
                labelText: 'Phone Number *',
                controller: controller.phoneNumberController,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                validator: controller.validatePhoneNumber,
                onChanged: controller.onPhoneNumberChanged,
                digitsOnly: true,
                maxLength: 10,
                suffixIcon:
                    controller.isLoadingCustomer.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : controller.customerFound.value
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            buildStyledTextField(
              labelText: 'Email',
              controller: controller.emailController,
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 16),

            // Address
            buildStyledTextField(
              labelText: 'Address *',
              controller: controller.addressController,
              hintText: 'Enter address',
              maxLines: 3,
              validator: controller.validateAddress,
            ),
            const SizedBox(height: 16),

            // City, State, Pincode Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'City *',
                    controller: controller.cityController,
                    hintText: 'Enter city',
                    validator: controller.validateCity,
                    keyboardType: TextInputType.name,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'State *',
                    controller: controller.stateController,
                    hintText: 'Enter state',
                    validator: controller.validateState,
                    keyboardType: TextInputType.name,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Pincode *',
                    controller: controller.pincodeController,
                    hintText: 'pincode',
                    keyboardType: TextInputType.number,
                    validator: controller.validatePincode,
                    digitsOnly: true,
                    maxLength: 6,
                  ),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(SalesCrudOperationController controller) {
    return Column(
      children: [
        // Price Calculation Section
        _buildPriceCalculationSection(controller),

        // Payment Details Section
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
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
                _buildSectionTitle('Payment Details', Icons.payment),
                const SizedBox(height: 16),

                // Payment Mode Selection
                Text(
                  'Payment Mode',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      _buildPaymentModeRadio(
                        controller,
                        'Full Payment',
                        PaymentMode.fullPayment,
                      ),
                      const SizedBox(width: 16),
                      _buildPaymentModeRadio(
                        controller,
                        'Dues (Partial Payment)',
                        PaymentMode.partialPayment,
                      ),
                      const SizedBox(width: 16),
                      _buildPaymentModeRadio(
                        controller,
                        'EMI',
                        PaymentMode.emi,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Mode Specific Fields
                Obx(() => _buildPaymentModeFields(controller)),

                const SizedBox(height: 24),

                // Price Summary
                _buildPriceSummary(controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCalculationSection(
    SalesCrudOperationController controller,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
            _buildSectionTitle('Price Calculation', Icons.calculate),
            const SizedBox(height: 16),

            // Conditionally show GST field
            Obx(() {
              if (controller.shouldShowGST.value) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildStyledTextField(
                            labelText: 'GST Percentage (%)',
                            controller: controller.gstPercentageController,
                            hintText: '18',
                            keyboardType: TextInputType.number,
                            onChanged: (value) => controller.calculatePrices(),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildStyledTextField(
                            labelText: 'Extra Charges (₹)',
                            controller: controller.extraChargesController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            onChanged: (value) => controller.calculatePrices(),
                            digitsOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                // Only show Extra Charges when GST is hidden
                return Column(
                  children: [
                    // Info message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.shopGSTNumber.value.isEmpty
                                  ? 'GST not applicable - Shop GST number not registered'
                                  : 'GST not applicable for online source items',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildStyledTextField(
                      labelText: 'Extra Charges (₹)',
                      controller: controller.extraChargesController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => controller.calculatePrices(),
                      digitsOnly: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
            }),

            // Accessories Cost and Repair Charges Row
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Accessories Cost (₹)',
                    controller: controller.accessoriesCostController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.calculatePrices(),
                    digitsOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Repair Charges (₹)',
                    controller: controller.repairChargesController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.calculatePrices(),
                    digitsOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Discount
            buildStyledTextField(
              labelText: 'Total Discount (₹)',
              controller: controller.totalDiscountController,
              hintText: '0',
              keyboardType: TextInputType.number,
              onChanged: (value) => controller.calculatePrices(),
              digitsOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(SalesCrudOperationController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),

            _buildSummaryRow(
              'Base Amount:',
              '₹${controller.baseAmount.value.toStringAsFixed(2)}',
            ),

            // Dotted Divider
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),
            // Conditionally show "Amount without GST" only if GST is applicable
            if (controller.shouldShowGST.value)
              _buildSummaryRow(
                'Amount without GST:',
                '₹${controller.amountWithoutGST.value.toStringAsFixed(2)}',
              ),

            // Conditionally show GST row only if GST is applicable
            _buildSummaryRow(
              'GST (${controller.gstPercentage.value.toStringAsFixed(1)}%):',
              '₹${controller.gstAmount.value.toStringAsFixed(2)}',
            ),
            if (controller.selectedPaymentMethod.isNotEmpty)
              _buildSummaryRow(
                'Payment Method:',
                '${controller.selectedPaymentMethod}',
              ),

            if (controller.selectedPaymentMode.value == PaymentMode.emi) ...[
              _buildSummaryRow('Payment Mode:', 'EMI'),
              _buildSummaryRow(
                'EMI Tenure:',
                '${controller.selectedEMITenure.value} months',
              ),
              _buildSummaryRow(
                'Monthly EMI:',
                controller.monthlyEMI.toStringAsFixed(2),
              ),
            ],

            if (controller.selectedPaymentMode.value ==
                PaymentMode.partialPayment)
              _buildSummaryRow('Payment Mode:', 'DUES'),

            _buildSummaryRow(
              'Down Payment:',
              controller.downPaymentAmount.toString(),
            ),
            // ignore: unrelated_type_equality_checks
            if (controller.selectedPaymentMode.value ==
                PaymentMode.partialPayment) ...[
              _buildSummaryRow(
                'Remaining Dues:',
                controller.remainingDuesAmount.value.toStringAsFixed(2),
              ),
              _buildSummaryRow(
                'Retrieval Date:',
                '${controller.selectedpaymentRetrievalDate.value}',
              ),
            ],

            // Dotted Divider
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),
            _buildSummaryRow(
              'Total Payable Amount:',
              '₹${controller.totalPayableAmount.value.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? AppColors.primaryLight : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeRadio(
    SalesCrudOperationController controller,
    String title,
    PaymentMode mode,
  ) {
    return Expanded(
      child: Row(
        children: [
          Radio<PaymentMode>(
            value: mode,
            groupValue: controller.selectedPaymentMode.value,
            onChanged: (value) => controller.onPaymentModeChanged(value!),
            activeColor: AppColors.primaryLight,
          ),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildPaymentModeFields(SalesCrudOperationController controller) {
    switch (controller.selectedPaymentMode.value) {
      case PaymentMode.fullPayment:
        return _buildFullPaymentFields(controller);
      case PaymentMode.partialPayment:
        return _buildPartialPaymentFields(controller);
      case PaymentMode.emi:
        return _buildEMIFields(controller);
    }
  }

  Widget _buildFullPaymentFields(SalesCrudOperationController controller) {
    return Column(
      children: [
        // Payment Method
        buildStyledDropdown(
          labelText: 'Payment Method *',
          hintText: 'Select Payment Method',
          value:
              controller.selectedPaymentMethod.value.isEmpty
                  ? null
                  : controller.selectedPaymentMethod.value,
          items: PaymentTypes.paymentMethods,
          onChanged: (value) => controller.onPaymentMethodChanged(value ?? ''),
          validator: controller.validatePaymentMethod,
        ),
        const SizedBox(height: 16),

        // Payable Amount
        buildStyledTextField(
          labelText: 'Payable Amount (₹)',
          controller: controller.payableAmountController,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: controller.validatePayableAmount,
        ),
      ],
    );
  }

  Widget _buildPartialPaymentFields(SalesCrudOperationController controller) {
    return Column(
      children: [
        // Payment Method
        buildStyledDropdown(
          labelText: 'Payment Method *',
          hintText: 'Select Payment Method',
          value:
              controller.selectedPaymentMethod.value.isEmpty
                  ? null
                  : controller.selectedPaymentMethod.value,
          items: PaymentTypes.paymentMethods,
          onChanged: (value) => controller.onPaymentMethodChanged(value ?? ''),
          validator: controller.validatePaymentMethod,
        ),
        const SizedBox(height: 16),

        // Down Payment
        buildStyledTextField(
          labelText: 'Down Payment (₹) *',
          controller: controller.downPaymentController,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: controller.validateDownPayment,
        ),
        const SizedBox(height: 16),

        // Payment Retrieval Date
        // In _buildPartialPaymentFields method
        buildStyledTextField(
          labelText: 'Payment Retrieval Date *',
          controller: controller.paymentRetrievalDateController,
          hintText: 'dd-mm-yyyy',
          readOnly: true,
          onTap: () async {
            await controller.selectPaymentRetrievalDate();
            // Force UI update
            controller.paymentRetrievalDateController.notifyListeners();
          },
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: controller.validatePaymentRetrievalDate,
        ),
      ],
    );
  }

  Widget _buildEMIFields(SalesCrudOperationController controller) {
    return Column(
      children: [
        // Payment Method
        buildStyledDropdown(
          labelText: 'Payment Method *',
          hintText: 'Select Payment Method',
          value:
              controller.selectedPaymentMethod.value.isEmpty
                  ? null
                  : controller.selectedPaymentMethod.value,
          items: PaymentTypes.paymentMethods,
          onChanged: (value) => controller.onPaymentMethodChanged(value ?? ''),
          validator: controller.validatePaymentMethod,
        ),
        const SizedBox(height: 16),

        // Down Payment
        buildStyledTextField(
          labelText: 'Down Payment (₹) *',
          controller: controller.downPaymentController,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: controller.validateDownPayment,
        ),
        const SizedBox(height: 16),

        // EMI Tenure
        buildStyledDropdown(
          labelText: 'EMI Tenure (Months)',
          hintText: 'Select EMI Tenure',
          value:
              controller.selectedEMITenure.value.isEmpty
                  ? null
                  : controller.selectedEMITenure.value,
          items: controller.emiTenureOptions,
          onChanged: (value) => controller.onEMITenureChanged(value ?? ''),
          validator: controller.validateEMITenure,
        ),
        const SizedBox(height: 16),

        // Monthly EMI
        buildStyledTextField(
          readOnly: true,
          labelText: 'Monthly EMI (₹) *',
          controller: controller.monthlyEMIController,
          hintText: 'Monthly EMI amount',
          keyboardType: TextInputType.number,
          // validator: controller.validateMonthlyEMI,
        ),
      ],
    );
  }

  Widget _buildStep1Navigation(SalesCrudOperationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.goToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildStep2Navigation(SalesCrudOperationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                child: OutlinedButton(
                  onPressed:
                      controller.isProcessingSale.value
                          ? null
                          : controller.goToStep1,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      controller.isProcessingSale.value
                          ? null
                          : controller.completeSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      controller.isProcessingSale.value
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
                            'Complete Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
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
            color: AppColors.primaryLight.withValues(alpha: 0.1),
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

  Widget buildShimmerTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 14,
            width: 100,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 6),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class MaxValueInputFormatter extends TextInputFormatter {
  final int max;

  MaxValueInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null) return oldValue;

    if (value > max) {
      return oldValue; // Reject change if input exceeds max
    }

    return newValue;
  }
}
