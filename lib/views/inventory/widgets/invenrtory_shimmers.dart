import 'package:flutter/material.dart';
import 'package:smartbecho/utils/shimmer_responsive_utils.dart';
import 'package:shimmer/shimmer.dart';



Widget _BuildStatsCardShimmer(BuildContext context) {
  final padding = ShimmerResponsiveUtils.getResponsivePadding(context);
  final margin = ShimmerResponsiveUtils.getResponsiveMargin(context);
  final iconSize = ShimmerResponsiveUtils.getResponsiveIconSize(context);
  final titleHeight = ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 12);
  final valueHeight = ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 20);
  final subtitleHeight = ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 10);

  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: ShimmerResponsiveUtils.isSmallScreen(context) ? 140 : 180,
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.only(right: margin * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
       // border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and icon row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: titleHeight,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: margin * 2),
              Container(
                height: iconSize * 0.6,
                width: iconSize * 0.6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          SizedBox(height: margin * 3),
          // Value section
          Container(
            height: valueHeight,
            width: ShimmerResponsiveUtils.getScreenWidth(context) * 0.3,
            color: Colors.grey[300],
          ),
          SizedBox(height: margin),
          // Subtitle section
          Container(
            height: subtitleHeight,
            width: ShimmerResponsiveUtils.getScreenWidth(context) * 0.4,
            color: Colors.grey[300],
          ),
        ],
      ),
    ),
  );
}
Widget buildShimmerStatList(BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(
      horizontal: ShimmerResponsiveUtils.getResponsivePadding(context),
    ),
    child: Row(
      children: List.generate(
        5,
        (_) => _BuildStatsCardShimmer(context),
      ),
    ),
  );
}
