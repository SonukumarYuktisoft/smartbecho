import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/pay_bill_controller.dart';
import 'package:smartbecho/models/account%20management%20models/pay_bill_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_build_date_pickerfield.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/views/account%20management/components/paybill/add_bill.dart';
import 'package:url_launcher/url_launcher.dart';

class PayBillsPage extends StatefulWidget {
  @override
  _PayBillsPageState createState() => _PayBillsPageState();
}

class _PayBillsPageState extends State<PayBillsPage>
    with TickerProviderStateMixin {
  final PayBillsController controller = Get.put(PayBillsController());

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
          Get.to(() => AddPayBillPage());
        },
        backgroundColor: AppColors.primaryLight,
        label: Text(
          'Add Bill',
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
                                controller.payBills.isEmpty
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
                                  'Payment Records',
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
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${controller.filteredPayBills.length} Bills',
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
                        hintText: 'Search by company, person, or purpose...',
                        onChanged: controller.onSearchChanged,
                        onFilter: () => _showFilterBottomSheet(context),
                        clearFilters: () => controller.onSearchChanged(''),
                      ),
                      minHeight: 80,
                      maxHeight: 80,
                    ),
                  ),

                  // Bills grid
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.payBills.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildInitialLoadingState(),
                        );
                      }

                      if (controller.filteredPayBills.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmptyState());
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= controller.filteredPayBills.length) {
                              return _buildLoadingMoreIndicator();
                            }

                            final bill = controller.filteredPayBills[index];
                            return _buildPayBillCard(bill);
                          },
                          childCount:
                              controller.filteredPayBills.length +
                              (controller.hasMoreData.value &&
                                      controller.isLoading.value
                                  ? 1
                                  : 0),
                        ),
                        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 2,
                        //   childAspectRatio: 0.75,
                        //   crossAxisSpacing: 12,
                        //   mainAxisSpacing: 12,
                        // ),
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
              'Loading payment bills...',
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
                      hintText: 'Search by company, person, or purpose...',
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
                // SizedBox(width: 8),
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
                //     onPressed: () =>   PayBillAnalyticsBottomSheet.show(context),
                //     icon: Icon(
                //       Icons.analytics,
                //       size: 18,
                //       color: AppColors.primaryLight,
                //     ),
                //     tooltip: 'Filter & Sort',
                //   ),
                // ),
                SizedBox(width: 4),
              ] else ...[
                Icon(
                  Icons.filter_list,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    String filterText = 'All Bills';
                    List<String> activeFilters = [];

                    if (controller.selectedCompany.value != 'All') {
                      activeFilters.add(controller.selectedCompany.value);
                    }

                    if (controller.selectedMonth.value !=
                            DateTime.now().month ||
                        controller.selectedYear.value != DateTime.now().year) {
                      activeFilters.add(
                        '${controller.monthDisplayText} ${controller.selectedYear.value}',
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
                      controller.companies
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
                      Obx(() {
                        return Expanded(
                          child: buildDatePickerField(
                            context: context,
                            labelText: 'Start Date',
                            hintText: 'dd/mm/yyyy',
                            selectedDate: controller.startDateText.value,
                            onTap:
                                () => controller.selectCustomStartDate(context),
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
                            selectedDate: controller.endDateText.value,
                            onTap:
                                () => controller.selectCustomEndDate(context),
                          ),
                        );
                      }),
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
                      //  onPressed: () {
                      //       controller.clearFilters();
                      //       controller.searchController.clear();
                      //     },
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

  // void _resetFilters() {
  //   controller.selectedCompany.value = 'All';
  //   controller.onMonthChanged(DateTime.now().month);
  //   controller.onYearChanged(DateTime.now().year);
  //   controller.searchController.clear();
  //   controller.onSearchChanged('');
  //   Get.back();
  // }
  Widget _buildPayBillCard(PayBill bill) {
    final Color companyColor = controller.getCompanyColor(bill.company);
    final Color purposeColor = controller.getPurposeColor(bill.purpose);

    return Card(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPayBillDetails(bill),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // ---------------------- LEFT ICON BOX ----------------------
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
                            'BILL',
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

                    // // ---------------------- MIDDLE TEXT AREA ----------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company Name + Purpose Tag + Amount in one row
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
                                      bill.paidToPerson,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      // "Paid By ${bill.company}",
                                
                                      // bill.company,
                                      bill.purpose,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Purpose Tag - Now moved to top right near amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (bill.purpose.isNotEmpty)
                                    // Container(
                                    //   // margin: const EdgeInsets.only(left: 8),
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 8,
                                    //     vertical: 3,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: purposeColor.withOpacity(0.1),
                                    //     borderRadius: BorderRadius.circular(6),
                                    //     border: Border.all(
                                    //       color: purposeColor.withOpacity(0.2),
                                    //       width: 0.7,
                                    //     ),
                                    //   ),
                                    //   child: Text(
                                    //     bill.purpose,
                                    //     style: TextStyle(
                                    //       color: purposeColor,
                                    //       fontSize: 10,
                                    //       fontWeight: FontWeight.w600,
                                    //     ),
                                    //   ),
                                    // ),
                                    AppFormatterHelper.formatAmountWidget(
                                      value: bill.amount,
                                      showTypeOnly: true,
                                    ),
                                  AppFormatterHelper.formatAmountWidget(
                                    value: bill.amount,
                                    showRupee: true,
                                  ),

                                  //          Container(
                                  //   padding: const EdgeInsets.all(4),
                                  //   decoration: BoxDecoration(
                                  //     color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  //     borderRadius: BorderRadius.circular(4),
                                  //   ),
                                  //   child: Icon(
                                  //     Icons.chevron_right,
                                  //     size: 16,
                                  //     color: const Color(0xFF3B82F6),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),

                          // const SizedBox(height: 10),

                          // Compact Details Row
                          Row(
                            children: [
                              // // Paid To Person
                              // Icon(
                              //   Icons.person_outline,
                              //   size: 14,
                              //   color: const Color(0xFF9CA3AF),
                              // ),
                              // const SizedBox(width: 5),
                              // Flexible(
                              //   child: Text(
                              //     bill.paidToPerson,
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
                                // DateFormatH('dd MMM').format(bill.formattedDate),
                                DateFormatterHelper.format(bill.formattedDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Payment Mode
                              Icon(
                                Icons.payment_rounded,
                                size: 12,
                                color: const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  bill.paymentMode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: const Color(
                              //       0xFFF98117,
                              //     ).withOpacity(0.1),
                              //     borderRadius: BorderRadius.circular(50),
                              //   ),
                              //   child: const Icon(
                              //     Icons.chevron_right,
                              //     size: 20,
                              //     color: Color(0xFFF98117),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Compact Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // // Paid To Person
                    // Icon(
                    //   Icons.person_outline,
                    //   size: 14,
                    //   color: const Color(0xFF9CA3AF),
                    // ),
                    // const SizedBox(width: 5),
                    // Flexible(
                    //   child: Text(
                    //     bill.paidToPerson,
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
                    // Expanded(
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.calendar_today_rounded,
                    //         size: 14,
                    //         color: const Color(0xFF9CA3AF),
                    //       ),
                    //       const SizedBox(width: 5),
                    //       Text(
                    //         // DateFormatH('dd MMM').format(bill.formattedDate),
                    //         DateFormatterHelper.format(bill.formattedDate),
                    //         style: const TextStyle(
                    //           fontSize: 12,
                    //           color: Color(0xFF6B7280),
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),

                    //       const SizedBox(width: 12),

                    //       // Payment Mode
                    //       Icon(
                    //         Icons.payment_rounded,
                    //         size: 12,
                    //         color: const Color(0xFF9CA3AF),
                    //       ),
                    //       const SizedBox(width: 5),
                    //       Flexible(
                    //         child: Text(
                    //           bill.paymentMode,
                    //           style: const TextStyle(
                    //             fontSize: 10,
                    //             color: Color(0xFF6B7280),
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
 
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
        ),
      ),
    );
  }

  // Helper Widget for compact detail items (Reusable)
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6B7280),
            size: 12,
          ), // Reduced icon size
          const SizedBox(width: 4),
          // Use Expanded here to ensure the combined label and value don't overflow
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 9, // Reduced font size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 9.5, // Reduced font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPayBillDetails(PayBill bill) {
    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: true,

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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.getCompanyColor(bill.company),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Bill ID: #${bill.id}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha: 0.1),
                    const Color(0xFF10B981).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF059669).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount Paid',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppFormatterHelper.formatAmountWidget(
                    value: bill.amount,
                    showRupee: true,
                    compact: false,
                    style: TextStyle(
                      // color: Color(0xFF059669),
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Company', bill.company, Icons.business),
                  _buildDetailRow(
                    'Purpose',
                    bill.purpose,
                    Icons.category_outlined,
                  ),
                  _buildDetailRow(
                    'Paid To',
                    bill.paidToPerson,
                    Icons.person_outline,
                  ),
                  _buildDetailRow(
                    'Paid By',
                    bill.paidBy,
                    Icons.account_circle_outlined,
                  ),
                  _buildDetailRow(
                    'Payment Mode',
                    bill.paymentMode,
                    Icons.payment_outlined,
                  ),
                  _buildDetailRow(
                    'Date',
                    DateFormatterHelper.format(bill.formattedDate),

                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),

            // Description Section
            if (bill.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notes_outlined,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Description',
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bill.description,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // File Attachment
            if (bill.uploadedFileUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(bill.uploadedFileUrl);
                  if (bill.uploadedFileUrl.isNotEmpty) {
                    await launchUrl(url);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open file',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.attach_file_outlined,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attachment Available',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tap to view uploaded file',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton.icon(
            //         onPressed: () {
            //           Navigator.of(context).pop();
            //         },
            //         icon: const Icon(Icons.share_outlined, size: 18),
            //         label: const Text('Share'),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: const Color(0xFF6B7280),
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           elevation: 0,
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: ElevatedButton.icon(
            //         onPressed: () {
            //           Navigator.of(context).pop();
            //         },
            //         icon: const Icon(Icons.edit_outlined, size: 18),
            //         label: const Text('Edit'),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: const Color(0xFF3B82F6),
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           elevation: 0,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.hasActiveFilters
                  ? 'No Bills Found'
                  : 'No Payment Bills Available',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.hasActiveFilters
                  ? 'Try adjusting your search criteria or filters to find what you\'re looking for.'
                  : 'Payment bills will appear here once they are added to the system.',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            if (controller.hasActiveFilters)
              ElevatedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text(
                  'Clear Filters',
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
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
