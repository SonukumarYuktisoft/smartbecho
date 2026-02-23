import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/roles%20management%20%20controllers/role_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';

class ShopRoleslist extends StatefulWidget {
  final String shopId;

  const ShopRoleslist({super.key, required this.shopId});

  @override
  State<ShopRoleslist> createState() => _ShopRoleslistState();
}

class _ShopRoleslistState extends State<ShopRoleslist> {
    final RoleManagementController controller = Get.find<RoleManagementController>();

  @override
  void initState() {
    controller.getShopRoles(shopId:widget.shopId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Obx(
      () => controller.shopRolesLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.shopRolesList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No shop roles available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : AppRefreshIndicator(
                 onRefresh: () async{
                   controller.getShopRoles(shopId: widget.shopId);
                 },
                child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.shopRolesList.length,
                    itemBuilder: (context, index) {
                      final role = controller.shopRolesList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: role.isGlobal
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role.isGlobal ? 'Global' : 'Local',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: role.isGlobal
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ),
    );
  }
}