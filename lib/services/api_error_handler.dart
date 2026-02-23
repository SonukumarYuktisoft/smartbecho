import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/route_services.dart';

class ApiErrorHandler {
  ApiErrorHandler(Response<dynamic>? response);

  // ==================== 1. HANDLE ERROR (DioException & Generic) ====================
  static String handleError(
    dynamic error, {
    BuildContext? context,
    bool showToast = false,
  }) {
    String message = "Something went wrong";
    String? description;

    // Handle DioException
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = "Connection Timeout";
          description = "Server took too long to respond";
          break;

        case DioExceptionType.connectionError:
          message = "No Internet Connection";
          description = "Please check your network and try again";
          break;

        case DioExceptionType.badCertificate:
          message = "Security Error";
          description = "SSL verification failed";
          break;

        case DioExceptionType.cancel:
          message = "Request Cancelled";
          break;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode >= 500) {
            message = "Server Error";
            description = "Please try again later";
          } else if (statusCode >= 400) {
            message = "Request Failed";
            description = _extractErrorFromResponse(error.response) ?? "Invalid request";
          }
          break;

        default:
          message = "Network Error";
          description = "Please check your connection";
      }

      log("❌ DioException: ${error.type} - $message");
    }
    // Handle Generic Exceptions
    else {
      final errorStr = error.toString().toLowerCase();

      if (errorStr.contains('timeout')) {
        message = "Request Timeout";
        description = "Operation took too long";
      } else if (errorStr.contains('socket')) {
        message = "Network Error";
        description = "Connection failed";
      } else if (errorStr.contains('format')) {
        message = "Data Error";
        description = "Invalid data received";
      } else {
        description = "Please try again";
      }

      log("❌ Exception: $error");
    }

    // Show toast if enabled
    if (showToast) {
      ToastHelper.error(
        message: message,
        description: description,
        context: context,
      );
    }

    // Return full message for UI
    return description != null ? "$message: $description" : message;
  }

  // ==================== 2. HANDLE SERVER RESPONSE ====================
  /// Handles HTTP Response validation
  /// Returns Map with success, message, and data
  static Map<String, dynamic> handleResponse(
    Response? response, {
    BuildContext? context,
    bool showToast = false,
  }) {
    if (response == null) {
      final msg = "Something went wrong";
      final desc = "Unable to process request";

      log("⚠️ Response is null - Request failed");

      return {
        'success': false,
        'message': msg,
        'description': desc,
        'fullMessage': "$msg: $desc",
        'data': null,
      };
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    log( name:  "🔍 Response Status"," $statusCode");

    // 🔥 CRITICAL: Handle 401 Unauthorized
    if (statusCode == 401) {
      log( name: 'Unauthorized log',"🔐 401 Detected in handleResponse - Triggering logout");
      // _handleLogout();
      
      final message = _extractMessage(data is Map ? data : {}, fallback: 'Session expired');
      
      if (showToast) {
        ToastHelper.error(
          message: 'Unauthorized',
          description: message,
          context: context,
        );
      }

      return {
        'success': false,
        'message': 'Unauthorized',
        'description': message,
        'fullMessage': 'Unauthorized: $message',
        'data': data,
      };
    }

    // SUCCESS (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return _handleSuccess(data, context, showToast);
    }

    // ERROR (400+)
    return _handleErrorResponse(statusCode, data, context, showToast);
  }

  // ==================== PRIVATE: SUCCESS HANDLER ====================
  static Map<String, dynamic> _handleSuccess(
    dynamic data,
    BuildContext? context,
    bool showToast,
  ) {
    // Extract message
    final message = data is Map ? _extractMessage(data) : 'Success';

    // Check backend status field
    if (data is Map && data.containsKey('status')) {
      final status = data['status']?.toString().toUpperCase() ?? '';

      if (status == 'FAIL' || status == 'ERROR') {
        // Backend returned error with 200 status
        if (showToast) {
          ToastHelper.error(message: message, context: context);
        }

        log("❌ Backend Error: $message");
        return {
          'success': false,
          'message': message,
          'description': null,
          'fullMessage': message,
          'data': data,
        };
      }
    }

    // Success - Show toast if enabled
    if (showToast) {
      ToastHelper.success(message: message, context: context);
    }

    log("✅ Success: $message");
    return {
      'success': true,
      'message': message,
      'description': null,
      'fullMessage': message,
      'data': data,
    };
  }

  // ==================== PRIVATE: ERROR RESPONSE HANDLER ====================
  static Map<String, dynamic> _handleErrorResponse(
    int statusCode,
    dynamic data,
    BuildContext? context,
    bool showToast,
  ) {
    String message = "Request Failed";
    String? description;

    // 🔥 FIRST: Try to extract error message from server response
    if (data is Map) {
      final serverMessage = _extractMessage(data, fallback: '');
      if (serverMessage.isNotEmpty) {
        // Use server message directly
        message = serverMessage;
      }
    }

    // ONLY use hardcoded messages if server didn't provide one
    if (message == "Request Failed" || message.isEmpty) {
      if (statusCode >= 500) {
        message = "Server Error";
        description = "Please try again later";

        switch (statusCode) {
          case 502:
            description = "Server temporarily unavailable";
            break;
          case 503:
            description = "Server under maintenance";
            break;
          case 504:
            description = "Server timeout";
            break;
        }
      } else if (statusCode >= 400) {
        switch (statusCode) {
          case 401:
            message = "Unauthorized";
            description = "Session expired";
            break;
          case 403:
            message = "Access Denied";
            description = "You don't have permission";
            break;
          case 404:
            message = "Not Found";
            description = "Resource not found";
            break;
          case 422:
            message = "Validation Error";
            break;
          case 429:
            message = "Too Many Requests";
            description = "Please wait and try again";
            break;
          default:
            message = "Request Failed";
            break;
        }
      }
    }

    // Show toast if enabled
    if (showToast) {
      ToastHelper.error(
        message: message,
        description: description,
        context: context,
      );
    }

    log("❌ Error ($statusCode): $message");

    final fullMsg = description != null ? "$message: $description" : message;
    return {
      'success': false,
      'message': message,
      'description': description,
      'fullMessage': fullMsg,
      'data': data,
    };
  }

  // ==================== LOGOUT HANDLER ====================
  static Future<void> _handleLogout() async {
    try {
      log("🚪 Logging out due to 401...");
      await SharedPreferencesHelper.clearAll();
      await SecureStorageHelper.clearAll();
      RouteService.toLogin();
    } catch (e) {
      log("❌ Logout error: $e");
    }
  }

  // ==================== HELPER: EXTRACT MESSAGE ====================
  static String _extractMessage(Map data, {String fallback = 'Success'}) {
    return data['message'] ??
        data['msg'] ??
        data['error'] ??
        data['description'] ??
        data['detail'] ??
        fallback;
  }

  // ==================== HELPER: EXTRACT ERROR FROM RESPONSE ====================
  static String? _extractErrorFromResponse(Response? response) {
    if (response?.data is Map) {
      return _extractMessage(response!.data, fallback: '');
    }
    return null;
  }
}