import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:smartbecho/services/network/connectivity_manager.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';

/// Dio Interceptor for handling connectivity and auto-retry
class ConnectivityInterceptor extends Interceptor {
  final ConnectivityManager _connectivityManager = ConnectivityManager();
  final int maxRetries;
  final Duration retryDelay;

  ConnectivityInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check connection before making request
    if (!_connectivityManager.isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        // Wait for connection to be restored
        await _waitForConnection();
        await Future.delayed(retryDelay);

        // Retry the request
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }

  Future<void> _waitForConnection() async {
    if (_connectivityManager.isConnected) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = _connectivityManager.connectionStream.listen((isConnected) {
      if (isConnected) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Timeout after 30 seconds
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription.cancel();
      },
    );
  }
}

/// Logging Interceptor for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('MESSAGE: ${err.message}');
    super.onError(err, handler);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 10),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        log(
          '🔄 Retry attempt ${retryCount + 1}/$maxRetries',
          name: 'RetryInterceptor',
        );

        // Wait for connection to restore
        await _waitForConnection();
        await Future.delayed(retryDelay);

        // Retry the request
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final response = await dio.fetch(err.requestOptions);
          log('✅ Retry successful', name: 'RetryInterceptor');
          return handler.resolve(response);
        } catch (e) {
          log('❌ Retry failed', name: 'RetryInterceptor');
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }

  Future<void> _waitForConnection() async {
    final connectivityManager = ConnectivityManager();
    if (connectivityManager.isConnected) return;

    log('⏳ Waiting for connection...', name: 'RetryInterceptor');

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = connectivityManager.connectionStream.listen((isConnected) {
      if (isConnected) {
        log('✅ Connection restored', name: 'RetryInterceptor');
        subscription.cancel();
        completer.complete();
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription.cancel();
      },
    );
  }
}
