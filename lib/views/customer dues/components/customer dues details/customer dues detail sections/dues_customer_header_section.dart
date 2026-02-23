import 'package:flutter/material.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class DuesCustomerHeaderSection extends StatelessWidget {
  final CustomerDueDetailsModel dueDetails;

  const DuesCustomerHeaderSection({Key? key, required this.dueDetails})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: AssetImage(AppImagesString.detailsPagePatternImage,),
        fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          colors: AppColors.primaryGradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Initials
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                   
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(dueDetails.customer.name ?? ""),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Name
                Text(
                  dueDetails.customer.name ?? "Unknown",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Personal Information Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Due ID', '#${dueDetails.duesId}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Customer ID',
                        '${dueDetails.customer.id ?? "N/A"}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Date',
                        _formatDate(dueDetails.creationDateTime),
                      ),
                      if (dueDetails.customer.email != null &&
                          dueDetails.customer.email!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Email ID', dueDetails.customer.email!),
                      ],
                      if (dueDetails.customer.primaryAddress != null &&
                          dueDetails.customer.primaryAddress!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Address',
                          dueDetails.customer.primaryAddress!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _buildStatusBadge()),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color badgeColor;

    if (dueDetails.isOverpaid) {
      badgeColor = const Color(0xFF10B981);
      statusText = 'Overpaid';
    } else if (dueDetails.isFullyPaid) {
      badgeColor = const Color(0xFF10B981);
      statusText = 'Paid';
    } else {
      badgeColor = const Color(0xFFF59E0B);
      statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    List<String> nameParts =
        name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
