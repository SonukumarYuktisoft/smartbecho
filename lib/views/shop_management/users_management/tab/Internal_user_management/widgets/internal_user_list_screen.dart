import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/Internal%20user%20management%20controller/Internal_user_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/Internal_user_management/widgets/internal_user_card.dart';
import 'create_internal_user_screen.dart';

class InternalUserListScreen extends StatelessWidget {
  final String shopId;

  const InternalUserListScreen({
    super.key,
    required this.shopId,
  });

  @override
  Widget build(BuildContext context) {
    final InternalUserManagementController controller =
        Get.put(InternalUserManagementController());

    // Load users on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getInternalUsers(shopId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
     
      body: Obx(() {
        if (controller.internalUsersLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        }

        if (controller.internalUsersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Internal Users Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first internal user',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return AppRefreshIndicator(
          onRefresh: () => controller.getInternalUsers(shopId),
          
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.internalUsersList.length,
            itemBuilder: (context, index) {
              final user = controller.internalUsersList[index];
              return InternalUserCard(
                user: user,
                shopId: shopId,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => CreateInternalUserScreen(shopId: shopId));
        },
        backgroundColor:  AppColors.primaryLight,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}