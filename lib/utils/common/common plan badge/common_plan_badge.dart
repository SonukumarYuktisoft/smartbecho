
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/services/configs/plan_config.dart';

class CommonPlanBadge extends StatelessWidget {
  final String planName;
  final double size;
  final bool showGradient;

  const CommonPlanBadge({
    super.key,
    required this.planName,
    this.size =20,
    this.showGradient = true,
    
  });

  @override
  Widget build(BuildContext context) {
    final planConfig = PlanConfig.getPlanByName(planName);
    final containerSize = size * 2;
    final iconSize = size;

    return ClipOval(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer effect layer
          Shimmer.fromColors(
            direction: ShimmerDirection.ttb,
            baseColor: (planConfig['gradientColors'] as List<Color>)[0],
            highlightColor: Colors.white,
            period: const Duration(milliseconds: 2000),
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                gradient: showGradient
                    ? LinearGradient(
                        colors: planConfig['gradientColors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !showGradient
                    ? (planConfig['gradientColors'] as List<Color>)[0]
                    : null,
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    color: (planConfig['gradientColors'] as List<Color>)[0]
                        .withOpacity(0.4),
                    blurRadius: containerSize * 0.2,
                    offset: Offset(0, containerSize * 0.06),
                  ),
                ],
              ),
            ),
          ),
          
          // Icon layer
          Container(
            width: containerSize,
            height: containerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                planConfig['icon'] as IconData,
                size: iconSize,
                color: planConfig['iconColor'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
