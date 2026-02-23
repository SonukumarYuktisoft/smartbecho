import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/controllers/hsn-codecontrollers/hsn_code_controller.dart';
import 'package:smartbecho/models/hsncode_models/hsn_code_model.dart';
import 'package:smartbecho/views/hsn-code/widgets/add_and_edit_hsncode.dart';
import 'package:smartbecho/views/hsn-code/widgets/hsn_code_card.dart';

class HsnCodeScreen extends StatelessWidget {
  HsnCodeScreen({super.key});

  final TextEditingController searchController = TextEditingController();
  final HsnCodeController controller = Get.put(HsnCodeController());
  final ScrollController scrollController = ScrollController();
  final RxBool hasSearchText = false.obs;
  final RxString activeFilter = ''.obs;

  @override
  Widget build(BuildContext context) {
    // Setup lazy loading listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreHsnCodes();
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: "HSN Code Management",
        onPressed: () {
          Get.find<BottomNavigationController>().setIndex(0);
          Get.back();
        },
      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => AddEditHsnCodeForm(
              itemCategories: controller.itemCategories,
              onSave: (Map<String, dynamic> data) {
                controller.addHsnCode(data);
              },
            ),
          );
        },
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content with padding for floating header
            Obx(
              () =>
                  controller.isLoading.value && controller.hsnCodes.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          // Spacer for floating header
                          SliverToBoxAdapter(child: SizedBox(height: 160)),

                          // HSN Code List
                          controller.hsnCodes.isEmpty
                              ? SliverFillRemaining(
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No HSN codes found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try adjusting your search or filters',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final hsnCode = controller.hsnCodes[index];
                                    return HsnCodeCard(
                                      hsnCode: hsnCode,
                                      onEdit: () {
                                        Get.to(
                                          () => AddEditHsnCodeForm(
                                            hsnCode: hsnCode,
                                            itemCategories:
                                                controller.itemCategories,
                                            onSave: (data) {
                                              controller.updateHsnCode(
                                                hsnCode.id.toString(),
                                                data,
                                              );
                                              Get.back();
                                            },
                                          ),
                                        );
                                      },
                                      onDelete:
                                          () => _confirmDelete(
                                            context,
                                            hsnCode.id.toString(),
                                          ),
                                    );
                                  }, childCount: controller.hsnCodes.length),
                                ),
                              ),

                          // Loading More Indicator
                          if (controller.isLoadingMore.value)
                            SliverToBoxAdapter(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryLight,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading more...',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
            ),

            // Floating Search Bar and Generate Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CommonSearchBar(
                      controller: searchController,
                              keyboardType: TextInputType.number,


                      // onChanged: controller.onSearchChanged,
                      hintText: 'Search HSN codes...',
                      searchQuery: RxString(''),
                      hasFilters: false,
                      clearFilters: () {
                        searchController.clear();
                        hasSearchText.value = false;
                        
                        controller.searchHsnCodes('');
                      },
                      onFieldSubmitted: (value) {
                                hasSearchText.value = value.isNotEmpty;
                                // Debounce search
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    if (searchController.text == value) {
                                      controller.searchHsnCodes(value);
                                    }
                                  },
                                );
                              },
                      // onFilter: () => _showFilterBottomSheet(context),
                    ),
                    // // Search Bar
                    // Container(
                    //   padding: const EdgeInsets.all(2),
                    //   height: 48,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.08),
                    //         spreadRadius: 0,
                    //         blurRadius: 8,
                    //         offset: const Offset(0, 2),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextField(
                    //           keyboardType: TextInputType.number,
                    //           controller: searchController,
                    //           onSubmitted: (value) {
                    //             hasSearchText.value = value.isNotEmpty;
                    //             // Debounce search
                    //             Future.delayed(
                    //               const Duration(milliseconds: 500),
                    //               () {
                    //                 if (searchController.text == value) {
                    //                   controller.searchHsnCodes(value);
                    //                 }
                    //               },
                    //             );
                    //           },
                    //           decoration: InputDecoration(
                    //             prefixIcon: Icon(
                    //               Icons.search,
                    //               size: 22,
                    //               color: Colors.grey[600],
                    //             ),
                    //             hintText: 'Search HSN codes...',
                    //             hintStyle: TextStyle(
                    //               fontSize: 15,
                    //               color: Colors.grey[500],
                    //               fontWeight: FontWeight.w400,
                    //             ),
                    //             suffixIcon: Obx(
                    //               () =>
                    //                   hasSearchText.value
                    //                       ? IconButton(
                    //                         onPressed: () {
                    //                           searchController.clear();
                    //                           hasSearchText.value = false;
                    //                           controller.searchHsnCodes('');
                    //                         },
                    //                         icon: Icon(
                    //                           Icons.clear,
                    //                           size: 18,
                    //                           color: Colors.grey[400],
                    //                         ),
                    //                       )
                    //                       : const SizedBox(),
                    //             ),
                    //             border: InputBorder.none,
                    //             contentPadding: const EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //               vertical: 12,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       // // Filter Button
                          // Container(
                          //   margin: const EdgeInsets.only(right: 4),
                          //   height: 40,
                          //   width: 40,
                          //   decoration: BoxDecoration(
                          //     color: AppColors.primaryLight.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(
                          //       color: AppColors.primaryLight.withOpacity(0.3),
                          //     ),
                          //   ),
                          //   child: IconButton(
                          //     onPressed: () {
                          //       _showFilterBottomSheet(context);
                          //     },
                          //     icon: Icon(
                          //       Icons.tune,
                          //       size: 20,
                          //       color: AppColors.primaryLight,
                          //     ),
                          //     padding: EdgeInsets.zero,
                          //     tooltip: 'Filter',
                          //   ),
                          // ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // Generate Button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed:
                                controller.isAutoGenerating.value
                                    ? null
                                    : () {
                                      controller.autoGenerate();
                                    },
                            icon:
                                controller.isAutoGenerating.value
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                    : const Icon(Icons.auto_awesome, size: 20),
                            label: Text(
                              controller.isAutoGenerating.value
                                  ? 'Generating...'
                                  : 'Generate HSN Codes',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Active Filter Display
                    Obx(
                      () =>
                          activeFilter.value.isNotEmpty
                              ? Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryLight.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_alt,
                                      size: 16,
                                      color: AppColors.primaryLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Filter: ${activeFilter.value}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        activeFilter.value = '';
                                        controller.refreshHsnCodes();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Obx(
                //   () => Wrap(
                //     spacing: 8,
                //     runSpacing: 8,
                //     children: controller.itemCategories.map((category) {
                //       return FilterChip(
                //         label: Text(category),
                //         selected: activeFilter.value == category,
                //         onSelected: (selected) {
                //           if (selected) {
                //             activeFilter.value = category;
                //             controller.searchHsnCodes(category);
                //           } else {
                //             activeFilter.value = '';
                //             controller.refreshHsnCodes();
                //           }
                //           Get.back();
                //         },
                //         selectedColor: AppColors.primaryLight.withOpacity(0.2),
                //         checkmarkColor: AppColors.primaryLight,
                //       );
                //     }).toList(),
                //   ),
                // ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      activeFilter.value = '';
                      controller.refreshHsnCodes();
                      Get.back();
                    },
                    child: const Text('Reset Filters'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete HSN Code'),
            content: const Text(
              'Are you sure you want to delete this HSN code?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.deleteHsnCode(id);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
