import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:smartbecho/services/permission_service/permission_guard_service.dart';
import 'package:smartbecho/services/api_error_handler.dart';
import 'package:smartbecho/services/network/connectivity_interceptors.dart';
import 'package:smartbecho/services/route_services.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class ApiServices {
  Dio _dio = Dio();
  final PermissionGuardService _permissionGuard = PermissionGuardService();

  ApiServices() {
    _setupInterceptors();
  }

  // ==================== INTERCEPTOR SETUP ====================
  void _setupInterceptors() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          handler.next(options);
        },
        onResponse: (response, handler) async {
          // 🔥 ADDED: Check for 401 in response (when validateStatus = true)
          if (response.statusCode == 401) {
            log("🔐 401 detected in onResponse - Attempting token refresh...");
            
            if (await _refreshToken()) {
              try {
                String? newToken = await SharedPreferencesHelper.getJwtToken();
                response.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                final retryResponse = await _dio.fetch(response.requestOptions);
                log("✅ Request succeeded after token refresh (from response)");
                return handler.resolve(retryResponse);
              } catch (retryError) {
                log("❌ Retry failed: $retryError");
                await _handleLogout();
                return handler.next(response);
              }
            } else {
              log("❌ Token refresh failed");
              await _handleLogout();
            }
          }

          await _extractAndSaveSession(response);
          handler.next(response);
        },
        onError: (error, handler) async {
          // 🔐 401 Unauthorized → Token refresh
          if (error.response?.statusCode == 401) {
            log("🔄 401 Error in onError - Attempting token refresh...");

            if (await _refreshToken()) {
              try {
                String? newToken = await SharedPreferencesHelper.getJwtToken();
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                final response = await _dio.fetch(error.requestOptions);
                log("✅ Request succeeded after token refresh");
                return handler.resolve(response);
              } catch (retryError) {
                log("❌ Retry failed: $retryError");
                await _handleLogout();
              }
            } else {
              log("❌ Token refresh failed");
              await _handleLogout();
            }
          }

          handler.next(error);
        },
      ),
    );

    _dio.interceptors.addAll([
      ConnectivityInterceptor(),
      LoggingInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);
  }

  // ==================== TOKEN REFRESH ====================
  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        log("❌ No refresh token found");
        return false;
      }

      log("🔄 Attempting token refresh...");

      final response = await _dio.post(
        'YOUR_BASE_URL/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {"Content-Type": "application/json"},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken =
            data['userToken'] ??
            data['accessToken'] ??
            data['jwtToken'] ??
            data['token'];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          log("❌ No access token in refresh response");
          return false;
        }

        await SharedPreferencesHelper.setJwtToken(newAccessToken);

        final newRefreshToken = data['refreshToken'];
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await SecureStorageHelper.setRefreshToken(newRefreshToken);
        }

        log("✅ Token refreshed successfully");
        return true;
      }
      
      log("❌ Token refresh failed: Status ${response.statusCode}");
      return false;
    } catch (e) {
      log("❌ Token refresh error: $e");
      return false;
    }
  }

  // ==================== LOGOUT HANDLER ====================
  Future<void> _handleLogout() async {
    try {
      log("🚪 Logging out user...");
      await SharedPreferencesHelper.clearAll();
      await SecureStorageHelper.clearAll();
      RouteService.toLogin();
    } catch (e) {
      log("❌ Logout error: $e");
    }
  }

  // ==================== SESSION HANDLER ====================
  Future<void> _extractAndSaveSession(Response response) async {
    try {
      final setCookieList = response.headers['set-cookie'];
      if (setCookieList != null && setCookieList.isNotEmpty) {
        for (String cookie in setCookieList) {
          final jsessionIdMatch = RegExp(
            r'JSESSIONID=([^;]+)',
          ).firstMatch(cookie);
          if (jsessionIdMatch != null) {
            await SecureStorageHelper.setJSessionId(jsessionIdMatch.group(1)!);
            break;
          }
        }
      }
    } catch (e) {
      log("❌ Session error: $e");
    }
  }

  // ==================== GET REQUEST ====================
  Future<Response?>  requestGetForApi({
    required String url,
    Map<String, dynamic>? dictParameter,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
    CancelToken? cancelToken
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📦 DATA: $dictParameter");
      log("📡 GET: $url");

      Response response = await _dio.get(
        url,
        cancelToken:cancelToken,
        queryParameters: dictParameter,
        options: Options(
          headers: await getHeader(authToken),
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );

       log(name:"Server response log","${response.toString()}");
      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
  log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error log',"${error.toString()}",);
      return null;
    }
  }

  // ==================== POST REQUEST ====================
  Future<Response?> requestPostForApi({
    required String url,
    required Map<String, dynamic> dictParameter,
    Map<String, dynamic>? queryParameters,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 POST: $url");
      log("📦 DATA: $dictParameter");
      log("🔍 Query : $queryParameters");

      Response response = await _dio.post(
        url,
        data: dictParameter,
        queryParameters: queryParameters,
        options: Options(
          headers: await getHeader(authToken),
          followRedirects: false,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );

      log(name:"Server response log","${response.toString()}");

      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
    log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error log',"${error.toString()}",);
      return null;
    }
  }

  // ==================== PUT REQUEST ====================
  Future<Response?> requestPutForApi({
    required String url,
    Map<String, dynamic>? dictParameter,
    FormData? formData,
    required bool authToken,
    getx.RxDouble? percent,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 PUT: $url");
      log("📦 DATA: $dictParameter");

      Response response = await _dio.put(
        url,
        data: formData ?? dictParameter,
        onSendProgress:
            percent != null
                ? (count, total) => percent.value = (count / total) * 100
                : null,
        options: Options(
          headers: await getHeaderForFormData(authToken),
          followRedirects: false,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );

       log(name:"Server response log","${response.toString()}");
      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error log',"${error.toString()}",);
      return null;
    }
  }

  // ==================== DELETE REQUEST ====================
  Future<Response?> requestDeleteForApi({
    required String url,
    required Map<String, dynamic> dictParameter,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 DELETE: $url");
      log("📦 DATA: $dictParameter");

      Response response = await _dio.delete(
        url,
        data: dictParameter,
        options: Options(
          headers: await getHeader(authToken),
          followRedirects: false,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );

       log(name:"Server response log","${response.toString()}");
      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error', "${error.toString()}");
      return null;
    }
  }

  // ==================== PATCH REQUEST ====================
  Future<Response?> requestPatchForApi({
    required String url,
    required Map<String, dynamic> dictParameter,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 PATCH: $url");
      log("📦 DATA: $dictParameter");

      Response response = await _dio.patch(
        url,
        data: dictParameter,
        options: Options(
          headers: await getHeader(authToken),
          followRedirects: false,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );
       log(name:"Server response log","${response.toString()}");

      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error log',"${error.toString()}",);
      return null;
    }
  }

  // ==================== MULTIPART REQUEST ====================
  Future<Response?> requestMultipartApi({
    String? url,
    FormData? formData,
    String method = 'POST',
    getx.RxDouble? percent,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 MULTIPART $method: $url");
      log("📦 DATA: $formData");

      Response response;
      if (method.toUpperCase() == 'PUT') {
        response = await _dio.put(
          url!,
          data: formData,
          onSendProgress:
              percent != null
                  ? (sent, total) => percent.value = (sent / total) * 100
                  : null,
          options: Options(
            headers: await getHeader(authToken),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
      } else {
        response = await _dio.post(
          url!,
          data: formData,
          onSendProgress:
              percent != null
                  ? (sent, total) => percent.value = (sent / total) * 100
                  : null,
          options: Options(
            headers: await getHeader(authToken),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
      }

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );
       log(name:"Server response log","${response.toString()}");

      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return e.response;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error', "${error.toString()}");
      return Response(
        requestOptions: RequestOptions(path: url ?? ''),
        statusCode: 0,
        data: {"error": error.toString()},
      );
    }
  }

  // ==================== GET WITH JSESSIONID ====================
  Future<Response?> requestGetWithJSessionId({
    required String url,
    Map<String, dynamic>? dictParameter,
    required bool authToken,
    String? jsessionId,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      String? sessionId =
          jsessionId ?? await SecureStorageHelper.getJSessionId();
      if (sessionId == null) {
        log("❌ No JSESSIONID found");
        return null;
      }

      final headers = await getHeaderWithJSessionId(
        jsessionId: sessionId,
        authToken: authToken,
      );

      log("📡 GET with JSESSIONID: $url");
      log("📦 DATA: $dictParameter");

      Response response = await _dio.get(
        url,
        queryParameters: dictParameter,
        options: Options(
          headers: headers,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: showToast,
      );

       log(name:"Server response log","${response.toString()}");
      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(name: 'Catch error', "${error.toString()}");
      return null;
    }
  }

  // ==================== GST LEDGER GET ====================
  Future<Response?> requestGstLegerGetForApi({
    required String url,
    Map<String, dynamic>? dictParameter,
    required bool authToken,
    ResponseType? responseType,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
  }) async {
    if (!await _permissionGuard.checkPermission(
      featureKey: featureKey,
      context: context,
    ))
      return null;

    try {
      log("📡 GST GET: $url");
      log("📦 DATA: $dictParameter");

      Response response = await _dio.get(
        url,
        queryParameters: dictParameter,
        options: Options(
          headers: await getHeader(authToken),
          responseType: responseType ?? ResponseType.json,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      if (responseType == null || responseType == ResponseType.json) {
        ApiErrorHandler.handleResponse(
          response,
          context: context,
          showToast: showToast,
        );
      }

       log(name:"Server response log","${response.toString()}");
      return response;
    } on DioException catch (e) {
      ApiErrorHandler.handleError(e, context: context, showToast: showToast);
log(name:"error log","${e.toString()}");
      return null;
    } catch (error) {
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      log(  name: 'Catch error', "${error.toString()}" );
      return null;
    }
  }

  // ==================== HEADERS ====================
  Future<Map<String, String>> getHeader(bool authToken) async {
    if (authToken) {
      String? jwtToken = await SharedPreferencesHelper.getJwtToken();
      log("Token : --- ${jwtToken ?? ''} ");
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      };
    }
    return {"Content-Type": "application/json"};
  }

  Future<Map<String, String>> getHeaderForFormData(bool authToken) async {
    if (authToken) {
      String? jwtToken = await SharedPreferencesHelper.getJwtToken();
      return {"Authorization": "Bearer $jwtToken"};
    }
    return {};
  }

  Future<Map<String, String>> getHeaderWithJSessionId({
    required String jsessionId,
    required bool authToken,
  }) async {
    Map<String, String> headers = {"Content-Type": "application/json"};

    if (authToken) {
      String? jwtToken = await SharedPreferencesHelper.getJwtToken();
      if (jwtToken != null && jwtToken.isNotEmpty) {
        headers["Cookie"] = "JSESSIONID=$jsessionId; jwtToken=$jwtToken";
        headers["Authorization"] = "Bearer $jwtToken";
      } else {
        headers["Cookie"] = "JSESSIONID=$jsessionId";
      }
    } else {
      headers["Cookie"] = "JSESSIONID=$jsessionId";
    }

    return headers;
  }

  // ==================== SESSION UTILITIES ====================
  Future<bool> isSessionValid() async {
    String? jsessionId = await SecureStorageHelper.getJSessionId();
    return jsessionId != null && jsessionId.isNotEmpty;
  }

  Future<void> refreshSession() async {
    log("🔄 Session refresh requested");
  }
}