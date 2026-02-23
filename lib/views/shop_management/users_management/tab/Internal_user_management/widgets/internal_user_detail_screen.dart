import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/shop%20management%20controller/Internal%20user%20management%20controller/Internal_user_management_controller.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_model.dart';
import 'package:smartbecho/models/shop%20management%20models/Internal%20user%20management%20models/internal_user_detail_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'edit_internal_user_screen.dart';

class InternalUserDetailScreen extends StatefulWidget {
  final InternalUser user;
  final String shopId;

  const InternalUserDetailScreen({
    super.key,
    required this.user,
    required this.shopId,
  });

  @override
  State<InternalUserDetailScreen> createState() =>
      _InternalUserDetailScreenState();
}

class _InternalUserDetailScreenState extends State<InternalUserDetailScreen> {
  final InternalUserManagementController controller =
      Get.find<InternalUserManagementController>();

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    await controller.getInternalUserById(
      userId: widget.user.id,
      shopId: widget.shopId,
    );
  }

  Future<void> _navigateToEdit() async {
    if (controller.userDetail.value != null) {
      Get.to(
        () => EditInternalUserScreen(
          userDetail: controller.userDetail.value!,
          shopId: widget.shopId,
        ),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please wait, loading user details...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit User',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.userDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryLight),
          );
        }

        final userDetail = controller.userDetail.value;
        if (userDetail == null) {
          return const Center(child: Text('Failed to load user details'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Profile Photo
              _buildHeaderSection(userDetail),

              // Details Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Information Section
                    _buildContactSection(userDetail),
                    const SizedBox(height: 16),

                    // Role Information Section
                    if (userDetail.roleId != null ||
                        userDetail.roleName != null)
                      _buildRoleSection(userDetail),
                    const SizedBox(height: 16),

                    // Identification Section
                    _buildIdentificationSection(userDetail),
                    const SizedBox(height: 16),

                    // Notification Preferences Section
                    _buildNotificationSection(userDetail),
                    const SizedBox(height: 16),

                    // Address Section
                    if (userDetail.userAddress != null)
                      _buildAddressSection(userDetail),
                    const SizedBox(height: 16),

                    // Status Section
                    _buildStatusSection(userDetail),
                    const SizedBox(height: 16),

                    // All Shops Section (ListView)
                    if (userDetail.userShops.isNotEmpty)
                      _buildAllShopsSection(userDetail),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEdit,
        backgroundColor: AppColors.primaryLight,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Edit User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeaderSection(InternalUserDetail userDetail) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.primaryLight),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 4),
              image: userDetail.profilePhotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(userDetail.profilePhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userDetail.profilePhotoUrl == null
                ? Center(
                    child: Text(
                      userDetail.name.isNotEmpty
                          ? userDetail.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userDetail.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Show Role Badge
          if (userDetail.roleName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    userDetail.roleName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Contact Information Section
  Widget _buildContactSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contact Information'),
        _buildInfoCard([
          _buildInfoRow(Icons.email_outlined, 'Email', userDetail.email),
          _buildInfoRow(Icons.phone_outlined, 'Phone', userDetail.phone),
        ]),
      ],
    );
  }

  // Role Information Section
  Widget _buildRoleSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Role Information'),
        _buildInfoCard([
          if (userDetail.roleName != null)
            _buildInfoRow(
              Icons.badge_outlined,
              'Role Name',
              userDetail.roleName!,
              valueColor: AppColors.primaryLight,
            ),
          if (userDetail.roleId != null)
            _buildInfoRow(
              Icons.tag,
              'Role ID',
              userDetail.roleId.toString(),
            ),
        ]),
      ],
    );
  }

  // Identification Section
  Widget _buildIdentificationSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Identification'),
        _buildInfoCard([
          if (userDetail.adhaarNumber != null)
            _buildInfoRow(
              Icons.credit_card,
              'Aadhaar Number',
              userDetail.adhaarNumber!,
            ),
          if (userDetail.pan != null)
            _buildInfoRow(
              Icons.receipt_long,
              'PAN Number',
              userDetail.pan!,
            ),
        ]),
      ],
    );
  }

  // Notification Preferences Section
  Widget _buildNotificationSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notification Preferences'),
        _buildInfoCard([
          _buildSwitchRow('Email Notifications', userDetail.notifyByEmail),
          _buildSwitchRow('SMS Notifications', userDetail.notifyBySMS),
          _buildSwitchRow('WhatsApp Notifications', userDetail.notifyByWhatsApp),
        ]),
      ],
    );
  }

  // Address Section
  Widget _buildAddressSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Address'),
        _buildInfoCard([
          _buildInfoRow(
            Icons.label_outline,
            'Label',
            userDetail.userAddress!.label,
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Address Line 1',
            userDetail.userAddress!.addressLine1,
          ),
          if (userDetail.userAddress!.addressLine2.isNotEmpty)
            _buildInfoRow(
              Icons.location_on_outlined,
              'Address Line 2',
              userDetail.userAddress!.addressLine2,
            ),
          _buildInfoRow(
            Icons.location_city,
            'City',
            userDetail.userAddress!.city,
          ),
          _buildInfoRow(
            Icons.map_outlined,
            'State',
            userDetail.userAddress!.state,
          ),
          _buildInfoRow(
            Icons.pin_drop_outlined,
            'Pincode',
            userDetail.userAddress!.pincode,
          ),
          _buildInfoRow(
            Icons.public,
            'Country',
            userDetail.userAddress!.country,
          ),
        ]),
      ],
    );
  }

  // Status Section
  Widget _buildStatusSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status'),
        _buildInfoCard([
          _buildInfoRow(
            Icons.info_outline,
            'Status',
            userDetail.status == 1 ? 'Active' : 'Inactive',
            valueColor: userDetail.status == 1 ? Colors.green : Colors.red,
          ),
        ]),
      ],
    );
  }

  // All Shops Section with ListView
  Widget _buildAllShopsSection(InternalUserDetail userDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Associated Shops (${userDetail.userShops.length})'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userDetail.userShops.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final userShop = userDetail.userShops[index];
            return _buildShopCard(userShop, index + 1);
          },
        ),
      ],
    );
  }

  // Individual Shop Card
  Widget _buildShopCard(UserShop userShop, int shopNumber) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Header with Number Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shop #$shopNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: userShop.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userShop.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: userShop.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Shop Details
            _buildShopDetailRow(
              Icons.store,
              'Shop Name',
              userShop.shop.shopStoreName,
            ),
            _buildShopDetailRow(
              Icons.badge,
              'Shop ID',
              userShop.shop.shopId,
            ),
            _buildShopDetailRow(
              Icons.person_outline,
              'Role',
              userShop.isOwner ? 'Owner' : 'Member',
            ),
            if (userShop.shop.gstnumber != null)
              _buildShopDetailRow(
                Icons.receipt_long,
                'GST Number',
                userShop.shop.gstnumber!,
              ),
            _buildShopDetailRow(
              Icons.calendar_today,
              'Joined At',
              _formatDate(userShop.joinedAt),
            ),

            // Shop Address if available
            if (userShop.shop.shopAddress != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildShopDetailRow(
                Icons.location_on_outlined,
                'Address',
                '${userShop.shop.shopAddress!.addressLine1}, ${userShop.shop.shopAddress!.city}, ${userShop.shop.shopAddress!.state} - ${userShop.shop.shopAddress!.pincode}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Shop Detail Row
  Widget _buildShopDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
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
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}