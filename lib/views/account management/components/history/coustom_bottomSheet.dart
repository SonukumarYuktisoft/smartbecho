import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

Future<T?> showCustomBottomSheet<T>({
  required Widget child,
  bool isScrollControlled = true,
  Color backgroundColor = Colors.white,
  double borderRadius = 16,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent, // ✅ allows visible rounded corners
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(borderRadius),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: child,
              ),
            ],
          ),
        ),
      );
    },
  );
}
