import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/commission_received_controller.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:smartbecho/utils/charts/chart_widgets.dart';
import 'package:smartbecho/utils/common/common_build_date_pickerfield.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/views/account%20management/components/history/coustom_bottomSheet.dart';

class CommissionReceivedAnalyticsBottomSheet extends StatefulWidget {
  const CommissionReceivedAnalyticsBottomSheet({Key? key}) : super(key: key);

  @override
  State<CommissionReceivedAnalyticsBottomSheet> createState() =>
      _CommissionReceivedAnalyticsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CommissionReceivedAnalyticsBottomSheet(),
    );
  }
}

class _CommissionReceivedAnalyticsBottomSheetState
    extends State<CommissionReceivedAnalyticsBottomSheet> {
  final CommissionReceivedController controller =
      Get.find<CommissionReceivedController>();

  final RxBool isFiltersVisible = true.obs;
  final RxString currentView = 'Monthly'.obs;
  var selectedCompany = Rx<String?>(null);

  final RxString selectedYear = DateTime.now().year.toString().obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load initial chart data
    controller.loadMonthlyChartData();
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
                    'Commission Analytics',
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
              if (controller.isLoading.value &&
                  controller.commissions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF10B981)),
                      const SizedBox(height: 16),
                      Text(
                        'Loading analytics data...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (controller.commissions.isEmpty) {
                return _buildEmptyState();
              }

              return FeatureVisitor(
                featureKey: FeatureKeys.ACCOUNTS.getLedgerAnalyticsDaily,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // View Toggle Buttons
                      _buildViewToggle(),
                      const SizedBox(height: 20),

                      // Chart based on current view
                      Obx(() {
                        if (currentView.value == 'Monthly') {
                          return _buildMonthlyChart(screenWidth, isSmallScreen);
                        } else if (currentView.value == 'Trends') {
                          return _buildTrendsChart(screenWidth, isSmallScreen);
                        } else {
                          return _buildCompanyChart(screenWidth, isSmallScreen);
                        }
                      }),
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

  Future<dynamic> _showCompanyChartDataFilter(
    CommissionReceivedController controller,
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
              value: controller.companyChartDateFilterType.value,
              items: ['Month', 'Year', 'Custom'],
              onChanged: (value) {
                if (value != null) {
                  controller.companyDateFilterTypeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Conditional Date Inputs based on filter type
          Obx(() {
            if (controller.companyChartDateFilterType.value == 'Custom') {
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
                            controller.companyChartStartDateText.value,
                        onTap:
                            () => controller.companySelectCustomStartDate(
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
                        selectedDate: controller.companyChartEndDateText.value,
                        onTap:
                            () =>
                                controller.companySelectCustomEndDate(context),
                      ),
                    );
                  }),
                ],
              );
            } else if (controller.companyChartDateFilterType.value == 'Year') {
              // Year Only
              return buildStyledDropdown(
                labelText: 'Year',
                hintText: 'Select Year',
                value: controller.selectedCompanyChartMonth.value.toString(),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return year.toString();
                }),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateCompanyYear(value);

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

                          controller.updateCompanyMonth(monthIndex);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildStyledDropdown(
                      labelText: 'Year',
                      hintText: 'Select Year',
                      value:
                          controller.selectedCompanyChartYear.value.toString(),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - index;
                        return year.toString();
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateCompanyYear(value);

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
                    controller.clearCompanyChartData();
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

  Future<dynamic> _showMonthlyFilter(
    CommissionReceivedController controller,
    BuildContext context,
  ) {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CommonDropdownSearch<String>(
                    items: _getCompanyOptions(),
                    selectedItem: controller.selectedMonthlyChartCompany.value,
                    labelText: 'Select Company',
                    hintText: 'Choose a Company',
                    prefixIcon: Icons.business,
                    onChanged: (value) {
                      if (value != null) {
                        selectedCompany.value = value;
                        controller.loadMonthlyChartData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: buildStyledDropdown(
                    labelText: 'Year',
                    hintText: 'Select Year',
                    value: controller.selectedMonthlyChartYear.value.toString(),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return year.toString();
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateMonthlyChartYear(value);

                        // controller.onYearChanged(int.parse(value));
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: buildStyledDropdown(
                    labelText: 'Month',
                    hintText: 'Select Month',
                    enabled: false,
                    value: controller.monthDisplayText,
                    items: controller.months,
                    onChanged: (value) {
                      if (value != null) {
                        final monthIndex = controller.months.indexOf(value) + 1;

                        controller.updateMonthlyMonth(monthIndex);
                      }
                    },
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.clearMonthlyChart();
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

  Future<dynamic> _showTrendsFilter(
    CommissionReceivedController controller,
    BuildContext context,
  ) {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CommonDropdownSearch<String>(
                    items: _getCompanyOptions(),
                    selectedItem: controller.selectedMonthlyChartCompany.value,
                    labelText: 'Select Company',
                    hintText: 'Choose a Company',
                    prefixIcon: Icons.business,
                    onChanged: (value) {
                      if (value != null) {
                        selectedCompany.value = value;
                        controller.loadMonthlyChartData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: buildStyledDropdown(
                    labelText: 'Year',
                    hintText: 'Select Year',
                    value: controller.selectedMonthlyChartYear.value.toString(),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return year.toString();
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateMonthlyChartYear(value);

                        // controller.onYearChanged(int.parse(value));
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: buildStyledDropdown(
                    labelText: 'Month',
                    hintText: 'Select Month',
                    enabled: false,
                    value: controller.monthDisplayText,
                    items: controller.months,
                    onChanged: (value) {
                      if (value != null) {
                        final monthIndex = controller.months.indexOf(value) + 1;

                        controller.updateMonthlyMonth(monthIndex);
                      }
                    },
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.clearMonthlyChart();
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

  Widget _buildToggleButton(String label) {
    return Expanded(
      child: Obx(() {
        final isSelected = currentView.value == label;
        return GestureDetector(
          onTap: () {
            currentView.value = label;
            // Load data based on selected view
            if (label == 'Monthly') {
              controller.loadMonthlyChartData();
            } else if (label == 'Trends') {
              controller.loadMonthlyChartData();
            } else {
              controller.loadCompanyChartData();
            }
          },
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

  // ✅ Monthly Chart with AutoChart
  Widget _buildMonthlyChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        Row(
          children: [
            Text(
              'Filters',
              style: AppStyles.custom(
                color: const Color(0xFF1A1A1A),
                size: 16,
                weight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                _showMonthlyFilter(controller, context);
              },
              label: Text('Filter'),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 4),

            Obx(() {
              return controller.isMonthlyChartActive.value
                  ? IconButton.outlined(
                    icon: Icon(Icons.clear, color: AppColors.primaryLight),
                    onPressed: () {
                      controller.clearMonthlyChart();
                    },
                  )
                  : SizedBox.shrink();
            }),
          ],
        ),

        // // Filters
        // Obx(
        //   () =>
        //       isFiltersVisible.value
        //           ? Container(
        //             margin: const EdgeInsets.only(bottom: 16),
        //             padding: const EdgeInsets.all(16),
        //             decoration: BoxDecoration(
        //               color: Colors.grey[50],
        //               borderRadius: BorderRadius.circular(12),
        //               border: Border.all(color: Colors.grey[200]!),
        //             ),
        //             child: Row(
        //               children: [
        //                 Obx(() {
        //                   return Expanded(
        //                     child: CommonDropdownSearch<String>(
        //                       items: _getCompanyOptions(),
        //                       selectedItem: selectedCompany.value,
        //                       labelText: 'Select Company',
        //                       hintText: 'Choose a Company',
        //                       prefixIcon: Icons.business,
        //                       onChanged: (value) {
        //                         if (value != null) {
        //                           selectedCompany.value = value;
        //                           controller.loadMonthlyChartData();
        //                         }
        //                       },
        //                     ),
        //                   );
        //                 }),
        //                 const SizedBox(width: 12),
        //                 Expanded(
        //                   child: Obx(
        //                     () => _buildFilterDropdown(
        //                       label: 'Year',
        //                       value: selectedYear.value,
        //                       items: _getAvailableYears(),
        //                       onChanged: (value) {
        //                         if (value != null) {
        //                           selectedYear.value = value;
        //                           controller.loadMonthlyChartData();
        //                         }
        //                       },
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           )
        //           : const SizedBox.shrink(),
        // ),

        // ✅ AutoChart with API data
        Obx(() {
          if (controller.isLoadingMonthlyChart.value) {
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
                    Text(
                      'Loading chart data...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.monthlyChartApiData.isEmpty) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return AutoChart(
            apiResponse: controller.monthlyChartApiData,
            title: 'Monthly Commission',
            chartType: ChartType.column,
            subtitle: 'Year ${selectedYear.value}',
          );
        }),
      ],
    );
  }

  // ✅ Trends Chart (Line Chart)
  Widget _buildTrendsChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        GestureDetector(
          onTap: () {
            isFiltersVisible.toggle();
            _showTrendsFilter(controller, context);
          },
          child: Row(
            children: [
              Text(
                'Filters',
                style: AppStyles.custom(
                  color: const Color(0xFF1A1A1A),
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showMonthlyFilter(controller, context);
                },
                label: Text('Filter'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 4),

              Obx(() {
                return controller.isMonthlyChartActive.value
                    ? IconButton.outlined(
                      icon: Icon(Icons.clear, color: AppColors.primaryLight),
                      onPressed: () {
                        controller.clearMonthlyChart();
                      },
                    )
                    : SizedBox.shrink();
              }),
            ],
          ),
        ),

        // // Filters
        // Obx(
        //   () =>
        //       isFiltersVisible.value
        //           ? Container(
        //             margin: const EdgeInsets.only(bottom: 16),
        //             padding: const EdgeInsets.all(16),
        //             decoration: BoxDecoration(
        //               color: Colors.grey[50],
        //               borderRadius: BorderRadius.circular(12),
        //               border: Border.all(color: Colors.grey[200]!),
        //             ),
        //             child: Row(
        //               children: [
        //                 Obx(() {
        //                   return Expanded(
        //                     child: CommonDropdownSearch<String>(
        //                       items: _getCompanyOptions(),
        //                       selectedItem: selectedCompany.value,
        //                       labelText: 'Select Company',
        //                       hintText: 'Choose a Company',
        //                       prefixIcon: Icons.business,
        //                       onChanged: (value) {
        //                         if (value != null) {
        //                           selectedCompany.value = value;
        //                           controller.loadMonthlyChartData();
        //                         }
        //                       },
        //                     ),
        //                   );
        //                 }),
        //                 const SizedBox(width: 12),
        //                 Expanded(
        //                   child: Obx(
        //                     () => _buildFilterDropdown(
        //                       label: 'Year',
        //                       value: selectedYear.value,
        //                       items: _getAvailableYears(),
        //                       onChanged: (value) {
        //                         if (value != null) {
        //                           selectedYear.value = value;
        //                           controller.loadMonthlyChartData();
        //                         }
        //                       },
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           )
        //           : const SizedBox.shrink(),
        // ),

        // ✅ Line Chart with API data
        Obx(() {
          if (controller.isLoadingMonthlyChart.value) {
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
                    Text(
                      'Loading chart data...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.monthlyChartApiData.isEmpty) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return AutoChart(
            apiResponse: controller.monthlyChartApiData,
            title: 'Commission Trends',
            chartType: ChartType.line,
            subtitle: 'Year ${controller.selectedMonthlyChartYear.value}',
          );
        }),
      ],
    );
  }

  // ✅ Company Chart (Bar Chart)
  Widget _buildCompanyChart(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Header
        GestureDetector(
          onTap: () {
            _showCompanyChartDataFilter(controller, context);
          },
          child: Row(
            children: [
              Text(
                'Filters',
                style: AppStyles.custom(
                  color: const Color(0xFF1A1A1A),
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showCompanyChartDataFilter(controller, context);
                },
                label: Text('Filter'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 4),

              Obx(() {
                return controller.isCompanyChartActive.value
                    ? IconButton.outlined(
                      icon: Icon(Icons.clear, color: AppColors.primaryLight),
                      onPressed: () {
                        controller.clearCompanyChartData();
                      },
                    )
                    : SizedBox.shrink();
              }),
            ],
          ),
        ),

        // ✅ Bar Chart with API data
        Obx(() {
          if (controller.isLoadingCompanyChart.value) {
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
                    Text(
                      'Loading chart data...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.companyChartApiData.isEmpty) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return AutoChart(
            apiResponse: controller.companyChartApiData,
            title: 'Company-wise Commission',
            chartType: ChartType.column,
            subtitle: 'Year ${selectedYear.value}',
          );
        }),
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
              child: const Icon(
                Icons.analytics_outlined,
                size: 50,
                color: Color(0xFF10B981),
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
              'Add some commission records to see analytics and trends.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCompanyOptions() {
    final options = <String>{'All Companies'};
    for (var commission in controller.commissions) {
      options.add(commission.company);
    }
    return options.toList()..sort();
  }

  List<String> _getAvailableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => (currentYear - index).toString());
  }
}
