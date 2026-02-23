import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common_build_date_pickerfield.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_insights_controller.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/payment_distribution_model.dart';
import 'package:smartbecho/views/account%20management/components/history/coustom_bottomSheet.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesInsightsController controller =
        Get.find<SalesInsightsController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Distribution",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Distribution Chart",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Filters Row
            FeatureVisitor(
              featureKey: FeatureKeys.SALES.paymentSalesDistribution,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Expanded(
                      //   flex: 2,
                      //   child: buildStyledDropdown(
                      //     labelText: "Year",
                      //     hintText: "Select Year",
                      //     value:
                      //         controller.selectedPaymentYear.value.toString(),
                      //     items: controller.years,
                      //     onChanged: (v) {
                      //       controller.updatePaymentDisYear(v!);
                      //     },
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
                      // Expanded(
                      //   flex: 2,
                      //   child: buildStyledDropdown(
                      //     labelText: "Month",
                      //     hintText: "Select Month",
                      //     value: controller.monthDisplayText,
                      //     items: controller.months,
                      //     onChanged: (v) {
                      //       controller.updatePaymentDisMonth(
                      //         controller.months.indexOf(v!) + 1,
                      //       );
                      //     },
                      //   ),
                      // ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showPaymentMethodsFilterBottomSheet(
                            controller,
                            context,
                          );
                        },
                        label: Text('Filter'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Obx(() {
                        return controller.canClearPaymentMethodDistribution()
                            ? SizedBox(
                              //  width: 140,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  controller.clearPaymentMethodDistribution();
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
                              ),
                            )
                            : const SizedBox();
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Content
                  _distributionChart(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showPaymentMethodsFilterBottomSheet(
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
                'Filter Distribution',
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
          // Date Filter Type Selection
          Obx(
            () => buildStyledDropdown(
              labelText: 'Date Filter',
              hintText: 'Select Type',
              value: controller.paymentChartDateFilterType.value,
              items: ['Month', 'Year', 'Custom'],
              onChanged: (value) {
                if (value != null) {
                  controller.paymentOnDateFilterTypeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Conditional Date Inputs based on filter type
          Obx(() {
            if (controller.paymentChartDateFilterType.value == 'Custom') {
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
                            controller.paymentChartStartDateText.value,
                        onTap:
                            () => controller.paymentSelectCustomStartDate(
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
                        selectedDate: controller.paymentChartEndDateText.value,
                        onTap:
                            () =>
                                controller.paymentSelectCustomEndDate(context),
                      ),
                    );
                  }),
                ],
              );
            } else if (controller.paymentChartDateFilterType.value == 'Year') {
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
                    controller.updatePaymentDisYear(value);

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

                          controller.updatePaymentDisMonth(monthIndex);
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
                          controller.updatePaymentDisYear(value);

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
                    controller.clearPaymentMethodDistribution();
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

  Obx _distributionChart(SalesInsightsController controller) {
    return Obx(() {
      if (controller.isPaymentChartLoading.value) {
        return SizedBox(
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.paymentDistributions.isEmpty) {
        return SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  "No payment data available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout
            bool isWideScreen = constraints.maxWidth > 800;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
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
                            child: _buildDistributionTable(
                              controller.paymentDistributions,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _buildPieChartSection(
                              controller.paymentDistributions,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          _buildPieChartSection(
                            controller.paymentDistributions,
                          ),
                          SizedBox(height: 24),
                          _buildDistributionTable(
                            controller.paymentDistributions,
                          ),
                        ],
                      ),
            );
          },
        );
      }
    });
  }

  Widget _buildDistributionTable(List<PaymentDistribution> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.table_chart, color: Colors.blue[700], size: 24),
            SizedBox(width: 8),
            Text(
              "Distribution Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Table Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Payment Method",
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
                  "Amount",
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
          constraints: BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.only(
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    // Color Indicator & Method Name
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
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "${item.paymentMethod} - ${item.paymentType}",
                              style: TextStyle(
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

                    // Amount
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹${_formatAmount(item.totalAmount)}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
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
                        padding: EdgeInsets.symmetric(
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
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
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
                    color: Colors.blue[900],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "₹${_formatAmount(_calculateTotal(data))}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue[900],
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
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection(List<PaymentDistribution> data) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart, color: Colors.green[700], size: 24),
            SizedBox(width: 8),
            Text(
              "Distribution Chart",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
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
                    PaymentDistribution item = entry.value;

                    return PieChartSectionData(
                      value: item.percentage,
                      title: "${item.percentage.toStringAsFixed(1)}%",
                      radius: 80,
                      color: _colorForIndex(index),
                      titleStyle: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        "${percentage.toStringAsFixed(1)}%",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Color _colorForIndex(int index) {
    List<Color> colors = [
      Color(0xFFEF5350), // Red
      Color(0xFF26C6DA), // Cyan
      Color(0xFF7E57C2), // Deep Purple
      Color(0xFF66BB6A), // Green
      Color(0xFFFF7043), // Orange
      Color(0xFF42A5F5), // Blue
      Color(0xFFEC407A), // Pink
      Color(0xFFFFCA28), // Amber
    ];
    return colors[index % colors.length];
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(2)}K";
    }
    return amount.toStringAsFixed(0);
  }

  double _calculateTotal(List<PaymentDistribution> data) {
    return data.fold(0.0, (sum, item) => sum + item.totalAmount);
  }
}
