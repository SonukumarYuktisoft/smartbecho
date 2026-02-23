import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/gst_ledger_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/charts/fl_charts.dart';


class GstLedgerAnalyticsBottomSheet extends StatefulWidget {
  const GstLedgerAnalyticsBottomSheet({Key? key}) : super(key: key);

  @override
  State<GstLedgerAnalyticsBottomSheet> createState() => 
      _GstLedgerAnalyticsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GstLedgerAnalyticsBottomSheet(),
    );
  }
}

class _GstLedgerAnalyticsBottomSheetState 
    extends State<GstLedgerAnalyticsBottomSheet> {
  final GstLedgerController controller = Get.find<GstLedgerController>();
  
  final RxBool isFiltersVisible = true.obs;
  final RxString currentView = 'Monthly'.obs;
  final RxString selectedEntityName = 'All'.obs;
  final RxString selectedTransactionType = 'All'.obs;
  final RxString selectedHsnCode = 'All'.obs;
  final RxString selectedYear = DateTime.now().year.toString().obs;
  final RxString dateFilterType = 'Month'.obs;
  final RxString selectedMonth = DateTime.now().month.toString().obs;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    if (dateFilterType.value == 'Month') {
      await controller.loadMonthlySummary(
        year: selectedYear.value,
        entityName: selectedEntityName.value,
        transactionType: selectedTransactionType.value,
        hsnCode: selectedHsnCode.value,
      );
    } else {
      if (controller.startDateController.text.isNotEmpty && 
          controller.endDateController.text.isNotEmpty) {
        await controller.loadMonthlySummary(
          startDate: controller.startDateController.text,
          endDate: controller.endDateController.text,
          entityName: selectedEntityName.value,
          transactionType: selectedTransactionType.value,
          hsnCode: selectedHsnCode.value,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.primaryLight, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GST Ledger Analytics',
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
          Expanded(
            child: Obx(() {
              if (controller.isChartLoading.value && controller.monthlyChartData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primaryLight),
                      const SizedBox(height: 16),
                      Text('Loading analytics...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                );
              }

              return FeatureVisitor(
                featureKey: FeatureKeys.GST.getGstLedgerMonthlySummary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildViewToggle(),
                      const SizedBox(height: 20),
                      _buildFiltersSection(),
                      const SizedBox(height: 20),
                      _buildChartSection(),
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
          _buildToggleButton('By Entity'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label) {
    return Expanded(
      child: Obx(() {
        final isSelected = currentView.value == label;
        return GestureDetector(
          onTap: () => currentView.value = label,
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

  Widget _buildFiltersSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.filter_list, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text('Filters', style: AppStyles.custom(color: const Color(0xFF1A1A1A), size: 16, weight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            Obx(() => IconButton(
              icon: Icon(
                isFiltersVisible.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.primaryLight,
              ),
              onPressed: () => isFiltersVisible.toggle(),
            )),
          ],
        ),
        Obx(() => isFiltersVisible.value
            ? Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildDateFilterSection(),
                    const SizedBox(height: 12),
                    _buildOtherFiltersSection(),
                  ],
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildDateFilterSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Obx(() => _buildDateTypeButton('Month'))),
            const SizedBox(width: 12),
            Expanded(child: Obx(() => _buildDateTypeButton('Custom'))),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (dateFilterType.value == 'Month') {
            return Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    label: 'Month',
                    value: selectedMonth.value,
                    items: List.generate(12, (i) => (i + 1).toString()),
                    onChanged: (v) {
                      if (v != null) selectedMonth.value = v;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown(
                    label: 'Year',
                    value: selectedYear.value,
                    items: _getAvailableYears(),
                    onChanged: (v) {
                      if (v != null) {
                        selectedYear.value = v;
                        _loadChartData();
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Start Date',
                    controller: controller.startDateController,
                    onTap: () async {
                      await controller.selectStartDate(context);
                      if (controller.startDateController.text.isNotEmpty &&
                          controller.endDateController.text.isNotEmpty) {
                        _loadChartData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    label: 'End Date',
                    controller: controller.endDateController,
                    onTap: () async {
                      await controller.selectEndDate(context);
                      if (controller.startDateController.text.isNotEmpty &&
                          controller.endDateController.text.isNotEmpty) {
                        _loadChartData();
                      }
                    },
                  ),
                ),
              ],
            );
          }
        }),
      ],
    );
  }

  Widget _buildOtherFiltersSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildFilterDropdown(
                label: 'Entity',
                value: selectedEntityName.value,
                items: _getEntityOptions(),
                onChanged: (v) {
                  if (v != null) {
                    selectedEntityName.value = v;
                    _loadChartData();
                  }
                },
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildFilterDropdown(
                label: 'Transaction Type',
                value: selectedTransactionType.value,
                items: _getTransactionTypeOptions(),
                onChanged: (v) {
                  if (v != null) {
                    selectedTransactionType.value = v;
                    _loadChartData();
                  }
                },
              )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFilterDropdown(
          label: 'HSN Code',
          value: selectedHsnCode.value,
          items: _getHsnCodeOptions(),
          onChanged: (v) {
            if (v != null) {
              selectedHsnCode.value = v;
              _loadChartData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Obx(() {
      if (currentView.value == 'Monthly') {
        return _buildDualBarChart();
      } else if (currentView.value == 'Trends') {
        return _buildLineChart();
      } else {
        return _buildEntityChart();
      }
    });
  }

  Widget _buildDualBarChart() {
    final data = _getMonthlyGstData();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Monthly GST Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              ),
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Credit', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 12),
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Debit', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ReusableBarChart(
            title: '',
            data: data['credit']!,
            barColor: const Color(0xFF10B981),
            chartHeight: 150,
            valuePrefix: '₹',
            showGrid: true,
            showValues: false,
          ),
          const SizedBox(height: 16),
          ReusableBarChart(
            title: '',
            data: data['debit']!,
            barColor: const Color(0xFFEF4444),
            chartHeight: 150,
            valuePrefix: '₹',
            showGrid: true,
            showValues: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final data = _getMonthlyTotalGst();
    return ReusableLineChart(
      title: 'Monthly GST Trends',
      data: data,
      lineColor: AppColors.primaryLight,
      chartHeight: 300,
      valuePrefix: '₹',
      showGrid: true,
      showDots: true,
      showArea: true,
    );
  }

  Widget _buildEntityChart() {
    final data = _getEntityChartData();
    return ReusableBarChart(
      title: 'Entity-wise GST Chart',
      data: data,
      barColor: const Color(0xFF8B5CF6),
      chartHeight: 300,
      valuePrefix: '₹',
      showGrid: true,
      showValues: true,
    );
  }

  Widget _buildDateTypeButton(String type) {
    final isSelected = dateFilterType.value == type;
    return GestureDetector(
      onTap: () {
        dateFilterType.value = type;
        if (type == 'Month') {
          controller.startDateController.clear();
          controller.endDateController.clear();
          _loadChartData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'dd/mm/yyyy' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty ? Colors.grey[400] : const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        Text(label, style: const TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w500)),
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
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            style: const TextStyle(color: Color(0xFF374151), fontSize: 14, fontWeight: FontWeight.w500),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    selectedEntityName.value = 'All';
    selectedTransactionType.value = 'All';
    selectedHsnCode.value = 'All';
    selectedYear.value = DateTime.now().year.toString();
    dateFilterType.value = 'Month';
    selectedMonth.value = DateTime.now().month.toString();
    controller.startDateController.clear();
    controller.endDateController.clear();
    _loadChartData();
  }

  Map<String, Map<String, double>> _getMonthlyGstData() {
    final creditData = <String, double>{};
    final debitData = <String, double>{};
    final year = int.parse(selectedYear.value);

    for (int i = 1; i <= 12; i++) {
      final monthKey = '$year-${i.toString().padLeft(2, '0')}';
      creditData[monthKey] = 0.0;
      debitData[monthKey] = 0.0;
    }

    for (var item in controller.monthlyChartData) {
      final monthKey = '$year-${item.month.toString().padLeft(2, '0')}';
      creditData[monthKey] = item.credit;
      debitData[monthKey] = item.debit;
    }

    return {'credit': creditData, 'debit': debitData};
  }

  Map<String, double> _getMonthlyTotalGst() {
    final data = <String, double>{};
    final year = int.parse(selectedYear.value);

    for (int i = 1; i <= 12; i++) {
      final monthKey = '$year-${i.toString().padLeft(2, '0')}';
      data[monthKey] = 0.0;
    }

    for (var item in controller.monthlyChartData) {
      final monthKey = '$year-${item.month.toString().padLeft(2, '0')}';
      data[monthKey] = item.credit + item.debit;
    }

    return data;
  }

  Map<String, double> _getEntityChartData() {
    final data = <String, double>{};
    for (var entry in controller.ledgerEntries) {
      try {
        final date = DateTime.parse(entry.date);
        if (date.year == int.parse(selectedYear.value)) {
          final totalGst = entry.cgstAmount + entry.sgstAmount + entry.igstAmount;
          data[entry.relatedEntityName] = (data[entry.relatedEntityName] ?? 0) + totalGst;
        }
      } catch (e) {
        continue;
      }
    }
    if (data.isEmpty) data['No Data'] = 0.0;
    return data;
  }

  List<String> _getEntityOptions() => ['All', ...controller.entityNames.where((e) => e != 'All')];
  List<String> _getTransactionTypeOptions() => ['All', ...controller.transactionTypes.where((e) => e != 'All')];
  List<String> _getHsnCodeOptions() => ['All', ...controller.hsnCodes.where((e) => e != 'All')];
  List<String> _getAvailableYears() => List.generate(5, (i) => (DateTime.now().year - i).toString());
}