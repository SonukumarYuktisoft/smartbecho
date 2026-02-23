import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/role_management/widgets/all_roles_list.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/role_management/widgets/create_role_screen.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/role_management/widgets/shop_rolesList.dart';

class RoleManagementScreen extends StatelessWidget {
  final String shopId;
  const RoleManagementScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final RoleManagementController controller = Get.put(
      RoleManagementController(),
    );
    final currentTab = 'all_roles'.obs;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: Column(
        children: [
          // Tab Section
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => currentTab.value = 'all_roles',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  currentTab.value == 'all_roles'
                                      ? AppColors.primaryLight
                                      : Colors.grey.withValues(alpha: 0.2),
                              width: currentTab.value == 'all_roles' ? 3 : 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'All Roles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  currentTab.value == 'all_roles'
                                      ? AppColors.primaryLight
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => currentTab.value = 'shop_roles',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  currentTab.value == 'shop_roles'
                                      ? AppColors.primaryLight
                                      : Colors.grey.withValues(alpha: 0.2),
                              width: currentTab.value == 'shop_roles' ? 3 : 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Shop Roles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  currentTab.value == 'shop_roles'
                                      ? AppColors.primaryLight
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(
              () =>
                  currentTab.value == 'all_roles'
                      ? AllRolesList()
                      : ShopRoleslist(shopId: shopId,),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() =>  CreateRoleScreen(shopId: shopId,));
        },
        backgroundColor: AppColors.primaryLight,
        label: const Text('Create Role', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  

}
