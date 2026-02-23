import 'package:flutter/material.dart';
import 'package:smartbecho/models/account%20management%20models/view%20history/transactionList_model.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/utils/helper/string_formatter.dart';

class ViewHistoryCard extends StatelessWidget {
  final Transaction data;

  const ViewHistoryCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCredit =
        data.transactionType.toLowerCase().contains('credit') ||
        data.transactionType.toLowerCase().contains('deposit');
    final Color amountColor =
        isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final IconData transactionIcon =
        isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      color: Colors.white,

      child: Container(
        // margin: const EdgeInsets.only(bottom: 12),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   border: Border.all(
        //     color: amountColor.withOpacity(0.1),
        //     width: 1,
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.04),
        //       blurRadius: 12,
        //       offset: const Offset(0, 2),
        //       spreadRadius: 1,
        //     ),
        //   ],
        // ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle tap - show transaction details
              _showTransactionDetails(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Icon
                  // Container(
                  //   // width: 48,
                  //   // height: 48,
                  //   padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: amountColor.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(12),

                  //     border: Border.all(
                  //       color: amountColor.withOpacity(0.2),

                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       // Icon(transactionIcon, color: amountColor, size: 22),
                  //       // const SizedBox(height: 4),
                  //       Text(
                  //         data.transactionType,
                  //         style: TextStyle(
                  //           fontSize: 11,
                  //           fontWeight: FontWeight.w600,
                  //           color: amountColor,
                  //           letterSpacing: 0.2,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(width: 14),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${isCredit ? '+' : '-'} ₹${data.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: amountColor,
                                letterSpacing: -0.3,
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: amountColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),

                                border: Border.all(
                                  color: amountColor.withOpacity(0.2),

                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                data.transactionType,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: amountColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Entity Name
                        Text(
                          // data.entityName,
                          StringFormatter.smart(data.entityName),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Transaction Type Badge
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 10,
                        //     vertical: 4,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: amountColor.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(6),
                        //     border: Border.all(
                        //       color: amountColor.withOpacity(0.2),
                        //       width: 0.5,
                        //     ),
                        //   ),
                        //   child: Text(
                        //     data.transactionType,
                        //     style: TextStyle(
                        //       fontSize: 11,
                        //       fontWeight: FontWeight.w600,
                        //       color: amountColor,
                        //       letterSpacing: 0.2,
                        //     ),
                        //   ),
                        // ),

                        // Payment Method & Date Row
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Payment Method
                                  Icon(
                                    Icons.payment_rounded,
                                    size: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      StringFormatter.toTitle(
                                        data.paymentAccountType,
                                      ),

                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Date
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    DateFormatterHelper.format(data.date),

                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // const SizedBox(width: 12),

                  // // Amount Section
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       '${isCredit ? '+' : '-'} ₹${data.amount.toStringAsFixed(2)}',
                  //       style: TextStyle(
                  //         fontSize: 17,
                  //         fontWeight: FontWeight.w700,
                  //         color: amountColor,
                  //         letterSpacing: -0.3,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 4),
                  //     Container(
                  //       padding: const EdgeInsets.all(4),
                  //       decoration: BoxDecoration(
                  //         color: const Color(0xFF3B82F6).withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       child: Icon(
                  //         Icons.chevron_right,
                  //         size: 16,
                  //         color: const Color(0xFF3B82F6),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(context),
    );
  }

  Widget _buildTransactionDetailsSheet(BuildContext context) {
    final bool isCredit =
        data.transactionType.toLowerCase().contains('credit') ||
        data.transactionType.toLowerCase().contains('deposit');
    final Color amountColor =
        isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: amountColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: amountColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: amountColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            isCredit
                                ? 'Credit Transaction'
                                : 'Debit Transaction',
                            style: TextStyle(
                              fontSize: 13,
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Amount Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        amountColor.withOpacity(0.1),
                        amountColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: amountColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCredit ? 'Amount Received' : 'Amount Paid',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: amountColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${data.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Details Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Entity Name',
                        StringFormatter.smart(data.entityName),
                        Icons.business,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Transaction Type',
                        data.transactionType,
                        Icons.sync_alt,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Payment Method',
                        // data.paymentAccountType,
                        StringFormatter.smart(data.paymentAccountType),
                        Icons.payment,
                      ),
                      const Divider(height: 24),

                      _buildDetailRow(
                        'Date',
                        DateFormatterHelper.format(data.date),
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: () {
                //           // Share functionality
                //           Navigator.pop(context);
                //         },
                //         icon: const Icon(Icons.share, size: 18),
                //         label: const Text('Share'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFF6B7280),
                //           foregroundColor: Colors.white,
                //           padding: const EdgeInsets.symmetric(vertical: 14),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           elevation: 0,
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: () {
                //           // Download receipt
                //           Navigator.pop(context);
                //         },
                //         icon: const Icon(Icons.download, size: 18),
                //         label: const Text('Receipt'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFF3B82F6),
                //           foregroundColor: Colors.white,
                //           padding: const EdgeInsets.symmetric(vertical: 14),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           elevation: 0,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 18),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
