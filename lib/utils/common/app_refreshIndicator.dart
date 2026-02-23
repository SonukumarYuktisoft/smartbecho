import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      color: AppColors.primaryLight,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
