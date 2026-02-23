import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock%20details%20sections/stock_additional_info_section.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock%20details%20sections/stock_amount_section.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock%20details%20sections/stock_header_section.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock%20details%20sections/stock_imei_section.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock%20details%20sections/stock_specifications_section.dart';

class StockItemDetailsPage extends StatelessWidget {
  const StockItemDetailsPage({Key? key, required this.stockItem}) : super(key: key);
final StockItem stockItem;
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
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
                    // Stock Header Section
                    StockHeaderSection(stockItem: stockItem),
                    const SizedBox(height: 16),

                    // Specifications Section
                    StockSpecificationsSection(stockItem: stockItem),
                    const SizedBox(height: 16),

                    // Amount Details Section
                    StockAmountSection(stockItem: stockItem),

                    // IMEI Mapping Section (if available)
                    if (stockItem.parsedColorImeiMapping != null) ...[
                      const SizedBox(height: 16),
                      StockImeiSection(stockItem: stockItem),
                    ],

                    const SizedBox(height: 16),

                    // Additional Information Section
                    StockAdditionalInfoSection(stockItem: stockItem),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}