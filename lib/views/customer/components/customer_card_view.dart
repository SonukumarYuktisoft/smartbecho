import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_card_view_controller.dart';
import 'package:smartbecho/models/customer%20management/customer_data_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/show_network_image.dart';

class CustomerCardViewPage extends StatelessWidget {
  final CustomerCardsController controller = Get.put(
    CustomerCardsController(),
    permanent: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Customer Details',),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // buildCustomAppBar("Customer Details", isdark: true),
            // Show loading indicator when initially loading or searching
            Obx(
              () => (controller.isLoading.value && controller.apiCustomers.isEmpty) ||
                      controller.isSearching.value
                  ? LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      color: Color(0xFF6C5CE7),
                    )
                  : SizedBox(),
            ),
            _buildCompactSearchAndFilters(),
            NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent &&
                    !controller.isLoadingMore.value &&
                    !controller.isLoading.value &&
                    !controller.isSearching.value) {
                  controller.loadMoreCustomers();
                }
                return false;
              },
              child: Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Stats as a sliver that can scroll with content
                    SliverToBoxAdapter(child: _buildCompactStatsRow()),
                    // Customer cards
                    _buildCustomerCardsSlivers(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSearchAndFilters() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(2),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
                  ),
                  child: TextFormField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                      prefixIcon: 
                       Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                      
                      suffixIcon: Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                onPressed: () => controller.onSearchChanged(''),
                                icon: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              )
                            : SizedBox(),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Compact filter toggle
              Obx(
                () => Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha:0.3)),
                  ),
                  child: IconButton(
                    onPressed: () => controller.toggleFiltersExpanded(),
                    icon: Icon(
                      controller.isFiltersExpanded.value
                          ? Icons.expand_less
                          : Icons.tune,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    tooltip: 'Filters',
                  ),
                ),
              ),
             
            ],
          ),

          // Expandable filters section
          Obx(
            () => AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: controller.isFiltersExpanded.value ? null : 0,
              child: controller.isFiltersExpanded.value
                  ? Column(
                      children: [
                        SizedBox(height: 12),
                        // Filter chips in a more compact layout
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildCompactFilterChip('All'),
                                  _buildCompactFilterChip('New'),
                                  _buildCompactFilterChip('Regular'),
                                  _buildCompactFilterChip('Repeated'),
                                  _buildCompactFilterChip('VIP'),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            // Compact sort dropdown
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha:0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Obx(
                                    () => DropdownButton<String>(
                                      value: controller.sortBy.value,
                                      onChanged: (value) =>
                                          controller.onSortChanged(value!),
                                      underline: SizedBox(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                      items: [
                                        'Name',
                                        'Total Purchase',
                                        'Total Dues',
                                        'Location',
                                      ]
                                          .map(
                                            (sort) => DropdownMenuItem(
                                              value: sort,
                                              child: Text(sort),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Clear filters button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => controller.resetFilters(),
                            icon: Icon(Icons.clear_all, size: 14),
                            label: Text(
                              'Clear All',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size(0, 0),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip(String filter) {
    return Obx(
      () => FilterChip(
        label: Text(
          filter,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: controller.selectedFilter.value == filter
                ? Colors.white
                : Colors.grey[700],
          ),
        ),
        selected: controller.selectedFilter.value == filter,
        onSelected: (selected) => controller.onFilterChanged(filter),
        selectedColor: Color(0xFF6C5CE7),
        backgroundColor: Colors.grey[100],
        checkmarkColor: Colors.white,
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 1,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }

  Widget _buildCompactStatsRow() {
    return Container(
      height: 60, // Reduced height
      margin: EdgeInsets.fromLTRB(16, 4, 16, 8), // Reduced margins
      child: Obx(
        () => Row(
          children: [
            _buildCompactStatItem(
              'All',
              controller.getCustomerCountByType('All'),
              Color(0xFF6C5CE7),
            ),
            _buildCompactStatItem(
              'New',
              controller.getCustomerCountByType('New'),
              Color(0xFF00CEC9),
            ),
            _buildCompactStatItem(
              'Regular',
              controller.getCustomerCountByType('Regular'),
              Color(0xFF6C5CE7),
            ),
            _buildCompactStatItem(
              'Repeated',
              controller.getCustomerCountByType('Repeated'),
              Color(0xFF51CF66),
            ),
            _buildCompactStatItem(
              'VIP',
              controller.getCustomerCountByType('VIP'),
              Color(0xFFFFD700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 6), // Reduced margin
        padding: EdgeInsets.all(8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.05),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9, // Reduced font size
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCardsSlivers() {
    return Obx(() {
      if (controller.hasError.value) {
        return SliverFillRemaining(child: _buildErrorState());
      }

      if (controller.isLoading.value && controller.apiCustomers.isEmpty) {
        return SliverFillRemaining(child: _buildLoadingState());
      }

      if (controller.filteredCustomers.isEmpty && 
          !controller.isLoading.value && 
          !controller.isSearching.value) {
        return SliverFillRemaining(child: _buildEmptyState());
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8, // Adjust this to control card height
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == controller.filteredCustomers.length) {
                return controller.isLoadingMore.value
                    ? Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C5CE7),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              }

              final customer = controller.filteredCustomers[index];
              return _buildCompactCustomerCard(customer, index);
            },
            childCount: controller.filteredCustomers.length +
                (controller.isLoadingMore.value ? 1 : 0),
          ),
        ),
      );
    });
  }

  Widget _buildCompactCustomerCard(Customer customer, int index) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.06),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: controller
              .getCustomerTypeColor(customer.customerType)
              .withValues(alpha:0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with avatar and customer type badge
          Row(
            children: [
              customer.profilePhotoUrl == null || customer.profilePhotoUrl.isEmpty
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            controller.getCustomerTypeColor(customer.customerType),
                            controller
                                .getCustomerTypeColor(customer.customerType)
                                .withValues(alpha:0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        controller.getCustomerTypeIcon(customer.customerType),
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: cachedImage(
                        customer.profilePhotoUrl,
                        width: 36,
                        height: 36,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
              Spacer(),
              _buildCompactCustomerTypeBadge(customer.customerType),
            ],
          ),

          SizedBox(height: 6),

          // Customer name
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 6),

          // Phone number
          Row(
            children: [
              Icon(Icons.phone, size: 10, color: Colors.grey[500]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer.primaryPhone,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 10, color: Colors.grey[500]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer.location,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Spacer(),

          // Purchase and Dues section
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Purchase row
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 10,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Purchase',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Text(
                      customer.formattedTotalPurchase,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF51CF66),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                // Dues row
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 10,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Dues',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Text(
                      customer.formattedTotalDues,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            customer.totalDues > 0
                                ? Color(0xFFFF6B6B)
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 28,
                  child: ElevatedButton(
                    onPressed:
                        () => controller.callCustomer(customer.primaryPhone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF51CF66).withValues(alpha:0.1),
                      foregroundColor: Color(0xFF51CF66),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.call, size: 12),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () => controller.editCustomer(customer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C5CE7).withValues(alpha:0.1),
                      foregroundColor: Color(0xFF6C5CE7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.edit, size: 12),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.customerDetails, arguments: customer.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B).withValues(alpha:0.1),
                      foregroundColor: Color.fromARGB(255, 160, 152, 152),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.remove_red_eye, size: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCustomerTypeBadge(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: controller.getCustomerTypeColor(type).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: controller.getCustomerTypeColor(type).withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.getCustomerTypeIcon(type),
            size: 8,
            color: controller.getCustomerTypeColor(type),
          ),
          SizedBox(width: 2),
          Text(
            type.length > 6 ? type.substring(0, 3) : type,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: controller.getCustomerTypeColor(type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          SizedBox(height: 16),
          Text(
            'Loading customers...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            'Error loading customers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshCustomers(),
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
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
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty 
                ? 'No customers found for "${controller.searchQuery.value}"'
                : 'No customers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Try searching with a different name or phone number'
                : 'Try adjusting your filters or search terms',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.resetFilters(),
            child: Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}