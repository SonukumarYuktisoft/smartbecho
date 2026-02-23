import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/pay_bill_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/charts/fl_charts.dart';

class PayBillAnalyticsBottomSheet extends StatefulWidget {
  const PayBillAnalyticsBottomSheet({Key? key}) : super(key: key);

  @override
  State<PayBillAnalyticsBottomSheet> createState() =>
      _PayBillAnalyticsBottomSheetState();

  // Static method to show the bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PayBillAnalyticsBottomSheet(),
    );
  }
}

class _PayBillAnalyticsBottomSheetState
    extends State<PayBillAnalyticsBottomSheet> {
  final PayBillsController controller = Get.find<PayBillsController>();

  final RxBool isFiltersVisible = true.obs;

  @override
  void initState() {
    super.initState();
    // Just process existing data, don't reload
    controller.processAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primaryLight,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pay Bills Analytics',
                    style: AppStyles.custom(
                      color: const Color(0xFF1A1A1A),
                      size: 22,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.payBills.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryLight),
                      const SizedBox(height: 16),
                      Text(
                        'Loading analytics data...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (controller.payBills.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View Toggle Buttons
                    _buildViewToggle(),
                    const SizedBox(height: 20),

                    // Chart based on current view
                    Obx(() {
                      if (controller.analyticsCurrentView.value == 'Monthly') {
                        return _buildMonthlyChart(screenWidth, isSmallScreen);
                      } else if (controller.analyticsCurrentView.value ==
                          'Trends') {
                        return _buildTrendsChart(screenWidth, isSmallScreen);
                      } else {
                        return _buildCompanyChart(screenWidth, isSmallScreen);
                      }
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton('Monthly'),
          _buildToggleButton('Trends'),
          _buildToggleButton('By Company'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.analyticsCurrentView.value == label;
        return GestureDetector(
          onTap: () => controller.setAnalyticsView(label),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthlyChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        Row(
          children: [
            Icon(Icons.filter_list, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text(
              'Filters',
              style: AppStyles.custom(
                color: const Color(0xFF1A1A1A),
                size: 16,
                weight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Obx(
              () => IconButton(
                icon: Icon(
                  isFiltersVisible.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryLight,
                ),
                onPressed: () => isFiltersVisible.toggle(),
              ),
            ),
          ],
        ),

        // Filters
        Obx(
          () =>
              isFiltersVisible.value
                  ? Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => _buildFilterDropdown(
                              label: 'Distributer',
                              value: controller.analyticsSelectedCompany.value,
                              items: controller.analyticsAvailableCompanies,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setAnalyticsCompany(value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => _buildFilterDropdown(
                              label: 'Year',
                              value: controller.analyticsMonthlyYear.value,
                              items: controller.analyticsAvailableYears,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setAnalyticsMonthlyYear(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),

        // Chart - Using FL Chart
        GetBuilder<PayBillsController>(
          builder: (ctrl) {
            final chartData = Map<String, double>.from(ctrl.monthlyChartData);
            return ReusableBarChart(
              title: 'Monthly Pay Bills Chart',
              data: chartData,
              barColor: AppColors.primaryLight,
              chartHeight: 300,
              valuePrefix: '₹',
              showGrid: true,
              showValues: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendsChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        Row(
          children: [
            Icon(Icons.filter_list, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text(
              'Filters',
              style: AppStyles.custom(
                color: const Color(0xFF1A1A1A),
                size: 16,
                weight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Obx(
              () => IconButton(
                icon: Icon(
                  isFiltersVisible.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryLight,
                ),
                onPressed: () => isFiltersVisible.toggle(),
              ),
            ),
          ],
        ),

        // Filters
        Obx(
          () =>
              isFiltersVisible.value
                  ? Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => _buildFilterDropdown(
                              label: 'Company',
                              value: controller.analyticsSelectedCompany.value,
                              items: controller.analyticsAvailableCompanies,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setAnalyticsCompany(value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => _buildFilterDropdown(
                              label: 'Year',
                              value: controller.analyticsMonthlyYear.value,
                              items: controller.analyticsAvailableYears,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setAnalyticsMonthlyYear(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),

        // Line Chart - Using FL Chart
        GetBuilder<PayBillsController>(
          builder: (ctrl) {
            final chartData = Map<String, double>.from(ctrl.monthlyChartData);
            return ReusableLineChart(
              title: 'Monthly Trends',
              data: chartData,
              lineColor: AppColors.primaryLight,
              chartHeight: 300,
              valuePrefix: '₹',
              showGrid: true,
              showDots: true,
              showArea: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompanyChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        Row(
          children: [
            Icon(Icons.filter_list, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text(
              'Filters',
              style: AppStyles.custom(
                color: const Color(0xFF1A1A1A),
                size: 16,
                weight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Obx(
              () => IconButton(
                icon: Icon(
                  isFiltersVisible.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryLight,
                ),
                onPressed: () => isFiltersVisible.toggle(),
              ),
            ),
          ],
        ),

        // Filters
        Obx(
          () =>
              isFiltersVisible.value
                  ? Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => _buildFilterDropdown(
                              label: 'Year',
                              value: controller.analyticsCompanyYear.value,
                              items: controller.analyticsAvailableYears,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setAnalyticsCompanyYear(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),

        // Chart - Using FL Chart
        GetBuilder<PayBillsController>(
          builder: (ctrl) {
            final chartData = Map<String, double>.from(ctrl.companyChartData);
            return ReusableBarChart(
              title: 'Company-wise Pay Bills Chart',
              data: chartData,
              barColor: const Color(0xFF10B981),
              chartHeight: 300,
              valuePrefix: '₹',
              showGrid: true,
              showValues: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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
              child: Icon(
                Icons.analytics_outlined,
                size: 50,
                color: AppColors.primaryLight,
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
              'Add some payment bills to see analytics and trends.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
