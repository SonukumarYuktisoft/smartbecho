// subscription_status_widget.dart
// Modern widget to show user's subscription plan with icon and shimmer effect
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/subscription%20plan/current_user_subscription_screen.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';

class SubscriptionStatusWidget extends StatefulWidget {
  final String userId;
  final bool showLabel;
  final double iconSize;
  final double fontSize;

  const SubscriptionStatusWidget({
    super.key,
    required this.userId,
    this.showLabel = true,
    this.iconSize = 32,
    this.fontSize = 14,
  });

  @override
  State<SubscriptionStatusWidget> createState() => _SubscriptionStatusWidgetState();
}

class _SubscriptionStatusWidgetState extends State<SubscriptionStatusWidget> {
  final controller = Get.put(SubscriptionController());
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSubscription();
  }

  void _initializeSubscription() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.getCurrentSubscription();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentSubscriptionLoading.value) {
        return _buildShimmerLoading();
      }

      final subscription = controller.currentSubscriptions.isNotEmpty
          ? controller.currentSubscriptions.first
          : null;

      final planCode = subscription?.planCode ?? 'FREE';
      final planName = subscription?.planNameSnapshot ?? 'Free Plan';
      final isActive = subscription?.active ?? false;

      return _buildPlanBadge(
        planCode: planCode,
        planName: planName,
        isActive: isActive,
      );
    });
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.iconSize,
              height: widget.iconSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 8),
              Container(
                width: 70,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanBadge({
    required String planCode,
    required String planName,
    required bool isActive,
  }) {
    final planInfo = _getPlanInfo(planCode);

    return InkWell(
      onTap: () {
        Get.to(() => CurrentUserSubscriptionScreen(userId: widget.userId));
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: planInfo['gradient'] as LinearGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (planInfo['color'] as Color).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon with Shimmer for premium plans
            if (planCode != 'FREE' && planCode != 'TRIAL')
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.white,
                // period: const Duration(milliseconds: 1500),
                child: Icon(
                  planInfo['icon'] as IconData,
                  color: Colors.white,
                  size: widget.iconSize,
                ),
              )
            else
              Icon(
                planInfo['icon'] as IconData,
                color: Colors.white,
                size: widget.iconSize,
              ),
            
            if (widget.showLabel) ...[
              const SizedBox(width: 10),
              Text(
                planInfo['displayName'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPlanInfo(String planCode) {
    switch (planCode.toUpperCase()) {
      case 'DIAMOND':
      case 'PREMIUM':
        return {
          'icon': Icons.diamond,
          'displayName': 'Diamond',
          'color': const Color(0xFF00D9FF),
          'gradient': const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };

      case 'GOLD':
      case 'PRO':
        return {
          'icon': Icons.workspace_premium,
          'displayName': 'Gold',
          'color': const Color(0xFFFFD700),
          'gradient': const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };

      case 'SILVER':
      case 'BASIC':
        return {
          'icon': Icons.stars,
          'displayName': 'Silver',
          'color': const Color(0xFFC0C0C0),
          'gradient': const LinearGradient(
            colors: [Color(0xFFE8E8E8), Color(0xFFA8A8A8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };

      case 'BRONZE':
        return {
          'icon': Icons.grade,
          'displayName': 'Bronze',
          'color': const Color(0xFFCD7F32),
          'gradient': const LinearGradient(
            colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };

      case 'TRIAL':
        return {
          'icon': Icons.timer,
          'displayName': 'Trial',
          'color': AppColors.primaryLight,
          'gradient': LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryLight.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };

      case 'FREE':
      default:
        return {
          'icon': Icons.card_membership_outlined,
          'displayName': 'Free',
          'color': Colors.grey[700],
          'gradient': LinearGradient(
            colors: [Colors.grey[500]!, Colors.grey[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        };
    }
  }
}

// Compact version for app bar
class SubscriptionStatusBadge extends StatelessWidget {
  final String userId;

  const SubscriptionStatusBadge({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SubscriptionStatusWidget(
      userId: userId,
      showLabel: false,
      iconSize: 24,
    );
  }
}