import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchWidget extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final String? initialValue;
  final VoidCallback? onClear;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final TextEditingController? controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CustomSearchWidget({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.initialValue,
    this.onClear,
    this.primaryColor,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = true,
    this.controller,
    this.enabled = true,
    this.keyboardType,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.height,
    this.textStyle,
    this.hintStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primary = primaryColor ?? const Color(0xFF6C5CE7);
    final Color bgColor = backgroundColor ?? Colors.grey[50]!;
    final double radius = borderRadius ?? 12.0;
    final EdgeInsetsGeometry padding = contentPadding ?? 
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    // Use provided controller or create a reactive one
    final TextEditingController textController = controller ?? 
        TextEditingController(text: initialValue);

    // For reactive behavior when no controller is provided
    final RxString searchValue = (initialValue ?? '').obs;

    return Container(
      height: height,
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        style: textStyle,
        onTap: onTap,
        onSubmitted: onSubmitted,
        onChanged: (value) {
          if (controller == null) {
            searchValue.value = value;
          }
          onChanged(value);
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon ?? Icons.search,
            color: primary,
            size: 20,
          ),
          suffixIcon: _buildSuffixIcon(
            primary, 
            textController, 
            searchValue, 
            showClearButton
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: primary.withValues(alpha:0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: primary.withValues(alpha:0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha:0.3),
            ),
          ),
          filled: true,
          fillColor: enabled ? bgColor : Colors.grey[100],
          contentPadding: padding,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(
    Color primaryColor, 
    TextEditingController textController,
    RxString searchValue,
    bool showClear
  ) {
    if (suffixIcon != null) return suffixIcon;
    
    if (!showClear) return null;

    if (controller != null) {
      // Use controller-based approach
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: textController,
        builder: (context, value, child) {
          return value.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: () {
                    textController.clear();
                    onChanged('');
                    onClear?.call();
                  },
                )
              : const SizedBox.shrink();
        },
      );
    } else {
      // Use reactive approach
      return Obx(
        () => searchValue.value.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey,
                  size: 18,
                ),
                onPressed: () {
                  textController.clear();
                  searchValue.value = '';
                  onChanged('');
                  onClear?.call();
                },
              )
            : const SizedBox.shrink(),
      );
    }
  }
}

// Predefined search widget variants for common use cases
class SearchVariants {
  // Compact search for filters
  static Widget compact({
    required String hintText,
    required Function(String) onChanged,
    String? initialValue,
    VoidCallback? onClear,
    Color? primaryColor,
  }) {
    return CustomSearchWidget(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      onClear: onClear,
      primaryColor: primaryColor,
      height: 40,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 10,
    );
  }

  // Large search for main screens
  static Widget large({
    required String hintText,
    required Function(String) onChanged,
    String? initialValue,
    VoidCallback? onClear,
    Color? primaryColor,
  }) {
    return CustomSearchWidget(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      onClear: onClear,
      primaryColor: primaryColor,
      height: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 16,
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  // Minimal search without borders
  static Widget minimal({
    required String hintText,
    required Function(String) onChanged,
    String? initialValue,
    VoidCallback? onClear,
    Color? primaryColor,
  }) {
    return CustomSearchWidget(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      onClear: onClear,
      primaryColor: primaryColor,
      backgroundColor: Colors.transparent,
      borderRadius: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Search with custom icon
  static Widget withIcon({
    required String hintText,
    required Function(String) onChanged,
    required IconData icon,
    String? initialValue,
    VoidCallback? onClear,
    Color? primaryColor,
  }) {
    return CustomSearchWidget(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      onClear: onClear,
      primaryColor: primaryColor,
      prefixIcon: icon,
    );
  }

  // Search with action button
  static Widget withAction({
    required String hintText,
    required Function(String) onChanged,
    required Widget actionWidget,
    String? initialValue,
    VoidCallback? onClear,
    Color? primaryColor,
  }) {
    return CustomSearchWidget(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      onClear: onClear,
      primaryColor: primaryColor,
      suffixIcon: actionWidget,
      showClearButton: false,
    );
  }
}
