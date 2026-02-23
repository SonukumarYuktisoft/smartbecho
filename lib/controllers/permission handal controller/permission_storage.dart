
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbecho/models/permission%20handal%20models/permission_model.dart';

class PermissionStorage {
  static const _featuresKey = 'feature_permissions';
  static const _sectionsKey = 'section_permissions';

  /// 💾 Save complete permission response
  Future<void> save(PermissionResponseModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save features
      await prefs.setString(
        _featuresKey,
        jsonEncode(model.payload?.features ?? {}),
      );
      
      // Save sections
      await prefs.setString(
        _sectionsKey,
        jsonEncode(model.payload?.sectionPermissions ?? {}),
      );
      
      log('💾 [PermissionStorage] Saved permissions');
      log('   ├─ Features: ${model.payload?.features.length ?? 0}');
      log('   └─ Sections: ${model.payload?.sectionPermissions.length ?? 0}');
    } catch (e) {
      log('❌ [PermissionStorage] Save error: $e');
    }
  }

  /// 📖 Read features
  Future<Map<String, String>> readFeatures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_featuresKey);

      if (raw == null || raw.isEmpty) {
        log('⚠️ [PermissionStorage] No features found');
        return {};
      }

      return Map<String, String>.from(jsonDecode(raw));
    } catch (e) {
      log('❌ [PermissionStorage] Read features error: $e');
      return {};
    }
  }

  /// 📖 Read sections
  Future<Map<String, String>> readSections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sectionsKey);

      if (raw == null || raw.isEmpty) {
        log('⚠️ [PermissionStorage] No sections found');
        return {};
      }

      return Map<String, String>.from(jsonDecode(raw));
    } catch (e) {
      log('❌ [PermissionStorage] Read sections error: $e');
      return {};
    }
  }

  /// 📖 Read both
  Future<Map<String, dynamic>> readAll() async {
    return {
      'features': await readFeatures(),
      'sections': await readSections(),
    };
  }

  /// 🧹 Clear all
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_featuresKey);
      await prefs.remove(_sectionsKey);
      log('🧹 [PermissionStorage] Cleared all permissions');
    } catch (e) {
      log('❌ [PermissionStorage] Clear error: $e');
    }
  }

  /// Read legacy format (backward compatibility)
  Future<Map<String, String>> read() async {
    return await readFeatures();
  }
}
