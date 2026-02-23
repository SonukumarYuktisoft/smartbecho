import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_profile_button.dart';

Widget buildCustomAppBar(
  String title, {
  required bool isdark,
  Widget? actionItem,
  void Function()? onPressed,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isdark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isdark ? Colors.black : Colors.white,
              size: 20,
            ),
            onPressed: onPressed ?? () => Get.back(),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const Spacer(),
        Text(
          title,
          style: TextStyle(
            color: isdark ? Colors.black : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        actionItem ?? SizedBox.shrink(),
      ],
    ),
  );
}

SliverAppBar buildStyledSliverAppBar({
  required String title,
  required bool isDark,

  List<Widget>? actionItem,
  void Function()? onPressed,
}) {
  return SliverAppBar(
    expandedHeight: 80.0,
    floating: true,
    pinned: true,
    snap: false,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: isDark ? Colors.black : Colors.grey[50],
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 0, // Remove default spacing
    leading: Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                !isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: !isDark ? Colors.black : Colors.white,
            size: 22,
          ),
          onPressed:
              onPressed ??
              () {
                Get.back();
              },
          padding: const EdgeInsets.all(8),
        ),
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    centerTitle: true, // Center the title
    actions: actionItem,
  );
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: maxHeight,
      child: Container(color: Colors.grey[50], child: child),
    );
  }

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DashboardController controller = Get.find<DashboardController>();

  final String title;
  final List<Widget>? actionItem;
  final VoidCallback? onPressed;
  final bool showBackButton;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final PreferredSizeWidget? bottom;

  CustomAppBar({
    Key? key,
    required this.title,
    this.actionItem,
    this.onPressed,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleStyle,
     this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
      actionsPadding: EdgeInsets.only(right: 16),
      bottom:bottom,

      elevation: 0,
      title: Text(
        title,
        style:
            titleStyle ??
            TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_sharp, color: Colors.white),
        onPressed: onPressed ?? Get.back,
      ),

      actions:
          actionItem ??
          [buildProfileButton(() => Get.toNamed(AppRoutes.profile))],
    );
  }

  Widget _buildProfileButton(VoidCallback onTap) {
    return Obx(() {
      final url = controller.profilePhotoUrl.value;
      final hasUrl = url.isEmpty;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 3, bottom: 3),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child:
              hasUrl
                  ? CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF8FAFC),
                    backgroundImage: NetworkImage(url),
                  )
                  : CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF8FAFC),
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
          // : Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF8FAFC),
          //     borderRadius: BorderRadius.circular(50),
          //     border: Border.all(color: const Color(0xFFE2E8F0)),
          //   ),
          //   child: Center(
          //     child: Icon(
          //       Icons.person_rounded,
          //       color: const Color(0xFF64748B),
          //       size: 20,
          //     ),
          //   ),
          // ),
        ),
      );
    });
  }
}

//
