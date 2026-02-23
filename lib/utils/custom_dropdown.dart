import 'package:flutter/material.dart';

Widget buildStyledDropdown({
  required String labelText,
  required String hintText,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
  String? Function(String?)? validator,
  bool enabled = true,
  Widget? suffixIcon,
  double ? borderRadius 
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
          color: enabled ? Colors.white : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(borderRadius??12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: suffixIcon,
            
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            
          ),
          hint: Text(
            hintText,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          menuMaxHeight: 250,
          items: enabled
              ? items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList()
              : [],
          onChanged: enabled ? onChanged : null,
          validator: validator,
        ),
      ),
    ],
  );
}

