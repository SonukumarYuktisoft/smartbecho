import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/add_new_stock_operation_controller.dart';
import 'package:smartbecho/utils/BarcodeScanner/Barcodes_scanner.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_back_button.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/common/app%20borders/dashed_border.dart';
import 'package:smartbecho/utils/helper/validator/validator_hepler.dart';

class AddNewStockForm extends StatelessWidget {
  AddNewStockForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AddNewStockOperationController controller = Get.find();
    final BarcodeScannerController barcodeScannerController = Get.put(
      BarcodeScannerController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'Add New Stock'),
      body: Form(
        key: controller.addBillFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildFormContent(controller)],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AddNewStockOperationController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: customBackButton(isdark: true),
      ),
      automaticallyImplyLeading: false,
      title: Text(
        'Add Stock Information',
        style: AppStyles.custom(
          color: const Color(0xFF1A1A1A),
          size: 18,
          weight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFormContent(AddNewStockOperationController controller) {
    final BillHistoryController billHistoryController =
        Get.find<BillHistoryController>();
    return SafeArea(
      child: Container(
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
              // Distributor Name and Date
              Row(
                children: [
                  // Expanded(
                  //   child: buildStyledTextField(
                  //     labelText: 'Distributor Name *',
                  //     controller: controller.companyNameController,
                  //     hintText: 'Enter distributor name',
                  //     validator: controller.validateCompanyName,
                  //   ),
                  // ),
                  Expanded(
                    child: Obx(
                      () => buildAutocompleteField(
                        labelText: 'Distributor *',
                        controller: controller.companyNameController,
                        suggestions: billHistoryController.companyOptionsList,
                        hintText: 'Select or type Distributor',
                        onChanged: (value) {},
                        validator: controller.validateCompanyName,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(controller),
                      child: AbsorbPointer(
                        child: buildStyledTextField(
                          labelText: 'Date *',
                          controller: controller.dateController,
                          hintText: 'Select date',
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Stock Items', Icons.inventory_2),
              const SizedBox(height: 16),

              // Items List
              Obx(
                () => Column(
                  children: [
                    ...controller.billItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      BillItem item = entry.value;
                      return _buildItemCard(controller, item, index);
                    }).toList(),

                    // Add Item Button
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        onPressed: controller.addNewItem,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Another Item'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          foregroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    if (controller.billItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No items added yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Total Summary', Icons.receipt),
              const SizedBox(height: 16),

              // Total Summary
              Row(
                children: [
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'Without GST Amount *',
                      controller: controller.withoutGstController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildStyledTextField(
                      labelText: 'Total Amount (with GST) *',
                      controller: controller.amountController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              buildStyledTextField(
                labelText: 'Total GST Amount *',
                controller: controller.totalGstAmountController,
                hintText: '0',
                keyboardType: TextInputType.number,
                readOnly: true,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Invoice Upload', Icons.attach_file),
              const SizedBox(height: 16),

              _buildFileUploadSection(controller),

              const SizedBox(height: 32),

              // Action Buttons
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        child: OutlinedButton(
                          onPressed:
                              controller.isAddingBill.value
                                  ? null
                                  : controller.cancelAddBill,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reset Form',
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
                      flex: 2,
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              controller.isAddingBill.value
                                  ? null
                                  : () {
                                    controller.addBillToSystem();
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              controller.isAddingBill.value
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
                                    'Save Stock',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error Message Display
              Obx(
                () =>
                    controller.hasAddBillError.value
                        ? Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
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
                                  controller.addBillErrorMessage.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    AddNewStockOperationController controller,
    BillItem item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => controller.removeItem(index),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          Obx(
            () => buildStyledDropdown(
              labelText: 'Category *',
              hintText: 'Select Category',
              value: item.category.value.isEmpty ? null : item.category.value,
              items: controller.categories,
              onChanged: (String? newValue) {
                item.category.value = newValue ?? '';
              },
            ),
          ),
          const SizedBox(height: 16),

          // Company - with autocomplete
          Obx(
            () => _buildAutocompleteField(
              labelText: 'Company *',
              controller: item.companyController,
              suggestions: item.companySuggestions,
              hintText: 'Select or type Company',
              onChanged: (value) {
                item.company.value = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Company is required';
                }
                return null;
              },
              keyboardType: TextInputType.name,
            ),
          ),
          const SizedBox(height: 16),

          // Model - with autocomplete
          Obx(
            () => _buildAutocompleteField(
              labelText: 'Model *',
              controller: item.modelController,
              suggestions: item.modelSuggestions,
              hintText: 'Select or type Model',
              onChanged: (value) {
                item.model.value = value;
              },
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Model is required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Show RAM and ROM only for SMARTPHONE/TABLET
          Obx(
            () =>
                (item.category.value.toUpperCase() == 'SMARTPHONE' ||
                        item.category.value.toUpperCase() == 'TABLET')
                    ? Column(
                      children: [
                        // NEW CODE - Replace with this:
                        Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => buildStyledDropdown(
                                  labelText: 'RAM (GB) *',
                                  hintText: 'Select RAM',
                                  value:
                                      item.ram.value.isEmpty
                                          ? null
                                          : item.ram.value,
                                  items: item.ramOptions,
                                  enabled: true,
                                  onChanged: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      item.ram.value = value;
                                      item.ramController.text = value;
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'RAM is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => buildStyledDropdown(
                                  labelText: 'Storage (ROM) (GB) *',
                                  hintText: 'Select Storage',
                                  value:
                                      item.rom.value.isEmpty
                                          ? null
                                          : item.rom.value,
                                  items: item.storageOptions,
                                  enabled: true,
                                  onChanged: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      item.rom.value = value;
                                      item.romController.text = value;
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'ROM is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: buildStyledDropdown(
                        //         labelText: 'RAM (GB) *',
                        //         hintText: 'Select RAM *',
                        //         value:
                        //             item.selectedAddRam.value.isEmpty
                        //                 ? null
                        //                 : item.selectedAddRam.value,
                        //         items: item.ramOptions,
                        //         enabled: true,
                        //         onChanged:
                        //             (value) =>
                        //                 item.onAddRamChanged(value ?? ''),
                        //         validator: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             return 'RAM is required';
                        //           }
                        //           return null;
                        //         },
                        //       ),
                        //     ),
                        //     const SizedBox(width: 5),
                        //     Expanded(
                        //       child: buildStyledDropdown(
                        //         labelText: 'Storage (ROM) (GB) *',
                        //         hintText: 'Select Storage *',
                        //         value:
                        //             item.selectedAddStorage.value.isEmpty
                        //                 ? null
                        //                 : item.selectedAddStorage.value,
                        //         items: item.storageOptions,
                        //         enabled: true,
                        //         onChanged: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             item.romController.text = value.toString();
                        //           }
                        //         } ,
                        //         // onChanged:
                        //         //     (value) =>
                        //         //         item.onAddStorageChanged(value ?? ''),
                        //         validator: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             return 'ROM is required';
                        //           }
                        //           return null;
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Obx(
                        //         () => _buildAutocompleteField(
                        //           labelText: 'RAM *',
                        //           controller: item.ramController,
                        //           suggestions: item.ramSuggestions,
                        //           hintText: 'Select or type RAM',
                        //           keyboardType: TextInputType.number,
                        //           onChanged: (value) {
                        //             item.ram.value = value;
                        //           },
                        //           validator: (value) {
                        //             if (value == null || value.isEmpty) {
                        //               return 'RAM is required';
                        //             }
                        //             return null;
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 16),
                        //     Expanded(
                        //       child: Obx(
                        //         () => _buildAutocompleteField(
                        //           labelText: 'ROM *',
                        //           controller: item.romController,
                        //           suggestions: item.romSuggestions,
                        //           hintText: 'Select or type ROM',
                        //           keyboardType: TextInputType.number,
                        //           onChanged: (value) {
                        //             item.rom.value = value;
                        //           },
                        //           validator: (value) {
                        //             if (value == null || value.isEmpty) {
                        //               return 'ROM is required';
                        //             }
                        //             return null;
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 16),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),

          // Color - with autocomplete
          Obx(
            () => _buildAutocompleteField(
              labelText: 'Color *',
              controller: item.colorController,
              suggestions: item.colorSuggestions,
              hintText: 'Select or type Color',
              onChanged: (value) {
                item.color.value = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Color is required';
                }
                return null;
              },
              keyboardType: TextInputType.name,
            ),
          ),
          const SizedBox(height: 16),

          // Quantity
          buildStyledTextField(
            labelText: 'Quantity *',
            controller: item.qtyController,
            hintText: '0',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              item.qty.value = value;
              controller.calculateItemTotals(index);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Quantity is required';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Enter valid quantity';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Unit Price and Discount
          Row(
            children: [
              Expanded(
                child: buildStyledTextField(
                  labelText: 'Unit Price *',
                  controller: item.unitPriceController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    item.unitPrice.value = value;
                    controller.calculateItemTotals(index);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unit price is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildStyledTextField(
                  labelText: 'Discount Percentage (%)',
                  controller: item.discountController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    item.discountPercentage.value = value;
                    controller.calculateItemTotals(index);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Selling Price
          buildStyledTextField(
            labelText: 'Selling Price *',
            controller: item.sellingPriceController,
            hintText: '0',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              item.sellingPrice.value = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selling price is required';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          buildStyledTextField(
            labelText: 'Description (Optional)',
            controller: item.descriptionController,
            hintText: 'Enter item description',
            // maxLines: 2,
            onChanged: (value) {
              item.description.value = value;
            },
            validator: ValidatorHelper.validateDescription,
          ),
          const SizedBox(height: 16),
          // GST fields (only if hasGstNumber is true)
          if (controller.hasGstNumber!) ...[
            Row(
              children: [
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'GST Percentage *',
                    controller: item.gstPercentageController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStyledTextField(
                    labelText: 'Without GST Amount *',
                    controller: item.withoutGstAmountController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildStyledTextField(
              labelText: 'With GST Amount *',
              controller: item.withGstAmountController,
              hintText: '0',
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            const SizedBox(height: 16),
          ],

          // IMEI Numbers (Optional) - shown based on quantity
          Obx(() {
            int qty = int.tryParse(item.qty.value) ?? 0;
            if (qty > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IMEI Numbers (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(qty, (imeiIndex) {
                    if (imeiIndex >= item.imeiControllers.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TextField
                          Expanded(
                            child: buildStyledTextField(
                              labelText: 'IMEI ${imeiIndex + 1}',
                              controller: item.imeiControllers[imeiIndex],
                              hintText: 'Enter IMEI number (optional)',
                              keyboardType: TextInputType.number,
                              digitsOnly: true,
                              maxLength: 15,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Scanner Button
                          Column(
                            children: [
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    // final data
                                    final barcodeScannerController =
                                        Get.find<BarcodeScannerController>();
                                    final scannedData =
                                        await barcodeScannerController
                                            .openBarcodeScanner();
                                    if (scannedData != null) {
                                      barcodeScannerController.setBarcode(
                                        scannedData,
                                      );

                                      item.imeiControllers[imeiIndex].text =
                                          scannedData;
                                    } else {
                                      barcodeScannerController.clearBarcode();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  tooltip: 'Scan IMEI ${imeiIndex + 1}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String labelText,
    required TextEditingController controller,
    required RxList<String> suggestions,
    required String hintText,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    // Get suggestions list - this triggers Obx reactivity
    final suggestionsList = suggestions.toList();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return suggestionsList;
        }
        return suggestionsList.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
        onChanged(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sync with the main controller only once
        if (fieldController.text.isEmpty && controller.text.isNotEmpty) {
          fieldController.text = controller.text;
        }

        fieldController.removeListener(() {});
        fieldController.addListener(() {
          if (controller.text != fieldController.text) {
            controller.text = fieldController.text;
            onChanged(fieldController.text);
          }
        });

        return buildStyledTextField(
          labelText: labelText,
          controller: fieldController,
          hintText: hintText,
          keyboardType: keyboardType,
          focusNode: focusNode,
          validator: validator,
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileUploadSection(AddNewStockOperationController controller) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child:
            controller.selectedFile.value != null
                ? _buildSelectedFileCard(controller)
                : _buildFilePickerButton(controller),
      ),
    );
  }

  Widget _buildFilePickerButton(AddNewStockOperationController controller) {
    return Obx(
      () => InkWell(
        onTap: controller.isFileUploading.value ? null : controller.pickFile,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: DashedBorder(
            color: Colors.grey.shade600,
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 4,
            borderRadius: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isFileUploading.value)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: AppColors.primaryLight,
                      size: 24,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  controller.isFileUploading.value
                      ? 'Selecting file...'
                      : 'Upload File',
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.isFileUploading.value
                      ? 'Please wait'
                      : 'Click to select file',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(AddNewStockOperationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(controller.fileName.value),
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
                  controller.fileName.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'File selected successfully',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.removeFile,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  Future<void> _selectDate(AddNewStockOperationController controller) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          controller.dateController.text.isNotEmpty
              ? DateTime.tryParse(controller.dateController.text) ??
                  DateTime.now()
              : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF14B8A6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format date as YYYY-MM-DD
      String formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.dateController.text = formattedDate;
    }
  }
}
