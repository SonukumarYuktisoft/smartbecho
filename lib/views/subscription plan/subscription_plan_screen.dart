import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/subscription_plan_model.dart';
import 'package:smartbecho/views/subscription%20plan/paymet_page.dart';
import 'package:smartbecho/services/configs/plan_config.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  final SubscriptionController _controller = Get.put(
    SubscriptionController(),
  );
  final selectedPeriod = 'MONTHLY'.obs;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.getSubscriptionPlans();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (_controller.plansLoading.value) {
          return Center(
            child: const CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        }

        if (_controller.plansWithUpgrade.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No subscription plans available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: false,
              pinned: true,
              expandedHeight: 280,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                ),
              ),
              centerTitle: true,
              title: const Text(
                'Pricing Plans',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choose Your Perfect Plan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Manage inventory smarter and faster with Smart Becho',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_controller.currentSubscriptions.isNotEmpty)
                        _buildCurrentSubscriptionBanner(),
                    ],
                  ),
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 80,
                maxHeight: 80,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: _buildCustomScrollableToggle(),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 16,
                  vertical: 32,
                ),
                child: Obx(() {
                  if (_controller.plansLoading.value) {
                    return const Center(
                      child: SizedBox(
                        height: 100,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    );
                  }

                  // 🔥 Group plans by planCode and get the one matching selected period
                  final Map<String, List<SubscriptionPlanWithUpgrade>> groupedPlans = {};
                  for (var plan in _controller.plansWithUpgrade) {
                    final key = plan.planCode?.trim() ?? '';
                    if (!groupedPlans.containsKey(key)) {
                      groupedPlans[key] = [];
                    }
                    groupedPlans[key]!.add(plan);
                  }

                  // 🔥 Get plans for selected period
                  final displayPlans = <SubscriptionPlanWithUpgrade>[];
                  for (var planGroup in groupedPlans.values) {
                    final planForPeriod = planGroup.firstWhereOrNull(
                      (p) => p.period == selectedPeriod.value,
                    );
                    if (planForPeriod != null) {
                      displayPlans.add(planForPeriod);
                    }
                  }

                  return isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: displayPlans.map((plan) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _buildPricingCard(plan),
                              ),
                            );
                          }).toList(),
                        )
                      : isTablet
                          ? Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: displayPlans.map((plan) {
                                return SizedBox(
                                  width: (screenWidth - 48) / 2,
                                  child: _buildPricingCard(plan),
                                );
                              }).toList(),
                            )
                          : Column(
                              children: displayPlans.map((plan) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildPricingCard(plan),
                                );
                              }).toList(),
                            );
                }),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Cancel anytime • Secure payment',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentSubscriptionBanner() {
    return Obx(() {
      if (_controller.currentSubscriptionLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: const SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
              ),
            ),
          ),
        );
      }

      if (_controller.currentSubscriptions.isEmpty) {
        return const SizedBox.shrink();
      }

      final currentSub = _controller.currentSubscriptions.first;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Subscription',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentSub.planNameSnapshot ?? "Plan"} • '
                    '${currentSub.period == 'MONTHLY' ? 'Monthly' : 'Yearly'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCustomScrollableToggle() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToggleButton('Monthly', 'MONTHLY'),
              _buildToggleButton(
                'Yearly',
                'YEARLY',
                badge: 'Save 16%',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, {String? badge}) {
    final isActive = selectedPeriod.value == value;

    return GestureDetector(
      onTap: () => selectedPeriod.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
            if (badge != null && isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(SubscriptionPlanWithUpgrade planWithUpgrade) {
    final features = _parseFeatures(planWithUpgrade.featuresJson);
    final isPopular = planWithUpgrade.planName?.toLowerCase().contains('pro') ?? false;
    final isBasic = (planWithUpgrade.basePrice ?? 0) == 0;
    final planConfig = PlanConfig.getPlanByName(planWithUpgrade.planName ?? 'pro');

    return Obx(() {
      // 🔥 Determine button state based on API response
      final isSamePlan = planWithUpgrade.isSamePlan ?? false;
      final canPurchase = planWithUpgrade.canPurchase ?? true;
      final isUpgrade = planWithUpgrade.isUpgrade ?? false;
      final isFree = (planWithUpgrade.upgradePrice ?? 0) <= 0;

      // 🔥 Button text logic
      String buttonText;
      bool isButtonDisabled;

      if (isSamePlan) {
        buttonText = 'Current Plan';
        isButtonDisabled = true;
      } else if (!canPurchase) {
        buttonText = 'Not Available';
        isButtonDisabled = true;
      } else if (isBasic) {
        buttonText = 'Get Started';
        isButtonDisabled = false;
      } else if (isUpgrade) {
        buttonText = 'Upgrade';
        isButtonDisabled = false;
      } else {
        buttonText = 'Subscribe Now';
        isButtonDisabled = false;
      }

      return Container(
        constraints: const BoxConstraints(minHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPopular
              ? Border.all(color: AppColors.primaryLight, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isPopular
                  ? AppColors.primaryLight.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isPopular ? 20 : 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isPopular
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primaryLight.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: planConfig['gradientColors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isPopular ? null : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ MOST POPULAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isPopular) const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: isPopular ? Colors.white : Colors.black87,
                        highlightColor: isPopular
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.8),
                        period: const Duration(milliseconds: 2000),
                        child: Text(
                          planWithUpgrade.planName ?? 'Unknown Plan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isPopular ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSamePlan)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (planWithUpgrade.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      planWithUpgrade.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isPopular
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPopular
                              ? Colors.white
                              : AppColors.primaryLight,
                        ),
                      ),
                      Text(
                        isBasic
                            ? 'Free'
                            : (planWithUpgrade.upgradePrice?.toStringAsFixed(0) ?? '0'),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: isPopular
                              ? Colors.white
                              : AppColors.primaryLight,
                        ),
                      ),
                      if (!isBasic) ...[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '/${selectedPeriod.value == 'MONTHLY' ? 'month' : 'year'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isPopular
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // 🔥 Show discount badge if upgrade price differs from base
                  if (isUpgrade && !isFree && planWithUpgrade.basePrice != planWithUpgrade.upgradePrice) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Discounted from ₹${planWithUpgrade.basePrice?.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (features.isNotEmpty)
                    ...features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  if (planWithUpgrade.trialDays != null && planWithUpgrade.trialDays! > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Trial days Available (${planWithUpgrade.trialDays} days)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (planWithUpgrade.maxShopsAllowed != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Max shops/Users allowed (${planWithUpgrade.maxShopsAllowed})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonDisabled
                      ? null
                      : () {
                          // 🔥 Navigate directly to PaymentPage with planWithUpgrade
                          Get.to(() => PaymentPage(
                            planWithUpgrade: planWithUpgrade,
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonDisabled
                        ? Colors.grey[400]
                        : (isPopular
                            ? AppColors.primaryLight
                            : Colors.white),
                    foregroundColor: isButtonDisabled
                        ? Colors.grey[700]
                        : (isPopular
                            ? Colors.white
                            : AppColors.primaryLight),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isButtonDisabled
                          ? BorderSide.none
                          : (isPopular
                              ? BorderSide.none
                              : BorderSide(
                                  color: AppColors.primaryLight,
                                  width: 2,
                                )),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isButtonDisabled ? Colors.grey[700] : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<String> _parseFeatures(String? featuresJson) {
    if (featuresJson == null || featuresJson.isEmpty) return [];
    try {
      final List decoded = json.decode(featuresJson);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
}

// 🔥 Sticky header delegate (unchanged)
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}