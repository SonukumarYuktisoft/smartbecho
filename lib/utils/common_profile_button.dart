import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';

Widget buildProfileButton(VoidCallback onTap) {
  final controller = Get.find<DashboardController>();

  return Obx(() {
    final url = controller.profilePhotoUrl.value;
    final hasUrl = url.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 3, bottom: 3),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF8FAFC),
          image: DecorationImage(
            image:
                hasUrl
                    ? NetworkImage(url)
                    : const AssetImage("assets/images/profile.png"),
                    fit: BoxFit.cover,
          ),
        ),
        // child: CircleAvatar(
        //   radius: 18,
        //   backgroundColor: const Color(0xFFF8FAFC),
        //   backgroundImage: hasUrl
        //       ? NetworkImage(url)
        //       : const AssetImage("assets/images/profile.png")

        // ),
      ),
    );
  });
}
