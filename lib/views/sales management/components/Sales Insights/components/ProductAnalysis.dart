import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:smartbecho/utils/charts/chart_widgets.dart';
import 'package:smartbecho/utils/common/common_build_date_pickerfield.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_insights_controller.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/BrandSalesResponse.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/TopSellingModelsResponse.dart';
import 'package:smartbecho/views/account%20management/components/history/coustom_bottomSheet.dart';

// ==================== BRAND DISTRIBUTION PIE CHART ====================
class BrandDistributionChart extends StatelessWidget {
  final List<BrandSaleItem> brandSales;

  const BrandDistributionChart({super.key, required this.brandSales});

  @override
  Widget build(BuildContext context) {
    // Group by brand and sum quantities
    Map<String, int> brandTotals = {};
    int totalQty = 0;

    for (var item in brandSales) {
      brandTotals[item.brand] =
          (brandTotals[item.brand] ?? 0) + item.totalQuantity;
      totalQty += item.totalQuantity;
    }

    // Create list with percentages for display
    List<BrandData> brandDataList =
        brandTotals.entries.map((entry) {
          double percentage = totalQty > 0 ? (entry.value / totalQty) * 100 : 0;
          return BrandData(
            brand: entry.key,
            quantity: entry.value,
            percentage: percentage,
          );
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 800;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              isWideScreen
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDistributionTable(brandDataList, totalQty),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildPieChartSection(brandDataList),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      _buildPieChartSection(brandDataList),
                      const SizedBox(height: 24),
                      _buildDistributionTable(brandDataList, totalQty),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildDistributionTable(List<BrandData> data, int totalQty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.table_chart, color: Colors.teal[700], size: 24),
            const SizedBox(width: 8),
            const Text(
              "Brand Distribution Summary",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Brand",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Quantity",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Share",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Rows
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: data.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Color Indicator & Brand Name
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: _colorForIndex(index),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _colorForIndex(index).withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              item.brand,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${item.quantity} units",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Percentage
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _colorForIndex(index).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${item.percentage.toStringAsFixed(1)}%",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: _colorForIndex(index),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Total Summary
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Total",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal[900],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "$totalQty units",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal[900],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "100%",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection(List<BrandData> data) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart, color: Colors.teal[700], size: 24),
            const SizedBox(width: 8),
            const Text(
              "Distribution Chart",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              startDegreeOffset: -90,
              sections:
                  data.asMap().entries.map((entry) {
                    int index = entry.key;
                    BrandData item = entry.value;

                    return PieChartSectionData(
                      value: item.percentage,
                      title: "${item.percentage.toStringAsFixed(1)}%",
                      radius: 80,
                      color: _colorForIndex(index),
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      badgeWidget:
                          item.percentage > 10
                              ? null
                              : _buildBadge(item.percentage),
                      badgePositionPercentageOffset: 1.3,
                    );
                  }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Add touch interactions if needed
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        "${percentage.toStringAsFixed(1)}%",
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Color _colorForIndex(int index) {
    List<Color> colors = [
      Colors.teal,
      Colors.tealAccent.shade400,
      Colors.cyan,
      Colors.blue,
      Colors.green,
      Colors.lightGreen,
      Colors.purple,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}

// Helper class to store brand data with percentage
class BrandData {
  final String brand;
  final int quantity;
  final double percentage;

  BrandData({
    required this.brand,
    required this.quantity,
    required this.percentage,
  });
}

// ==================== TOP SELLING MODELS BAR CHART ====================
class TopSellingModelsChart extends StatelessWidget {
  final List<TopModelItem> models;

  const TopSellingModelsChart({super.key, required this.models});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    // Sort by quantity descending
    List<TopModelItem> sortedModels = List.from(models)
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    int maxQty = sortedModels.isNotEmpty ? sortedModels.first.quantity + 1 : 5;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < sortedModels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sortedModels[i].quantity.toDouble(),
              color: colors[i % colors.length],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxQty.toDouble(),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 0.8,
                    dashArray: [5, 5],
                  );
                },
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < sortedModels.length) {
                        String modelName = sortedModels[idx].model;
                        if (modelName.length > 10) {
                          modelName = modelName.substring(0, 10);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            modelName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: barGroups,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    int qty = sortedModels[groupIndex].quantity;
                    String model = sortedModels[groupIndex].model;
                    String brand = sortedModels[groupIndex].brand;
                    return BarTooltipItem(
                      '$model\n$brand: $qty',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PRODUCT ANALYSIS WIDGET ====================
class ProductAnalysis extends StatelessWidget {
  const ProductAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesInsightsController controller =
        Get.find<SalesInsightsController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          
          // ==================== BRAND DISTRIBUTION SECTION ====================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Brand Distribution",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sales distribution across different brands",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Filters Row
                FeatureVisitor(
                  featureKey: FeatureKeys.SALES.brandSales,

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showBrandFilterBottomSheet(controller, context);
                            },
                            label: Text('Filter'),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                            ),
                          ),

                          // const Spacer(),
                          // SizedBox(
                          //   width: 120,
                          //   child: Obx(
                          //     () => buildStyledDropdown(
                          //       labelText: "Month",
                          //       hintText: "Select Month",
                          //       value: controller.monthDisplayText,
                          //       items: controller.months,
                          //       onChanged: (v) {
                          //         int monthIdx =
                          //             controller.months.indexOf(v!) + 1;
                          //         controller.updateBrandDisMonth(monthIdx);
                          //       },
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 12),
                          // SizedBox(
                          //   width: 100,
                          //   child: Obx(
                          //     () => buildStyledDropdown(
                          //       labelText: "Year",
                          //       hintText: "Select Year",
                          //       value:
                          //           controller.selectedBrandDisYear.value
                          //               .toString(),
                          //       items: controller.years,
                          //       onChanged: (v) {
                          //         controller.updateBrandDisYear(v!);
                          //       },
                          //     ),
                          //   ),
                          // ),
                          SizedBox(width: 4),
                          Obx(() {
                            return controller.canClearBrandDistribution()
                                ? OutlinedButton.icon(
                                  onPressed: () {
                                    controller.clearBrandDistribution();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryLight,
                                    side: BorderSide(
                                      color: AppColors.primaryLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  label: const Text("Clear Filter"),
                                )
                                : const SizedBox();
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Brand Distribution Chart
                       
                      _bistributionChart(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ==================== TOP SELLING MODELS SECTION ====================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Top Selling Models",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Best performing phone models",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Filters Row
          FeatureVisitor(
            featureKey: FeatureKeys.SALES.topModels,

            child: Column(
              children: [
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showTopSellingModelFilterBottomSheet(controller, context);
                      },
                      label: Text('Filter'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    // const Spacer(),
                    // SizedBox(
                    //   width: 120,
                    //   child: Obx(
                    //     () => buildStyledDropdown(
                    //       labelText: "Month",
                    //       hintText: "Select Month",
                    //       value: controller.monthDisplayText,
                    //       items: controller.months,
                    //       onChanged: (v) {
                    //         int monthIdx = controller.months.indexOf(v!) + 1;
                    //         controller.updateTopModelsMonth(monthIdx);
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    // SizedBox(
                    //   width: 100,
                    //   child: Obx(
                    //     () => buildStyledDropdown(
                    //       labelText: "Year",
                    //       hintText: "Select Year",
                    //       value:
                    //           controller.selectedTopModelsYear.value.toString(),
                    //       items: controller.years,
                    //       onChanged: (v) {
                    //         controller.updateTopModelsYear(v!);
                    //       },
                    //     ),
                    //   ),
                    // ),

                    SizedBox(width: 4),
                    Obx(() {
                      return controller.canClearTopModels()
                          ? OutlinedButton.icon(
                            onPressed: () {
                              controller.clearTopModels();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryLight,
                              side: BorderSide(
                                color: AppColors.primaryLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.clear),
                            label: const Text("Clear Filter"),
                          )
                          : const SizedBox();
                    }),
                  ],
                ),
                // Top Selling Models Chart
                _topSellingModelsChart(controller),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<dynamic> _showBrandFilterBottomSheet(
    SalesInsightsController controller,
    BuildContext context,
  ) {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Brand',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CommonDropdownSearch<String>(
                    items: controller.itemCategoriesList,
                    selectedItem: controller.selectedItemCategory.value,
                    labelText: 'Select Category',
                    hintText: 'Choose a category',
                    prefixIcon: Icons.category,
                    onChanged: (value) {
                      controller.selectedItemCategory.value = value;
                      controller.fetchBrandDistribution();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Date Filter Type Selection
          Obx(
            () => buildStyledDropdown(
              labelText: 'Date Filter',
              hintText: 'Select Type',
              value: controller.brandChartDateFilterType.value,
              items: ['Month', 'Year', 'Custom'],
              onChanged: (value) {
                if (value != null) {
                  controller.brandDisOnDateFilterTypeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Conditional Date Inputs based on filter type
          Obx(() {
            if (controller.brandChartDateFilterType.value == 'Custom') {
              // Custom Date Range
              return Row(
                children: [
                  Obx(() {
                    return Expanded(
                      child: buildDatePickerField(
                        context: context,
                        labelText: 'Start Date',
                        hintText: 'dd/mm/yyyy',
                        selectedDate: controller.brandChartStartDateText.value,
                        onTap:
                            () => controller.brandDisSelectCustomStartDate(
                              context,
                            ),
                      ),
                    );
                  }),
                  SizedBox(width: 12),
                  Obx(() {
                    return Expanded(
                      child: buildDatePickerField(
                        context: context,
                        labelText: 'End Date',
                        hintText: 'dd/mm/yyyy',
                        selectedDate: controller.brandChartEndDateText.value,
                        onTap:
                            () =>
                                controller.brandDisSelectCustomEndDate(context),
                      ),
                    );
                  }),
                ],
              );
            } else if (controller.brandChartDateFilterType.value == 'Year') {
              // Year Only
              return buildStyledDropdown(
                labelText: 'Year',
                hintText: 'Select Year',
                value: controller.selectedYear.value.toString(),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return year.toString();
                }),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateBrandDisYear(value);

                    // controller.onYearChanged(int.parse(value));
                  }
                },
              );
            } else {
              // Month and Year
              return Row(
                children: [
                  Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Month',
                      hintText: 'Select Month',
                      value: controller.monthDisplayText,
                      items: controller.months,
                      onChanged: (value) {
                        if (value != null) {
                          final monthIndex =
                              controller.months.indexOf(value) + 1;

                          controller.updateBrandDisMonth(monthIndex);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Year',
                      hintText: 'Select Year',
                      value: controller.selectedYear.value.toString(),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - index;
                        return year.toString();
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateBrandDisYear(value);

                          // controller.onYearChanged(int.parse(value));
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          }),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.clearBrandDistribution();
                    Get.back();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: BorderSide(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // controller.applyFilters();
                    Get.back();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<dynamic> _showTopSellingModelFilterBottomSheet(
    SalesInsightsController controller,
    BuildContext context,
  ) {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Top Selling Model',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CommonDropdownSearch<String>(
                    items: controller.modelsList,
                    selectedItem: controller.selectedModel.value,
                    enabled: false,
                    labelText: 'Select Model',
                    hintText: 'Choose a model',
                    prefixIcon: Icons.phone_iphone,
                    onChanged: (value) {
                      controller.selectedModel.value = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Date Filter Type Selection
          Obx(
            () => buildStyledDropdown(
              labelText: 'Date Filter',
              hintText: 'Select Type',
              value: controller.topModelsChartDateFilterType.value,
              items: ['Month', 'Year', 'Custom'],
              onChanged: (value) {
                if (value != null) {
                  controller.topModelsOnDateFilterTypeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Conditional Date Inputs based on filter type
          Obx(() {
            if (controller.topModelsChartDateFilterType.value == 'Custom') {
              // Custom Date Range
              return Row(
                children: [
                  Obx(() {
                    return Expanded(
                      child: buildDatePickerField(
                        context: context,
                        labelText: 'Start Date',
                        hintText: 'dd/mm/yyyy',
                        selectedDate:
                            controller.topModelsChartStartDateText.value,
                        onTap:
                            () => controller.topModelsSelectCustomStartDate(
                              context,
                            ),
                      ),
                    );
                  }),
                  SizedBox(width: 12),
                  Obx(() {
                    return Expanded(
                      child: buildDatePickerField(
                        context: context,
                        labelText: 'End Date',
                        hintText: 'dd/mm/yyyy',
                        selectedDate:
                            controller.topModelsChartEndDateText.value,
                        onTap:
                            () => controller.topModelsSelectCustomEndDate(
                              context,
                            ),
                      ),
                    );
                  }),
                ],
              );
            } else if (controller.topModelsChartDateFilterType.value ==
                'Year') {
              // Year Only
              return buildStyledDropdown(
                labelText: 'Year',
                hintText: 'Select Year',
                value: controller.selectedYear.value.toString(),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return year.toString();
                }),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateTopModelsYear(value);

                    // controller.onYearChanged(int.parse(value));
                  }
                },
              );
            } else {
              // Month and Year
              return Row(
                children: [
                  Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Month',
                      hintText: 'Select Month',
                      value: controller.monthDisplayText,
                      items: controller.months,
                      onChanged: (value) {
                        if (value != null) {
                          final monthIndex =
                              controller.months.indexOf(value) + 1;

                          controller.updateTopModelsMonth(monthIndex);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Year',
                      hintText: 'Select Year',
                      value: controller.selectedYear.value.toString(),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - index;
                        return year.toString();
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateTopModelsYear(value);

                          // controller.onYearChanged(int.parse(value));
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          }),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.clearTopModels();
                    Get.back();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: BorderSide(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // controller.applyFilters();
                    Get.back();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Obx _topSellingModelsChart(SalesInsightsController controller) {
    return Obx(() {
      if (controller.topModelsChartLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        );
      }

      if (controller.topModelsList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(Icons.trending_up, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "No model data available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return TopSellingModelsChart(models: controller.topModelsList);
    });
  }

  Obx _bistributionChart(SalesInsightsController controller) {
    return Obx(() {
      if (controller.isBrandChartLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        );
      }

      if (controller.brandSalesList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(Icons.shopping_bag, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "No brand data available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return BrandDistributionChart(brandSales: controller.brandSalesList);
    });
  }
}
