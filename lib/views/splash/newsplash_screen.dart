import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/services/jwt_validator.dart';
import 'package:smartbecho/services/route_services.dart';

import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/services/validate_user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String appVersion = "";

  @override
  void initState() {
    super.initState();
    // _loadAppVersion();
    _checkTokenAndNavigate();
  }

  // Future<void> _loadAppVersion() async {
  //   final info = await PackageInfo.fromPlatform();
  //   setState(() {
  //     appVersion = info.version; // real app version
  //   });
  // }

  Future<void> _checkTokenAndNavigate() async {
    try {
      bool isOnboarded = await SharedPreferencesHelper.getIsOnboarding();
      if (!isOnboarded) {
        RouteService.toBoardingScreen();
        return;
      }

      bool isLoggedIn = await ValidateUser.checkLoginStatus();
      if (!isLoggedIn) {
        RouteService.toLogin();
        return;
      }

      final token = await SharedPreferencesHelper.getJwtToken();
      if (token == null || token.isEmpty) {
        RouteService.toLogin();
        return;
      }

      final isExpired = JwtHelper.isTokenExpired(token);
      if (isExpired) {
        await SharedPreferencesHelper.setIsLoggedIn(false);
        RouteService.toLogin();
      } else {
        RouteService.toBottomNavigation();
      }
    } catch (e) {
      print('Error during splash checks: $e');
      RouteService.toLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      backgroundColor:Colors.white,
      // body: Stack(
      //   children: [
      //     Center(
      //       child: Image.asset(
      //         'assets/icons/splash_icon.png',
      //         width: 150,
      //         height: 150,
      //       ),
      //     ),
      //     Positioned(
      //       bottom: 20,
      //       left: 0,
      //       right: 0,
      //       child: Center(
      //         child: Text(
      //           "v 1.0.0+1",
      //           style: const TextStyle(color: Colors.grey, fontSize: 12),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
