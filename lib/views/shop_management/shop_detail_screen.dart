import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/shop%20management%20models/my_shops_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/shop_management/edit_shop_screen.dart';
import 'package:shimmer/shimmer.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor:AppColors.primaryLight,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_rounded, color: AppColors.primaryLight),
                  onPressed: () {
                    Get.to(() => EditShopScreen(shop: shop));
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Shop Image with Shimmer
                  shop.profilePhotoUrl != null
                      ? Image.network(
                          shop.profilePhotoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultBackground();
                          },
                        )
                      : _buildDefaultBackground(),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Shop Info Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: shop.isActive 
                                ? Colors.green.shade400 
                                : Colors.red.shade400,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (shop.isActive 
                                    ? Colors.green 
                                    : Colors.red).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                shop.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Shop Name
                        Text(
                          shop.shopStoreName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        
                        // Shop ID
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${shop.shopId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Card
                  _buildQuickStatsCard(),
                  SizedBox(height: 20),

                  // Shop Information Section
                  _buildSectionTitle(
                    'Shop Information',
                    Icons.info_rounded,
                    AppColors.primaryLight,
                  ),
                  SizedBox(height: 12),
                  _buildModernInfoCard([
                    _buildModernInfoRow(
                      Icons.calendar_today_rounded,
                      'Created Date',
                      _formatDate(shop.createdAt),
                      Color(0xFF8B5CF6),
                    ),
                    if (shop.gstnumber != null && shop.gstnumber!.isNotEmpty)
                      _buildModernInfoRow(
                        Icons.receipt_long_rounded,
                        'GST Number',
                        shop.gstnumber!,
                        Color(0xFF10B981),
                      ),
                    _buildModernInfoRow(
                      Icons.update_rounded,
                      'Last Updated',
                      _formatDate(shop.updatedAt),
                      Color(0xFFF59E0B),
                    ),
                  ]),
                  SizedBox(height: 20),

                  // Address Section
                  _buildSectionTitle(
                    'Address Details',
                    Icons.location_on_rounded,
                    Color(0xFFEF4444),
                  ),
                  SizedBox(height: 12),
                  _buildModernInfoCard([
                    if (shop.shopAddress.label != null && shop.shopAddress.label!.isNotEmpty)
                      _buildModernInfoRow(
                        Icons.label_rounded,
                        'Label',
                        shop.shopAddress.label!,
                        Color(0xFF06B6D4),
                      ),
                    _buildModernInfoRow(
                      Icons.home_rounded,
                      'Address Line 1',
                      shop.shopAddress.addressLine1,
                      AppColors.primaryLight,
                    ),
                    if (shop.shopAddress.addressLine2.isNotEmpty)
                      _buildModernInfoRow(
                        Icons.home_outlined,
                        'Address Line 2',
                        shop.shopAddress.addressLine2,
                        Color(0xFF3B82F6),
                      ),
                    _buildModernInfoRow(
                      Icons.location_city_rounded,
                      'City',
                      shop.shopAddress.city,
                      Color(0xFF8B5CF6),
                    ),
                    _buildModernInfoRow(
                      Icons.map_rounded,
                      'State',
                      shop.shopAddress.state,
                      Color(0xFFF59E0B),
                    ),
                    _buildModernInfoRow(
                      Icons.pin_drop_rounded,
                      'Pincode',
                      shop.shopAddress.pincode,
                      Color(0xFFEF4444),
                    ),
                    _buildModernInfoRow(
                      Icons.public_rounded,
                      'Country',
                      shop.shopAddress.country,
                      Color(0xFF10B981),
                    ),
                  ]),
                  SizedBox(height: 20),

                  // Social Media Section
                  if (shop.socialMediaLinks.isNotEmpty) ...[
                    _buildSectionTitle(
                      'Social Media Links',
                      Icons.share_rounded,
                      Color(0xFF06B6D4),
                    ),
                    SizedBox(height: 12),
                    _buildSocialMediaCard(),
                    SizedBox(height: 20),
                  ],

                  // Images Section
                  if (shop.images.isNotEmpty) ...[
                    _buildSectionTitle(
                      'Shop Images',
                      Icons.photo_library_rounded,
                      Color(0xFFF59E0B),
                    ),
                    SizedBox(height: 12),
                    _buildImagesGrid(),
                    SizedBox(height: 20),
                  ],

                  // Edit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:AppColors.primaryGradientLight,
                      stops: [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => EditShopScreen(shop: shop));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Edit Shop Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            Color(0xFF3B82F6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.calendar_today_rounded,
              'Created',
              _formatDateShort(shop.creationDate),
              Color(0xFF8B5CF6),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.location_city_rounded,
              'Location',
              shop.shopAddress.city,
              Color(0xFFEF4444),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_rounded,
              'Status',
              shop.isActive ? 'Active' : 'Inactive',
              shop.isActive ? Color(0xFF10B981) : Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: shop.socialMediaLinks.asMap().entries.map((entry) {
          final index = entry.key;
          final link = entry.value;
          final platform = link['platform'] ?? 'Social Media';
          final url = link['url'] ?? 'N/A';
          
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF06B6D4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: Color(0xFF06B6D4),
                    size: 20,
                  ),
                ),
                title: Text(
                  platform,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF06B6D4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
              if (index < shop.socialMediaLinks.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagesGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: shop.images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_rounded,
                color: Colors.grey.shade400,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}