import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/Internal_user_management/widgets/internal_user_list_screen.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/role_management/role_management_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final shopId = controller.shopId.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 40,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  tabs: [
                    _buildTab(
                      icon: Icons.person_outline_rounded,
                      label: 'Users Management',
                    ),
                    _buildTab(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Role Management',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  InternalUserListScreen(shopId: shopId),
                  RoleManagementScreen(shopId: shopId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _buildTab({required IconData icon, required String label}) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
