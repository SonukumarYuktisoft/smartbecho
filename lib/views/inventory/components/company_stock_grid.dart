import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_stock_comtroller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_styles.dart';

class CompanyStockGrid extends StatefulWidget {
  const CompanyStockGrid({super.key});

  @override
  _CompanyStockGridState createState() => _CompanyStockGridState();
}

class _CompanyStockGridState extends State<CompanyStockGrid> {
  final InventorySalesStockController controller =
      Get.find<InventorySalesStockController>();

  String selectedFilter = 'All';
  String sortBy = 'Company Name';
  String searchQuery = '';
  String selectedCategory = 'SMARTPHONE'; // Default category
  final TextEditingController searchController = TextEditingController();

  List<String> filterOptions = ['All', 'Low Stock', 'Good Stock', 'High Stock'];

  List<String> sortOptions = [
    'Company Name',
    'Total Stock (High to Low)',
    'Total Stock (Low to High)',
    'Models Count',
    'Low Stock Priority',
  ];

  // Static list of categories

  @override
  void initState() {
    super.initState();
    // Load initial data with default category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCompanyStocksByCategory(selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Company Stock Overview',
                  style: AppStyles.custom(
                    color: const Color(0xFF1A1A1A),
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getFilteredCompanies().length} Companies',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          Obx(()=>  controller.isLoadingCategories.value
              ? Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              )
              : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.category, size: 18),
                    hint: const Text('Select Category'),
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items:
                        controller.itemCategory.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                _getCategoryIcon(value),
                                const SizedBox(width: 8),
                                Text(
                                  value
                                      .replaceAll('_', ' ')
                                      .toLowerCase()
                                      .split(' ')
                                      .map(
                                        (word) =>
                                            word[0].toUpperCase() +
                                            word.substring(1),
                                      )
                                      .join(' '),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != selectedCategory) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                        // Call API with new category
                        controller.fetchCompanyStocksByCategory(
                          selectedCategory,
                        );
                      }
                    },
                  ),
                ),
              ),),
        
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search companies...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter and Sort Row
          Row(
            children: [
              // Filter Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      icon: const Icon(Icons.filter_list, size: 18),
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      items:
                          filterOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  _getFilterIcon(value),
                                  const SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFilter = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Sort Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortBy,
                      isExpanded: true,
                      icon: const Icon(Icons.sort, size: 18),
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      items:
                          sortOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          sortBy = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter Summary
          if (selectedFilter != 'All' || searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF3B82F6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFilterSummary(),
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selectedFilter != 'All' || searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = 'All';
                          searchQuery = '';
                          searchController.clear();
                        });
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),

          // Loading indicator
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Grid
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _getFilteredCompanies().length,
              itemBuilder: (context, index) {
                final company = _getFilteredCompanies()[index];
                return _buildCompanyCard(company);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'CHARGER':
        return const Icon(
          Icons.battery_charging_full,
          size: 16,
          color: Color(0xFF10B981),
        );
      case 'MOBILE':
        return const Icon(
          Icons.phone_android,
          size: 16,
          color: Color(0xFF3B82F6),
        );
      case 'HEADPHONE':
        return const Icon(Icons.headset, size: 16, color: Color(0xFF8B5CF6));
      case 'SPEAKER':
        return const Icon(Icons.speaker, size: 16, color: Color(0xFFF59E0B));
      case 'POWERBANK':
        return const Icon(Icons.power, size: 16, color: Color(0xFFEF4444));
      case 'CABLE':
        return const Icon(Icons.cable, size: 16, color: Color(0xFF6B7280));
      case 'ADAPTER':
        return const Icon(Icons.power, size: 16, color: Color(0xFF059669));
      case 'CASE':
        return const Icon(
          Icons.phone_in_talk,
          size: 16,
          color: Color(0xFFDC2626),
        );
      case 'SCREEN_GUARD':
        return const Icon(Icons.shield, size: 16, color: Color(0xFF7C3AED));
      case 'BATTERY':
        return const Icon(
          Icons.battery_std,
          size: 16,
          color: Color(0xFFEC4899),
        );
      default:
        return const Icon(Icons.category, size: 16, color: Color(0xFF6B7280));
    }
  }

  Widget _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return const Icon(Icons.apps, size: 16, color: Color(0xFF6B7280));
      case 'Low Stock':
        return const Icon(Icons.warning, size: 16, color: Color(0xFFF59E0B));
      case 'Good Stock':
        return const Icon(
          Icons.check_circle,
          size: 16,
          color: Color(0xFF10B981),
        );
      case 'High Stock':
        return const Icon(
          Icons.trending_up,
          size: 16,
          color: Color(0xFF3B82F6),
        );
      default:
        return const Icon(
          Icons.filter_list,
          size: 16,
          color: Color(0xFF6B7280),
        );
    }
  }

  String _getFilterSummary() {
    String summary = '';
    if (searchQuery.isNotEmpty) {
      summary += 'Searching for "$searchQuery"';
    }
    if (selectedFilter != 'All') {
      if (summary.isNotEmpty) summary += ' • ';
      summary += 'Filter: $selectedFilter';
    }
    summary += ' • ${_getFilteredCompanies().length} results';
    return summary;
  }

  List<dynamic> _getFilteredCompanies() {
    List<dynamic> companies = List.from(controller.companyStocks);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      companies =
          companies
              .where(
                (company) => company.company.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    // Apply category filter
    if (selectedFilter != 'All') {
      companies =
          companies.where((company) {
            switch (selectedFilter) {
              case 'Low Stock':
                return company.lowStockModels > 0;
              case 'Good Stock':
                return company.lowStockModels == 0 && company.totalStock > 50;
              case 'High Stock':
                return company.totalStock > 100;
              default:
                return true;
            }
          }).toList();
    }

    // Apply sorting
    companies.sort((a, b) {
      switch (sortBy) {
        case 'Company Name':
          return a.company.compareTo(b.company);
        case 'Total Stock (High to Low)':
          return b.totalStock.compareTo(a.totalStock);
        case 'Total Stock (Low to High)':
          return a.totalStock.compareTo(b.totalStock);
        case 'Models Count':
          return b.totalModels.compareTo(a.totalModels);
        case 'Low Stock Priority':
          return b.lowStockModels.compareTo(a.lowStockModels);
        default:
          return 0;
      }
    });

    return companies;
  }

  Widget _buildCompanyCard(company) {
    return InkWell(
      onTap:
          () => Get.toNamed(
            AppRoutes.companyStockDetails,
            parameters: {"companyName": company.company.toString()},
          ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getCompanyColor(company.company),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _getCategoryIcon(selectedCategory),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    company.company.toLowerCase(),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildStockStat('Total Stock', '${company.totalStock}', 'units'),
            const SizedBox(height: 8),
            _buildStockStat('Models', '${company.totalModels}', 'available'),
            const SizedBox(height: 8),
            _buildStockStat('Low Stock', '${company.lowStockModels}', 'models'),

            const SizedBox(height: 12),

            if (company.totalStock < 20)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Stock OK',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStat(String label, String value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$value $unit',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getCompanyColor(String company) {
    final colors = {
      'apple': const Color(0xFF007AFF),
      'samsung': const Color(0xFF1428A0),
      'google': const Color(0xFF4285F4),
      'xiaomi': const Color(0xFFFF6900),
      'oneplus': const Color(0xFFEB0028),
      'realme': const Color(0xFFFFC900),
      'oppo': const Color(0xFF1BA784),
      'vivo': const Color(0xFF4A90E2),
      'nokia': const Color(0xFF124191),
      'honor': const Color(0xFF2C5BFF),
    };

    return colors[company.toLowerCase()] ?? const Color(0xFF8B5CF6);
  }
}
