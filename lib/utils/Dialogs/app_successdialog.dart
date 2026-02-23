import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smartbecho/utils/app_colors.dart';

void appSuccessDialog({
  void Function()? onPressed,
  String? title,
  String? description,
}) {
  Get.dialog(
    
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              // width: 70,
              // height: 70,
              // decoration: BoxDecoration(
              //   color: Colors.green.withOpacity(0.1),
              //   shape: BoxShape.circle,
              // ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 75,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Flexible(
              child: Text(
                title ?? 'Success',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description ??
                  'Your Submission has been successfully submitted!',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
                fontWeight: FontWeight.normal,
                
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // // Cancel Button
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: () => Get.back(),
                //     style: OutlinedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //       side: const BorderSide(
                //         color: Color(0xFFE5E7EB),
                //         width: 1.5,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //     child: const Text(
                //       'Cancel',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //         color: Color(0xFF6B7280),
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed ?? Get.back,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
