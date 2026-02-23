// Create Role Screen
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/roles%20management%20%20models/create_role_model.dart';
import 'package:smartbecho/utils/app_colors.dart';

class CreateRoleScreen extends StatelessWidget {
  final String shopId;
  const CreateRoleScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final RoleManagementController controller =
        Get.find<RoleManagementController>();

    final roleNameController = TextEditingController();
    final selectedPermissions = <String>[].obs;
    final availablePermissions = <String>[].obs;
    final showPermissionList = false.obs;

    // Get unique permissions from all roles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allPermissions = <String>{};
      for (var role in controller.allRolesList) {
        if (role.permissions != null) {
          allPermissions.addAll(role.permissions!);
        }
      }
      availablePermissions.value = allPermissions.toList();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Create Role',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: // Create Button
          Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  controller.createRoleLoading.value
                      ? null
                      : () {
                        if (roleNameController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter role name',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (selectedPermissions.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please select at least one permission',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final roleData = CreateRoleModel(
                          shopId: shopId,
                          roleName: roleNameController.text.trim(),
                          permissions: selectedPermissions.toList(),
                        );

                        controller.createRole(roleData: roleData);
                      },
              icon:
                  controller.createRoleLoading.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.add),
              label: const Text(
                'Create Role',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Name
            const Text(
              'Role Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: roleNameController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Role Name *',
                  hintText: 'Enter role name (e.g., MANAGER)',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Permissions Section
            const Text(
              'Select Permissions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => Column(
                children: [
                  // Show selected permissions count
                  GestureDetector(
                    onTap: () {
                      showPermissionList.value = !showPermissionList.value;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedPermissions.isEmpty
                                ? 'No permissions selected'
                                : '${selectedPermissions.length} permission(s) selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            // onTap: () {
                            //   showPermissionList.value =
                            //       !showPermissionList.value;
                            // },
                            child: Icon(
                              showPermissionList.value
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Permissions List
                  if (showPermissionList.value)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children:
                            availablePermissions.map((permission) {
                              return Obx(
                                () => CheckboxListTile(
                                  title: Text(
                                    permission,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: selectedPermissions.contains(
                                    permission,
                                  ),
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      selectedPermissions.add(permission);
                                    } else {
                                      selectedPermissions.remove(permission);
                                    }
                                  },
                                  activeColor: AppColors.primaryLight,
                                  checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
