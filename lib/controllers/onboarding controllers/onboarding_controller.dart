import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class OnboardingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Dashboard',
      description: 'Get comprehensive insights and analytics at a glance',
      icon: Icons.dashboard_outlined,
      color: Color.fromARGB(255, 216, 220, 241),
      imagePath: AppImagesString.onboardingDashboard,
    ),
    OnboardingItem(
      title: 'Inventory Management',
      description: 'Real-time inventory tracking and stock management',
      icon: Icons.inventory_2_outlined,
      color: Color.fromARGB(255, 240, 220, 213),
      imagePath: AppImagesString.onboardingInventoryManagement,
    ),
    OnboardingItem(
      title: 'Account Management',
      description: 'Keep track of all your accounts and financial transactions',
      icon: Icons.account_balance_wallet_outlined,
      color: Color.fromARGB(255, 205, 240, 215),
      imagePath: AppImagesString.onboardingAccountManagement,
    ),

    OnboardingItem(
      title: 'HSN Code Management',
      description:
          'Manage and organize HSN codes efficiently for all your products',
      icon: Icons.qr_code_outlined,
      color: Color(0xFFFFE6CD),
      imagePath: AppImagesString.onboardingHSNCode,
    ),

    OnboardingItem(
      title: 'Dues Management',
      description: 'Monitor and manage pending payments and receivables',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFF0E3FD),
      imagePath: AppImagesString.onboardingDuesManagement,
    ),
    OnboardingItem(
      title: 'Sales Management',
      description: 'Track sales, generate invoices, and analyze performance',
      icon: Icons.point_of_sale_outlined,
      color: Color.fromARGB(255, 227, 249, 253),
      imagePath: AppImagesString.onboardingSalesManagement,
    ),
    OnboardingItem(
      title: 'Customer Management',
      description: 'Maintain detailed customer records and relationships',
      icon: Icons.people_outline_rounded,
      color: Color.fromARGB(255, 253, 227, 241),
      imagePath: AppImagesString.onboardingCustomerManagement,
    ),
    OnboardingItem(
      title: 'Product Returns',
      description: 'Handle product returns and refunds seamlessly',
      icon: Icons.keyboard_return_outlined,
      color: Color.fromARGB(255, 253, 227, 251),
      imagePath: AppImagesString.onboardingProductReturns,
    ),
    OnboardingItem(
      title: 'Bill History',
      description: 'Access complete billing history and transaction records',
      icon: Icons.history_outlined,
      color: Color.fromARGB(255, 218, 240, 243),
      imagePath: AppImagesString.onboardingBillHistory,
    ),
    OnboardingItem(
      title: 'Poster Generation',
      description:
          'Create stunning posters for your products and promotions with ease',
      icon: Icons.image_outlined,
      color: Color(0xFFFEFA99),
      imagePath: AppImagesString.onboardingPosterGeneration,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    animationController.forward();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skipOnboarding() {
    // Navigate to last page or complete onboarding
    pageController.jumpToPage(onboardingItems.length - 1);
  }

  void completeOnboarding() async {
    await SharedPreferencesHelper.setIsOnboarding(true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    super.onClose();
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String imagePath;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.imagePath,
  });
}
