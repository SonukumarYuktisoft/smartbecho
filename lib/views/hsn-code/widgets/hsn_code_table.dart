import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/hsn-codecontrollers/hsn_code_controller.dart';
import 'package:smartbecho/models/hsncode_models/hsn_code_model.dart';

class HsnCodeTable extends StatelessWidget {
  final List<HsnCodeModel> hsnCodes;

  final HsnCodeController controller = Get.find<HsnCodeController>();
  HsnCodeTable({Key? key, required this.hsnCodes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SingleChildScrollView(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              // sortColumnIndex: sortColumnIndex,
              // sortAscending: isAscending,
              headingRowColor: MaterialStateProperty.all(
             AppColors.primaryLight,
              ),
              columns: [
                DataColumn(
                  label: const Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'HSN Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'Item Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'GST Percentage',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  hsnCodes.map((hsnCode) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${hsnCode.id}')),
                        DataCell(Text(hsnCode.hsnCode)),
                        DataCell(Text(hsnCode.itemCategory)),
                        DataCell(Text('${hsnCode.gstPercentage}%')),
                        DataCell(Text(hsnCode.description ?? '')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  hsnCode.isActive ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hsnCode.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showAddEditDialog(
                                      context,
                                      hsnCode: hsnCode,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _confirmDelete(
                                      context,
                                      '${hsnCode.id}',
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {HsnCodeModel? hsnCode}) {
    final isEdit = hsnCode != null;
    final hsnCodeController = TextEditingController(text: hsnCode?.hsnCode);
    final descriptionController = TextEditingController(
      text: hsnCode?.description,
    );
    final gstController = TextEditingController(
      text: hsnCode?.gstPercentage.toString(),
    );
    String selectedCategory = hsnCode?.itemCategory ?? '';
    bool isActive = hsnCode?.isActive ?? true;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(isEdit ? 'Edit HSN Code' : 'Add New HSN Code'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: hsnCodeController,
                    decoration: const InputDecoration(
                      labelText: 'HSN Code *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedCategory.isEmpty ? null : selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Item Category *',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          controller.itemCategories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.replaceAll('_', ' ')),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedCategory = value ?? '';
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: gstController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'GST Percentage *',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder:
                        (context, setState) => DropdownButtonFormField<bool>(
                          value: isActive,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              isActive = value ?? true;
                            });
                          },
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (hsnCodeController.text.isEmpty ||
                      selectedCategory.isEmpty ||
                      gstController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please fill all required fields',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final data = {
                    'hsnCode': hsnCodeController.text,
                    'itemCategory': selectedCategory,
                    'gstPercentage': double.parse(gstController.text),
                    'description': descriptionController.text,
                    'isActive': isActive,
                  };

                  if (isEdit) {
                    controller.updateHsnCode(hsnCode.id.toString(), data);
                  } else {
                    controller.addHsnCode(data);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete HSN Code'),
            content: const Text(
              'Are you sure you want to delete this HSN code?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.deleteHsnCode(id);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
