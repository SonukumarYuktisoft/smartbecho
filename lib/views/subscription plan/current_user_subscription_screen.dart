import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common%20plan%20badge/common_plan_badge.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/user_subscription_model.dart';
import 'package:smartbecho/views/subscription%20plan/payment_history_screen.dart';
import 'package:smartbecho/views/subscription%20plan/subscription_history_screen.dart';
import 'package:smartbecho/views/subscription%20plan/subscription_plan_screen.dart';

class CurrentUserSubscriptionScreen extends StatelessWidget {
  final String userId;

  const CurrentUserSubscriptionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    // Fetch current subscription on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCurrentSubscription();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Subscription',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => SubscriptionHistoryScreen(userId: userId));
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.currentSubscriptionLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentSubscriptions.isEmpty) {
          return _buildNoSubscription(context);
        }

        final subscription = controller.currentSubscriptions.first;
        return _buildSubscriptionDetails(context, subscription, controller);
      }),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership_outlined,
                size: 80,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Active Subscription',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Subscribe to unlock premium features\nand grow your business',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const SubscriptionPlanScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails(
    BuildContext context,
    UserSubscription subscription,
    SubscriptionController controller,
  ) {
    final startDate = _parseDate(subscription.startDate);
    final endDate = _parseDate(subscription.endDate);
    final daysRemaining =
        endDate != null ? endDate.difference(DateTime.now()).inDays : 0;
    final isActive = subscription.active ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isActive
                        ? [
                          AppColors.primaryLight,
                          AppColors.primaryLight.withOpacity(0.8),
                        ]
                        : [Colors.grey.shade600, Colors.grey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? AppColors.primaryLight : Colors.grey)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: Colors.black87,
                        highlightColor: Colors.white.withValues(alpha: 0.8),
                        child: Text(
                          subscription.planNameSnapshot ?? 'Unknown Plan',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subscription.period ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    CommonPlanBadge(
                      planName: subscription.planNameSnapshot ?? 'N/A',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(isActive),

          const SizedBox(height: 24),

          // Days Remaining (if active)
          if (isActive && daysRemaining > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$daysRemaining Days Remaining',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Renews on ${_formatDate(subscription.endDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (isActive && daysRemaining > 0) const SizedBox(height: 16),

          // Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.code,
                  'Plan Code',
                  subscription.planCode ?? 'N/A',
                ),
                const Divider(height: 28),
                _buildDetailRow(
                  Icons.event_available,
                  'Subscribed On',
                  _formatDate(subscription.subscribedAt),
                ),
                const Divider(height: 28),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Start Date',
                  _formatDate(subscription.startDate),
                ),
                const Divider(height: 28),
                _buildDetailRow(
                  Icons.event,
                  'End Date',
                  _formatDate(subscription.endDate),
                ),
                if (subscription.pricePaid != null) ...[
                  const Divider(height: 28),
                  _buildDetailRow(
                    Icons.payments,
                    'Price Paid',
                    '₹${subscription.pricePaid!.toStringAsFixed(2)}',
                    valueColor: AppColors.primaryLight,
                  ),
                ],
                if (subscription.paymentTxnId != null) ...[
                  const Divider(height: 28),
                  _buildDetailRow(
                    Icons.receipt_long,
                    'Transaction ID',
                    subscription.paymentTxnId!,
                  ),
                ],
                if (subscription.shopId != null) ...[
                  const Divider(height: 28),
                  _buildDetailRow(
                    Icons.store,
                    'Shop ID',
                    subscription.shopId.toString(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          
       
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isActive) {
    return Column(
          children: [
            if (isActive) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const SubscriptionPlanScreen());
                  },
                  icon: const Icon(Icons.upgrade, color: Colors.white),
                  label: const Text(
                    'Upgrade Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const SubscriptionPlanScreen());
                  },
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => SubscriptionHistoryScreen(userId: userId),
                        );
                      },
                      icon: Icon(
                        Icons.history,
                        color: AppColors.primaryLight,
                      ),
                      label: Text(
                        'View History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => PaymentHistoryScreen());
                      },
                      icon: Icon(
                        Icons.history,
                        color: AppColors.primaryLight,
                      ),
                      label: Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryLight.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
