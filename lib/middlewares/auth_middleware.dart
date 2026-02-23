import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/services/jwt_validator.dart';
import 'package:smartbecho/services/route_services.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

import '../services/validate_user.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    _checkAuthAndRedirect();
    return page;
  }

  void _checkAuthAndRedirect() async {
    log("Authenticating...");
    try {
      final isLoggedIn = await ValidateUser.checkLoginStatus();
      final token = await SharedPreferencesHelper.getJwtToken();
      final isExpired = JwtHelper.isTokenExpired(token ?? '');

      if (!isLoggedIn || token == null || token.isEmpty || isExpired) {
        await SharedPreferencesHelper.setIsLoggedIn(false);
        RouteService.toLogin(clearStack: true);
      }
    } catch (e) {
      print('AuthMiddleware error: $e');
      RouteService.toLogin(clearStack: true);
    }
  }
}
