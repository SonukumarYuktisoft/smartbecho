import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartbecho/utils/app_colors.dart';

class DuesActionButtonsSection extends StatelessWidget {
  final VoidCallback onCallPressed;
  final VoidCallback onWhatsAppPressed;
  final VoidCallback onSharePressed;

  final bool isDark;

  const DuesActionButtonsSection({
    Key? key,
    required this.onCallPressed,
    required this.onWhatsAppPressed,
    required this.onSharePressed,
  
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick Action Buttons (Call, WhatsApp, Share)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.call,
                label: 'Call',
                color: const Color(0xFF10B981),
                onTap: onCallPressed,
              ),
              _buildQuickActionButton(
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: onWhatsAppPressed,
              ),
              _buildQuickActionButton(
                icon: Icons.share,
                label: 'Share',
                color: const Color(0xFF3B82F6),
                onTap: onSharePressed,
              ),
            ],
          ),
        ),

       

       
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}