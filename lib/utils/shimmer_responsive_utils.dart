// Responsive utility class for shimmer components
import 'package:flutter/material.dart';

class ShimmerResponsiveUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 414;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 414;
  }
  
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return width * 0.035; // Reduced for small screens
    if (width < 414) return width * 0.04; // Reduced for medium screens
    return width * 0.045; // Reduced for large screens
  }
  
  static double getResponsiveMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 2.0; // Small screens
    if (width < 414) return 3.0; // Medium screens
    return 4.0; // Large screens
  }
  
  static double getResponsiveFontSize(BuildContext context, {required double baseSize}) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width / 375; // Base width (iPhone 6/7/8)
    return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 1.2);
  }
  
  static double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 32.0; // Small screens
    if (width < 414) return 36.0; // Medium screens
    return 40.0; // Large screens
  }
}