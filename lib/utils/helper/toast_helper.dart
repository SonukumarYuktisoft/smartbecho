import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ToastHelper {
  /// Show success toast message
  static void success({
    required String message,
    String? description,
    BuildContext? context,
  }) {
    _showCustomSnackBar(
      message: message,
      description: description,
      color: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  /// Show error toast message
  static void error({
    required String message,
    String? description,
    BuildContext? context,
  
  }) {
    _showCustomSnackBar(
      message: message,
      duration: 7,
      description: description,
      color: const Color.fromARGB(255, 241, 34, 34),
      icon: Icons.error_rounded,
    );
  }

  /// Show info toast message
  static void info({
    required String message,
    String? description,
    BuildContext? context,
  }) {
    _showCustomSnackBar(
      message: message,
      description: description,
      color: const Color(0xFF3B82F6),
      icon: Icons.info_rounded,
    );
  }

  /// Show warning toast message
  static void warning({
    required String message,
    String? description,
    BuildContext? context,
  }) {
    _showCustomSnackBar(
      message: message,
      description: description,
      color: const Color(0xFFFBBF24),
      icon: Icons.warning_rounded,
      textColor: Colors.black87,
    );
  }

  /// Show custom toast message
  static void custom({
    BuildContext? context,
    required String message,
    String? description,
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    _showCustomSnackBar(
      message: message,
      description: description,
      color: color,
      icon: icon,
      textColor: textColor,
    );
  }

  static void _showCustomSnackBar({
    required String message,
    String? description,
    required Color color,
    required IconData icon,
    Color textColor = Colors.black,
    int? duration = 4,
  }) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: duration!),
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 0,
      overlayBlur: 0,
      titleText: const SizedBox.shrink(),
      messageText: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // MAIN CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CLOSE BUTTON (TOP-RIGHT)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
