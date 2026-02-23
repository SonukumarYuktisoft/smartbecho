import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_filters_section.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_floating_action_buttons.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_header_section.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_list_section.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_stats_section.dart';

class InventoryManagementScreen extends StatelessWidget {
  final InventoryController controller = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inventory Management',
        onPressed: () => Get.find<BottomNavigationController>().setIndex(0),
        actionItem: [
          IconButton(
            onPressed: controller.refreshData,

            icon: Icon(
              Icons.refresh,
              // color: const Color(0xFF6C5CE7),
              size: 25,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      floatingActionButton: InventoryFloatingActionButtons(
        controller: controller,
      ),
      body: SafeArea(
        child: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // Stats Cards Section
              SliverToBoxAdapter(
                child: InventoryStatsSection(controller: controller),
              ),

              // Filters Section
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  minHeight: 80,
                  maxHeight: 80,
                  child: Container(
                    color: Colors.grey[50],
                    child: InventoryFiltersSection(controller: controller),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: InventoryHeaderSection(controller: controller),
              ),
            ];
          },
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: InventoryListSection(controller: controller),
          ),
        ),
      ),
    );
  }
}
