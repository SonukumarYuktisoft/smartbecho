import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smartbecho/services/secure_storage_service.dart';

class CookieExtractor {
  /// Extract JSESSIONID from Dio Response and save to SecureStorage
  static Future<void> extractAndSaveJSessionId(Response response) async {
    try {
      // Get set-cookie headers from response
      final setCookieList = response.headers['set-cookie'];
      
      if (setCookieList == null || setCookieList.isEmpty) {
        log("⚠️ No set-cookie headers found in response");
        return;
      }

      // Look for JSESSIONID in cookies
      for (String cookie in setCookieList) {
        final jsessionIdMatch = RegExp(r'JSESSIONID=([^;,\s]+)').firstMatch(cookie);
        if (jsessionIdMatch != null) {
          final jsessionId = jsessionIdMatch.group(1)!;
          await SecureStorageHelper.setJSessionId(jsessionId);
          log("✅ JSESSIONID extracted and stored: ${jsessionId.substring(0, 8)}...");
          return;
        }
      }
      
      log("⚠️ JSESSIONID not found in any cookies");
      
    } catch (e) {
      log("❌ Error extracting JSESSIONID: $e");
    }
  }


}