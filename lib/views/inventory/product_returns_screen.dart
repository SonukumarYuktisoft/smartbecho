import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/product_return_controller.dart';
import 'package:smartbecho/models/inventory%20management/product_return_model.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/views/dashboard/widgets/error_cards.dart';
import 'package:smartbecho/views/inventory/components/return_detail_bottom_sheet.dart';

class ProductReturnsScreen extends StatelessWidget {
  final ProductReturnController controller =
      Get.find<ProductReturnController>();
  final BillHistoryController billHistoryController =
      Get.find<BillHistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Returns',
        onPressed: () => Get.back(),
        actionItem: [
          IconButton(
            onPressed: controller.refreshData,
            icon: Icon(Icons.refresh, size: 25),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            CommonSearchBar(
              controller: controller.searchQueryController,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.clearSearch();
                } else {
                  controller.search(value);
                }
              },
              hintText: 'Search by distributor, company...',
              searchQuery: RxString(''),
              clearFilters: () => controller.clearSearch(),
              hasFilters: false,
              // onFilter: () =>  _showFilterBottomSheet(context),
            ),
            // _buildSearchSection(),
            // Content
            Expanded(
              child: Obx(
                () =>
                    controller.isLoading.value
                        ? _buildShimmerCards()
                        : controller.hasError.value
                        ? buildErrorCard(
                          controller.errorMessage,
                          AppConfig.screenWidth,
                          AppConfig.screenHeight,
                          AppConfig.isSmallScreen,
                        )
                        : controller.productReturns.isEmpty
                        ? _buildEmptyState()
                        : _buildReturnsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.searchQueryController,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.clearSearch();
                } else {
                  controller.search(value);
                }
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
                hintText: 'Search by distributor, company...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: Obx(
                  () =>
                      controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                            onPressed: () => controller.clearSearch(),
                            icon: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          )
                          : SizedBox(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Container(
          //   height: 44,
          //   width: 44,
          //   decoration: BoxDecoration(
          //     color: AppColors.primaryLight.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: AppColors.primaryLight.withValues(alpha: 0.3),
          //     ),
          //   ),
          //   child: IconButton(
          //     onPressed: () {
          //       _showReturnFilter();
          //     },
          //     // onPressed: () => _showFilterBottomSheet(context),
          //     icon: Icon(
          //       Icons.tune,
          //       size: 20,
          //       // color: hasActiveFilters ? Colors.white : AppColors.primaryLight,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildReturnsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200) {
          if (!controller.isLoadingMore.value && controller.hasMoreData.value) {
            controller.loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount:
            controller.productReturns.length +
            (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.productReturns.length) {
            return _buildReturnCard(controller.productReturns[index]);
          } else {
            return _buildLoadingMoreCard();
          }
        },
      ),
    );
  }

  Widget _buildReturnCard(ProductReturn returnItem) {
    return InkWell(
      onTap: () => _showReturnDetails(returnItem),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Return ID Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradientLight,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Return #${returnItem.returnSequence}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Return Date
                Column(
                  children: [
                    _buildSource(source: returnItem.source),
                    Text(
                      DateFormat('MMM dd, yyyy').format(returnItem.returnDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            // Product Info
            Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, Color(0xFF59F0D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        returnItem.model,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${returnItem.company} • ${returnItem.itemCategory}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),
            // Specifications Row
            Row(
              children: [
                _buildSpecChip('RAM', returnItem.ram),
                SizedBox(width: 8),
                _buildSpecChip('ROM', returnItem.rom),
                SizedBox(width: 8),
                _buildSpecChip('Color', returnItem.color),
              ],
            ),
            SizedBox(height: 12),
            // Footer Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distributor',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      returnItem.distributor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Return Price',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '₹${returnItem.returnPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // Reason Preview
            if (returnItem.reason.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        returnItem.reason,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSpecChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadingMoreCard() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildShimmerCards() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_return_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Returns Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No product returns match your search',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSource({required String source}) {
    bool isOnline = source == 'Online'.toUpperCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
          width: 1,
        ),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showReturnDetails(ProductReturn returnItem) {
    Get.bottomSheet(
      ReturnDetailBottomSheet(returnItem: returnItem),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _showReturnFilter() {
    // Track selected distributor locally
    String? tempSelectedDistributor =
        controller.selectedDistributor.value.isEmpty
            ? null
            : controller.selectedDistributor.value;

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Returns',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Distributor Dropdown
              Obx(
                () => buildStyledDropdown(
                  value: tempSelectedDistributor,
                  labelText: 'Distributor',
                  items: billHistoryController.companyOptionsList,
                  hintText: 'Select or type Distributor',
                  onChanged: (value) {
                    tempSelectedDistributor = value;
                  },
                ),
              ),

              SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Start Date',
                      controller: controller.startDateController,
                      onTap: () async {
                        await controller.selectStartDate(Get.context!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'End Date',
                      controller: controller.endDateController,
                      onTap: () async {
                        await controller.selectEndDate(Get.context!);
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Clear all filters
                        tempSelectedDistributor = null;
                        controller.selectedDistributor.value = '';
                        controller.startDateController.clear();
                        controller.endDateController.clear();
                        controller.fetchProductReturns();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primaryLight),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply filters
                        if (tempSelectedDistributor != null) {
                          controller.selectedDistributor.value =
                              tempSelectedDistributor!;
                        } else {
                          controller.selectedDistributor.value = '';
                        }
                        controller.fetchProductReturns();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
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
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'dd/mm/yyyy' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          controller.text.isEmpty
                              ? Colors.grey[400]
                              : const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
