import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_status.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_title.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';

class FeatureVisitor extends StatelessWidget {
  final String featureKey;
  final Widget child;
  final String? featureTitle;

  const FeatureVisitor({
    Key? key,
    required this.featureKey,
    required this.child,
    this.featureTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<FeatureController>();
      final status = controller.statusOf(featureKey);

      // ✅ ALLOWED - Show full content
      if (status == FeatureStatus.allowed) {
        return child;
      }

      // 🔒 LOCKED - Premium Feature with Blur
      if (status == FeatureStatus.locked) {
        // Auto-fetch title from FeatureTitles if not provided
        final String displayTitle =
            featureTitle ?? FeatureTitles.getTitle(featureKey);

        return _buildLockedOverlay(featureTitle: displayTitle, child: child);
      }

      // 🚫 UNAUTHORIZED - Show Nothing
      return const SizedBox.shrink();
    });
  }

  Widget _buildLockedOverlay({required Widget child, String? featureTitle}) {
    final borderRadius = BorderRadius.circular(16);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.subscriptionPlanScreen),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            RepaintBoundary(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: IgnorePointer(child: child),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
            ),

            // 🔹 Disable child
            // IgnorePointer(child: child),

            //    Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.9,
            //     child: Container(color: Colors.white),
            //   ),
            // ),

            // 🔒 Lock Overlay
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double h = constraints.maxHeight;
                  final double w = constraints.maxWidth;

                  final double shortestSide = constraints.biggest.shortestSide;

                  // 🔒 PERFECT RESPONSIVE ICON SIZE
                  final double iconSize = (shortestSide * 0.32).clamp(
                    24.0,
                    72.0,
                  );
                  final double iconPadding = iconSize * 0.2;

                  final bool showDetails = h >= 200;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔒 Lock Icon (ALWAYS)
                        Shimmer.fromColors(
                          baseColor: Colors.black,
                          highlightColor: Colors.white,
                          direction: ShimmerDirection.btt,
                          child: Container(
                            padding: EdgeInsets.all(iconPadding),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight.withOpacity(0.12),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              size: iconSize,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),

                        // ❗ DETAILS ONLY IF SPACE EXISTS
                        if (showDetails) ...[
                          const SizedBox(height: 10),

                          if (featureTitle != null && featureTitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Unlock $featureTitle',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),

                          const SizedBox(height: 10),

                          SizedBox(
                            height: 40,
                            width: w * 0.6,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.subscriptionPlanScreen);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Unlock Now',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerSweep extends StatefulWidget {
  @override
  State<_ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<_ShimmerSweep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return FractionallySizedBox(
          widthFactor: 1.2,
          child: Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width * (_controller.value - 0.5),
              0,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
