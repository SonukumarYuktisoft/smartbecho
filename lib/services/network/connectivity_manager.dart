import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

/// Singleton service to manage internet connectivity
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isConnected => _isConnected;

  /// Initialize the connectivity listener
  Future<void> initialize() async {
    await _updateConnectionStatus(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      _updateStatus(false);
    } else {
      // On web, connectivity_plus reports online if browser has connection
      // On mobile, verify with actual HTTP request
      if (_isWebPlatform()) {
        _updateStatus(true);
      } else {
        final hasInternet = await _checkInternetConnection();
        _updateStatus(hasInternet);
      }
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }

  void _updateStatus(bool status) {
    if (_isConnected != status) {
      _isConnected = status;
      _connectionController.add(status);
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);
    return _isConnected;
  }

  bool _isWebPlatform() {
    try {
      return kIsWeb;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}