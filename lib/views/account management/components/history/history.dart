import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartbecho/controllers/account%20management%20controller/view_history_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/views/account%20management/components/history/coustom_bottomSheet.dart';
import 'package:smartbecho/views/account%20management/components/history/viwe_history_card.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ViewHistoryController controller = Get.put(ViewHistoryController());

  @override
  void initState() {
    super.initState();
    controller.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    controller.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (controller.scrollController.position.pixels >=
            controller.scrollController.position.maxScrollExtent - 200 &&
        !controller.isLoadingTransactions.value &&
        controller.hasMoreData.value) {
      controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () async {
                controller.refreshTransactionListData();
              },
              child: SingleChildScrollView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildFilterSection(), _buildTransactionList()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GST Ledger History',
                  style: AppStyles.custom(
                    color: const Color(0xFF1A1A1A),
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${controller.monthDisplayText} ${controller.selectedTransactionYear.value}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.transactionList.length} Entries',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        CommonSearchBar(
          readOnly: true,
          controller: TextEditingController(),
          searchQuery: RxString(''),
          hintText: 'Filter Transactions',
          onFilter: () => _showFilterBottomSheet(),
          onTap: () => _showFilterBottomSheet(),
        ),
        const SizedBox(height: 12),
        _buildActiveFilters(),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final isFiltered =
          controller.selectedTransactionType.value != "ALL" ||
          controller.selectedMonth.value != DateTime.now().month ||
          controller.selectedTransactionYear.value != DateTime.now().year;

      if (!isFiltered) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Filters',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => controller.clearFilters(),
                  icon: const Icon(Icons.clear, size: 14),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (controller.selectedTransactionType.value != "ALL")
                  _buildFilterChip(
                    'Type: ${controller.selectedTransactionType.value}',
                    () {
                      controller.selectedTransactionType.value = "ALL";
                      controller.applyFilters();
                    },
                  ),
                if (controller.selectedMonth.value != DateTime.now().month)
                  _buildFilterChip('Month: ${controller.monthDisplayText}', () {
                    controller.selectedMonth.value = DateTime.now().month;
                    controller.applyFilters();
                  }),
                if (controller.selectedTransactionYear.value !=
                    DateTime.now().year)
                  _buildFilterChip(
                    'Year: ${controller.selectedTransactionYear.value}',
                    () {
                      controller.selectedTransactionYear.value =
                          DateTime.now().year;
                      controller.applyFilters();
                    },
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.isLoadingTransactions.value &&
          controller.transactionList.isEmpty) {
        return _buildInitialLoadingState();
      } else if (controller.transactionList.isEmpty) {
        return _buildEmptyState();
      } else {
        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactionList.length,
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),
              itemBuilder: (context, index) {
                final data = controller.transactionList[index];
                return ViewHistoryCard(data: data);
              },
            ),
            _buildPaginationIndicator(),
          ],
        );
      }
    });
  }

  Widget _buildInitialLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLottieLoader(),
            const SizedBox(height: 16),
            const Text(
              'Loading transactions...',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    return Obx(() {
      if (controller.isLoadingTransactions.value &&
          controller.transactionList.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Loading more...',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
            ],
          ),
        );
      } else if (!controller.hasMoreData.value &&
          controller.transactionList.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'All transactions loaded',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters to see more results',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.clearFilters(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showFilterBottomSheet() {
    return showCustomBottomSheet(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Transactions',
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
              value: controller.dateFilterType.value,
              items: ['Month', 'Year',],
              // if heve 'Custom' only all this is item list
              onChanged: (value) {
                if (value != null) {
                  controller.onDateFilterTypeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Conditional Date Inputs based on filter type
          Obx(() {
            // if (controller.dateFilterType.value == 'Custom') {
            //   // Custom Date Range
            //   return Row(
            //     children: [
            //       Obx(() {
            //         return Expanded(
            //           child: _buildDatePickerField(
            //             context: context,
            //             labelText: 'Start Date',
            //             hintText: 'dd/mm/yyyy',
            //             selectedDate: controller.startDateText.value,
            //             onTap: () => controller.selectCustomStartDate(context),
            //           ),
            //         );
            //       }),
            //       SizedBox(width: 12),
            //       Obx(() {
            //         return Expanded(
            //           child: _buildDatePickerField(
            //             context: context,
            //             labelText: 'End Date',
            //             hintText: 'dd/mm/yyyy',
            //             selectedDate: controller.endDateText.value,
            //             onTap: () => controller.selectCustomEndDate(context),
            //           ),
            //         );
            //       }),
            //     ],
            //   );
            // }
            //  else
              if (controller.dateFilterType.value == 'Year') {
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
                    controller.onChangedYear(value);

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
                          // controller.onMonthChanged(monthIndex);
                          controller.onMonthChanged(monthIndex);
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
                          controller.onChangedYear(value);

                          // controller.onYearChanged(int.parse(value));
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          }),

          // Row(
          //   children: [
          //     Expanded(
          //       child: buildStyledDropdown(
          //         labelText: "Year",
          //         hintText: "Select Year",
          //         value: controller.selectedTransactionYear.value.toString(),
          //         items: controller.years,
          //         onChanged: (v) {
          //           controller.onChangedYear(v!);
          //         },
          //       ),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: buildStyledDropdown(
          //         labelText: "Month",
          //         hintText: "Select Month",
          //         value: controller.monthDisplayText,
          //         items: controller.months,
          //         onChanged: (v) {
          //           controller.onMonthChanged(
          //             controller.months.indexOf(v!) + 1,
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildStyledDropdown(
                  labelText: "Transaction Type",
                  hintText: "Select Type",
                  value:
                      controller.selectedTransactionType.value == "ALL"
                          ? null
                          : controller.selectedTransactionType.value,
                  items: controller.transactionTypes,
                  onChanged: (v) {
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
                    controller.applyFilters();
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

  Widget _buildDatePickerField({
    required BuildContext context,
    required String labelText,
    required String hintText,
    required String selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate.isEmpty ? hintText : selectedDate,
                    style: TextStyle(
                      color:
                          selectedDate.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF374151),
                      fontSize: 14,
                      fontWeight:
                          selectedDate.isEmpty
                              ? FontWeight.w400
                              : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
