import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartbecho/services/network/connectivity_manager.dart';

/// Mixin for pages that need connectivity handling [auto update]
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  final ConnectivityManager _manager = ConnectivityManager();
  StreamSubscription<bool>? _connectionSubscription;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    isConnected = _manager.isConnected;
    _connectionSubscription = _manager.connectionStream.listen((connected) {
      setState(() => isConnected = connected);
      onConnectivityChanged(connected);
    });
  }

  /// Override this to handle connectivity changes
  void onConnectivityChanged(bool isConnected) {}

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

/// Extension on BuildContext
extension ConnectivityContext on BuildContext {
  bool get isConnected => ConnectivityManager().isConnected;
  Future<bool> checkConnection() => ConnectivityManager().checkConnection();
}
