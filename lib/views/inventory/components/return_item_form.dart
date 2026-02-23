import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class ReturnItemForm extends StatefulWidget {
  final InventoryItem item;

  const ReturnItemForm({Key? key, required this.item}) : super(key: key);

  @override
  State<ReturnItemForm> createState() => _ReturnItemFormState();
}

class _ReturnItemFormState extends State<ReturnItemForm> {
  final InventoryController controller = Get.find<InventoryController>();
  final BillHistoryController billHistoryController =
      Get.find<BillHistoryController>();
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _distributorController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _returnPriceController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _returnReasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _selectedFile;
  String? _fileName;
  DateTime? _selectedDate;
  String? _selectedImei;

  bool imeiNotNull = false;


  @override
  void initState() {
    super.initState();
    // Pre-fill source from item
    _sourceController.text = widget.item.source ?? 'ONLINE';

    if (widget.item.imeiList != null && widget.item.imeiList!.isNotEmpty) {
      imeiNotNull = true;
      _quantityController.text = '1';
    } else {
      _quantityController.text = widget.item.quantity.toString();
      imeiNotNull = false;

    }
    // Set default return date to today
    _selectedDate = DateTime.now();
    _returnDateController.text = DateFormat(
      'MM/dd/yyyy',
    ).format(_selectedDate!);

    // Initialize IMEI selection based on source and availability
    log("✅ _initializeImeiSelection: ${widget.item.imeiList.toString()}");
    _initializeImeiSelection();
  }

  void _initializeImeiSelection() {
    final isOffline =
        (widget.item.source ?? 'ONLINE').toUpperCase() == 'OFFLINE';
    final hasImeiList =
        widget.item.imeiList != null && widget.item.imeiList!.isNotEmpty;

    if (isOffline && hasImeiList) {
      // Pre-select first IMEI for OFFLINE items
      _selectedImei = widget.item.imeiList!.first;
    } else {
      // For ONLINE or items without IMEI, set to null
      _selectedImei = null;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _distributorController.dispose();
    _returnDateController.dispose();
    _returnPriceController.dispose();
    _sourceController.dispose();
    _returnReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _returnDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final returnPrice =
          _returnPriceController.text.trim().isEmpty
              ? 0.0
              : double.tryParse(_returnPriceController.text.trim()) ?? 0.0;

      controller.submitProductReturn(
        item: widget.item,
        distributor: _distributorController.text.trim().toLowerCase(),
        returnDate: _selectedDate!,
        returnQuantity: _quantityController.text.trim(),
        returnPrice: returnPrice,
        source: _sourceController.text.trim(),
        reason: _returnReasonController.text.trim(),
        notes: _notesController.text.trim(),
        imei: _selectedImei ?? '', // Send empty string if null
        file: _selectedFile,
      );
    }
  }

  bool _shouldShowImeiDropdown() {
    log("✅ _shouldShowImeiDropdown: ${widget.item.imeiList.toString()}");
    final isOffline = _sourceController.text.toUpperCase().trim() == 'OFFLINE';
    final hasImeiList =
        widget.item.imeiList != null && widget.item.imeiList!.isNotEmpty;
    return isOffline && hasImeiList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Return',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Information Section
                    _buildSectionTitle('Product Information'),
                    SizedBox(height: 12),
                    _buildProductInfoSection(),
                    SizedBox(height: 24),

                    // Return Details Section
                    _buildSectionTitle('Return Details'),
                    SizedBox(height: 12),

                    // Distributor Name
                    Obx(
                      () => buildAutocompleteField(
                        labelText: 'Distributor *',
                        controller: _distributorController,
                        suggestions: billHistoryController.companyOptionsList,
                        hintText: 'Select or type Distributor',
                        onChanged: (value) {},
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Distributor name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Return Date
                    _buildDateField(),
                    SizedBox(height: 16),

                    // Return Price
                    buildStyledTextField(
                      controller: _returnPriceController,
                      labelText: 'Return Price (Optional)',
                      hintText: 'Return Price (Optional)',
                      keyboardType: TextInputType.number,
                      helperText: 'Leave empty to default to 0.0',
                    ),
                    SizedBox(height: 16),

                    // Source
                    buildStyledTextField(
                      controller: _sourceController,
                      labelText: 'Source',
                      hintText: 'Source',
                      onChanged: (value) {
                        setState(() {
                          final isOffline =
                              value.toUpperCase().trim() == 'OFFLINE';
                          final hasImeiList =
                              widget.item.imeiList != null &&
                              widget.item.imeiList!.isNotEmpty;

                          if (isOffline && hasImeiList) {
                            // Pre-select first IMEI when switching to OFFLINE
                            _selectedImei = widget.item.imeiList!.first;
                          } else {
                            // Clear IMEI when switching away from OFFLINE
                            _selectedImei = null;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // IMEI Dropdown (conditionally shown)
                    if (_shouldShowImeiDropdown()) ...[
                      _buildImeiDropdown(),
                      SizedBox(height: 16),
                    ],

                    // Return Reason
                    buildStyledTextField(
                      controller: _returnReasonController,
                      labelText: 'Return Reason *',
                      hintText: 'Return Reason *',
                      maxLines: 4,
                      validator: ValidatorHelper.validateReturnReason,
                    ),
                    SizedBox(height: 16),

                    // Notes
                    buildStyledTextField(
                      controller: _notesController,
                      labelText: 'Notes (Optional)',
                      hintText: 'Notes (Optional)',
                      maxLines: 4,
                    ),
                    SizedBox(height: 24),

                    // Upload Document Section
                    _buildUploadSection(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.isSubmittingReturn.value ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        controller.isSubmittingReturn.value
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildProductInfoRow('Company', widget.item.company),
          SizedBox(height: 12),
          _buildProductInfoRow('Category', widget.item.itemCategory),
          SizedBox(height: 12),
          if (widget.item.rom.isNotEmpty) ...[
            _buildProductInfoRow(
              'ROM',
              AppFormatterHelper.formatRamForUI(widget.item.rom),
            ),
            SizedBox(height: 12),
          ],

          if (widget.item.ram.isNotEmpty) ...[
            _buildProductInfoRow(
              'RAM',
              AppFormatterHelper.formatRamForUI(widget.item.ram),
            ),
            SizedBox(height: 12),
          ],

          _buildProductInfoRow(
            'Selling Price',
            '₹${widget.item.sellingPrice.toStringAsFixed(0)}',
          ),
          SizedBox(height: 12),
          _buildProductInfoRow('Model', widget.item.model),
          SizedBox(height: 12),
          _buildProductInfoRow('Color', widget.item.color),
          SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Total Quantity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Expanded(
                child: IgnorePointer(
                  ignoring: imeiNotNull,
                  child: buildStyledTextField(
                    controller: _quantityController,
                    labelText: 'Quantity *',
                    hintText: 'Enter Quantity  *',
                    digitsOnly: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Return reason is required';
                      }
                      if (double.tryParse(value) != null &&
                          double.parse(value) > widget.item.quantity) {
                        return 'Quantity  available stock (${widget.item.quantity})';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoRow(String labelText, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Return Date *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _returnDateController,
          readOnly: true,
          onTap: _selectDate,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Return date is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Return Date *',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildImeiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMEI (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedImei,
              isExpanded: true,
              hint: Text(
                'Select IMEI (Optional)',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'None',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                ...widget.item.imeiList!.map((imei) {
                  return DropdownMenuItem<String>(
                    value: imei,
                    child: Text(
                      imei,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedImei = newValue;
                });
              },
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Document (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Supported formats: PDF, JPEG, PNG, GIF (Max 10MB)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child:
                _selectedFile != null
                    ? Row(
                      children: [
                        Icon(Icons.attach_file, color: AppColors.primaryLight),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _fileName ?? 'File selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _removeFile,
                          icon: Icon(Icons.close, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Choose File',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  String formatRamForUI(String value) {
    // Extract only digits
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    return '${numbers} GB';
  }
}
