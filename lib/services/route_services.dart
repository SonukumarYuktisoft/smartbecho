import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';

class RouteService {
  static void toLogin({bool clearStack = false}) {
    if (clearStack) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  static void toSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  static void toResetPassword() {
    Get.toNamed(AppRoutes.resetPassword);
  }

  static void toVerifyEmail({Map<String, dynamic>? parameters}) {
    Map<String, String>? stringParameters;
    if (parameters != null) {
      stringParameters = parameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
    Get.toNamed(AppRoutes.verifyEmail, parameters: stringParameters);
  }

  // Main App Navigation
  static void toDashboard() {
    Get.toNamed(AppRoutes.dashboard);
  }
static void toBottomNavigation() {
    Get.toNamed(AppRoutes.bottomNavigation);
  }
  static void toProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  static void toSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  // Special Navigation Methods
  static void toBoardingScreen() {
    Get.offAllNamed(AppRoutes.onboardingScreen);
  }

  static void logout() {
    // Clear all data and go to login
    Get.delete<AuthController>(force: true);
    Get.deleteAll(force: true);
    Get.offAllNamed(AppRoutes.splash);
  }

  static void backToLogin() {
    Get.offNamedUntil(AppRoutes.login, (route) => false);
  }

  // Navigation with parameters
  static void toLoginWithEmail(String email) {
    Get.toNamed(AppRoutes.login, parameters: {'email': email});
  }

  static void toSignupWithEmail(String email) {
    Get.toNamed(AppRoutes.signup, parameters: {'email': email});
  }

  // // Back navigation
  // static void goBack() {
  //   if (Get.canPop()) {
  //     Get.back();
  //   } else {
  //     Get.offAllNamed(AppRoutes.home);
  //   }
  // }

  // // Check if can go back
  // static bool canGoBack() {
  //   return Get.canPop();
  // }

  // Get current route
  static String getCurrentRoute() {
    return Get.currentRoute;
  }

  // Navigation with result
  static Future<T?> toWithResult<T>(
    String routeName, {
    dynamic arguments,
  }) async {
    return Get.toNamed<T>(routeName, arguments: arguments);
  }

  // Replace current route
  static void offAndToNamed(String routeName, {dynamic arguments}) {
    Get.offAndToNamed(routeName, arguments: arguments);
  }
}
