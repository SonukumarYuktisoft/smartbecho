import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartbecho/services/network/connectivity_manager.dart';

/// Widget wrapper to handle connectivity UI
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showBanner;
  final Function()? onConnected;
  final Function()? onDisconnected;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showBanner = true,
    this.onConnected,
    this.onDisconnected,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityManager _manager = ConnectivityManager();
  bool _isConnected = true;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isConnected = _manager.isConnected;
    _subscription = _manager.connectionStream.listen((isConnected) {
      setState(() => _isConnected = isConnected);

      if (isConnected) {
        widget.onConnected?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Back Online'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        widget.onDisconnected?.call();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (!_isConnected && widget.showBanner)
          Material(
            color: Colors.red,
            child: SafeArea(
              bottom: true,
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await _manager.checkConnection();
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!_isConnected && widget.offlineWidget != null)
          widget.offlineWidget!,
      ],
    );
  }
}
