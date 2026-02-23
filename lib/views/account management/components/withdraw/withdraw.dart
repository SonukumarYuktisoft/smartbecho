import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/withdraw_history_controller.dart';
import 'package:smartbecho/models/account%20management%20models/withdraw_history_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/utils/helper/string_formatter.dart';
import 'package:smartbecho/views/account%20management/components/withdraw/add_withdraw.dart';
import 'package:smartbecho/views/account%20management/components/withdraw/withdrawal_analytics.dart';

class WithdrawHistoryPage extends StatefulWidget {
  @override
  _WithdrawHistoryPageState createState() => _WithdrawHistoryPageState();
}

class _WithdrawHistoryPageState extends State<WithdrawHistoryPage>
    with TickerProviderStateMixin {
  final WithdrawController controller = Get.put(WithdrawController());

  @override
  void initState() {
    super.initState();
    controller.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onScroll() {
    if (controller.scrollController.position.pixels >=
        controller.scrollController.position.maxScrollExtent - 200) {
      controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => AddWithdrawPage());
        },
        backgroundColor: AppColors.primaryLight,
        label: Text(
          'Add Withdraw',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(
          () => AppRefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200 &&
                    !controller.isLoading.value) {
                  controller.loadNextPage();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Loading Bar
                  SliverToBoxAdapter(
                    child:
                        controller.isLoading.value &&
                                controller.withdrawals.isEmpty
                            ? const LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              color: Color(0xFF1E293B),
                            )
                            : const SizedBox.shrink(),
                  ),

                  // Header section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Withdraw History',
                                  style: AppStyles.custom(
                                    color: const Color(0xFF1A1A1A),
                                    size: 20,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    '${controller.monthDisplayText} ${controller.selectedYear.value}',
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
                            () => Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${controller.filteredWithdrawals.length} Withdrawals',
                                        style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // const Text(
                                      //   'Withdrawals',
                                      //   style: TextStyle(
                                      //     color: Color(0xFFEF4444),
                                      //     fontSize: 10,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sticky filter button
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyHeaderDelegate(
                      // child: _buildFilterButton(context, showSearch: true),
                      child: CommonSearchBar(
                        controller: controller.searchController,
                        searchQuery: controller.searchQuery,
                        hintText: 'Search withdrawals...',
                        onChanged: controller.onSearchChanged,
                        onFilter: () => _showFilterBottomSheet(context),
                        clearFilters: () => controller.onSearchChanged(''),
                      ),
                      minHeight: 80,
                      maxHeight: 80,
                    ),
                  ),

                  // Withdrawals grid
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.withdrawals.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildInitialLoadingState(),
                        );
                      }

                      if (controller.filteredWithdrawals.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmptyState());
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >=
                                controller.filteredWithdrawals.length) {
                              return _buildLoadingMoreIndicator();
                            }

                            final withdrawal =
                                controller.filteredWithdrawals[index];
                            return _buildWithdrawCard(withdrawal);
                          },
                          childCount:
                              controller.filteredWithdrawals.length +
                              (controller.hasMoreData.value &&
                                      controller.isLoading.value
                                  ? 1
                                  : 0),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
              'Loading withdrawals...',
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

  Widget _buildFilterButton(BuildContext context, {bool showSearch = false}) {
    return Container(
      margin: EdgeInsets.fromLTRB(4, 8, 16, 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (showSearch) ...[
                Expanded(
                  child: TextFormField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (controller.searchController.text == value) {
                          controller.onSearchChanged(value);
                        }
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      hintText: 'Search withdrawals...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.onSearchChanged('');
                            },
                          );
                        }
                        return SizedBox.shrink();
                      }),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryLight,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Container(
                //   height: 40,
                //   width: 40,
                //   decoration: BoxDecoration(
                //     color: AppColors.primaryLight.withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(
                //       color: AppColors.primaryLight.withValues(alpha: 0.3),
                //     ),
                //   ),
                //   child: IconButton(
                //     onPressed: () =>   WithdrawalAnalyticsBottomSheet.show(context),
                //     icon: Icon(
                //       Icons.analytics,
                //       size: 18,
                //       color: AppColors.primaryLight,
                //     ),
                //     tooltip: 'Filter & Sort',
                //   ),
                // ),
                // SizedBox(width: 4),
              ] else ...[
                Icon(
                  Icons.filter_list,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    String filterText = 'All Withdrawals';
                    List<String> activeFilters = [];

                    if (controller.selectedMonth.value !=
                            DateTime.now().month ||
                        controller.selectedYear.value != DateTime.now().year) {
                      activeFilters.add(
                        '${controller.selectedMonth.value}/${controller.selectedYear.value}',
                      );
                    }

                    if (activeFilters.isNotEmpty) {
                      filterText = activeFilters.join(' • ');
                    }

                    return Text(
                      filterText,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                SizedBox(width: 8),
              ],
              // Filter Button
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: Icon(
                    Icons.tune,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                  tooltip: 'Filter & Sort',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => controller.refreshData(),
                    icon: Obx(
                      () =>
                          controller.isLoading.value
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryLight,
                                ),
                              )
                              : Icon(
                                Icons.refresh,
                                size: 18,
                                color: AppColors.primaryLight,
                              ),
                    ),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Date Filter Type Selection
              Obx(
                () => buildStyledDropdown(
                  labelText: 'Date Filter',
                  hintText: 'Select Type',
                  value: controller.dateFilterType.value,
                  items: ['Month', 'Year', 'Custom'],
                  onChanged: (value) {
                    if (value != null) {
                      controller.onDateFilterTypeChanged(value);
                    }
                  },
                ),
              ),

              SizedBox(height: 16),

              // Conditional Date Inputs based on filter type
              Obx(() {
                if (controller.dateFilterType.value == 'Custom') {
                  // Custom Date Range
                  return Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          context: context,
                          labelText: 'Start Date',
                          hintText: 'dd/mm/yyyy',
                          selectedDate: controller.startDateText.value,
                          onTap:
                              () => controller.selectCustomStartDate(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePickerField(
                          context: context,
                          labelText: 'End Date',
                          hintText: 'dd/mm/yyyy',
                          selectedDate: controller.endDateText.value,
                          onTap: () => controller.selectCustomEndDate(context),
                        ),
                      ),
                    ],
                  );
                } else if (controller.dateFilterType.value == 'Year') {
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
                        controller.onYearChanged(int.parse(value));
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
                              controller.onYearChanged(int.parse(value));
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      // onPressed: () {
                      //     controller.clearFilters();
                      //     controller.searchController.clear();
                      //   },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: BorderSide(color: AppColors.primaryLight),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Add this helper method for date picker fields
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

  // Update _resetFilters method
  void _resetFilters() {
    controller.dateFilterType.value = 'Month';
    controller.onMonthChanged(DateTime.now().month);
    controller.onYearChanged(DateTime.now().year);
    controller.customStartDate.value = null;
    controller.customEndDate.value = null;
    controller.searchController.clear();
    controller.startDateController.clear();
    controller.endDateController.clear();
    controller.onSearchChanged('');
    controller.startDateText.value = '';
    controller.endDateText.value = '';
    controller.searchController.clear();
    Get.back();
  }
  // SliverList implementation

  // Compact Row Card Widget for Withdrawal
  Widget _buildWithdrawCard(Withdraw withdrawal) {
    final Color withdrawColor = controller.getWithdrawnByColor(
      withdrawal.withdrawnBy,
    );
    final Color purposeColor = controller.getPurposeColor(withdrawal.purpose);

    return Card(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWithdrawDetails(withdrawal),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------- LEFT ICON BOX ----------------------
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: withdrawColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: withdrawColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: withdrawColor, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            'WDL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: withdrawColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ---------------------- MIDDLE TEXT AREA ----------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Person Name + Purpose Tag + Amount in one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Person Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,

                                  children: [
                                    Text(
                                      withdrawal.withdrawnBy,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (withdrawal.purpose.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 4,
                                          top: 4,
                                        ),
                                        // padding: const EdgeInsets.symmetric(
                                        //   horizontal: 8,
                                        //   vertical: 3,
                                        // ),
                                        // decoration: BoxDecoration(
                                        //   color: purposeColor.withOpacity(0.1),
                                        //   borderRadius: BorderRadius.circular(6),
                                        //   border: Border.all(
                                        //     color: purposeColor.withOpacity(0.2),
                                        //     width: 0.7,
                                        //   ),
                                        // ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,

                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getPurposeIcon(
                                                withdrawal.purpose,
                                              ),
                                              size: 15,
                                              color: purposeColor,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              withdrawal.purpose,
                                              style: TextStyle(
                                                color: purposeColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Purpose Tag + Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // if (withdrawal.purpose.isNotEmpty)
                                  //   Container(
                                  //     margin: const EdgeInsets.only(bottom: 4),
                                  //     padding: const EdgeInsets.symmetric(
                                  //       horizontal: 8,
                                  //       vertical: 3,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: purposeColor.withOpacity(0.1),
                                  //       borderRadius: BorderRadius.circular(6),
                                  //       border: Border.all(
                                  //         color: purposeColor.withOpacity(0.2),
                                  //         width: 0.7,
                                  //       ),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisSize: MainAxisSize.min,
                                  //       children: [
                                  //         Icon(
                                  //           _getPurposeIcon(withdrawal.purpose),
                                  //           size: 10,
                                  //           color: purposeColor,
                                  //         ),
                                  //         const SizedBox(width: 3),
                                  //         Text(
                                  //           withdrawal.purpose,
                                  //           style: TextStyle(
                                  //             color: purposeColor,
                                  //             fontSize: 10,
                                  //             fontWeight: FontWeight.w600,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  AppFormatterHelper.formatAmountWidget(
                                    value: withdrawal.formattedAmount,
                                    showTypeOnly: true,
                                    reverseValue: true,
                                  ),
                                  AppFormatterHelper.formatAmountWidget(
                                    value: withdrawal.formattedAmount,

                                    showRupee: true,
                                    reverseValue: true,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Compact Details Row
                          Row(
                            children: [
                              // // Payment Mode
                              // Icon(
                              //   _getPaymentModeIcon(withdrawal.paymentMode),
                              //   size: 14,
                              //   color: controller.getPaymentModeColor(
                              //     withdrawal.paymentMode,
                              //   ),
                              // ),
                              // const SizedBox(width: 5),
                              // Flexible(
                              //   child: Text(
                              //     withdrawal.paymentMode,
                              //     style: const TextStyle(
                              //       fontSize: 12,
                              //       color: Color(0xFF6B7280),
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //     maxLines: 1,
                              //     overflow: TextOverflow.ellipsis,
                              //   ),
                              // ),

                              // const SizedBox(width: 12),

                              // Date
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                withdrawal.formattedDate.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Notes (if available)
                          if (withdrawal.notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.notes_outlined,
                                  size: 14,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    withdrawal.notes,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // const SizedBox(width: 12),

                    // // ---------------------- RIGHT CHEVRON SECTION ----------------------
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     const SizedBox(height: 6),
                    //     Container(
                    //       padding: const EdgeInsets.all(4),
                    //       decoration: BoxDecoration(
                    //         color: const Color(0xFF3B82F6).withOpacity(0.1),
                    //         borderRadius: BorderRadius.circular(4),
                    //       ),
                    //       child: const Icon(
                    //         Icons.chevron_right,
                    //         size: 16,
                    //         color: Color(0xFF3B82F6),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Payment Mode ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            TextSpan(
                              text:  "${StringFormatter.toTitle(withdrawal.paymentMode)} ",
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFFF98117),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Text("${StringFormatter.toTitle(withdrawal.paymentMode)} Withdrawal",style: TextStyle(fontSize: 15, color: const Color(0xFFF98117), fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          //         Text("View Details",style: TextStyle(fontSize: 15, color: const Color(0xFFF98117), fontWeight: FontWeight.bold),),
                          // const SizedBox(width: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF98117).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Color(0xFFF98117),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods (add these if not present)
  IconData _getPurposeIcon(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'salary':
        return Icons.account_balance_wallet;
      case 'expense':
        return Icons.shopping_cart;
      case 'investment':
        return Icons.trending_up;
      case 'personal':
        return Icons.person;
      default:
        return Icons.category;
    }
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'upi':
        return Icons.qr_code;
      case 'bank transfer':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 50,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.hasActiveFilters
                  ? 'No withdrawals found'
                  : 'No withdrawals yet',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.hasActiveFilters
                  ? 'Try adjusting your filters to find what you\'re looking for'
                  : 'Withdrawals will appear here once they are recorded',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (controller.hasActiveFilters) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.clearFilters();
                  controller.searchController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading more...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDetails(Withdraw withdrawal) {
    Get.bottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      ignoreSafeArea: true,
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: controller.getWithdrawnByColor(
                      withdrawal.withdrawnBy,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdrawal Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        withdrawal.formattedDate.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount Withdrawn',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppFormatterHelper.formatAmountWidget(
                    value: withdrawal.formattedAmount,
                    showRupee: true,
                    reverseValue: true,
                    compact: false,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            _buildDetailRow(
              'Withdrawn By',
              withdrawal.withdrawnBy,
              Icons.person,
            ),
            _buildDetailRow(
              'Purpose',
              withdrawal.purpose,
              _getPurposeIcon(withdrawal.purpose),
            ),
            _buildDetailRow(
              'Payment Mode',
              withdrawal.paymentMode,
              _getPaymentModeIcon(withdrawal.paymentMode),
            ),
            _buildDetailRow(
              'Date',
              withdrawal.formattedDate.toString(),
              Icons.calendar_today,
            ),

            if (withdrawal.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  withdrawal.notes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Header Delegate Class
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
