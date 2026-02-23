import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/emi_settlement_controller.dart';
import 'package:smartbecho/models/account%20management%20models/emi%20settlement/emi_settlement_model.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/utils/helper/string_formatter.dart';
import 'package:smartbecho/views/account%20management/components/emi%20settlement/add_emi_settlement.dart';
import 'package:smartbecho/views/account%20management/components/emi%20settlement/emi_settlement_analytics.dart';
import 'package:smartbecho/views/account%20management/widgets/emi_settlement_chart.dart';

class EmiSettlementPage extends StatefulWidget {
  const EmiSettlementPage({Key? key}) : super(key: key);

  @override
  State<EmiSettlementPage> createState() => _EmiSettlementPageState();
}

class _EmiSettlementPageState extends State<EmiSettlementPage>
    with TickerProviderStateMixin {
  final EmiSettlementController controller = Get.put(EmiSettlementController());

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
          Get.to(() => AddEmiSettlementPage());
        },
        backgroundColor: AppColors.primaryLight,
        label: Text(
          'Add EMI Settlement',
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
                                controller.settlements.isEmpty
                            ? const LinearProgressIndicator()
                            : const SizedBox.shrink(),
                  ),

                  // Header section
                  _headerSection(),

                  // Sticky filter button
                  _filterButton(context),

                  // Settlements grid
                  _settlements_Grid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _settlements_Grid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: Obx(() {
        if (controller.isLoading.value && controller.settlements.isEmpty) {
          return SliverToBoxAdapter(child: _buildInitialLoadingState());
        }

        if (controller.filteredSettlements.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        // SliverList implementation
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= controller.filteredSettlements.length) {
                return _buildLoadingMoreIndicator();
              }

              final settlement = controller.filteredSettlements[index];
              return _buildSettlementCard(settlement);
            },
            childCount:
                controller.filteredSettlements.length +
                (controller.hasMoreData.value && controller.isLoading.value
                    ? 1
                    : 0),
          ),
        );
      }),
    );
  }

  SliverPersistentHeader _filterButton(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        // child: _buildFilterButton(context, showSearch: true),
        child: CommonSearchBar(
          controller: controller.searchController,
          searchQuery: controller.searchQuery,
          hintText: 'Search settlements...',
          onChanged: controller.onSearchChanged,
          onFilter: () => _showFilterBottomSheet(context),
          clearFilters: () => controller.onSearchChanged(''),
        ),
        minHeight: 80,
        maxHeight: 80,
      ),
    );
  }

  SliverToBoxAdapter _headerSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'EMI Settlements',
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.filteredSettlements.length} Entries',
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
              'Loading settlements...',
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
                      hintText: 'Search settlements...',
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
              ] else ...[
                Icon(
                  Icons.filter_list,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    String filterText = 'All Settlements';
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
              // Charts Button
              //    Container(
              //     height: 40,
              //     width: 40,
              //     decoration: BoxDecoration(
              //       color: AppColors.primaryLight.withValues(alpha: 0.1),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(
              //         color: AppColors.primaryLight.withValues(alpha: 0.3),
              //       ),
              //     ),
              //     child: IconButton(
              //       onPressed: () =>   EmiSettlementAnalyticsBottomSheet.show(context),
              //       icon: Icon(
              //         Icons.analytics,
              //         size: 18,
              //         color: AppColors.primaryLight,
              //       ),
              //       tooltip: 'Filter & Sort',
              //     ),
              //   ),
              // SizedBox(width: 8),
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
                          value: controller.monthDisplayText,

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

  Widget _buildStyledDropdownForSheet4({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            hint: Text(
              hintText,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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

  // Compact Row Card Widget for EMI Settlement
  Widget _buildSettlementCard(EmiSettlement settlement) {
    final Color companyColor = controller.getCompanyColor(
      settlement.companyName,
    );

    return Card(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSettlementDetails(settlement),
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
                          Icon(
                            controller.getCompanyIcon(settlement.companyName),
                            color: companyColor,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EMI',
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
                          // Company Name + Status + Amount in one row
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
                                      settlement.confirmedBy,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Date Row
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
                                            settlement.formattedDate,
                                          ),

                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Compact Details Row - First Line
                                    Row(
                                      children: [
                                        //company
                                        Icon(
                                          Icons.business,
                                          size: 14,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            settlement.companyName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // const SizedBox(width: 12),

                                        // Shop ID
                                        // Icon(
                                        //   Icons.store_outlined,
                                        //   size: 14,
                                        //   color: const Color(0xFF9CA3AF),
                                        // ),
                                        // const SizedBox(width: 5),
                                        // Flexible(
                                        //   child: Text(
                                        //     settlement.shopId,
                                        //     style: const TextStyle(
                                        //       fontSize: 12,
                                        //       color: Color(0xFF6B7280),
                                        //       fontWeight: FontWeight.w500,
                                        //     ),
                                        //     maxLines: 1,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Status + Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Settled',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    settlement.formattedAmount,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // // Date Row
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.calendar_today_rounded,
                          //       size: 14,
                          //       color: const Color(0xFF9CA3AF),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       DateFormatterHelper.format(
                          //         settlement.formattedDate,
                          //       ),

                          //       style: const TextStyle(
                          //         fontSize: 12,
                          //         color: Color(0xFF6B7280),
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // // Compact Details Row - First Line
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
                          //         settlement.companyName,
                          //         style: const TextStyle(
                          //           fontSize: 12,
                          //           color: Color(0xFF6B7280),
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //       ),
                          //     ),

                          //     // const SizedBox(width: 12),

                          //     // Shop ID
                          //     // Icon(
                          //     //   Icons.store_outlined,
                          //     //   size: 14,
                          //     //   color: const Color(0xFF9CA3AF),
                          //     // ),
                          //     // const SizedBox(width: 5),
                          //     // Flexible(
                          //     //   child: Text(
                          //     //     settlement.shopId,
                          //     //     style: const TextStyle(
                          //     //       fontSize: 12,
                          //     //       color: Color(0xFF6B7280),
                          //     //       fontWeight: FontWeight.w500,
                          //     //     ),
                          //     //     maxLines: 1,
                          //     //     overflow: TextOverflow.ellipsis,
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                          // const SizedBox(height: 6),

                          // // Date Row
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.calendar_today_rounded,
                          //       size: 14,
                          //       color: const Color(0xFF9CA3AF),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       DateFormatterHelper.format(
                          //         settlement.formattedDate,
                          //       ),

                          //       style: const TextStyle(
                          //         fontSize: 12,
                          //         color: Color(0xFF6B7280),
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                const SizedBox(height: 6),

                Row(
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
                              StringFormatter.toTitle(settlement.confirmedBy),
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
              ],
            ),
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
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No settlements found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            if (controller.hasActiveFilters)
              ElevatedButton.icon(
                onPressed: () {
                  controller.clearFilters();
                  controller.searchController.clear();
                  controller.refreshData();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Reset Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
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
              ),
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

  void _showSettlementDetails(EmiSettlement settlement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: controller.getCompanyColor(
                                  settlement.companyName,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                controller.getCompanyIcon(
                                  settlement.companyName,
                                ),
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
                                    settlement.companyName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    settlement.formattedAmount,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Details
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Company',
                                settlement.companyName,
                              ),
                              _buildDetailRow(
                                'Amount',
                                settlement.formattedAmount,
                              ),
                              _buildDetailRow(
                                'Confirmed By',
                                settlement.confirmedBy,
                              ),
                              _buildDetailRow(
                                'Date',
                                DateFormatterHelper.format(
                                  settlement.formattedDate,
                                ),
                              ),
                              _buildDetailRow('Status', 'Settled'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChartModal() {
    controller.loadChartData();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Color(0xFF3B82F6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'EMI Settlement Analytics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            // Year Selector
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: DropdownButton<int>(
                                  value: controller.chartYear.value,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF3B82F6),
                                    size: 16,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  items: List.generate(5, (index) {
                                    final year =
                                        DateTime.now().year - 2 + index;
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }),
                                  onChanged: (year) {
                                    if (year != null) {
                                      controller.onChartYearChanged(year);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Chart Content
                      Expanded(
                        child: Obx(() {
                          if (controller.isChartLoading.value) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFF3B82F6),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading chart data...',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!controller.hasChartData) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Icon(
                                      Icons.bar_chart,
                                      size: 40,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No chart data available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No data found for ${controller.chartYear.value}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            child: EmiSettlementChartWidget(
                              title: 'Monthly EMI Settlement Chart',
                              data: controller.chartData,
                              screenWidth: MediaQuery.of(context).size.width,
                              screenHeight: MediaQuery.of(context).size.height,
                              isSmallScreen:
                                  MediaQuery.of(context).size.width < 600,
                              initialChartType: "barchart",
                              customColors: const [
                                Color(0xFF3B82F6),
                                Color(0xFF10B981),
                                Color(0xFF8B5CF6),
                                Color(0xFFF59E0B),
                                Color(0xFFEF4444),
                                Color(0xFF06B6D4),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
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
