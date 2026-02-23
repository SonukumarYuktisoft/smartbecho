import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageHelper {
  // Key constants
  static const _jsessionIdKey = 'JSESSIONID';
  static const _refreshTokenKey = 'refresh_token';
  static const _jwtTokenKey = 'jwt_token';
  static const _tokenExpiryKey = 'token_expiry';
  static const _permissionCacheKey = 'permission_cache';
  static const _permissionTimestampKey = 'permission_timestamp';

  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ============================================================================
  // GENERIC GET/SET/DELETE METHODS
  // ============================================================================

  /// 💾 Set generic key-value pair
  static Future<void> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('✅ [SecureStorage] Set: $key');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Set error for $key: $e');
      rethrow;
    }
  }

  /// 📖 Get generic key value
  static Future<String?> get(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        debugPrint('✅ [SecureStorage] Get: $key');
      } else {
        debugPrint('⚠️ [SecureStorage] Get: $key (not found)');
      }
      return value;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Get error for $key: $e');
      rethrow;
    }
  }

  /// 🗑️ Delete generic key
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint('🗑️ [SecureStorage] Deleted: $key');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Delete error for $key: $e');
      rethrow;
    }
  }

  /// 🧹 Delete multiple keys
  static Future<void> deleteMultiple(List<String> keys) async {
    try {
      for (String key in keys) {
        await delete(key);
      }
      debugPrint('🧹 [SecureStorage] Deleted ${keys.length} keys');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Delete multiple error: $e');
      rethrow;
    }
  }

  /// 🧹 Clear all secure storage
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🧹 [SecureStorage] All data cleared');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Clear all error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // JWT TOKEN METHODS
  // ============================================================================

  /// 💾 Set JWT Token
  static Future<void> setJwtToken(String token) async {
    try {
      await set(_jwtTokenKey, token);
      debugPrint('✅ [SecureStorage] JWT Token saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] JWT Token save error: $e');
      rethrow;
    }
  }

  /// 📖 Get JWT Token
  static Future<String?> getJwtToken() async {
    try {
      return await get(_jwtTokenKey);
    } catch (e) {
      debugPrint('❌ [SecureStorage] JWT Token get error: $e');
      return null;
    }
  }

  /// 🗑️ Delete JWT Token
  static Future<void> deleteJwtToken() async {
    try {
      await delete(_jwtTokenKey);
      debugPrint('🗑️ [SecureStorage] JWT Token deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] JWT Token delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // JSESSIONID METHODS
  // ============================================================================

  /// 💾 Set JSESSIONID
  static Future<void> setJSessionId(String jsessionId) async {
    try {
      await set(_jsessionIdKey, jsessionId);
      debugPrint('✅ [SecureStorage] JSESSIONID saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] JSESSIONID save error: $e');
      rethrow;
    }
  }

  /// 📖 Get JSESSIONID
  static Future<String?> getJSessionId() async {
    try {
      return await get(_jsessionIdKey);
    } catch (e) {
      debugPrint('❌ [SecureStorage] JSESSIONID get error: $e');
      return null;
    }
  }

  /// 🗑️ Delete JSESSIONID
  static Future<void> deleteJSessionId() async {
    try {
      await delete(_jsessionIdKey);
      debugPrint('🗑️ [SecureStorage] JSESSIONID deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] JSESSIONID delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // REFRESH TOKEN METHODS
  // ============================================================================

  /// 💾 Set Refresh Token
  static Future<void> setRefreshToken(String refreshToken) async {
    try {
      await set(_refreshTokenKey, refreshToken);
      debugPrint('✅ [SecureStorage] Refresh Token saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Refresh Token save error: $e');
      rethrow;
    }
  }

  /// 📖 Get Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      return await get(_refreshTokenKey);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Refresh Token get error: $e');
      return null;
    }
  }

  /// 🗑️ Delete Refresh Token
  static Future<void> deleteRefreshToken() async {
    try {
      await delete(_refreshTokenKey);
      debugPrint('🗑️ [SecureStorage] Refresh Token deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Refresh Token delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // TOKEN EXPIRY METHODS
  // ============================================================================

  /// 💾 Set Token Expiry Time
  static Future<void> setTokenExpiry(DateTime expiryTime) async {
    try {
      await set(_tokenExpiryKey, expiryTime.toIso8601String());
      debugPrint('✅ [SecureStorage] Token expiry saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Token expiry save error: $e');
      rethrow;
    }
  }

  /// 📖 Get Token Expiry Time
  static Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = await get(_tokenExpiryKey);
      if (expiryStr != null) {
        return DateTime.parse(expiryStr);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Token expiry get error: $e');
      return null;
    }
  }

  /// ⏰ Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Token expiry check error: $e');
      return true; // Treat as expired if error
    }
  }

  /// 🗑️ Delete Token Expiry
  static Future<void> deleteTokenExpiry() async {
    try {
      await delete(_tokenExpiryKey);
      debugPrint('🗑️ [SecureStorage] Token expiry deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Token expiry delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PERMISSION CACHE METHODS
  // ============================================================================

  /// 💾 Set Permission Cache
  static Future<void> setPermissionCache(String cacheData) async {
    try {
      await set(_permissionCacheKey, cacheData);
      debugPrint('✅ [SecureStorage] Permission cache saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission cache save error: $e');
      rethrow;
    }
  }

  /// 📖 Get Permission Cache
  static Future<String?> getPermissionCache() async {
    try {
      return await get(_permissionCacheKey);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission cache get error: $e');
      return null;
    }
  }

  /// 🗑️ Delete Permission Cache
  static Future<void> deletePermissionCache() async {
    try {
      await delete(_permissionCacheKey);
      debugPrint('🗑️ [SecureStorage] Permission cache deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission cache delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PERMISSION TIMESTAMP METHODS
  // ============================================================================

  /// 💾 Set Permission Cache Timestamp
  static Future<void> setPermissionTimestamp(String timestamp) async {
    try {
      await set(_permissionTimestampKey, timestamp);
      debugPrint('✅ [SecureStorage] Permission timestamp saved');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission timestamp save error: $e');
      rethrow;
    }
  }

  /// 📖 Get Permission Cache Timestamp
  static Future<String?> getPermissionTimestamp() async {
    try {
      return await get(_permissionTimestampKey);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission timestamp get error: $e');
      return null;
    }
  }

  /// 🗑️ Delete Permission Cache Timestamp
  static Future<void> deletePermissionTimestamp() async {
    try {
      await delete(_permissionTimestampKey);
      debugPrint('🗑️ [SecureStorage] Permission timestamp deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Permission timestamp delete error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // AUTHENTICATION DATA METHODS
  // ============================================================================

  /// 🗑️ Clear only authentication data (tokens)
  static Future<void> clearAuthData() async {
    try {
      await deleteMultiple([
        _jsessionIdKey,
        _refreshTokenKey,
        _jwtTokenKey,
        _tokenExpiryKey,
      ]);
      debugPrint('🗑️ [SecureStorage] Auth data cleared');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Clear auth data error: $e');
      rethrow;
    }
  }

  /// 🗑️ Clear only permission data (cache)
  static Future<void> clearPermissionData() async {
    try {
      await deleteMultiple([
        _permissionCacheKey,
        _permissionTimestampKey,
      ]);
      debugPrint('🗑️ [SecureStorage] Permission data cleared');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Clear permission data error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SESSION VALIDATION METHODS
  // ============================================================================

  /// ✅ Check if user has valid session
  static Future<bool> hasValidSession() async {
    try {
      final jsessionId = await getJSessionId();
      final refreshToken = await getRefreshToken();
      final jwtToken = await getJwtToken();

      final isValid = jsessionId != null &&
          jsessionId.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty &&
          jwtToken != null &&
          jwtToken.isNotEmpty;

      debugPrint('✅ [SecureStorage] Session valid: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Session check error: $e');
      return false;
    }
  }

  /// ✅ Check if token needs refresh
  static Future<bool> shouldRefreshToken() async {
    try {
      final isExpired = await isTokenExpired();
      if (isExpired) {
        debugPrint('⏰ [SecureStorage] Token needs refresh');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Refresh check error: $e');
      return true; // Force refresh if error
    }
  }

  // ============================================================================
  // DEBUG METHODS
  // ============================================================================

  /// 🔍 Get all keys (Debug only)
  static Future<Map<String, String>> getAllKeys() async {
    try {
      final allEntries = await _storage.readAll();
      debugPrint('🔍 [SecureStorage] Total keys: ${allEntries.length}');
      return allEntries;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Get all keys error: $e');
      return {};
    }
  }

  /// 🔍 Print all stored data (Debug only - CAREFUL WITH SENSITIVE DATA)
  static Future<void> printAllData() async {
    try {
      final allData = await getAllKeys();
      debugPrint('🔍 [SecureStorage] Stored Data:');
      allData.forEach((key, value) {
        // Don't print sensitive values in production
        final displayValue = value.length > 20 ? '${value.substring(0, 20)}...' : value;
        debugPrint('  ├─ $key: $displayValue');
      });
    } catch (e) {
      debugPrint('❌ [SecureStorage] Print data error: $e');
    }
  }

  /// 🧪 Test secure storage
  static Future<bool> testStorage() async {
    try {
      const testKey = 'test_key_12345';
      const testValue = 'test_value_12345';

      // Write
      await set(testKey, testValue);

      // Read
      final readValue = await get(testKey);

      // Verify
      final isValid = readValue == testValue;

      // Delete
      await delete(testKey);

      debugPrint('🧪 [SecureStorage] Test result: ${isValid ? 'PASSED ✅' : 'FAILED ❌'}');
      return isValid;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Test error: $e');
      return false;
    }
  }
}