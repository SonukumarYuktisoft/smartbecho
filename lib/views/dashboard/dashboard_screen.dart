import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/controllers/user_prefs_controller.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/network/connectivity_mixin.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common_profile_button.dart';
import 'package:smartbecho/views/dashboard/dashboard_sections/account_summary_section.dart';
import 'package:smartbecho/views/dashboard/dashboard_sections/donut_charts_section.dart';
import 'package:smartbecho/views/dashboard/dashboard_sections/revenue_chart_section.dart';
import 'package:smartbecho/views/dashboard/dashboard_sections/statistics_section.dart';
import 'package:smartbecho/views/dashboard/dashboard_sections/welcome_section.dart';
import 'package:smartbecho/views/dashboard/widgets/dashboard_shimmers.dart';
import 'package:smartbecho/views/dashboard/widgets/drawer.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({Key? key}) : super(key: key);

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard>
    with TickerProviderStateMixin, ConnectivityAware {
  final DashboardController controller = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();
  final AccountManagementController accountManagementController =
      Get.find<AccountManagementController>();
  final UserPrefsController userPrefsController =
      Get.find<UserPrefsController>();
  final FeatureController featureController = Get.put(FeatureController());
  late AnimationController _chartAnimationController;
  late AnimationController _cardAnimationController;

  @override
  void onConnectivityChanged(d) {
    super.onConnectivityChanged(isConnected);
    if (d) {
      // controller.
    }
  }

  @override
  void initState() {
    super.initState();
    featureController.loadPermissionsAfterLogin();
    accountManagementController.fetchAccountSummaryDashboard();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          actionsPadding: const EdgeInsets.only(right: 16),
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          title: const Text(
            "Smart Becho",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryLight,
          actions: [buildProfileButton(() => Get.toNamed(AppRoutes.profile))],
        ),
        drawer: ModernAppDrawer(),
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: controller.animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.fadeAnimation,
                child: SlideTransition(
                  position: controller.slideAnimation,
                  child: AppRefreshIndicator(
                    onRefresh: controller.refreshDashboardData,

                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Obx(() {
                        if (controller.isAllDataLoading.value) {
                          return _buildLoadingContent();
                        }

                        if (controller.hasGlobalError.value) {
                          return _buildErrorContent();
                        }

                        return _buildMainContent();
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        WelcomeSection(),
        const SizedBox(height: 28),
        const DashboardKPICardsShimmer(),
        const SizedBox(height: 32),
        const FinancialOverviewShimmer(),
        const SizedBox(height: 32),
        const DashboardChartShimmer(title: "Revenue Analytics"),
        const SizedBox(height: 24),
        const DashboardChartShimmer(
          title: "Customer Distribution",
          height: 390,
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.globalErrorMessage.value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Welcome Section
        WelcomeSection(),
        const SizedBox(height: 10),
        // Statistics Section
        StatisticsSection(),
        const SizedBox(height: 10),

        // Donut Charts Section (Customers & Dues)
        DonutChartsSection(),
        const SizedBox(height: 10),

        // Account Summary Section
        AccountSummarySection(),
        const SizedBox(height: 10),

        // Revenue Chart Section
        RevenueChartSection(),

        const SizedBox(height: 80),
      ],
    );
  }
}
