// views/account management/components/gst_export_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/gst_ledger_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';

class GstExportBottomSheet extends StatefulWidget {
  @override
  _GstExportBottomSheetState createState() => _GstExportBottomSheetState();
}

class _GstExportBottomSheetState extends State<GstExportBottomSheet> {
  final GstLedgerController controller = Get.find<GstLedgerController>();

  String selectedFilterType = 'Month';
  String? selectedMonth;
  String? selectedYear;
  String? selectedFileFormat;
  String? selectedGstPortalFormat;

  bool includePurchaseData = false;
  bool includeProductDetails = true;
  bool includeCustomerDetails = true;
  bool includeSupplierDetails = true;

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  final List<String> filterTypes = ['Month', 'Custom Date Range'];
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<Map<String, String>> gstPortalFormats = [
    {'value': 'GSTR-1', 'label': 'GSTR-1', 'desc': 'Sales - GST Portal Format'},
    {'value': 'GSTR-2', 'label': 'GSTR-2', 'desc': 'Purchases - GST Portal Format'},
    {'value': 'JSON-SIMPLIFIED', 'label': 'GST Export', 'desc': 'Simplified Format'},
  ];

  final List<String> fileFormats = ['CSV', 'PDF', 'JSON', 'Excel'];

  @override
  void initState() {
    super.initState();
    selectedMonth = controller.monthDisplayText;
    selectedYear = controller.selectedYear.value.toString();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF3B82F6),
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            startDateController.text = picked.toIso8601String().split('T')[0];
          } else {
            endDateController.text = picked.toIso8601String().split('T')[0];
          }
        });
      }
    } catch (e) {
      _showError('Date Selection Error', 'Failed to select date');
    }
  }

  bool _validateForm() {
    // Validate date selection
    if (selectedFilterType == 'Month') {
      if (selectedMonth == null || selectedYear == null) {
        _showError('Validation Error', 'Please select both month and year');
        return false;
      }
    } else {
      if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
        _showError('Validation Error', 'Please select both start and end dates');
        return false;
      }
    }

    // Validate GST format selection
    if (selectedGstPortalFormat == null || selectedGstPortalFormat!.isEmpty) {
      _showError('Validation Error', 'Please select a GST export format');
      return false;
    }

    // For JSON-SIMPLIFIED, validate file format
    if (selectedGstPortalFormat == 'JSON-SIMPLIFIED' && selectedFileFormat == null) {
      _showError('Validation Error', 'Please select a file format for JSON export');
      return false;
    }

    return true;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _handleExport() async {
    if (!_validateForm()) return;

    // Build parameters based on filter type
    Map<String, String> params = {};

    if (selectedFilterType == 'Month') {
      params['month'] = (months.indexOf(selectedMonth!) + 1).toString().padLeft(2, '0');
      params['year'] = selectedYear!;
    } else {
      params['startDate'] = startDateController.text;
      params['endDate'] = endDateController.text;
    }

    try {
      bool success = false;

      // Call export based on selected format and WAIT for completion
      if (selectedGstPortalFormat == 'GSTR-1') {
        success = await controller.exportGstLedgerGSTR1(params: params);
      } else if (selectedGstPortalFormat == 'GSTR-2') {
        success = await controller.exportGstLedgerGSTR2(params: params);
      } else if (selectedGstPortalFormat == 'JSON-SIMPLIFIED') {
        params['format'] = selectedFileFormat ?? 'JSON';
        params['includePurchaseData'] = includePurchaseData.toString();
        params['includeProductDetails'] = includeProductDetails.toString();
        params['includeCustomerDetails'] = includeCustomerDetails.toString();
        params['includeSupplierDetails'] = includeSupplierDetails.toString();

        success = await controller.exportGstLedgerSimplifiedJson(params: params);
      }

      // Only close bottom sheet if export was successful
      if (success && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Export Error', 'Failed to export: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildFormatSection(),
                  const SizedBox(height: 20),

                  // Only show file format and toggles for JSON-SIMPLIFIED
                  if (selectedGstPortalFormat == 'JSON-SIMPLIFIED') ...[
                    _buildFileFormatSection(),
                    const SizedBox(height: 20),
                    _buildDataOptionsSection(),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Export GST Ledger',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),

        // Filter Type Dropdown
        buildStyledDropdown(
          labelText: 'Filter Type',
          hintText: 'Select Filter Type',
          value: selectedFilterType,
          items: filterTypes,
          onChanged: (value) {
            setState(() {
              selectedFilterType = value ?? 'Month';
            });
          },
        ),
        const SizedBox(height: 16),

        // Month/Year or Custom Date Range
        if (selectedFilterType == 'Month') ...[
          Row(
            children: [
              Expanded(
                child: buildStyledDropdown(
                  labelText: 'Month',
                  hintText: 'Select Month',
                  value: selectedMonth,
                  items: months,
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStyledDropdown(
                  labelText: 'Year',
                  hintText: 'Select Year',
                  value: selectedYear,
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - index;
                    return year.toString();
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  controller: startDateController,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'End Date',
                  controller: endDateController,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Export Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'GST Portal Formats',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        _buildGstPortalFormatSelector(),
      ],
    );
  }

  Widget _buildFileFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        buildStyledDropdown(
          labelText: 'Select File Format',
          hintText: 'Choose format',
          value: selectedFileFormat,
          items: fileFormats,
          onChanged: (value) {
            setState(() {
              selectedFileFormat = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDataOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        _buildToggleOption(
          title: 'Include Product/Item Details',
          subtitle: 'Include product/item information in export',
          value: includeProductDetails,
          onChanged: (value) {
            setState(() {
              includeProductDetails = value;
            });
          },
        ),
        _buildToggleOption(
          title: 'Include Customer Details',
          subtitle: 'Include customer information in export',
          value: includeCustomerDetails,
          onChanged: (value) {
            setState(() {
              includeCustomerDetails = value;
            });
          },
        ),
        _buildToggleOption(
          title: 'Include Supplier Details',
          subtitle: 'Include supplier information in export',
          value: includeSupplierDetails,
          onChanged: (value) {
            setState(() {
              includeSupplierDetails = value;
            });
          },
        ),
        if(includeSupplierDetails)
        _buildToggleOption(
          title: 'Include Purchase Data',
          subtitle: 'Include purchase data in the export',
          value: includePurchaseData,
          onChanged: (value) {
            setState(() {
              includePurchaseData = value;
              // Auto-enable supplier details when purchase data is enabled
              if (value) {
                includeSupplierDetails = true;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => OutlinedButton(
                onPressed: controller.isLoading.value ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: controller.isLoading.value 
                      ? Colors.grey.withValues(alpha: 0.3)
                      : AppColors.primaryLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.isLoading.value
                      ? Colors.grey
                      : AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () {
                return ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _handleExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Downloading...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.text.isEmpty ? 'Select date' : controller.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.text.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGstPortalFormatSelector() {
    return Column(
      children: gstPortalFormats.map((format) {
        final isSelected = selectedGstPortalFormat == format['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGstPortalFormat = format['value'];
              selectedFileFormat = null;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryLight.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight
                    : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryLight : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primaryLight : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        format['desc']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}