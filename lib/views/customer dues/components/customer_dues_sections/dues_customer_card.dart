// FILE: lib/views/customer_dues/sections/dues_customer_card.dart
import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/all_customer_dues_model.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class DuesCustomerCard extends StatelessWidget {
  final CustomerDue customer;
  final CustomerDuesController controller;
  final bool isDuesSection;

  const DuesCustomerCard({
    required this.customer,
    required this.controller,
    required this.isDuesSection,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = customer.remainingDue <= 0 ? Colors.green : Colors.red;
    Color progressColor = customer.paymentProgress >= 50 ? Colors.green : Colors.amber;

    return GestureDetector(
      onTap: () => controller.viewCustomerDetails(customer),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8ECFF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - White Background with Header
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Name + Notify Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          customer.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notify Button
                      if (isDuesSection)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCD34D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            
                               Text(
                                'Retrieval Date: ${customer.formattedRetrievalDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ), 
                        // const SizedBox(width: 8),
                      // // Notify Button
                      // if (isDuesSection)
                      //   GestureDetector(
                      //     onTap: () => controller.notifyCustomer(
                      //       customer.customerId,
                      //       customer.name ?? "",
                      //     ),
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 12,
                      //         vertical: 6,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: const Color(0xFFFCD34D),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           const Icon(
                      //             Icons.notifications,
                      //             color: Color(0xFF78350F),
                      //             size: 14,
                      //           ),
                      //           const SizedBox(width: 4),
                      //           const Text(
                      //             'Notify',
                      //             style: TextStyle(
                      //               fontSize: 12,
                      //               fontWeight: FontWeight.w600,
                      //               color: Color(0xFF78350F),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total Due Amount
                  Text(
                    '₹ Total Due - ${customer.totalDue}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            // Dotted Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDottedLine(),
              ),
            ),

            // Bottom Section - Light Background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two Column Layout
                  Row(
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID
                            _buildSpecRow(
                              icon: Icons.badge_outlined,
                              label: 'ID',
                              value: customer.id.toString(),
                            ),
                            const SizedBox(height: 10),
                            // Paid Amount
                            _buildSpecRow(
                              icon: Icons.check_circle_outlined,
                              label: 'Paid',
                              value: '₹${customer.totalPaid}',
                              valueColor: Colors.green,
                            ),
                          ],
                        ),
                      ),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status
                            _buildSpecRow(
                              icon: Icons.info_outlined,
                              label: 'Status',
                              value: customer.statusText,
                              valueColor: statusColor,
                            ),
                            const SizedBox(height: 10),
                            // Remaining Due
                            _buildSpecRow(
                              icon: Icons.money_off_outlined,
                              label: 'Remaining',
                              value: '₹${customer.remainingDue}',
                              valueColor: statusColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar Section (only for dues)
                  if (isDuesSection && customer.totalDue > 0) ...[
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: customer.paymentProgress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Payment Progress Text
                    Text(
                      '${customer.paymentProgress.toStringAsFixed(0)}% Paid',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],


                  // // View Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 40,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () => controller.viewCustomerDetails(customer),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF3B82F6),
                  //       foregroundColor: Colors.white,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //     ),
                  //     icon: const Icon(
                  //       Icons.visibility_outlined,
                  //       size: 18,
                  //     ),
                  //     label: const Text(
                  //       'View Details',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label- ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

