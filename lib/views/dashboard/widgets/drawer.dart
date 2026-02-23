import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:flutter/services.dart';

class ModernAppDrawer extends StatefulWidget {
  @override
  _ModernAppDrawerState createState() => _ModernAppDrawerState();
}

class _ModernAppDrawerState extends State<ModernAppDrawer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Modern menu items for drawer
  final List<DrawerMenuItem> _menuItems = [
    DrawerMenuItem(
      title: 'Dashboard',
      subtitle: 'Overview & Analytics',
      icon: Icons.dashboard_rounded,
      color: Color(0xFF667eea),
    ),
    DrawerMenuItem(
      title: 'Inventory Management',
      subtitle: 'Stock control & tracking',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF667eea),
      category: 'Core',
    ),
    DrawerMenuItem(
      title: 'Bill History',
      subtitle: 'Finance overview',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFfa709a),
      category: 'Finance',
    ),
    DrawerMenuItem(
      title: 'Product Returns',
      subtitle: 'View returned products',
      icon: Icons.assignment_return_rounded,
      color: AppColors.primaryLight,
      category: 'Inventory',
    ),
    DrawerMenuItem(
      title: 'Customer Management',
      subtitle: 'Manage customer data',
      icon: Icons.people_rounded,
      color: Color(0xFF4facfe),
      category: 'Relations',
    ),
    DrawerMenuItem(
      title: 'Sales Management',
      subtitle: 'Track & manage sales',
      icon: Icons.point_of_sale_rounded,
      color: Color(0xFF43e97b),
      category: 'Core',
    ),

    DrawerMenuItem(
      title: 'Dues Management',
      subtitle: 'Track pending payments',
      icon: Icons.receipt_rounded,
      color: Color(0xFF74b9ff),
      category: 'Finance',
    ),
    DrawerMenuItem(
      title: 'Account Management',
      subtitle: 'Manage Account data',
      icon: Icons.groups_3_sharp,
      color: Color(0xFFf093fb),
      category: 'Reports',
    ),
    DrawerMenuItem(
      title: 'HSN Code Management',
      subtitle: 'Manage HSN Codes',
      icon: Icons.qr_code,
      color: const Color(0xFF26A69A),
      category: 'Inventory',
    ),
    DrawerMenuItem(
      title: 'Poster Generation',
      subtitle: 'Create marketing content',
      icon: Icons.campaign_rounded,
      color: Color.fromARGB(255, 184, 121, 33),
      category: 'Marketing',
      isNew: true,
    ),
    
    // DrawerMenuItem(
    //   title: 'Reports & Analytics',
    //   subtitle: 'Business insights',
    //   icon: Icons.analytics_rounded,
    //   color: Color(0xFF9c88ff),
    //   category: 'Reports',
    // ),
    // DrawerMenuItem(
    //   title: 'Generate Inventory',
    //   subtitle: 'App preferences',
    //   icon: Icons.link,
    //   color: Color(0xFFfa709a),
    //   category: 'Marketing',
    // ),
    DrawerMenuItem(
      title: 'Settings',
      subtitle: 'App preferences',
      icon: Icons.settings_rounded,
      color: Color(0xFF8e8e93),
      category: 'System',
    ),
     DrawerMenuItem(
      title: 'User Management',
      subtitle: 'Manage User data',
      icon: Icons.person_3_sharp,
      color: Color.fromARGB(255, 33, 184, 43),
      category: 'System',
      isNew: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBackground(context), AppColors.backgroundColor(context)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(),
            // _buildQuickStats(), // temporarily disabled while aligning with AppColors
            Expanded(child: _buildMenuList()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-100 * (1 - _slideController.value), 0),
          child: Container(
            padding: EdgeInsets.only(top: 0, left: 24, right: 24, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.getPrimaryGradient(AppColors.isDarkMode(context)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getPrimaryGradient(AppColors.isDarkMode(context)).colors.first.withOpacity(0.28),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Becho',
                            style: AppStyles.custom(
                              size: 24,
                              weight: FontWeight.bold,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                          Text(
                            'Business Management',
                            style: AppStyles.custom(
                              size: 14,
                              color: AppColors.getTextSecondary(context),
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 20),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Color(0xFF00b894).withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(
                //       color: Color(0xFF00b894).withValues(alpha: 0.2),
                //       width: 1,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Container(
                //         width: 8,
                //         height: 8,
                //         decoration: BoxDecoration(
                //           color: Color(0xFF00b894),
                //           borderRadius: BorderRadius.circular(4),
                //         ),
                //       ),
                //       SizedBox(width: 8),
                //       Text(
                //         'System Online',
                //         style: AppStyles.custom(
                //           size: 12,
                //           color: Color(0xFF00b894),
                //           weight: FontWeight.w600,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*
  Widget _buildQuickStats() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStatItem('Sales', '₹1.2M', Color(0xFF43e97b)),
                Container(width: 1, height: 30, color: AppColors.getBorderColor(context)),
                _buildStatItem('Orders', '245', Color(0xFF667eea)),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                _buildStatItem('Stock', '89%', Color(0xFFfa709a)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppStyles.custom(
              size: 16,
              weight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: AppStyles.custom(
              size: 11,
              color: Color(0xFF636e72),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _buildMenuList() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              return _buildModernMenuItem(_menuItems[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildModernMenuItem(DrawerMenuItem item, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuTap(item, index),
          borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentColor(context).withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: AppColors.accentColor(context).withOpacity(0.28),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? item.color
                            : item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? Colors.white : item.color,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.title,
                            style: AppStyles.custom(
                              size: 15,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.accentColor(context)
                                  : AppColors.getTextPrimary(context),
                            ),
                          ),
                          if (item.isNew) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'NEW',
                                style: AppStyles.custom(
                                  size: 8,
                                  color: Colors.white,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        item.subtitle,
                              style: AppStyles.custom(
                                size: 12,
                                color: AppColors.getTextSecondary(context),
                                weight: FontWeight.w400,
                              ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor(context),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.getPrimaryGradient(AppColors.isDarkMode(context)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getPrimaryGradient(AppColors.isDarkMode(context)).colors.first.withOpacity(0.28),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Get Support',
                        style: AppStyles.custom(
                          size: 14,
                          color: Colors.white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '© 2025, Made with ❤️ by YUKTISOFT',
                  style: AppStyles.custom(
                    size: 11,
                    color: AppColors.getTextSecondary(context),
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMenuTap(DrawerMenuItem item, int index) {
    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });
    final bottomNavController = Get.find<BottomNavigationController>();

    print(_selectedIndex);
    switch (_selectedIndex) {
      case 1:
        bottomNavController.setIndex(1); // Inventory tab index
        Get.back(); // Drawer close
        break;

      // Get.toNamed(AppRoutes.inventory_management);

      case 2:
        // Get.toNamed(AppRoutes.billHistory);
        bottomNavController.setIndex(2);
        Get.back();
        break;
      case 3:
        Get.toNamed(AppRoutes.productReturns);
        break;
      case 4:
        Get.toNamed(AppRoutes.customerManagement);
        break;
      case 5:
        // Get.toNamed(AppRoutes.salesManagement);
        bottomNavController.setIndex(3);
        Get.back();
        break;
      case 6:
        Get.toNamed(AppRoutes.customerDuesManagement);
        bottomNavController.setIndex(4);
        Get.back();
        break;
      case 7:
        // Get.toNamed(AppRoutes.accountManagement);
        bottomNavController.setIndex(5);
        Get.back();
        break;
      case 8:
        Get.toNamed(AppRoutes.hsnCodeManagement);
        break;
      case 9:
        Get.toNamed(AppRoutes.posterGeneration);
        break;
      case 10:
        Get.toNamed(AppRoutes.settings);
        break;
        case 11:
        // Get.toNamed(AppRoutes.pricingScreen);

        Get.toNamed(AppRoutes.usersManagement);
        // Get.toNamed(AppRoutes.pricingScreen);
        break;
      // case 9:
      //   Get.toNamed(AppRoutes.generateInventory);

      default:
        _showNavigationSnackbar(item.title, item.color);
    }
  }

  // // Close drawer after selection
  // Navigator.of(context).pop();
  // // Show navigation feedback
  // _showNavigationSnackbar(item.title, item.color);
}

void _showNavigationSnackbar(String feature, Color color) {
  Get.snackbar(
    'Navigating to $feature',
    'Loading $feature module...',
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    colorText: Colors.white,
    margin: EdgeInsets.all(16),
    borderRadius: 12,
    icon: Icon(Icons.launch_rounded, color: Colors.white),
    shouldIconPulse: false,
    duration: Duration(seconds: 2),
    animationDuration: Duration(milliseconds: 300),
  );
}

// Menu Item Model for Drawer
class DrawerMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String category;
  final bool isNew;

  DrawerMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.category = 'General',
    this.isNew = false,
  });
}
