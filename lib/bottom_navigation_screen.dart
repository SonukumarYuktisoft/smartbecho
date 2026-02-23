import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/controllers/user_prefs_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/account%20management/account_management.dart';
import 'package:smartbecho/views/bill%20history/bill_history.dart';
import 'package:smartbecho/views/customer%20dues/customer_dues_management.dart';
import 'package:smartbecho/views/dashboard/dashboard_screen.dart';
import 'package:smartbecho/views/inventory/inventory_management.dart';
import 'package:smartbecho/views/sales%20management/sales_managenment_screen.dart';

/// Controller to manage the selected tab
class BottomNavigationController extends GetxController {
  final InventoryController inventoryController = Get.put<InventoryController>(
    InventoryController(),
  );
  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );
  final CustomerController customerController = Get.put(CustomerController());
  final SalesManagementController salesManagementController = Get.put(
    SalesManagementController(),
  );
  final AuthController authController = Get.put(AuthController());
  final CustomerDuesController customerDuesController = Get.put(
    CustomerDuesController(),
  );
  final UserPrefsController userPrefsController = Get.put(
    UserPrefsController(),
    permanent: true,
  );
  final AccountManagementController accountManagementController = Get.put(
    AccountManagementController(),
  );
  final BillHistoryController billHistoryController = Get.put(
    BillHistoryController(),
  );

  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is int) {
      selectedIndex.value = Get.arguments;
    }
  }

  void setIndex(int i) => selectedIndex.value = i;

  // Your actual pages
  final pages = <Widget>[
    InventoryDashboard(),
    InventoryManagementScreen(),
    BillsHistoryPage(),
    SalesManagementScreen(),
    CustomerDuesManagementScreen(),
    AccountManagementScreen(),
  ];
}

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BottomNavigationController());

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: c.selectedIndex.value, children: c.pages),
        bottomNavigationBar: CustomBottomNav(),
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final BottomNavigationController c = Get.find();

  final List<Map<String, dynamic>> items = [
    {'icon': Icons.home_filled, 'label': 'Dashboard'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Inventory'},
    {'icon': Icons.receipt_long_outlined, 'label': 'Bills'},
    {'icon': Icons.sell_outlined, 'label': 'Sales'},
    {'icon': Icons.money_off_csred_outlined, 'label': 'Dues'},
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Accounts'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = c.selectedIndex.value == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => c.setIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 14 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // ⭐ IMPORTANT
                      children: [
                        Icon(
                          items[index]['icon'],
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 22,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            items[index]['label'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
