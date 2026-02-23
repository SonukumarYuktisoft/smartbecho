
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/profile/user_profile_controller.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/shop_management_controller.dart';
import 'package:smartbecho/models/profile/user_profile_model.dart';
import 'package:smartbecho/utils/Dialogs/app_logoutdialog.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common%20plan%20badge/common_plan_badge.dart';
import 'package:smartbecho/views/subscription%20plan/Widget/subscription_bottom_sheet.dart';
import 'package:smartbecho/views/subscription%20plan/Widget/subscription_status_widget.dart';
import 'package:smartbecho/views/subscription%20plan/current_user_subscription_screen.dart';
import 'package:smartbecho/views/subscription%20plan/subscription_history_screen.dart';
import 'package:smartbecho/views/profile/update_profile.dart';
import 'package:smartbecho/views/shop_management/create_another_shop.dart';
import 'package:smartbecho/views/shop_management/shop_list_section.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';

class UserProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final ShopManagementController shopManagementController = Get.put(
    ShopManagementController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => Get.to(CreateAnotherShop()),
            backgroundColor: AppColors.primaryLight,
            icon: Icon(Icons.store_rounded, color: Colors.white),
            label: Text(
              'Create Shop',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (controller.userProfile.value != null) {
                Get.to(() => UpdateUserProfileScreen());
              }
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingWidget();
        }

        if (controller.hasError.value) {
          return _buildErrorWidget();
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(child: Text('No profile data available'));
        }

        return AppRefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),

                // Personal Information
                _buildPersonalInfo(user),

                // Address Information
                if (user.userAddress != null)
                  _buildAddressInfo(user.userAddress!),

                _buildSubscriptionStatusCard(user),

                // Notification Preferences
                _buildNotificationPreferences(user),

                // Account Status
                _buildAccountStatus(user),
                ShopListSection(),

                // Logout Button
                _buildLogoutButton(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryLight),
          SizedBox(height: 16),
          Text(
            'Loading Profile...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.refreshProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() {
                final isUploading = controller.isUploadingPhoto.value;
                final hasPhoto = user.profilePhotoUrl?.isNotEmpty ?? false;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 3),
                        image:
                            hasPhoto
                                ? DecorationImage(
                                  image: NetworkImage(user.profilePhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          !hasPhoto
                              ? Center(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                              : null,
                    ),
                    if (isUploading)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }),
              Positioned(
                bottom: 0,
                right: 0,
                child: Obx(
                  () => GestureDetector(
                    onTap:
                        controller.isUploadingPhoto.value
                            ? null
                            : controller.uploadProfilePhoto,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        controller.isUploadingPhoto.value
                            ? Icons.hourglass_empty
                            : Icons.camera_alt,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            user.name.isNotEmpty ? user.name : 'Name not provided',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            user.phone.isEmpty ? 'No phone number' : user.phone,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.badge_outlined, size: 16, color: Colors.white70),
              SizedBox(width: 4),
              Text(
                'User ID: ${user.id}',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(UserProfile user) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildInfoRow('Email', user.email),
          Divider(height: 24),
          _buildInfoRow(
            'Phone',
            user.phone.isEmpty ? 'Not provided' : user.phone,
          ),
          Divider(height: 24),
          _buildInfoRow(
            'Aadhaar Number',
            user.adhaarNumber?.isEmpty ?? true
                ? 'Not provided'
                : user.adhaarNumber!,
          ),
          // if (user.gstnumber != null) ...[
          //   Divider(height: 24),
          //   _buildInfoRow('GST Number', user.gstnumber!),
          // ],
        ],
      ),
    );
  }

  Widget _buildAddressInfo(UserAddress address) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          if (address.label != null) _buildInfoRow('Label', address.label!),
          if (address.label != null) Divider(height: 24),
          if (address.addressLine1 != null)
            _buildInfoRow('Address Line 1', address.addressLine1!),
          if (address.addressLine1 != null) Divider(height: 24),
          if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
            _buildInfoRow('Address Line 2', address.addressLine2!),
          if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
            Divider(height: 24),
          _buildInfoRow('City', address.city),
          Divider(height: 24),
          _buildInfoRow('State', address.state),
          Divider(height: 24),
          _buildInfoRow('PIN Code', address.pincode),
          Divider(height: 24),
          _buildInfoRow('Country', address.country),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(UserProfile user) {
    final subscriptionController = Get.put(SubscriptionController());

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => CurrentUserSubscriptionScreen(userId: user.id.toString()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final subscription =
                  subscriptionController.currentSubscriptions.isNotEmpty
                      ? subscriptionController.currentSubscriptions.first
                      : null;

              final planCode = subscription?.planCode ?? 'FREE';
              final planName = subscription?.planNameSnapshot ?? 'Free Plan';
              final isActive = subscription?.active ?? false;

              return Row(
                children: [
                  // Plan Badge
                  // SubscriptionStatusWidget(
                  //   userId: user.id.toString(),
                  //   showLabel: true,
                  //   iconSize: 28,
                  //   fontSize: 16,
                  // ),
                  Text(planName),
                  const Spacer(),
                  CommonPlanBadge(planName: planName),
                  // Status Indicator
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color:
                  //         isActive
                  //             ? Colors.green.withOpacity(0.1)
                  //             : Colors.grey.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(
                  //       color: isActive ? Colors.green : Colors.grey,
                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(
                  //         isActive ? Icons.check_circle : Icons.cancel,
                  //         size: 16,
                  //         color: isActive ? Colors.green : Colors.grey,
                  //       ),
                  //       const SizedBox(width: 6),
                  //       Text(
                  //         isActive ? 'Active' : 'Inactive',
                  //         style: TextStyle(
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.w600,
                  //           color: isActive ? Colors.green : Colors.grey,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(width: 8),

                  // // Arrow Icon
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationPreferences(UserProfile user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildSwitchRow('Email Notifications', user.notifyByEmail),
          Divider(height: 24),
          _buildSwitchRow('SMS Notifications', user.notifyBySMS),
          Divider(height: 24),
          _buildSwitchRow('WhatsApp Notifications', user.notifyByWhatsApp),
        ],
      ),
    );
  }

  Widget _buildAccountStatus(UserProfile user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            'Account Status',
            user.status == 1 ? 'Active' : 'Inactive',
            valueColor: user.status == 1 ? Colors.green : Colors.red,
          ),
          if (user.creationDate != null) ...[
            Divider(height: 24),
            _buildInfoRow('Member Since', user.creationDate!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: value ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              value ? 'Enabled' : 'Disabled',
              style: TextStyle(
                fontSize: 13,
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    appLogoutDialog(
      title: 'Logout',
      description: 'Are you sure you want to logout from your account?',
      onConfirm: () {
        Get.back();
        Get.find<AuthController>().logout();
      },
    );
  }
}
