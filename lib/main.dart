import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/routes/app_pages.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/network/connectivity_manager.dart';
import 'package:smartbecho/services/network/connectivity_wrapper.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/congratulations_page.dart';
import 'package:smartbecho/utils/page_not_found.dart';
import 'package:smartbecho/utils/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await ConnectivityManager().initialize();
  // 🔥 Initialize core services
   Get.put(FeatureController(), permanent: true);
  

  // 📱 Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🌍 Load environment variables
  await dotenv.load(fileName: ".env");

  // 🚀 Initialize API service (sets up interceptors)
  final apiService = ApiServices();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (BuildContext context) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        builder: (context, child) {
          return ConnectivityWrapper(
            showBanner: true,
            child: SafeArea(
              top: false,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: child!,
                  ),
                ],
              ),
            ),
          );
        },
        title: 'SmartBecho',
        theme: AppTheme.lightTheme,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        unknownRoute: GetPage(
          name: AppRoutes.notFound,
          page: () => PageNotFoundScreen(),
        ),
        debugShowCheckedModeBanner: false,
      
      ),
    );
  }
}