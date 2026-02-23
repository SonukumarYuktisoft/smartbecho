import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_styles.dart';

Widget buildErrorCard(
  RxString errorMessage,
  double screenWidth,
  double screenHeight,
  bool isSmallScreen,
) {
  return Container(
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.red[200]!, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.05),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            SizedBox(width: 8),
            Text(
              'Sales Summary',
              style: AppStyles.custom(
                size: isSmallScreen ? 14 : 16,
                weight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          errorMessage.value.isNotEmpty
              ? errorMessage.value
              : 'Unknown error occurred',
          style: AppStyles.custom(
            size: isSmallScreen ? 10 : 12,
            color: Colors.red[700],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        ElevatedButton(
          onPressed: () {},
          // controller.fetchSalesSummary(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Retry',
            style: AppStyles.custom(
              size: isSmallScreen ? 10 : 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
