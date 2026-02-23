import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/commission_received_controller.dart';
import 'package:smartbecho/models/account%20management%20models/commission_received_model.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/utils/helper/string_formatter.dart';
import 'package:smartbecho/views/account%20management/components/commision%20received/add_commision_record.dart';
import 'package:smartbecho/views/account%20management/components/commision%20received/commision_recieved_analytics.dart';
import 'package:url_launcher/url_launcher.dart';

class CommissionReceivedPage extends StatefulWidget {
  const CommissionReceivedPage({Key? key}) : super(key: key);

  @override
  State<CommissionReceivedPage> createState() => _CommissionReceivedPageState();
}

class _CommissionReceivedPageState extends State<CommissionReceivedPage>
    with TickerProviderStateMixin {
  final CommissionReceivedController controller = Get.put(
    CommissionReceivedController(),
  );

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
          Get.to(() => AddCommissionPage());
        },
        backgroundColor: AppColors.primaryLight,
        label: Text(
          'Add Commission',
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
                                controller.commissions.isEmpty
                            ? const LinearProgressIndicator()
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Commission Received',
                                  style: TextStyle(
                                    color: const Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
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
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${controller.filteredCommissions.length} Entries',
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
                        hintText: 'Search commissions...',
                        onChanged: controller.onSearchChanged,
                        onFilter: () => _showFilterBottomSheet(context),
                        clearFilters: () => controller.onSearchChanged(''),
                      ),
                      minHeight: 80,
                      maxHeight: 80,
                    ),
                  ),

                  // Commissions grid
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.commissions.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildInitialLoadingState(),
                        );
                      }

                      if (controller.filteredCommissions.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmptyState());
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >=
                                controller.filteredCommissions.length) {
                              return _buildLoadingMoreIndicator();
                            }

                            final commission =
                                controller.filteredCommissions[index];
                            return _buildCommissionCard(commission);
                          },
                          childCount:
                              controller.filteredCommissions.length +
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
              'Loading commissions...',
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
                      hintText: 'Search commissions...',
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
                //  Container(
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
                //     onPressed: () =>   CommissionReceivedAnalyticsBottomSheet.show(context),
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
                    String filterText = 'All Commissions';
                    List<String> activeFilters = [];

                    if (controller.selectedCompany.value != 'All') {
                      activeFilters.add(controller.selectedCompany.value);
                    }

                    if (controller.selectedMonth.value !=
                            DateTime.now().month ||
                        controller.selectedYear.value != DateTime.now().year) {
                      activeFilters.add(
                        '${controller.months[controller.selectedMonth.value - 1]} ${controller.selectedYear.value}',
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

              // Company Selection
              Obx(
                () => buildStyledDropdown(
                  labelText: 'Company',
                  hintText: 'All Companies',
                  value:
                      controller.selectedCompany.value == 'All'
                          ? null
                          : controller.selectedCompany.value,
                  items:
                      controller.companyOptions
                          .where((item) => item != 'All')
                          .toList(),
                  onChanged:
                      (value) => controller.onCompanyChanged(value ?? 'All'),
                ),
              ),

              SizedBox(height: 16),

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
                      final year = DateTime.now().year - 2 + index;
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
                          value:
                              controller.months[controller.selectedMonth.value -
                                  1],
                          items: controller.months,
                          onChanged: (value) {
                            if (value != null) {
                              controller.onMonthChanged(
                                controller.months.indexOf(value) + 1,
                              );
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
                            final year = DateTime.now().year - 2 + index;
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
                      //   controller.clearFilters();
                      //   controller.searchController.clear();
                      // },
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
    controller.selectedCompany.value = 'All';
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

  // Compact Row Card Widget for Commission
  Widget _buildCommissionCard(Commission commission) {
    final Color companyColor = controller.getCompanyColor(commission.company);

    return Card(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCommissionDetails(commission),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------- LEFT ICON BOX ----------------------
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: companyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: companyColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business, color: companyColor, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            'COM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: companyColor,
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
                          // Company Name + Amount in one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commission.company,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    // Date
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          DateFormatterHelper.format(
                                            commission.formattedDate,
                                          ),
                                
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Payment Mode
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payment_rounded,
                                          size: 12,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          commission.receivedMode,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  AppFormatterHelper.formatAmountWidget(
                                    value: commission.amount,
                                    showTypeOnly: true,
                                  ),
                                  AppFormatterHelper.formatAmountWidget(
                                    value: commission.amount,
                                    showRupee: true,
                                  ),
                                ],
                              ),
                              // // Amount
                              // Text(
                              //   commission.formattedAmount,
                              //   style: const TextStyle(
                              //     fontSize: 17,
                              //     fontWeight: FontWeight.w700,
                              //     color: Color(0xFF10B981),
                              //     letterSpacing: -0.3,
                              //   ),
                              // ),
                            ],
                          ),

                          // const SizedBox(height: 10),

                          // // Compact Details Row
                          // Row(
                          //   children: [
                          //     // Confirmed By
                          //     Icon(
                          //       Icons.person_outline,
                          //       size: 14,
                          //       color: const Color(0xFF9CA3AF),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Flexible(
                          //       child: Text(
                          //         commission.confirmedBy,
                          //         style: const TextStyle(
                          //           fontSize: 12,
                          //           color: Color(0xFF6B7280),
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //       ),
                          //     ),

                          //     const SizedBox(width: 12),

                          //     // Date
                          //     Icon(
                          //       Icons.calendar_today_rounded,
                          //       size: 14,
                          //       color: const Color(0xFF9CA3AF),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       DateFormatterHelper.format(
                          //         commission.formattedDate,
                          //       ),

                          //       style: const TextStyle(
                          //         fontSize: 12,
                          //         color: Color(0xFF6B7280),
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),

                          //     const SizedBox(width: 12),

                          //     // Payment Mode
                          //     Icon(
                          //       Icons.payment_rounded,
                          //       size: 12,
                          //       color: const Color(0xFF9CA3AF),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Flexible(
                          //       child: Text(
                          //         commission.receivedMode,
                          //         style: const TextStyle(
                          //           fontSize: 10,
                          //           color: Color(0xFF6B7280),
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),

                    // const SizedBox(width: 12),

                    // // ---------------------- RIGHT ATTACHMENT/CHEVRON SECTION ----------------------
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     const SizedBox(height: 6),
                    //     Container(
                    //       padding: const EdgeInsets.all(4),
                    //       decoration: BoxDecoration(
                    //         color: (commission.uploadedFileUrl != null &&
                    //                 commission.uploadedFileUrl!.isNotEmpty)
                    //             ? const Color(0xFF10B981).withOpacity(0.1)
                    //             : const Color(0xFF3B82F6).withOpacity(0.1),
                    //         borderRadius: BorderRadius.circular(4),
                    //       ),
                    //       child: Icon(
                    //         (commission.uploadedFileUrl != null &&
                    //          commission.uploadedFileUrl!.isNotEmpty)
                    //             ? Icons.attach_file
                    //             : Icons.chevron_right,
                    //         size: 16,
                    //         color: (commission.uploadedFileUrl != null &&
                    //                 commission.uploadedFileUrl!.isNotEmpty)
                    //             ? const Color(0xFF10B981)
                    //             : const Color(0xFF3B82F6),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            "Confirmed By ",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),

                          Expanded(
                            child: Text(
                              StringFormatter.toTitle(commission.confirmedBy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFF98117),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// RIGHT ICON
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF98117).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Color(0xFFF98117),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              child: Icon(Icons.money_off, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Text(
              controller.hasActiveFilters
                  ? 'No commissions found'
                  : 'No Commission Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.hasActiveFilters
                  ? 'Try adjusting your filters to find what you\'re looking for'
                  : 'Commission records will appear here once they are added',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (controller.hasActiveFilters) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.clearFilters(),
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

  void _showCommissionDetails(Commission commission) {
    Get.bottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      ignoreSafeArea: true,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: controller.getCompanyColor(commission.company),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business,
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
                        'Commission Details',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Commission ID: #${commission.id}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.1),
                    const Color(0xFF059669).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Commission Amount',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppFormatterHelper.formatAmountWidget(
                    value: commission.amount,
                    showRupee: true,
                    compact: false,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Text(
                  //   commission.formattedAmount,
                  //   style: const TextStyle(
                  //     color: Color(0xFF10B981),
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Details Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Company',
                    commission.company,

                    Icons.business,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Confirmed By',
                    commission.confirmedBy,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Payment Mode',
                    commission.receivedMode,
                    Icons.payment_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Date',
                    DateFormatterHelper.format(commission.formattedDate),

                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),

            // Description Section
            if (commission.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notes_outlined,
                          color: Color(0xFF6B7280),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      commission.description,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // File Attachment
            if (commission.uploadedFileUrl != null &&
                commission.uploadedFileUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  if (commission.uploadedFileUrl != null) {
                    final url = Uri.parse(commission.uploadedFileUrl!);
                    if (commission.uploadedFileUrl!.isNotEmpty) {
                      await launchUrl(url);
                    } else {
                      Get.snackbar(
                        'Error',
                        'Could not open file',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.attach_file_outlined,
                          color: Color(0xFF3B82F6),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attachment Available',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tap to view uploaded file',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
