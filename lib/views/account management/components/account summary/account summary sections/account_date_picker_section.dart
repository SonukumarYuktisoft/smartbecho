// lib/views/account_management/components/sections/account_date_picker_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';

class AccountDatePickerSection extends StatelessWidget {
  final AccountManagementController controller;
  // final VoidCallback onDatePicked;
  // final VoidCallback onResetToday;
  // final VoidCallback onClearData;

  const AccountDatePickerSection({
    Key? key,
    required this.controller,
    // required this.onDatePicked,
    // required this.onResetToday,
    // required this.onClearData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void openDatePicker() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryLight,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        controller.updateSelectedDate(pickedDate);
      }
    }

    void _clearData() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Clear Data'),
              content: const Text('Are you sure you want to clear all data?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.clearAllData();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
    }

    void _resetToToday() {
      controller.updateSelectedDate(DateTime.now());
    }

    return Obx(() {
      return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Date and Edit Row
          OutlinedButton.icon(
            onPressed: openDatePicker,
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
      
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.formattedSelectedDate,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            icon: Icon(Icons.calendar_today, size: 20, color: Colors.white),
             style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10),
      
                side: BorderSide(color: Colors.white)),
                
              ),
         
          if (controller.isActiveAc.value) ...[
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                controller.updateSelectedDate(DateTime.now());
              },
              label: Text(
                'Clear Filter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.clear, size: 18, color: const Color.fromARGB(255, 251, 1, 1)),
              style: OutlinedButton.styleFrom(
                               padding: EdgeInsets.symmetric(horizontal: 10),
      
                side: BorderSide(color: Colors.red,width: 1.5),
              ),
            ),
          ],
        ],
      );
    });
  }
}
