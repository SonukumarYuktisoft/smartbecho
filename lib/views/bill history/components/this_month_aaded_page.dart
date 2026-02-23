import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/models/bill%20history/this_month_added_stock_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class ThisMonthStockScreen extends GetView<ThisMonthStockController> {
  const ThisMonthStockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'This Month Online Added Stock'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // buildCustomAppBar("This Month Online Added Stock", isdark: true),

            // Loading indicator
            Obx(
              () =>
                  controller.isLoading.value
                      ? LinearProgressIndicator(
                       
                      )
                      : SizedBox.shrink(),
            ),

            // Stats section
            _buildStatsSection(),

            // Filter and sort section
            _buildFilterSection(),

            // Stock items list
            Expanded(child: _buildStockItemsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E293B),
                strokeWidth: 2,
              ),
            ),
          );
        }

        return Container(
          height: 140,
          child: ListView(
             scrollDirection: Axis.horizontal,
             shrinkWrap: true,
            children: [
              BuildStatsCard(
                label: 'Total Items',
                value: controller.totalItems.value.toString(),
                icon: Icons.inventory_2,
                color: Color(0xFF3B82F6),
                width: 180,
            isAmount:  false,
              ),
              BuildStatsCard(
                label: 'Total Quantity',
                value: controller.totalQuantity.value.toString(),
                icon: Icons.format_list_numbered,
                color: Color(0xFF10B981),
                width: 180,
            isAmount:  false,
              ),
              BuildStatsCard(
                label: 'Total Value',
                value: controller.totalValue.value.toStringAsFixed(0),
                icon: Icons.currency_rupee,
                color: Color(0xFFF59E0B),
                width: 180,
              ),
              BuildStatsCard(
                label: 'Unique Models',
                value: controller.uniqueModels.value.toString(),
                icon: Icons.devices,
                color: Color(0xFF8B5CF6),
                width: 180,
            isAmount:  false,
              ),
              BuildStatsCard(
                label: 'Companies',
                value: controller.uniqueCompanies.value.toString(),
                icon: Icons.business,
                color: Color(0xFFEF4444),
                width: 180,
            isAmount:  false,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _BuildStatsCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showFilterBottomSheet(),
              icon: Icon(Icons.filter_list, size: 18),
              label: Obx(() {
                String filterText = 'Filter & Sort';
                List<String> activeFilters = [];

                if (controller.selectedCompany.value != 'All') {
                  activeFilters.add(controller.selectedCompany.value);
                }

                if (controller.selectedCategory.value != 'All') {
                  activeFilters.add(controller.selectedCategory.value);
                }

                if (activeFilters.isNotEmpty) {
                  filterText = activeFilters.join(' • ');
                }

                return Text(
                  filterText,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                );
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => controller.refreshData(),
              icon: Obx(
                () =>
                    controller.isLoading.value
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                           
                          ),
                        )
                        : Icon(Icons.refresh, color: Color(0xFF1E293B)),
              ),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItemsList() {
    return Obx(() {
      if (controller.error.value.isNotEmpty && controller.stockItems.isEmpty) {
        return _buildErrorState();
      }

      if (controller.isLoading.value && controller.stockItems.isEmpty) {
        return _buildLoadingState();
      }

      final filteredItems = controller.filteredItems;

      if (filteredItems.isEmpty) {
        return _buildEmptyState();
      }

      return AppRefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _buildStockItemCard(item);
          },
        ),
      );
    });
  }

  Widget _buildStockItemCard(ThisMonthStockItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: controller
              .getCategoryColor(item.itemCategory)
              .withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with company and category
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  controller
                      .getCompanyColor(item.company)
                      .withValues(alpha: 0.1),
                  controller
                      .getCompanyColor(item.company)
                      .withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Company logo/icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller.getCompanyColor(item.company),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            controller.getCompanyIcon(item.company),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller.getCompanyColor(item.company),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            controller.getCompanyIcon(item.company),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.companyDisplayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: controller.getCompanyColor(item.company),
                        ),
                      ),
                      Text(
                        item.model,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCategoryBadge(item),
              ],
            ),
          ),


 Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDottedLine(),
              ),
            ),
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Specifications row
                Row(
                  children: [
                    _buildSpecChip('RAM', item.ram, Icons.memory),
                    SizedBox(width: 8),
                    _buildSpecChip('ROM', item.rom, Icons.storage),
                    SizedBox(width: 8),
                    _buildSpecChip('Color', item.color, Icons.palette),
                  ],
                ),

                SizedBox(height: 12),

                // Price and quantity row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selling Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.qty} units',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Date added
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Added on ${item.formattedDate}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(ThisMonthStockItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: controller.getCategoryColor(item.itemCategory),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.getCategoryIcon(item.itemCategory),
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            item.categoryDisplayName,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Company and Category Row
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Company',
                        hintText: 'Select Company',
                        value:
                            controller.selectedCompany.value == 'All'
                                ? null
                                : controller.selectedCompany.value,
                        items: controller.companyOptions,
                        onChanged: controller.onCompanyChanged,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Category',
                        hintText: 'Select Category',
                        value:
                            controller.selectedCategory.value == 'All'
                                ? null
                                : controller.selectedCategory.value,
                        items: controller.categoryOptions,
                        onChanged: controller.onCategoryChanged,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Sort Option
              Obx(
                () => buildStyledDropdown(
                  labelText: 'Sort By',
                  hintText: 'Select Sort Field',
                  value: controller.getSortDisplayName(controller.sortBy.value),
                  items:
                      controller.sortOptions
                          .map((e) => controller.getSortDisplayName(e))
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final sortField = controller.sortOptions.firstWhere(
                        (field) =>
                            controller.getSortDisplayName(field) == value,
                      );
                      controller.onSortChanged(sortField);
                    }
                  },
                  suffixIcon: Icon(
                    controller.sortDir.value == 'asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetFilters();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1E293B),
                        side: BorderSide(color: AppColors.primaryLight),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Loading stock items...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No stock items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Obx(
              () => Text(
                controller.error.value,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
