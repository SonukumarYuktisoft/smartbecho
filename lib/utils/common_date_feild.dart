 import 'package:flutter/material.dart';

Widget buildDateField({
    required String labelText,
    required TextEditingController controller,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Date',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

 