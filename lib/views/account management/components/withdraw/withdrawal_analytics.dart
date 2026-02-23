import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/withdraw_history_controller.dart';
import 'package:smartbecho/models/account%20management%20models/withdraw_history_model.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';

class WithdrawalAnalyticsBottomSheet extends StatefulWidget {
  const WithdrawalAnalyticsBottomSheet({Key? key}) : super(key: key);

  @override
  State<WithdrawalAnalyticsBottomSheet> createState() =>
      _WithdrawalAnalyticsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawalAnalyticsBottomSheet(),
    );
  }
}

class _WithdrawalAnalyticsBottomSheetState
    extends State<WithdrawalAnalyticsBottomSheet> {
  final WithdrawController controller = Get.find<WithdrawController>();

  @override
  void initState() {
    super.initState();
    // Fetch fresh data when opening modal - clear cache
    controller.selectedWithdrawalMonth.value = DateTime.now().month;
    controller.selectedWithdrawalYear.value = DateTime.now().year;
    controller.loadMonthlyWithdrawalChart();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context),

          // Year selector and Refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => GestureDetector(
                    onTap: () => _showYearPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySwatch,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.selectedWithdrawalYear.value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.backgroundLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Refresh button
                Obx(
                  () => IconButton(
                    onPressed:
                        controller.isWithdrawalLoading.value
                            ? null
                            : () {
                              // Clear cache and reload
                              controller.withdrawalChartData.clear();
                              controller.loadMonthlyWithdrawalChart();
                            },
                    icon:
                        controller.isWithdrawalLoading.value
                            ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryLight,
                                ),
                              ),
                            )
                            : const Icon(
                              Icons.refresh,
                              color: AppColors.primarySwatch,
                            ),
                    splashRadius: 15,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isWithdrawalLoading.value &&
                  controller.withdrawals.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading analytics...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (controller.withdrawals.isEmpty) {
                return _buildEmptyState();
              }

              return FeatureVisitor(
                featureKey: FeatureKeys.WITHDRAWAL.getWithdrawalsMonthlySummary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards with donut chart
                      _buildSummaryWithDonutChart(context),
                
                      const SizedBox(height: 24),
                
                      // Month pills
                      _buildMonthPills(),
                
                      const SizedBox(height: 20),
                
                      // Monthly cards grid
                      _buildMonthlyCardsGrid(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Withdrawal Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Year',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...years.map(
              (year) => Obx(
                () => ListTile(
                  title: Text(
                    year.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing:
                      controller.selectedWithdrawalYear.value == year
                          ? const Icon(
                            Icons.check,
                            color: AppColors.primaryLight,
                          )
                          : const SizedBox.shrink(),
                  onTap: () {
                    controller.onWithdrawalYearChanged(year);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryWithDonutChart(BuildContext context) {
    return Obx(() {
      final List<Map<String, dynamic>> filteredData =
          _getFilteredMonthlyData();

      double totalWithdrawals = 0;
      double totalByAdmin = 0;
      double totalByUser = 0;

      for (var data in filteredData) {
        final amount = (data['amount'] as num).toDouble();
        totalWithdrawals += amount;
        
        final withdrawnBy = (data['withdrawnBy'] as String).toLowerCase();
        // Count admin vs user withdrawals
        if (withdrawnBy.contains('admin') ||
            withdrawnBy.contains('owner') ||
            withdrawnBy.contains('manager')) {
          totalByAdmin += amount;
        } else {
          totalByUser += amount;
        }
      }

      final adminPercent =
          totalWithdrawals > 0
              ? (totalByAdmin / totalWithdrawals * 100)
              : 0.0;
      final userPercent =
          totalWithdrawals > 0 ? (totalByUser / totalWithdrawals * 100) : 0.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Donut chart with center text
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: _getPieChartSections(
                        totalByAdmin,
                        totalByUser,
                        totalWithdrawals,
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                  // Center text showing total
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${_formatAmount(totalWithdrawals)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Withdrawn',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary items in row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '₹${_formatAmount(totalByAdmin)}',
                    '${adminPercent.toStringAsFixed(1)}% Admin',
                    AppColors.primaryLight,
                    Icons.person,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildSummaryItem(
                    '₹${_formatAmount(totalByUser)}',
                    '${userPercent.toStringAsFixed(1)}% Others',
                    const Color(0xFFFF9800),
                    Icons.account_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  List<PieChartSectionData> _getPieChartSections(
    double admin,
    double user,
    double total,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.2),
          value: 1,
          title: '0%',
          radius: 35,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ];
    }

    final adminPercent = (admin / total * 100);
    final userPercent = (user / total * 100);

    return [
      // Admin section
      PieChartSectionData(
        color: AppColors.primaryLight,
        value: admin,
        title: '${adminPercent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: 0.98,
      ),
      // User section
      PieChartSectionData(
        color: const Color(0xFFFF9800),
        value: user,
        title: '${userPercent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: 0.98,
      ),
    ];
  }

  Widget _buildSummaryItem(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMonthPills() {
    final months = [
      {'name': 'All', 'value': null},
      {'name': 'Jan', 'value': 1},
      {'name': 'Feb', 'value': 2},
      {'name': 'Mar', 'value': 3},
      {'name': 'Apr', 'value': 4},
      {'name': 'May', 'value': 5},
      {'name': 'Jun', 'value': 6},
      {'name': 'Jul', 'value': 7},
      {'name': 'Aug', 'value': 8},
      {'name': 'Sep', 'value': 9},
      {'name': 'Oct', 'value': 10},
      {'name': 'Nov', 'value': 11},
      {'name': 'Dec', 'value': 12},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];

          return Obx(() {
            final isSelected =
                controller.selectedWithdrawalMonth.value == month['value'];

            return GestureDetector(
              onTap: () {
                if (month['value'] == null) {
                  controller.selectedWithdrawalMonth.value = DateTime.now().month;
                } else {
                  controller.selectedWithdrawalMonth.value =
                      month['value'] as int;
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primaryLight : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    month['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildMonthlyCardsGrid() {
    return Obx(() {
      final monthlyData = _getMonthlyBreakdown();

      if (monthlyData.isEmpty) {
        return _buildEmptyState();
      }

      final monthColors = [
        const Color(0xFF00BCD4), // January
        const Color(0xFF9C27B0), // February
        const Color(0xFF7C4DFF), // March
        const Color(0xFFFF7043), // April
        AppColors.primaryLight, // May
        const Color(0xFF2196F3), // June
        const Color(0xFFEF5350), // July
        const Color(0xFFFF9800), // August
        const Color(0xFF00BCD4), // September
        const Color(0xFF2196F3), // October
        AppColors.primaryLight, // November
        const Color(0xFF00BCD4), // December
      ];

      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthNum = index + 1;
          final amount = monthlyData[monthNum] ?? 0.0;
          final color = monthColors[index];

          return _buildMonthlyCard(
            months[index],
            amount,
            color,
          );
        },
      );
    });
  }

  Widget _buildMonthlyCard(
    String monthName,
    double amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Withdrawn',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${_formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 50,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Data Available',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some withdrawals to see analytics and trends.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getFilteredMonthlyData() {
    final year = controller.selectedWithdrawalYear.value;
    final selectedMonth = controller.selectedWithdrawalMonth.value;

    return controller.withdrawals
        .where((withdrawal) {
          try {
            final date = withdrawal.date;
            final isYearMatch = date.year == year;
            final isMonthMatch =
                selectedMonth == DateTime.now().month || date.month == selectedMonth;

            return isYearMatch && isMonthMatch;
          } catch (e) {
            return false;
          }
        })
        .map((withdrawal) {
          return {
            'amount': withdrawal.amount,
            'month': withdrawal.date.month,
            'withdrawnBy': withdrawal.withdrawnBy,
          };
        })
        .toList();
  }

  Map<int, double> _getMonthlyBreakdown() {
    final year = controller.selectedWithdrawalYear.value;
    final monthlyData = <int, double>{};

    // Initialize all months
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = 0.0;
    }

    // Filter and aggregate
    for (var withdrawal in controller.withdrawals) {
      try {
        final date = withdrawal.date;
        if (date.year == year) {
          monthlyData[date.month] =
              (monthlyData[date.month] ?? 0) + withdrawal.amount;
        }
      } catch (e) {
        continue;
      }
    }

    return monthlyData;
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toStringAsFixed(0);
  }
}