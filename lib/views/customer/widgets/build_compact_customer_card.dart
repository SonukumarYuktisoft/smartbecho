import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_card_view_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/show_network_image.dart';
import 'package:smartbecho/models/customer%20management/customer_data_model.dart';

class BuildCompactCustomerCard extends StatelessWidget {
  BuildCompactCustomerCard({super.key});
  // final CustomerCardsController controller = Get.put(
  //   CustomerCardsController(),
  //   permanent: false,
  // );
  final CustomerController controller = Get.find<CustomerController>();
  final ScrollController _scrollController = ScrollController();

  void _setupScrollListener() {
    // Prevent duplicate listeners (important for Stateless rebuilds)
    if (!_scrollController.hasListeners) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          if (!controller.isLoadingMore.value &&
              !controller.isLoading.value &&
              !controller.isLastPage.value) {
            controller.loadMoreCustomersn();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupScrollListener();
    return Obx(() {
      if (controller.hasError.value) {
        return _buildErrorState();
      }

      if (controller.isLoading.value ) {
        return _buildLoadingState();
      }

      if (controller.filteredApiCustomers.isEmpty &&
          !controller.isLoading.value) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //   crossAxisCount: 2,
        //   crossAxisSpacing: 12,
        //   mainAxisSpacing: 12,
        //   childAspectRatio: 0.75, // Adjust card height
        // ),
        itemCount:
            controller.filteredApiCustomers.length +
            (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.filteredApiCustomers.length) {
            return controller.isLoadingMore.value
                ? Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C5CE7),
                      strokeWidth: 2,
                    ),
                  ),
                )
                : const SizedBox.shrink();
          }

          final customer = controller.filteredApiCustomers[index];
            //  List<Color>  cardColors =[
            //   const Color(0xFF1F2937),
            //   Colors.red,
            //   Colors.green,
            //   Colors.blue,
            //   Colors.orange,
            //   Colors.yellow,
            //   Colors.purple,
            //   Colors.teal,
            //   Colors.indigo,
            //   Colors.brown,
            //   Colors.cyan,
            //   Colors.amber,
            //   Colors.deepPurpleAccent,
            //   Colors.lightGreen,
              
            //  ];
          return _buildCompactCustomerCard(customer, index,);
        },
      );
    });
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
            // onPressed: () => controller.refreshCustomers(),
            onPressed: () => controller.loadCustomersFromApi(loadMore: false),
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
Widget _buildCompactCustomerCard(Customer customer, int index, {Color? color}) {
  return InkWell(
    onTap: () => Get.toNamed(AppRoutes.customerDetails, arguments: customer.id),
    child: Card.outlined(
      shadowColor: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      color: color?.withValues(alpha: 0.5) ?? Colors.white,
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            // Avatar section with gradient background
            Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        controller.getCustomerTypeColor(customer.customerType),
                        controller
                            .getCustomerTypeColor(customer.customerType)
                            .withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: customer.profilePhotoUrl == null ||
                            customer.profilePhotoUrl.isEmpty
                        ? Image.asset(
                            'assets/icons/customer.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            customer.profilePhotoUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),

            // Customer info section with name, phone, and address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  Text(
                    customer.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Customer phone number
                  Text(
                    customer.primaryPhone,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Customer address
                  Text(
                    customer.primaryAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),

            // Right section with total purchase and dues amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total purchase amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF51CF66),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Display total purchase value
                    Text(
                      '₹ ${customer.totalPurchase.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF51CF66),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Dues amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dues:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Display dues value
                    Text(
                      '₹ ${customer.totalDues.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCompactCustomerTypeBadge(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: controller.getCustomerTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: controller.getCustomerTypeColor(type).withValues(alpha: 0.3),
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
}
