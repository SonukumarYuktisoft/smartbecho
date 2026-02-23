import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showConfirmationBottomSheet({
  String? title,
  String? message,
  String? highlightedValue,
  required VoidCallback onEdit,
  required VoidCallback onContinue,
}) {
  Get.bottomSheet(
    isDismissible: false,
    enableDrag: false,
    PopScope(
      canPop: false,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Warning Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade600,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title (Optional)
              if (title != null && title.isNotEmpty)
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (title != null && title.isNotEmpty) const SizedBox(height: 12),

              // Message with Highlighted Value
              if (message != null && message.isNotEmpty)
                Center(
                  child: _buildMessageWithHighlight(message, highlightedValue),
                ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        onEdit();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}

// ✅ Helper function to build message with highlighted value
Widget _buildMessageWithHighlight(String message, String? highlightedValue) {
  if (highlightedValue == null || highlightedValue.isEmpty) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF6B7280),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Split message by the highlighted value
  final parts = message.split(highlightedValue);

  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF6B7280),
        height: 1.5,
      ),
      children: [
        TextSpan(text: parts[0]),
        TextSpan(
          text: highlightedValue,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444), // Red highlight
            backgroundColor: Color(0xFFFEE2E2), // Light red background
          ),
        ),
        if (parts.length > 1) TextSpan(text: parts[1]),
      ],
    ),
  );
}
