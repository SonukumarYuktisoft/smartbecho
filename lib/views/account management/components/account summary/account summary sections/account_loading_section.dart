// lib/views/account_management/components/sections/account_loading_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_lottie_loader.dart';

/// Full page loader for initial data load
class AccountFullPageLoader extends StatelessWidget {
  final String? selectedDate;

  const AccountFullPageLoader({Key? key, this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildInitialLoadingState(),
              Text(
                'Loading Account Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fetching your financial data...',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Show selected date during loading
              if (selectedDate != null)
                Text(
                  'Date: $selectedDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLottieLoader(),
          
          ],
        ),
      ),
    );
  }
}

/// Refreshing overlay for when data is being updated
class AccountRefreshingOverlay extends StatelessWidget {
  const AccountRefreshingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator()),
          const SizedBox(width: 10),
          Text(
            'Updating data...',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class AccountErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const AccountErrorState({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: AppColors.errorLight),
          const SizedBox(height: 16),
          Text(
            'Failed to load account summary',
            style: TextStyle(
              color: AppColors.errorLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
