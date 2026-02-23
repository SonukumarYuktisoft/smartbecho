import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/user_subscription_model.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  final String userId;

  const SubscriptionHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  final SubscriptionController _controller = Get.put(SubscriptionController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.getSubscriptionHistory(userId: widget.userId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      if (_controller.hasMoreHistory.value && !_controller.historyLoading.value) {
        _controller.loadMoreHistory(widget.userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.getSubscriptionHistory(userId: widget.userId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.historyLoading.value && _controller.historyList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.historyList.isEmpty) {
          return _buildEmptyState();
        }

        return AppRefreshIndicator(
          onRefresh: () async {
            await _controller.getSubscriptionHistory(userId: widget.userId);
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _controller.historyList.length + 1,
            itemBuilder: (context, index) {
              if (index == _controller.historyList.length) {
                return _controller.hasMoreHistory.value
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final subscription = _controller.historyList[index];
              return _buildHistoryCard(subscription);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Subscription History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your subscription history will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(UserSubscription subscription) {
    final isActive = subscription.active ?? false;
    final startDate = _parseDate(subscription.startDate);
    final endDate = _parseDate(subscription.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subscription.planNameSnapshot ?? 'Unknown Plan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expired',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Period & Plan Code
            Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  subscription.period ?? 'N/A',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.code,
                  subscription.planCode ?? 'N/A',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dates
            _buildDateRow(
              'Subscribed',
              _formatDate(subscription.subscribedAt),
              Icons.event_available,
            ),
            const SizedBox(height: 6),
            _buildDateRow(
              'Duration',
              '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
              Icons.date_range,
            ),

            // Price & Transaction
            if (subscription.pricePaid != null) ...[
              const SizedBox(height: 6),
              _buildDateRow(
                'Price Paid',
                '₹${subscription.pricePaid!.toStringAsFixed(2)}',
                Icons.payment,
              ),
            ],

            if (subscription.paymentTxnId != null) ...[
              const SizedBox(height: 6),
              _buildDateRow(
                'Transaction',
                subscription.paymentTxnId!,
                Icons.receipt_long,
              ),
            ],

            // Shop ID
            if (subscription.shopId != null) ...[
              const SizedBox(height: 6),
              _buildDateRow(
                'Shop ID',
                subscription.shopId.toString(),
                Icons.store,
              ),
            ],

            // Duration Indicator
            if (startDate != null && endDate != null) ...[
              const SizedBox(height: 12),
              _buildDurationIndicator(startDate, endDate, isActive),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationIndicator(DateTime startDate, DateTime endDate, bool isActive) {
    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsed = now.difference(startDate).inDays;
    final progress = (elapsed / totalDuration).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primaryLight : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isActive ? AppColors.primaryLight : Colors.grey,
            ),
            minHeight: 6,
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