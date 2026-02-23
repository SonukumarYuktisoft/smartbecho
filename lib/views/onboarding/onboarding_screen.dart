import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/onboarding%20controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController onboardingController = Get.put(
      OnboardingController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final currentItem =
            onboardingController.onboardingItems[onboardingController
                .currentPage
                .value];

        // ✅ Update status bar and navigation bar colors dynamically
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,

            // statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            // systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );

        return SafeArea(
          top: false, 
          bottom: false, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: currentItem.color,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  // ✅ Top padding for status bar area
                  SizedBox(height: MediaQuery.of(context).padding.top),

                  // Top Bar with Skip/Done button
                  _buildTopBar(onboardingController),

                  // Page Indicator
                  _buildPageIndicator(onboardingController),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  // PageView for swipe - ✅ Takes remaining space
                  Expanded(
                    child: PageView.builder(
                      controller: onboardingController.pageController,
                      onPageChanged: onboardingController.onPageChanged,
                      itemCount: onboardingController.onboardingItems.length,
                      itemBuilder: (context, index) {
                        return _buildOnboardingPage(
                          onboardingController.onboardingItems[index],
                          onboardingController,
                          context,
                        );
                      },
                    ),
                  ),

                  // Bottom Buttons Section - ✅ Fixed size, no overflow
                  _buildBottomSection(context),

                  // ✅ Bottom padding for navigation bar area
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ============================================================================
  // BOTTOM SECTION (Login Button + Signup Prompt)
  // ============================================================================
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical:
            MediaQuery.of(context).size.height * 0.02, // ✅ Responsive padding
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Take minimum space needed
        children: [
          // Login Button
          _buildLoginButton(context),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ), // ✅ Responsive spacing
          // Signup Prompt
          _buildSignupPrompt(),
        ],
      ),
    );
  }

  // ============================================================================
  // TOP BAR (Skip/Done Button)
  // ============================================================================
  Widget _buildTopBar(OnboardingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            final isLastPage =
                controller.currentPage.value ==
                controller.onboardingItems.length - 1;

            return TextButton(
              onPressed:
                  isLastPage
                      ? controller.completeOnboarding
                      : controller.skipOnboarding,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLastPage ? 'Done' : 'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE INDICATOR (Dots)
  // ============================================================================
  Widget _buildPageIndicator(OnboardingController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.onboardingItems.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: controller.currentPage.value == index ? 50 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  controller.currentPage.value == index
                      ? AppColors.primaryLight
                      : AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ONBOARDING PAGE CONTENT
  // ============================================================================
  Widget _buildOnboardingPage(
    OnboardingItem item,
    OnboardingController onboardingController,
    BuildContext context,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: onboardingController.fadeAnimation,
      child: SlideTransition(
        position: onboardingController.slideAnimation,
        child: SingleChildScrollView(
          physics:
              const NeverScrollableScrollPhysics(), // ✅ Disable scroll inside PageView
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.032, // ✅ Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03), // ✅ Responsive spacing
                // Image
                _buildImageContainer(item, context),

                SizedBox(height: screenHeight * 0.03), // ✅ Responsive spacing
                // Description
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.018, // ✅ Responsive font size
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  // maxLines: 3, // ✅ Limit lines to prevent overflow
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // IMAGE CONTAINER
  // ============================================================================
  Widget _buildImageContainer(OnboardingItem item, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.45, // ✅ Responsive height (30% of screen)
      constraints: BoxConstraints(
        maxHeight: 350, // ✅ Maximum height cap
        minHeight: 200, // ✅ Minimum height for small phones
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(200),
          topRight: Radius.circular(200),
        ),
        child: Image.asset(
          item.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(200),
                  topRight: Radius.circular(200),
                ),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: screenHeight * 0.12, // ✅ Responsive icon size
                  color: item.color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // LOGIN BUTTON
  // ============================================================================
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.065, // ✅ Responsive height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryLight.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Get.offNamed(AppRoutes.login);
        },
        child: Text(
          'Login',
          style: TextStyle(
            fontSize:
                MediaQuery.of(context).size.height * 0.022, // ✅ Responsive font
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SIGNUP PROMPT
  // ============================================================================
  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.offNamed(AppRoutes.signup);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
