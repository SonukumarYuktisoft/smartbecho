import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:smartbecho/utils/charts/chart_widgets.dart';
import 'package:smartbecho/utils/common_month_year_dropdown.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/customer/widgets/customer_screen_shimmers.dart';
import 'package:smartbecho/views/dashboard/widgets/dashboard_shimmers.dart';
import 'package:smartbecho/views/dashboard/widgets/error_cards.dart';

class CustomerAnalytics extends StatefulWidget {
  const CustomerAnalytics({super.key});

  @override
  State<CustomerAnalytics> createState() => _CustomerAnalyticsState();
}

class _CustomerAnalyticsState extends State<CustomerAnalytics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ NEW CUSTOMERS FILTER (separate)
  int? _newCustomerMonth;
  int? _newCustomerYear;

  // ✅ REPEAT CUSTOMERS FILTER (separate)
  int? _repeatCustomerMonth;
  int? _repeatCustomerYear;

  // Filter variables for Tab 2 (Village Distribution)
  int? _villageDistributionMonth;
  int? _villageDistributionYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final currentYear = DateTime.now().year;
    _newCustomerYear = currentYear;
    _repeatCustomerYear = currentYear;
    _villageDistributionYear = currentYear;

    _fetchInitialData();
  }

  void _fetchInitialData() {
    customerAnalyticsController.fetchMonthlyNewCustomerChart(
      year: _newCustomerYear,
      month: _newCustomerMonth,
    );
    customerAnalyticsController.fetchMonthlyRepeatCustomerChart(
      year: _repeatCustomerYear,
      month: _repeatCustomerMonth,
    );
    customerAnalyticsController.fetchVillageDistributionChart(
      year: _villageDistributionYear,
      month: _villageDistributionMonth,
    );
    customerAnalyticsController.fetchTopCustomerChart();
  }

  bool get isNewCustomerFilterActive =>
      _newCustomerMonth != null || _newCustomerYear != DateTime.now().year;

  bool get isRepeatCustomerFilterActive =>
      _repeatCustomerMonth != null || _repeatCustomerYear != DateTime.now().year;

  bool get isVillageFilterActive =>
      _villageDistributionMonth != null ||
      _villageDistributionYear != DateTime.now().year;

  void _clearNewCustomerFilters() {
    setState(() {
      _newCustomerMonth = null;
      _newCustomerYear = DateTime.now().year;
    });
    customerAnalyticsController.fetchMonthlyNewCustomerChart(
      year: _newCustomerYear,
      month: null,
    );
  }

  void _clearRepeatCustomerFilters() {
    setState(() {
      _repeatCustomerMonth = null;
      _repeatCustomerYear = DateTime.now().year;
    });
    customerAnalyticsController.fetchMonthlyRepeatCustomerChart(
      year: _repeatCustomerYear,
      month: null,
    );
  }

  void _clearVillageFilters() {
    setState(() {
      _villageDistributionMonth = null;
      _villageDistributionYear = DateTime.now().year;
    });
    customerAnalyticsController.fetchVillageDistributionChart(
      year: _villageDistributionYear,
      month: null,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final customerAnalyticsController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customer Analytics"),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNewCustomersTab(),
                  _buildVillageDistributionTab(),
                  _buildTopCustomersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradientLight,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            _buildTab('Customer', Icons.person_add_outlined),
            _buildTab('Village', Icons.location_on_outlined),
            _buildTab('Top', Icons.star_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, IconData icon) {
    return Tab(
      height: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(text, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 1: NEW CUSTOMERS & REPEAT CUSTOMERS
  // ============================================================
  Widget _buildNewCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ FILTER 1: NEW CUSTOMERS
          _buildFilterSection(
            title: 'New Customers Filter',
            showClear: isNewCustomerFilterActive,
            onClear: _clearNewCustomerFilters,
            selectedMonth: _newCustomerMonth,
            selectedYear: _newCustomerYear,
            onMonthChanged: (month) {
              setState(() {
                _newCustomerMonth = month;
              });
              customerAnalyticsController.fetchMonthlyNewCustomerChart(
                year: _newCustomerYear,
                month: _newCustomerMonth,
              );
            },
            onYearChanged: (year) {
              setState(() {
                _newCustomerYear = year;
              });
              customerAnalyticsController.fetchMonthlyNewCustomerChart(
                year: _newCustomerYear,
                month: _newCustomerMonth,
              );
            },
          ),
          const SizedBox(height: 16),

          // ✅ CHART 1: NEW CUSTOMERS (COLUMN)
          Obx(
            () => customerAnalyticsController.isMonthlyNewCustomerChartLoading.value
                ? _buildLoadingChart('Loading New Customers Chart...')
                : customerAnalyticsController.hasMonthlyNewCustomerChartError.value
                    ? buildErrorCard(
                        customerAnalyticsController.monthlyNewCustomerCharterrorMessage,
                        Get.width,
                        300,
                        true,
                      )
                    : AutoChart(
                        apiResponse: customerAnalyticsController.monthlyNewCustomerPayload,
                        title: 'New Customers',
                        chartType: ChartType.column,
                        subtitle:
                            'Year ${_newCustomerYear ?? DateTime.now().year}${_newCustomerMonth != null ? ' - Month ${_newCustomerMonth}' : ''}',
                      ),
          ),
          const SizedBox(height: 24),

          // ✅ FILTER 2: REPEAT CUSTOMERS
          _buildFilterSection(
            title: 'Repeat Customers Filter',
            showClear: isRepeatCustomerFilterActive,
            onClear: _clearRepeatCustomerFilters,
            selectedMonth: _repeatCustomerMonth,
            selectedYear: _repeatCustomerYear,
            onMonthChanged: (month) {
              setState(() {
                _repeatCustomerMonth = month;
              });
              customerAnalyticsController.fetchMonthlyRepeatCustomerChart(
                year: _repeatCustomerYear,
                month: _repeatCustomerMonth,
              );
            },
            onYearChanged: (year) {
              setState(() {
                _repeatCustomerYear = year;
              });
              customerAnalyticsController.fetchMonthlyRepeatCustomerChart(
                year: _repeatCustomerYear,
                month: _repeatCustomerMonth,
              );
            },
          ),
          const SizedBox(height: 16),

          // ✅ CHART 2: REPEAT CUSTOMERS (LINE)
          Obx(
            () => customerAnalyticsController.isMonthlyRepeatCustomerChartLoading.value
                ? _buildLoadingChart('Loading Repeat Customers Chart...')
                : customerAnalyticsController.hasMonthlyRepeatCustomerChartError.value
                    ? buildErrorCard(
                        customerAnalyticsController.monthlyRepeatCustomerChartErrorMessage,
                        Get.width,
                        300,
                        true,
                      )
                    : AutoChart(
                       
                       apiResponse:    customerAnalyticsController.monthlyRepeatCustomerPayload,
                        
                        title: 'Repeat Customers',
                        chartType: ChartType.column,
                        subtitle:
                            'Year ${_repeatCustomerYear ?? DateTime.now().year}${_repeatCustomerMonth != null ? ' - Month ${_repeatCustomerMonth}' : ''}',
                      ),
          ),
        ],
      ),
    );
  }
  dynamic _convertMapToListFormat(Map<String, double> data) {
    if (data.isEmpty) return {};

    // Convert to list of maps: [{"label": "FEBRUARY", "totalAmount": 3.0}, ...]
    final list = <Map<String, dynamic>>[];
    
    for (final entry in data.entries) {
      list.add({
        'label': entry.key,
        'totalAmount': entry.value,
      });
    }

    return list;
  }

 Map<String, double> _formatRepeatCustomerData(Map<String, double> data) {
    if (data.isEmpty) return {};

    // Only return data that has actual values (not zeros)
    final formattedData = <String, double>{};

    for (final entry in data.entries) {
      if (entry.value > 0) {
        formattedData[entry.key] = entry.value;
      }
    }

    // If no data, return original to show at least something
    return formattedData.isEmpty ? data : formattedData;
  }


  Widget _buildFilterSection({
    required String title,
    required bool showClear,
    required VoidCallback onClear,
    required int? selectedMonth,
    required int? selectedYear,
    required Function(int?) onMonthChanged,
    required Function(int?) onYearChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (showClear)
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: const BorderSide(color: AppColors.primaryLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          MonthYearDropdown(
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            onMonthChanged: onMonthChanged,
            onYearChanged: onYearChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingChart(String message) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 2: VILLAGE DISTRIBUTION
  // ============================================================
  Widget _buildVillageDistributionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterSection(
            title: 'Filter Options',
            showClear: isVillageFilterActive,
            onClear: _clearVillageFilters,
            selectedMonth: _villageDistributionMonth,
            selectedYear: _villageDistributionYear,
            onMonthChanged: (month) {
              setState(() {
                _villageDistributionMonth = month;
              });
              customerAnalyticsController.fetchVillageDistributionChart(
                year: _villageDistributionYear,
                month: _villageDistributionMonth,
              );
            },
            onYearChanged: (year) {
              setState(() {
                _villageDistributionYear = year;
              });
              customerAnalyticsController.fetchVillageDistributionChart(
                year: _villageDistributionYear,
                month: _villageDistributionMonth,
              );
            },
          ),
          const SizedBox(height: 16),
          Obx(
            () => customerAnalyticsController.isVillageDistributionChartLoading.value
                ? _buildLoadingChart('Loading Village Distribution Chart...')
                : customerAnalyticsController.hasVillageDistributionChartError.value
                    ? buildErrorCard(
                        customerAnalyticsController.villageDistributionChartErrorMessage,
                        Get.width,
                        300,
                        true,
                      )
                    : AutoChart(
                        apiResponse: customerAnalyticsController.villageDistributionPayload,
                        title: 'Village Distribution',
                        chartType: ChartType.column,
                        subtitle:
                            'Year ${_villageDistributionYear ?? DateTime.now().year}${_villageDistributionMonth != null ? ' - Month ${_villageDistributionMonth}' : ''}',
                      ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => customerAnalyticsController.isVillageDistributionChartLoading.value
                ? const SizedBox.shrink()
                : _buildLegendCard(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: TOP CUSTOMERS
  // ============================================================
  Widget _buildTopCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Obx(
            () => customerAnalyticsController.isTopCustomerChartLoading.value
                ? buildTopCustomersShimmer(isSmallScreen)
                : customerAnalyticsController.hasTopCustomerChartError.value
                    ? buildErrorCard(
                        customerAnalyticsController.topCustomerChartErrorMessage,
                        Get.width,
                        Get.height,
                        true,
                      )
                    : Column(
                        children: [
                          _buildTopCustomersChart(isSmallScreen),
                          const SizedBox(height: 16),
                          _buildTopCustomersList(),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildTopCustomersChart(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Customers Overview',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Top Customers by Purchase Amount',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: _buildHorizontalBarChart(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBarChart(bool isSmallScreen) {
    final dataList = customerAnalyticsController.topCustomerChartData;

    if (dataList.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxValue = dataList
        .map((e) => e['totalSales'] as double)
        .reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: dataList.map((entry) {
              final name = entry['name'] ?? '';
              final value = (entry['totalSales'] as num).toDouble();
              final percentage = value / maxValue;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: isSmallScreen ? 60 : 80,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              width: (constraints.maxWidth - 92) * percentage,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.primaryGradientLight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '₹${_formatAmount(value)}',
                                  style: TextStyle(
                                    color: percentage > 0.5
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTopCustomersList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Rankings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '#',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...customerAnalyticsController.topCustomerChartData
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final customer = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.grey[50] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          gradient:
                              LinearGradient(colors: AppColors.primaryGradientLight),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          customer['name'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${_formatAmount(customer['totalSales'])}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              })
              .toList(),
        ],
      ),
    );
  }

  Widget _buildLegendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Village Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: customerAnalyticsController.villageDistributionPayload
                .entries
                .map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getColorForLocation(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.key} (${entry.value.toInt()})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _getColorForLocation(String location) {
    const colors = [
      AppColors.primaryLight,
      Color(0xFFFF9500),
      Color(0xFF51CF66),
      Color(0xFFE74C3C),
      Color(0xFF00CEC9),
      Color(0xFFA29BFE),
    ];
    final index = customerAnalyticsController.villageDistributionPayload.keys
        .toList()
        .indexOf(location);
    return colors[index % colors.length];
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}