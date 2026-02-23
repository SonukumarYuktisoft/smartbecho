import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/generate%20inventory%20controller/generate_inventory_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class GenerateInventoryScreen extends StatefulWidget {
  @override
  _GenerateInventoryScreenState createState() =>
      _GenerateInventoryScreenState();
}

class _GenerateInventoryScreenState extends State<GenerateInventoryScreen> {
  final GenerateInventoryController controller =
      Get.find<GenerateInventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:  "Generate Inventory Link",
      onPressed: () {
        Get.find<BottomNavigationController>().setIndex(0);
        Get.back();
      },
      actionItem: [Obx(() {
        if (controller.hasGeneratedLink.value) {
          return IconButton(
            onPressed: controller.refreshLink,
            icon: Icon(Icons.refresh),
            tooltip: 'Generate New Link',
          );
        }
        return SizedBox.shrink();
      }), ]
      
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // _buildCustomAppBar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return buildCustomAppBar(
      "Generate Inventory Link",
      onPressed: () {
        Get.find<BottomNavigationController>().setIndex(0);
        Get.back();
      },
      isdark: true,
      actionItem: Obx(() {
        if (controller.hasGeneratedLink.value) {
          return IconButton(
            onPressed: controller.refreshLink,
            icon: Icon(Icons.refresh),
            tooltip: 'Generate New Link',
          );
        }
        return SizedBox.shrink();
      }),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 40),
          _buildHeaderSection(),
          SizedBox(height: 40),
          _buildGenerateButton(),
          SizedBox(height: 40),
          _buildGeneratedLinkSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Main Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6C5CE7).withValues(alpha: 0.2),
                Color(0xFF6C5CE7).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(Icons.link, size: 60, color: Color(0xFF6C5CE7)),
        ),
        SizedBox(height: 32),

        // Title
        Text(
          'Go beyond limits',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.backgroundDark,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),

        // Subtitle
        Text(
          'Let the world discover what you offer.',
          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Generate Inventory Link text
        Text(
          'Generate Inventory Link',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.backgroundDark,
          ),
        ),
        SizedBox(height: 12),

        // Description
        Text(
          'Click the button below to generate and share your inventory link.',
          style: TextStyle(fontSize: 16, color: Colors.grey[500], height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed:
              controller.isGenerating.value
                  ? null
                  : controller.generateInventoryLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child:
              controller.isGenerating.value
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    'Create Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      );
    });
  }

  Widget _buildGeneratedLinkSection() {
    return Obx(() {
      if (!controller.hasGeneratedLink.value) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Inventory Link',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Link container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.generatedLink.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: controller.copyLinkToClipboard,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.copy, size: 18, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Share Link',
                    Icons.share,
                    Colors.green,
                    onPressed: controller.shareInventoryLink,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Copy Link',
                    Icons.content_copy,
                    Colors.blue,
                    onPressed: controller.copyLinkToClipboard,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
