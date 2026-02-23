import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/emi_settlement_controller.dart';
import 'package:smartbecho/utils/common/common_dropdown_search.dart';

class CompanyFilterDropdown extends StatelessWidget {
  final EmiSettlementController controller;

  const CompanyFilterDropdown({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading indicator
      if (controller.isCompanyLoading.value) {
        return Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final companies = controller.companyOptions.toList();

      return CommonDropdownSearch<String>(
        items: companies,
        selectedItem: controller.selectedCompany.value,
        labelText: 'Company',
        hintText: 'Select company',
        prefixIcon: Icons.business,
        showSearch: true,
        enabled: true,
        itemAsString: (String company) => company,
        compareFn: (String item1, String item2) => item1 == item2,
        onChanged: (String? value) {
          if (value != null) {
            controller.onCompanyChanged(value);
          }
        },
        // validator: (String? value) {
        //   if (value == null || value.isEmpty) {
        //     return 'Please select a company';
        //   }
        //   return null;
        // },
      );
    });
  }
}