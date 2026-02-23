import 'dart:developer';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/permission_storage.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_status.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/models/permission%20handal%20models/permission_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class FeatureController extends GetxController {
  final PermissionStorage _storage = PermissionStorage();
  // API service instance
  final ApiServices _apiService = ApiServices();

  // App config instance
  final AppConfig _config = AppConfig.instance;

  // 📊 Features
  final RxMap<String, FeatureStatus> features = <String, FeatureStatus>{}.obs;

  // 📊 Sections
  final RxMap<String, FeatureStatus> sections = <String, FeatureStatus>{}.obs;

  @override
  void onInit() {
    super.onInit();
    log('🎯 [FeatureController] Initialized');
  }

  /// 📥 Load from storage
  Future<void> loadPermissions() async {
    try {
      log('📥 [FeatureController] Loading permissions...');

      final all = await _storage.readAll();
      final rawFeatures = all['features'] as Map<String, String>? ?? {};
      final rawSections = all['sections'] as Map<String, String>? ?? {};

      _parseFeatures(rawFeatures);
      _parseSections(rawSections);

      log(
        '✅ [FeatureController] Loaded ${features.length} features, ${sections.length} sections',
      );
    } catch (e) {
      log('❌ [FeatureController] Load error: $e');
    }
  }

  Future<void> loadPermissionsAfterLogin() async {
    try {
      log('📥 [AuthController] Loading permissions...');

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.permissionsEndpoint,

        authToken: true,
      );

      if (response == null || response.statusCode != 200) {
        log('⚠️ [AuthController] Failed to fetch permissions');
        return;
      }

      log('✅ [AuthController] Permissions response received');

      final permissionModel = PermissionResponseModel.fromJson(response.data);

      log(
        '📊 [AuthController] Features: ${permissionModel.payload?.features.length ?? 0}',
      );
      log(
        '📊 [AuthController] Sections: ${permissionModel.payload?.sectionPermissions.length ?? 0}',
      );

      await PermissionStorage().save(permissionModel);

      log('✅ [AuthController] Permissions saved to storage');

      if (Get.isRegistered<FeatureController>()) {
        final controller = Get.find<FeatureController>();
        await controller.loadFromResponse(permissionModel);
        log('✅ [AuthController] Permissions loaded into controller');
        log('   ├─ Total features: ${controller.getAllFeatures().length}');
        log('   └─ Total sections: ${controller.getAllSections().length}');
      } else {
        log('⚠️ [AuthController] FeatureController not registered');
      }
    } catch (e) {
      log('⚠️ [AuthController] Permission loading error: $e');
      // Don't block login if permissions fail
    }
  }

  // // AuthController class mein ye method add karo
  // Future<void> loadPermissionsAfterLogin() async {
  //   try {
  //     // 1. Fetch permissions from API
  //     dio.Response? response = await _apiService.requestGetForApi(
  //       url: _config.permissionsEndpoint,
  //       authToken: true, // JWT token use karega
  //     );

  //     if (response != null && response.statusCode == 200) {
  //       // 2. Parse and save to storage
  //       final permissionModel = PermissionResponseModel.fromJson(response.data);
  //       await PermissionStorage().save(permissionModel);

  //       // 3. Load into FeatureController
  //       if (Get.isRegistered<FeatureController>()) {
  //         await Get.find<FeatureController>().loadPermissions();
  //         log("✅ Permissions loaded successfully");
  //       }
  //     }
  //   } catch (e) {
  //     log("⚠️ Failed to load permissions: $e");
  //     // Don't block login if permissions fail
  //   }
  // }

  /// 📥 Load from API response
  Future<void> loadFromResponse(PermissionResponseModel response) async {
    try {
      log('📥 [FeatureController] Loading from API response...');

      // Save to storage
      await _storage.save(response);

      // Parse features
      _parseFeatures(response.payload?.features ?? {});

      // Parse sections
      _parseSections(response.payload?.sectionPermissions ?? {});

      log('✅ [FeatureController] Loaded from response');
    } catch (e) {
      log('❌ [FeatureController] Load from response error: $e');
    }
  }

  /// 📊 Parse features
  void _parseFeatures(Map<String, String> rawFeatures) {
    try {
      final parsed = <String, FeatureStatus>{};

      rawFeatures.forEach((key, value) {
        final status = _stringToStatus(value);
        parsed[key] = status;
      });

      features.assignAll(parsed);
      log('✅ [FeatureController] Parsed ${parsed.length} features');
    } catch (e) {
      log('❌ [FeatureController] Parse features error: $e');
    }
  }

  /// 📊 Parse sections
  void _parseSections(Map<String, String> rawSections) {
    try {
      final parsed = <String, FeatureStatus>{};

      rawSections.forEach((key, value) {
        final status = _stringToStatus(value);
        parsed[key] = status;
      });

      sections.assignAll(parsed);
      log('✅ [FeatureController] Parsed ${parsed.length} sections');
    } catch (e) {
      log('❌ [FeatureController] Parse sections error: $e');
    }
  }

  /// 🔄 Convert string to status
  FeatureStatus _stringToStatus(String value) {
    final upperValue = value.toUpperCase().trim();

    switch (upperValue) {
      case 'ALLOWED':
        return FeatureStatus.allowed;
      case 'LOCKED':
        return FeatureStatus.locked;
      case 'UNAUTHORIZED':
        return FeatureStatus.unauthorized;
      default:
        return FeatureStatus.unauthorized;
    }
  }

  // ========================================================================
  // FEATURE CHECKS
  // ========================================================================

  FeatureStatus statusOf(String feature) {
    return features[feature] ?? FeatureStatus.unauthorized;
  }

  bool isFeatureAllowed(String feature) {
    return statusOf(feature) == FeatureStatus.allowed;
  }

  bool isFeatureLocked(String feature) {
    return statusOf(feature) == FeatureStatus.locked;
  }

  bool isFeatureUnauthorized(String feature) {
    return statusOf(feature) == FeatureStatus.unauthorized;
  }

  // ========================================================================
  // SECTION CHECKS
  // ========================================================================

  FeatureStatus sectionStatusOf(String section) {
    return sections[section] ?? FeatureStatus.unauthorized;
  }

  bool isSectionAllowed(String section) {
    return sectionStatusOf(section) == FeatureStatus.allowed;
  }

  bool isSectionLocked(String section) {
    return sectionStatusOf(section) == FeatureStatus.locked;
  }

  bool isSectionUnauthorized(String section) {
    return sectionStatusOf(section) == FeatureStatus.unauthorized;
  }

  // ========================================================================
  // GETTERS
  // ========================================================================

  Map<String, FeatureStatus> getAllFeatures() => features;

  Map<String, FeatureStatus> getAllSections() => sections;

  Future<void> clearAll() async {
    try {
      await _storage.clear();
      features.clear();
      sections.clear();
      log('🧹 [FeatureController] All cleared');
    } catch (e) {
      log('❌ [FeatureController] Clear error: $e');
    }
  }
}
