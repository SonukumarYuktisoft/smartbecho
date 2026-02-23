import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/bill_history_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bill_details/bill%20details%20sections/bill_amount_details_section.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bill_details/bill%20details%20sections/bill_header_section.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bill_details/bill%20details%20sections/bill_items_section.dart';

class BillDetailsPage extends StatelessWidget {
  const BillDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Bill bill = Get.arguments as Bill;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bill Details',
        onPressed: () => Get.back(),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill Header Section
                    BillHeaderSection(bill: bill),
                    const SizedBox(height: 16),

                    // Items Section
                    BillItemsSection(bill: bill),
                    const SizedBox(height: 16),

                    // Amount Details Section
                    BillAmountDetailsSection(bill: bill),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(bill),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButton(Bill bill) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () => _downloadBill(bill),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(Icons.download, size: 20),
        label: const Text(
          'Download Bill',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _downloadBill(Bill bill) {
    Get.snackbar(
      'Download',
      'Downloading Bill #${bill.billId}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.primaryLight,
      colorText: Colors.white,
      icon: const Icon(Icons.download, color: Colors.white),
      margin: const EdgeInsets.all(16),
    );
  }
}