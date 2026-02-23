import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_styles.dart';

class CommonWidgets {
  
  // Background Container
  static Widget backgroundContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Light purple
            Color(0xFFF3E5F5), // Very light purple
            Color(0xFFEDE7F6), // Lavender
          ],
        ),
      ),
      child: child,
    );
  }
  
  // Main Card Container
  static Widget mainCard({required Widget child}) {
    return Card(
      elevation: 12,
      shadowColor: Colors.purple.withValues(alpha:0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFAF8FC),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
  
  // Header Widget
  static Widget buildHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF9C27B0),
                Color(0xFFBA68C8),
              ],
            ),
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppStyles.custom(
            color: Color(0xFF4A148C),
            size: 28,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppStyles.custom(
            color: Colors.grey[600]!,
            size: 16,
            weight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
  
  // Animated Text Field
  static Widget buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              validator: validator,
              style: AppStyles.custom(
                color: Color(0xFF2E2E2E),
                size: 16,
                weight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppStyles.custom(
                  color: Colors.grey[500]!,
                  size: 16,
                  weight: FontWeight.w400,
                ),
                prefixIcon: Icon(prefixIcon, color: Color(0xFF9C27B0)),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Color(0xFFF8F5FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE1BEE7), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9C27B0), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Animated Button
  static Widget buildAnimatedButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFFBA68C8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF9C27B0).withValues(alpha:0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: AppStyles.custom(
                      color: Colors.white,
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
  
  // Text Button
  static Widget buildTextButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppStyles.custom(
          color: color ?? Color(0xFF9C27B0),
          size: 14,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // Toggle Auth Text
  static Widget buildToggleAuthText({
    required String question,
    required String actionText,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: AppStyles.custom(
            color: Colors.grey[600]!,
            size: 14,
            weight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionText,
            style: AppStyles.custom(
              color: Color(0xFF9C27B0),
              size: 14,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  // Password Visibility Icon
  static Widget buildPasswordVisibilityIcon({
    required bool isObscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Color(0xFF9C27B0),
      ),
      onPressed: onPressed,
    );
  }
  
  // Custom App Bar
  static AppBar buildCustomAppBar({String? title}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: title != null ? Text(
        title,
        style: AppStyles.custom(
          color: Color(0xFF4A148C),
          size: 20,
          weight: FontWeight.w600,
        ),
      ) : null,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Color(0xFF9C27B0)),
        onPressed: () => Get.back(),
      ),
    );
  }
}