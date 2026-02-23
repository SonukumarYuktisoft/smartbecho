import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/roles_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';

class AllRolesList extends StatelessWidget {
  const AllRolesList({super.key});

  @override
  Widget build(BuildContext context) {
    final RoleManagementController controller = Get.find<RoleManagementController>();

    return Obx(
      () =>
          controller.allRolesLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.allRolesList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No roles available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : AppRefreshIndicator(
                 onRefresh: () async{
                   controller.getAllRoles();
                 },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.allRolesList.length,
                  itemBuilder: (context, index) {
                    final role = controller.allRolesList[index];
                    return RoleCard(role: role);
                  },
                ),
              ),
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 20,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  role.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${role.permissions?.length ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}