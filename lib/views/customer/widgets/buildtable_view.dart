import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_card_view_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/show_network_image.dart';

class BuildtableView extends StatelessWidget {
  final CustomerController controller = Get.find<CustomerController>();

  BuildtableView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DataTable(
            headingRowHeight: 56,
            dataRowHeight: 72,
            columnSpacing: 24,
            horizontalMargin: 20,
            headingRowColor: MaterialStateProperty.all(
              const Color(0xFF6C5CE7).withOpacity(0.05),
            ),
            border: TableBorder.all(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            columns: [
              _buildDataColumn('Customer', 'name', Icons.person),
              // _buildDataColumn('Phone', 'phone', Icons.phone),
              // _buildDataColumn('Location', 'location', Icons.location_on),
              // _buildDataColumn('Type', 'type', Icons.category),
              _buildDataColumn('Purchase', 'purchase', Icons.shopping_cart),
              _buildDataColumn('Dues', 'dues', Icons.account_balance_wallet),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ],
            rows:
                controller.filteredApiCustomers.map((customer) {
                  return DataRow(
                    cells: [
                      // Customer Name with Avatar
                      DataCell(
                        Row(
                          children: [
                            customer.profilePhotoUrl == null ||
                                    customer.profilePhotoUrl.isEmpty
                                ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        controller.getCustomerTypeColor(
                                          customer.customerType,
                                        ),
                                        controller
                                            .getCustomerTypeColor(
                                              customer.customerType,
                                            )
                                            .withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    controller.getCustomerTypeIcon(
                                      customer.customerType,
                                    ),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: cachedImage(
                                    customer.profilePhotoUrl,
                                    width: 40,
                                    height: 40,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'ID: ${customer.id}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      customer.primaryPhone,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        customer.location,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // // Phone
                      // DataCell(
                      //   Row(
                      //     children: [
                      //       Icon(
                      //         Icons.phone,
                      //         size: 16,
                      //         color: Colors.grey[600],
                      //       ),
                      //       const SizedBox(width: 6),
                      //       Text(
                      //         customer.primaryPhone,
                      //         style: const TextStyle(fontSize: 13),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // // Location
                      // DataCell(
                      //   Row(
                      //     children: [
                      //       Icon(
                      //         Icons.location_on,
                      //         size: 16,
                      //         color: Colors.grey[600],
                      //       ),
                      //       const SizedBox(width: 6),
                      //       SizedBox(
                      //         width: 120,
                      //         child: Text(
                      //           customer.location,
                      //           style: const TextStyle(fontSize: 13),
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // // Type Badge
                      // DataCell(
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 10,
                      //       vertical: 6,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: controller
                      //           .getCustomerTypeColor(customer.customerType)
                      //           .withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(
                      //         color: controller
                      //             .getCustomerTypeColor(customer.customerType)
                      //             .withOpacity(0.3),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(
                      //           controller.getCustomerTypeIcon(
                      //             customer.customerType,
                      //           ),
                      //           size: 14,
                      //           color: controller.getCustomerTypeColor(
                      //             customer.customerType,
                      //           ),
                      //         ),
                      //         const SizedBox(width: 6),
                      //         Text(
                      //           customer.customerType,
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w600,
                      //             color: controller.getCustomerTypeColor(
                      //               customer.customerType,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // Purchase
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF51CF66).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            customer.formattedTotalPurchase,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF51CF66),
                            ),
                          ),
                        ),
                      ),

                      // Dues
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                customer.totalDues > 0
                                    ? const Color(0xFFFF6B6B).withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            customer.formattedTotalDues,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color:
                                  customer.totalDues > 0
                                      ? const Color(0xFFFF6B6B)
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),

                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed:
                                  () => controller.callCustomer(
                                    customer.primaryPhone,
                                  ),
                              icon: const Icon(Icons.call, size: 18),
                              color: const Color(0xFF51CF66),
                              tooltip: 'Call',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF51CF66,
                                ).withOpacity(0.1),
                              ),
                            ),
                            // const SizedBox(width: 4),
                            // IconButton(
                            //   onPressed: () => controller.editCustomer(customer),
                            //   icon: const Icon(Icons.edit, size: 18),
                            //   color: const Color(0xFF6C5CE7),
                            //   tooltip: 'Edit',
                            //   style: IconButton.styleFrom(
                            //     backgroundColor:
                            //         const Color(0xFF6C5CE7).withOpacity(0.1),
                            //   ),
                            // ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed:
                                  () => Get.toNamed(
                                    AppRoutes.customerDetails,
                                    arguments: customer.id,
                                  ),
                              icon: const Icon(Icons.visibility, size: 18),
                              color: const Color(0xFF6C5CE7),
                              tooltip: 'View Details',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF6C5CE7,
                                ).withOpacity(0.1),
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
    );
  }

  // Build sortable column header
  DataColumn _buildDataColumn(String label, String columnKey, IconData icon) {
    return DataColumn(
      label: Obx(
        () => InkWell(
          onTap: () => controller.sortCustomers(columnKey),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6C5CE7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(width: 4),
              if (controller.sortColumn.value == columnKey)
                Icon(
                  controller.isAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color: const Color(0xFF6C5CE7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
