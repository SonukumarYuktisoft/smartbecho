import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/models/hsncode_models/hsn_code_model.dart';

class AddEditHsnCodeForm extends StatefulWidget {
  final HsnCodeModel? hsnCode;
  final List<String> itemCategories;
  final Function(Map<String, dynamic> data) onSave;
  final VoidCallback? onCancel;

  const AddEditHsnCodeForm({
    Key? key,
    this.hsnCode,
    required this.itemCategories,
    required this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<AddEditHsnCodeForm> createState() => _AddEditHsnCodeFormState();
}

class _AddEditHsnCodeFormState extends State<AddEditHsnCodeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController hsnCodeController;
  late TextEditingController descriptionController;
  late TextEditingController gstController;
  String? selectedCategory;
  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.hsnCode != null;
    hsnCodeController = TextEditingController(text: widget.hsnCode?.hsnCode);
    descriptionController = TextEditingController(
      text: widget.hsnCode?.description,
    );
    gstController = TextEditingController(
      text: widget.hsnCode?.gstPercentage.toString(),
    );
    selectedCategory = widget.hsnCode?.itemCategory;
    isActive = widget.hsnCode?.isActive ?? true;
  }

  @override
  void dispose() {
    hsnCodeController.dispose();
    descriptionController.dispose();
    gstController.dispose();
    super.dispose();
  }

  bool get isEdit => widget.hsnCode != null;

  String get formattedTitle {
    if (!isEdit) return 'New HSN Code';
    return hsnCodeController.text.isEmpty ? 'HSN Code' : hsnCodeController.text;
  }

  String get formattedSubtitle {
    if (!isEdit) return 'Fill details to add HSN code';
    List<String> parts = [];
    if (selectedCategory != null) parts.add(selectedCategory!);
    if (gstController.text.isNotEmpty) parts.add('${gstController.text}% GST');
    return parts.isEmpty ? 'Edit HSN Code details' : parts.join(' • ');
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select an item category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);

    final data = {
      'hsnCode': hsnCodeController.text,
      'itemCategory': selectedCategory,
      'gstPercentage': double.parse(gstController.text),
      'description': descriptionController.text,
      'isActive': isActive,
    };

    widget.onSave(data);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar:CustomAppBar(title:     isEdit ? 'EDIT HSN CODE' : 'ADD NEW HSN CODE',),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildFormHeader(), _buildFormContent()],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isdark = true;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isdark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isdark ? Colors.black : Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.all(8),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
                  isEdit ? 'EDIT HSN CODE' : 'ADD NEW HSN CODE',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isEdit
                      ? 'Update HSN details'
                      : 'Fill details to add HSN code',
                  style: const TextStyle(
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
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.qr_code_2,
                color: AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedTitle,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formattedSubtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedCategory != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  selectedCategory!,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
            _buildSectionTitle('HSN Code Information', Icons.info_outline),
            const SizedBox(height: 16),

            // HSN Code Field
            _buildStyledTextField(
              labelText: 'HSN Code',
              controller: hsnCodeController,
              hintText: 'Enter HSN code',
              prefixIcon: Icons.qr_code,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter HSN code';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Item Category Dropdown
            _buildStyledDropdown(
              labelText: 'Item Category',
              hintText: 'Select Category',
              prefixIcon: Icons.category,
              value: selectedCategory,
              items: widget.itemCategories,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // GST Percentage Field
            _buildStyledTextField(
              labelText: 'GST Percentage',
              controller: gstController,
              hintText: '0.0',
              prefixIcon: Icons.percent,
              suffixText: '%',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GST percentage';
                }
                final gst = double.tryParse(value);
                if (gst == null || gst < 0 || gst > 100) {
                  return 'Enter valid percentage (0-100)';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Additional Details', Icons.description),
            const SizedBox(height: 16),

            // Description Field
            _buildStyledTextField(
              labelText: 'Description (Optional)',
              controller: descriptionController,
              hintText: 'Enter description',
              prefixIcon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            _buildStyledDropdown(
              labelText: 'Status',
              hintText: 'Select Status',
              prefixIcon: Icons.toggle_on,
              value: isActive ? 'Active' : 'Inactive',
              items: const ['Active', 'Inactive'],
              onChanged: (value) {
                setState(() {
                  isActive = value == 'Active';
                });
              },
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                if (widget.onCancel != null) {
                                  widget.onCancel!();
                                } else {
                                  Get.back();
                                }
                              },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          isLoading
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
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEdit ? Icons.check : Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEdit ? 'Update' : 'Save',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ],
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
            color: AppColors.primaryLight.withOpacity(0.1),
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

  Widget _buildStyledTextField({
    required String labelText,
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    String? suffixText,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, color: AppColors.primaryLight, size: 20)
                    : null,
            suffixText: suffixText,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
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

  Widget _buildStyledDropdown({
    required String labelText,
    required String hintText,
    IconData? prefixIcon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, color: AppColors.primaryLight, size: 20)
                    : null,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
