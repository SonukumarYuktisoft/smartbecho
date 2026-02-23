import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/shop_management/users_management/tab/Internal_user_management/widgets/internal_user_detail_screen.dart';

class InternalUserCard extends StatelessWidget {
  final InternalUser user;
  final String shopId;

  const InternalUserCard({super.key, required this.user, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => InternalUserDetailScreen(user: user, shopId: shopId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Avatar with Initials - Rounded Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                image:
                    user.profilePhotoUrl != null
                        ? DecorationImage(
                          image: NetworkImage(user.profilePhotoUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  user.profilePhotoUrl == null
                      ? Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Phone
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status & Role Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Indicator
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        user.status == 1
                            ? const Color(0xFF10B981)
                            : Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 4),

                // Role Badge
                if (user.roleName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.roleName!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
