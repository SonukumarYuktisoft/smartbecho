import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/views/customer/customer_sections/customer%20sub%20sections/customer_list_states.dart';
import 'package:smartbecho/views/customer/widgets/customer_card_widget.dart';

/// Compact customer card list with infinite scroll
/// Displays customer cards with pagination support
class BuildCompactCustomerCard extends StatelessWidget {
  BuildCompactCustomerCard({super.key});

  final CustomerController controller = Get.find<CustomerController>();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _setupScrollListener();

    return Obx(() {
      if (controller.hasError.value) {
        return CustomerListStates.error(
          errorMessage: controller.errorMessage.value,
          onRetry: () => controller.loadCustomersFromApi(loadMore: false),
        );
      }

      if (controller.isLoading.value) {
        return CustomerListStates.loading();
      }

      if (controller.filteredApiCustomers.isEmpty) {
        return CustomerListStates.empty(
          searchQuery: controller.searchQuery.value,
          onClearFilters: controller.resetFilters,
        );
      }

      return _buildCustomerList();
    });
  }

  /// Setup infinite scroll listener
  void _setupScrollListener() {
    if (!_scrollController.hasListeners) {
      _scrollController.addListener(() {
        if (_shouldLoadMore()) {
          controller.loadMoreCustomersn();
        }
      });
    }
  }

  /// Check if should load more customers
  bool _shouldLoadMore() {
    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - 200 &&
        !controller.isLoadingMore.value &&
        !controller.isLoading.value &&
        !controller.isLastPage.value;
  }

  /// Build customer list with pagination
  Widget _buildCustomerList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.filteredApiCustomers.length +
          (controller.isLoadingMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.filteredApiCustomers.length) {
          return _buildLoadingIndicator();
        }

        final customer = controller.filteredApiCustomers[index];
        return CustomerCardWidget(
          customer: customer,
          controller: controller,
        );
      },
    );
  }

  /// Build loading indicator for pagination
  Widget _buildLoadingIndicator() {
    if (!controller.isLoadingMore.value) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
          strokeWidth: 2,
        ),
      ),
    );
  }
}