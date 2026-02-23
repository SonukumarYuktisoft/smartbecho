import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/emi_settlement_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/views/account%20management/components/emi%20settlement/widgets/CompanyFilterDropdown.dart';

class EmiSettlementAnalyticsBottomSheet extends StatefulWidget {
  const EmiSettlementAnalyticsBottomSheet({Key? key}) : super(key: key);

  @override
  State<EmiSettlementAnalyticsBottomSheet> createState() =>
      _EmiSettlementAnalyticsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmiSettlementAnalyticsBottomSheet(),
    );
  }
}

class _EmiSettlementAnalyticsBottomSheetState
    extends State<EmiSettlementAnalyticsBottomSheet> {
  final EmiSettlementController controller =
      Get.find<EmiSettlementController>();

  @override
  void initState() {
    super.initState();
    // Fetch fresh data when opening modal
    controller.chartYear.value = DateTime.now().year;
    controller.loadChartData();
    controller.loadCompanyDropdownData();
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

          // Year selector, Company filter and Refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Company Dropdown
                Expanded(child: CompanyFilterDropdown(controller: controller)),
                const SizedBox(width: 8),

                Obx(
                  () => Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Year',
                      hintText: 'Select Year',
                      value: controller.chartYear.value.toString(),
                      items: List.generate(
                        5,
                        (index) => (DateTime.now().year - index).toString(),
                      ),
                      onChanged: (newYear) {
                        if (newYear != null) {
                          controller.onChartYearChanged(int.parse(newYear));
                        }
                      },
                      borderRadius: 8,
                      suffixIcon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Obx(() {
                  return controller.activeCharFilters()
                      ? IconButton(
                        onPressed:
                            controller.isChartLoading.value
                                ? null
                                : () => controller.clearCharFilters(),
                        icon: const Icon(
                          Icons.filter_alt_off,
                          color: AppColors.primarySwatch,
                        ),
                        tooltip: 'Clear Filters',
                        splashRadius: 15,
                      )
                      : IconButton(
                        onPressed:
                            controller.isChartLoading.value
                                ? null
                                : () {
                                  controller.clearCharFilters();
                                },
                        icon:
                            controller.isChartLoading.value
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
                        tooltip: 'Refresh',
                        splashRadius: 15,
                      );
                }),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              // Show loading in content area only
              if (controller.isChartLoading.value &&
                  controller.chartData.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!controller.hasChartData) {
                return _buildEmptyState();
              }

              return FeatureVisitor(
                featureKey: FeatureKeys.EMI.getEmiSettlementsMonthlySummary,

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards with donut chart
                      _buildSummaryWithDonutChart(context),

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
            'EMI Settlement Analytics',
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
      builder:
          (context) => Container(
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
                          controller.chartYear.value == year
                              ? const Icon(
                                Icons.check,
                                color: AppColors.primaryLight,
                              )
                              : const SizedBox.shrink(),
                      onTap: () {
                        controller.onChartYearChanged(year);
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
      double totalSettlements = 0;
      Map<String, double> companyBreakdown = {};

      // Calculate totals from chart data
      for (var data in controller.chartData) {
        totalSettlements += data.amount;
      }

      // Get company breakdown from settlements if available
      if (controller.settlements.isNotEmpty) {
        final year = controller.chartYear.value;

        for (var settlement in controller.settlements) {
          try {
            // Parse date string to DateTime
            final settlementDate = DateTime.parse(settlement.date);
            if (settlementDate.year == year) {
              companyBreakdown[settlement.companyName] =
                  (companyBreakdown[settlement.companyName] ?? 0) +
                  settlement.amount;
            }
          } catch (e) {
            // Skip if date parsing fails
            continue;
          }
        }
      }

      // Get top 2 companies
      final sortedCompanies =
          companyBreakdown.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final topCompany1 =
          sortedCompanies.isNotEmpty ? sortedCompanies[0] : null;
      final topCompany2 =
          sortedCompanies.length > 1 ? sortedCompanies[1] : null;

      final company1Amount = topCompany1?.value ?? 0.0;
      final company2Amount = topCompany2?.value ?? 0.0;

      final company1Percent =
          totalSettlements > 0
              ? (company1Amount / totalSettlements * 100)
              : 0.0;
      final company2Percent =
          totalSettlements > 0
              ? (company2Amount / totalSettlements * 100)
              : 0.0;

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
                        company1Amount,
                        company2Amount,
                        totalSettlements,
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
                        '₹${_formatAmount(totalSettlements)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Settlement',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                    '₹${_formatAmount(company1Amount)}',
                    '${company1Percent.toStringAsFixed(1)}% ${topCompany1?.key ?? "N/A"}',
                    AppColors.primaryLight,
                    Icons.business,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildSummaryItem(
                    '₹${_formatAmount(company2Amount)}',
                    '${company2Percent.toStringAsFixed(1)}% ${topCompany2?.key ?? "Others"}',
                    const Color(0xFFFF9800),
                    Icons.business_center,
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
    double company1,
    double company2,
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

    final company1Percent = (company1 / total * 100);
    final company2Percent = (company2 / total * 100);

    return [
      // Company 1 section
      PieChartSectionData(
        color: AppColors.primaryLight,
        value: company1,
        title: '${company1Percent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: 0.98,
      ),
      // Company 2 section
      PieChartSectionData(
        color: const Color(0xFFFF9800),
        value: company2,
        title: '${company2Percent.toStringAsFixed(0)}%',
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
        'December',
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

          return _buildMonthlyCard(months[index], amount, color);
        },
      );
    });
  }

  Widget _buildMonthlyCard(String monthName, double amount, Color color) {
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
                'Total Settlement',
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
              'Add some EMI settlements to see analytics and trends.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Map<int, double> _getMonthlyBreakdown() {
    final year = controller.chartYear.value;
    final monthlyData = <int, double>{};

    // Initialize all months
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = 0.0;
    }

    // Use chart data for monthly breakdown
    for (var data in controller.chartData) {
      final monthIndex = _getMonthIndex(data.month);
      if (monthIndex > 0) {
        monthlyData[monthIndex] = data.amount;
      }
    }

    return monthlyData;
  }

  int _getMonthIndex(String monthName) {
    final months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    return months.indexOf(monthName.toLowerCase()) + 1;
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
