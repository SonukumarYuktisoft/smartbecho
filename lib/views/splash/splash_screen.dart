// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:smartbecho/services/jwt_validator.dart';
// import 'package:smartbecho/services/route_services.dart';
// import 'package:smartbecho/services/shared_preferences_services.dart';
// import 'package:smartbecho/services/validate_user.dart';
// import 'dart:math';
// import 'package:smartbecho/utils/app_colors.dart';

// class SmartBechoSplash extends StatefulWidget {
//   const SmartBechoSplash({super.key});

//   @override
//   State<SmartBechoSplash> createState() => _SmartBechoSplashState();
// }

// class _SmartBechoSplashState extends State<SmartBechoSplash>
//     with TickerProviderStateMixin {
//   late AnimationController fadeController;
//   late AnimationController floatController;

//   final List<AnimationController> iconControllers = [];
//   final List<Animation<double>> iconOpacities = [];

//   final List<AnimationController> titleControllers = [];
//   final List<Animation<double>> titleOpacities = [];

//   // Icons and their labels (like HTML)
//   final List<Map<String, String>> icons = [
//     {'emoji': '📦', 'label': 'Inventory Mgmt'},
//     {'emoji': '👥', 'label': 'Customer Mgmt'},
//     {'emoji': '💰', 'label': 'Sales Details'},
//     {'emoji': '📘', 'label': 'Accounting'},
//     {'emoji': '⏰', 'label': 'Dues Reminder'},
//     {'emoji': '📊', 'label': 'Analytics'},
//     {'emoji': '🧾', 'label': 'Invoicing'},
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Fade + Scale animation for Smart Becho text
//     fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..forward();

//     // Floating animation for all icons
//     floatController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat(reverse: true);

//     _startCircularSequence();
//     // Auto navigate after 4 seconds with JWT token check
//     Future.delayed(Duration(seconds: 4), () async {
//       await _checkTokenAndNavigate();
//     });

//   }

//   Future<void> _checkTokenAndNavigate() async {
//     try {

//       bool isonboared = await SharedPreferencesHelper.getIsOnboarding();
//        if (!isonboared) {
//         RouteService.toBoardingScreen();
//         return;
//       }
//       // First check if user has basic login status
//       bool isLoggedIn = await ValidateUser.checkLoginStatus();
      
//       if (!isLoggedIn) {
//         RouteService.toLogin();
//         return;
//       }

//       // Get JWT token using SharedPreferencesHelper
//       final token = await SharedPreferencesHelper.getJwtToken();
      
//       if (token == null || token.isEmpty) {
//         // No token found, navigate to login
//         RouteService.toLogin();
//         return;
//       }

//       // Check if token is expired
//       final isExpired = JwtHelper.isTokenExpired(token);
      
//       if (isExpired) {
//         // Token expired, clear login status and navigate to login
//         print('JWT Token expired, redirecting to login');
//         // Clear the expired token and login status
//         await SharedPreferencesHelper.setIsLoggedIn(false);
//         RouteService.toLogin();
//       } else {
//         // Token is valid, navigate to dashboard
//         print('JWT Token is valid, navigating to dashboard');
//         RouteService.toBottomNavigation();
//       }
//     } catch (e) {
//       print('Error checking token in splash screen: $e');
//       // On error, navigate to login for safety
//       RouteService.toLogin();
//     }
//   }
//   Future<void> _startCircularSequence() async {
//     // Create controllers for icons & titles
//     for (int i = 0; i < icons.length; i++) {
//       final iconCtrl = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 500),
//       );
//       final titleCtrl = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 400),
//       );
//       iconControllers.add(iconCtrl);
//       titleControllers.add(titleCtrl);
//       iconOpacities.add(CurvedAnimation(parent: iconCtrl, curve: Curves.easeIn));
//       titleOpacities.add(CurvedAnimation(parent: titleCtrl, curve: Curves.easeIn));
//     }

//     // Smart Becho show hone ke baad icons ek-ek kar ke aayenge
//     await Future.delayed(const Duration(milliseconds: 900));

//     for (int i = 0; i < icons.length; i++) {
//       await Future.delayed(const Duration(milliseconds: 250));
//       iconControllers[i].forward();
//     }

//     // Jab icons show ho jayein to titles ek-ek kar ke appear ho
//     await Future.delayed(const Duration(milliseconds: 700));
//     for (int i = 0; i < titleControllers.length; i++) {
//       await Future.delayed(const Duration(milliseconds: 200));
//       titleControllers[i].forward();
//     }
//   }

//   @override
//   void dispose() {
//     fadeController.dispose();
//     floatController.dispose();
//     for (final c in iconControllers) {
//       c.dispose();
//     }
//     for (final c in titleControllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final floatAnim = Tween(begin: 0.0, end: -10.0)
//         .chain(CurveTween(curve: Curves.easeInOut))
//         .animate(floatController);

//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: const Color(0xFFE9FAFA),
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: AppColors.primaryGradientLight,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // 🌟 Smart Becho Center Logo
//               FadeTransition(
//                 opacity: fadeController,
//                 child: ScaleTransition(
//                   scale: fadeController,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         'Smart Becho',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 12,
//                               color: Colors.black54,
//                               offset: Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // SizedBox(height: 10),
//                       // Text(
//                       //   'Sell smarter • Track smarter • Grow faster',
//                       //   textAlign: TextAlign.center,
//                       //   style: TextStyle(
//                       //     fontSize: 14,
//                       //     color: Colors.white70,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),

//               // 🌀 Icons arranged in circle
//               ..._buildCircularIcons(size.width / 2.5, floatAnim),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildCircularIcons(double radius, Animation anim) {
//     final List<Widget> widgets = [];
//     final double angleStep = (2 * pi) / icons.length;

//     for (int i = 0; i < icons.length; i++) {
//       final double angle = i * angleStep - pi / 2; // start top
//       final double dx = radius * cos(angle);
//       final double dy = radius * sin(angle);

//       widgets.add(AnimatedBuilder(
//         animation: anim,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(dx, dy + anim.value),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 FadeTransition(
//                   opacity: iconOpacities.isNotEmpty ? iconOpacities[i] : kAlwaysCompleteAnimation,
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 55,
//                         height: 55,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.25),
//                               blurRadius: 15,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: Text(
//                             icons[i]['emoji']!,
//                             style: const TextStyle(fontSize: 22),
//                           ),
//                         ),
//                       ),
//                           const SizedBox(height: 5),
//                         Text(
//                   icons[i]['label']!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black45,
//                         offset: Offset(0, 1),
//                         blurRadius: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 // Text(
//                 //   icons[i]['label']!,
//                 //   textAlign: TextAlign.center,
//                 //   style: const TextStyle(
//                 //     fontSize: 10,
//                 //     color: Colors.white,
//                 //     fontWeight: FontWeight.w500,
//                 //     shadows: [
//                 //       Shadow(
//                 //         color: Colors.black45,
//                 //         offset: Offset(0, 1),
//                 //         blurRadius: 2,
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//               ],
//             ),
//           );
//         },
//       ));
//     }
//     return widgets;
//   }
// }



