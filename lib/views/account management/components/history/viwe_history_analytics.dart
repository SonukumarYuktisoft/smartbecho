import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartbecho/controllers/account%20management%20controller/view_history_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/views/account%20management/components/history/coustom_bottomSheet.dart';
import 'package:smartbecho/views/account%20management/components/history/viwe_history_card.dart';

class ViweHistoryAnalytics extends StatefulWidget {
  const ViweHistoryAnalytics({super.key});

  @override
  State<ViweHistoryAnalytics> createState() => _ViweHistoryAnalyticsState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ViweHistoryAnalytics(),
    );
  }
}

class _ViweHistoryAnalyticsState extends State<ViweHistoryAnalytics> {
  final ViewHistoryController controller = Get.put(ViewHistoryController());

  @override
  void initState() {
    controller.scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (controller.scrollController.position.pixels >=
        controller.scrollController.position.maxScrollExtent - 200) {
      controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: AppRefreshIndicator(
           onRefresh: () async {
              controller.refreshData();
            },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildHeader(controller),
                  // // SizedBox(height: 16),
                  // _buildFiltersSection(),
                  // _buiidGridCard(),
                  // _buildHeader(controller),
                  // SizedBox(height: 16),
                  // _buildAnalyticsSection(controller),
                  // SizedBox(height: 24),
                  // _buildChartContainer(controller),
                  _buildHeader(controller),
                  _buildAnalyticsSection(controller),
                  SizedBox(height: 24),
                  _buildChartContainer(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Obx _buiidGridCard() {
    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      } else if (controller.transactionList.isEmpty) {
        return _buildEmptyState();
      } else {
        return GridView.builder(
          controller: controller.scrollController,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: controller.transactionList.length,
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = controller.transactionList[index];
            return ViewHistoryCard(data: data);
          },
        );
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No commissions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.clearFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   margin: EdgeInsets.only(right: 6),
          //   decoration: BoxDecoration(
          //     color: AppColors.primaryLight.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Obx(() {
          //     return Text(controller.transactionList.length.toString());
          //   }),
          // ),
          Expanded(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Filter Transactions',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
              ),
              onTap: () {
                _showFilterBottomSheet();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              showCustomBottomSheet(
                child: Column(
                  children: [
                    _buildHeader(controller),
                    _buildAnalyticsSection(controller),
                    SizedBox(height: 24),
                    _buildChartContainer(controller),
                  ],
                ),
              );
            },
            icon: Icon(Icons.bar_chart_rounded),

            style: ButtonStyle(elevation: MaterialStatePropertyAll<double>(0)),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showFilterBottomSheet() {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildStyledDropdown(
                  labelText: "years",
                  hintText: "Select Year",
                  value: controller.selectedTransactionYear.value.toString(),
                  items: controller.years,
                  onChanged: (v) {
                    print(v);
                    controller.onChangedYear(v!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildStyledDropdown(
                  labelText: "Months",
                  hintText: "Months",
                  value: controller.monthDisplayText,
                  items: controller.months,
                  onChanged: (v) {
                    controller.onMonthChanged(
                      controller.months.indexOf(v!) + 1,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildStyledDropdown(
                  labelText: "Transaction Type",
                  hintText: "Select Type",
                  value:
                      controller.selectedTransactionType.value == "All"
                          ? null
                          : controller.selectedTransactionType.value,
                  items: controller.transactionTypes,
                  onChanged: (v) {
                    // print(v);
                    controller.onTransactionTypeChanged(v.toString());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: BorderSide(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  icon: Icon(Icons.search, size: 18),
                  label: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ViewHistoryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        _buildYearDropdown(controller),

        Obx(() {
          return controller.activeFinancialSummary()
              ? SizedBox(
                //  width: 140,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFinancialSummary();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Clear Filter",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              )
              : const SizedBox();
        }),
      ],
    );
  }

  Widget _buildYearDropdown(ViewHistoryController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButton<int>(
          value: controller.selectedYear.value,
          items:
              controller.availableYears.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (year) {
            if (year != null) {
              controller.onYearChanged(year);
            }
          },
          underline: SizedBox.shrink(),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(ViewHistoryController controller) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                _buildAnalyticsTab(controller, 'Monthly', 'monthly'),
                SizedBox(width: 8),
                _buildAnalyticsTab(controller, 'By Company', 'company'),
                SizedBox(width: 8),
                _buildAnalyticsTab(controller, 'Trends', 'trends'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(
    ViewHistoryController controller,
    String label,
    String tabId,
  ) {
    final isActive = controller.selectedAnalyticsTab.value == tabId;
    return GestureDetector(
      onTap: () => controller.onAnalyticsTabChanged(tabId),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF6C5CE7) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isActive
                    ? Color(0xFF6C5CE7)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer(ViewHistoryController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            height: 350,
            child: Center(child: CustomLottieLoader()),
          );
        }

        if (controller.financialData.isEmpty) {
          return Container(
            height: 350,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No data available for ${controller.selectedYear.value}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildChartHeader(controller),
            SizedBox(height: 20),
            _buildSelectedChart(controller),
          ],
        );
      }),
    );
  }

  Widget _buildChartHeader(ViewHistoryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getChartTitle(controller),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: controller.refreshData,
          icon: Icon(Icons.refresh, color: Colors.grey[700], size: 20),
        ),
      ],
    );
  }

  String _getChartTitle(ViewHistoryController controller) {
    switch (controller.selectedAnalyticsTab.value) {
      case 'monthly':
        return 'Monthly Overview ${controller.selectedYear.value}';
      case 'company':
        return 'Company Performance ${controller.selectedYear.value}';
      case 'trends':
        return 'Financial Trends ${controller.selectedYear.value}';
      default:
        return 'Financial Overview ${controller.selectedYear.value}';
    }
  }

  Widget _buildSelectedChart(ViewHistoryController controller) {
    switch (controller.selectedAnalyticsTab.value) {
      case 'monthly':
        return _buildMonthlyBarChart(controller);
      case 'company':
        return _buildCompanyPieChart(controller);
      case 'trends':
        return _buildTrendsLineChart(controller);
      default:
        return _buildMonthlyBarChart(controller);
    }
  }

  Widget _buildMonthlyBarChart(ViewHistoryController controller) {
    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: controller.getMaxValue() * 1.1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = '';
                      switch (rodIndex) {
                        case 0:
                          label = 'Bills Paid';
                          break;
                        case 1:
                          label = 'Sales Amount';
                          break;
                        case 2:
                          label = 'Commissions';
                          break;
                      }
                      return BarTooltipItem(
                        '$label\n₹${controller.formatAmount(rod.toY)}',
                        TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < controller.financialData.length) {
                          return Text(
                            controller.financialData[value.toInt()].monthName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          controller.formatAmount(value),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    controller.financialData.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.totalBillsPaid,
                            color: Color(0xFFFF6B6B),
                            width: 8,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          BarChartRodData(
                            toY: data.totalSalesAmount,
                            color: Colors.grey[500]!,
                            width: 8,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          BarChartRodData(
                            toY: data.totalCommissions,
                            color: Color(0xFF51CF66),
                            width: 8,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      );
                    }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: controller.getHorizontalInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildBarChartLegend(),
        ],
      ),
    );
  }

  Widget _buildBarChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Bills Paid', Color(0xFFFF6B6B)),
        SizedBox(width: 20),
        _buildLegendItem('Sales Amount', Colors.grey[500]!),
        SizedBox(width: 20),
        _buildLegendItem('Commissions', Color(0xFF51CF66)),
      ],
    );
  }

  Widget _buildCompanyPieChart(ViewHistoryController controller) {
    final totalBills = controller.financialData.fold(
      0.0,
      (sum, item) => sum + item.totalBillsPaid,
    );
    final totalSales = controller.financialData.fold(
      0.0,
      (sum, item) => sum + item.totalSalesAmount,
    );
    final totalCommissions = controller.financialData.fold(
      0.0,
      (sum, item) => sum + item.totalCommissions,
    );
    final grandTotal = totalBills + totalSales + totalCommissions;

    if (grandTotal == 0) {
      return Container(
        height: 300,
        child: Center(
          child: Text(
            'No data available for pie chart',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  mouseCursorResolver: (FlTouchEvent event, pieTouchResponse) {
                    return pieTouchResponse?.touchedSection != null
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic;
                  },
                ),
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  if (totalBills > 0)
                    PieChartSectionData(
                      color: Color(0xFFFF6B6B),
                      value: totalBills,
                      title:
                          '${((totalBills / grandTotal) * 100).toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (totalSales > 0)
                    PieChartSectionData(
                      color: Colors.grey[500]!,
                      value: totalSales,
                      title:
                          '${((totalSales / grandTotal) * 100).toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (totalCommissions > 0)
                    PieChartSectionData(
                      color: Color(0xFF51CF66),
                      value: totalCommissions,
                      title:
                          '${((totalCommissions / grandTotal) * 100).toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildPieChartLegend(totalBills, totalSales, totalCommissions),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(
    double totalBills,
    double totalSales,
    double totalCommissions,
  ) {
    return Column(
      children: [
        if (totalBills > 0)
          _buildPieLegendItem(
            'Bills Paid',
            '₹${ViewHistoryController().formatAmount(totalBills)}',
            Color(0xFFFF6B6B),
          ),
        if (totalSales > 0)
          _buildPieLegendItem(
            'Sales Amount',
            '₹${ViewHistoryController().formatAmount(totalSales)}',
            Colors.grey[500]!,
          ),
        if (totalCommissions > 0)
          _buildPieLegendItem(
            'Commissions',
            '₹${ViewHistoryController().formatAmount(totalCommissions)}',
            Color(0xFF51CF66),
          ),
      ],
    );
  }

  Widget _buildPieLegendItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsLineChart(ViewHistoryController controller) {
    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: controller.getHorizontalInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < controller.financialData.length) {
                          return Text(
                            controller.financialData[value.toInt()].monthName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          controller.formatAmount(value),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (controller.financialData.length - 1).toDouble(),
                minY: 0,
                maxY: controller.getMaxValue() * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        controller.financialData.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.totalBillsPaid,
                          );
                        }).toList(),
                    isCurved: true,
                    color: Color(0xFFFF6B6B),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFFFF6B6B),
                          ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots:
                        controller.financialData.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.totalSalesAmount,
                          );
                        }).toList(),
                    isCurved: true,
                    color: Colors.grey[500]!,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.grey[500]!,
                          ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots:
                        controller.financialData.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.totalCommissions,
                          );
                        }).toList(),
                    isCurved: true,
                    color: Color(0xFF51CF66),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFF51CF66),
                          ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      return Colors.black87;
                    },
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        String label = '';
                        switch (barSpot.barIndex) {
                          case 0:
                            label = 'Bills Paid';
                            break;
                          case 1:
                            label = 'Sales Amount';
                            break;
                          case 2:
                            label = 'Commissions';
                            break;
                        }
                        return LineTooltipItem(
                          '$label\n₹${controller.formatAmount(flSpot.y)}',
                          TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildBarChartLegend(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
