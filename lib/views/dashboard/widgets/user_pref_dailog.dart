import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/user_prefs_controller.dart';

class ViewPreferencesBottomSheet extends StatelessWidget {
  final UserPrefsController controller;

  const ViewPreferencesBottomSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7).withValues(alpha:0.1),
                        const Color(0xFFA29BFE).withValues(alpha:0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: const Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Preferences',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Customize your dashboard layout',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Top Stats Section
                  _buildModernPreferenceSection(
                    context: context,
                    title: 'Top Statistics',
                    description: 'Sales overview and key metrics',
                    icon: Icons.analytics_rounded,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7).withValues(alpha:0.1),
                        const Color(0xFFA29BFE).withValues(alpha:0.05),
                      ],
                    ),
                    isGridView: controller.isTopStatGridView,
                    onToggle: controller.toggleTopStatViewMode,
                  ),

                  const SizedBox(height: 24),

                  // Inventory Summary Section
                  _buildModernPreferenceSection(
                    context: context,
                    title: 'Inventory Summary',
                    description: 'Stock levels and EMI information',
                    icon: Icons.inventory_2_rounded,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA29BFE).withValues(alpha:0.1),
                        const Color(0xFF6C5CE7).withValues(alpha:0.05),
                      ],
                    ),
                    isGridView: controller.isInventorySummaryGridView,
                    onToggle: controller.toggleInventorySummaryViewMode,
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Preferences Updated',
                          'Your view preferences have been saved successfully!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green[600],
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF6C5CE7).withValues(alpha:0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Apply Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildModernPreferenceSection({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
    required RxBool isGridView,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Toggle Options
          Obx(() => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModernToggleOption(
                    context: context,
                    title: 'Grid View',
                    subtitle: 'Side by side',
                    icon: Icons.grid_view_rounded,
                    isSelected: isGridView.value,
                    onTap: () {
                      if (!isGridView.value) onToggle();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildModernToggleOption(
                    context: context,
                    title: 'List View',
                    subtitle: 'Stacked',
                    icon: Icons.view_agenda_rounded,
                    isSelected: !isGridView.value,
                    onTap: () {
                      if (isGridView.value) onToggle();
                    },
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernToggleOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF6C5CE7)
            : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected 
                  ? Colors.white
                  : Colors.grey[600],
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected 
                  ? Colors.white
                  : Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected 
                  ? Colors.white.withValues(alpha:0.9)
                  : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension method to show the bottom sheet easily
extension ViewPreferencesBottomSheetExtension on BuildContext {
  void showViewPreferencesBottomSheet(UserPrefsController controller) {
    Get.bottomSheet(
      ViewPreferencesBottomSheet(controller: controller),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }
}

// Alternative: Static method to show bottom sheet
class ViewPreferencesBottomSheetHelper {
  static void show(UserPrefsController controller) {
    Get.bottomSheet(
      ViewPreferencesBottomSheet(controller: controller),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }
}