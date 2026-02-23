import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/online_added_product_model.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20details%20page/online%20add%20product%20details%20sections/product_header_section.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20details%20page/online%20add%20product%20details%20sections/product_purchase_section.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20details%20page/online%20add%20product%20details%20sections/product_specifications_section.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20details%20page/online%20add%20product%20details%20sections/product_system_info_section.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

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
                    // Product Header Section
                    ProductHeaderSection(product: product),
                    const SizedBox(height: 16),

                    // Product Specifications Section
                    ProductSpecificationsSection(product: product),
                    const SizedBox(height: 16),

                    // Purchase Details Section
                    ProductPurchaseSection(product: product),

                    // System Information Section (if available)
                    if (product.shopId.isNotEmpty || product.id > 0) ...[
                      const SizedBox(height: 16),
                      ProductSystemInfoSection(product: product),
                    ],

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