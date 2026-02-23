 import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';

Widget buildDatePickerField({
    required BuildContext context,
    required String labelText,
    required String hintText,
    required String selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate.isEmpty ? hintText : selectedDate,
                    style: TextStyle(
                      color:
                          selectedDate.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF374151),
                      fontSize: 14,
                      fontWeight:
                          selectedDate.isEmpty
                              ? FontWeight.w400
                              : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
