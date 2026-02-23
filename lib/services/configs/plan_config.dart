

import 'package:flutter/material.dart';

class PlanConfig {
  // ============ ROLE-BASED PLANS ============
  
  // Admin Role
  static const String admin = 'admin';
  static const List<Color> adminGradientColors = [
    Color(0xFFDC143C), // Crimson
    Color(0xFFFF6347), // Tomato
    Color(0xFFCD5C5C), // Indian Red
  ];
  static const IconData adminIcon = Icons.admin_panel_settings;
  static const Color adminIconColor = Colors.white;
  
  // Super Admin Role
  static const String superAdmin = 'superadmin';
  static const List<Color> superAdminGradientColors = [
    Color(0xFF8B0000), // Dark Red
    Color(0xFFB22222), // Fire Brick
    Color(0xFFDC143C), // Crimson
  ];
  static const IconData superAdminIcon = Icons.shield;
  static const Color superAdminIconColor = Colors.white;
  
  // Manager Role
  static const String manager = 'manager';
  static const List<Color> managerGradientColors = [
    Color(0xFF4B0082), // Indigo
    Color(0xFF6A0DAD), // Purple
    Color(0xFF8A2BE2), // Blue Violet
  ];
  static const IconData managerIcon = Icons.manage_accounts;
  static const Color managerIconColor = Colors.white;
  
  // Owner Role
  static const String owner = 'owner';
  static const List<Color> ownerGradientColors = [
    Color(0xFF000080), // Navy
    Color(0xFF191970), // Midnight Blue
    Color(0xFF4169E1), // Royal Blue
  ];
  static const IconData ownerIcon = Icons.person_pin_circle;
  static const Color ownerIconColor = Colors.white;
  
  // Editor Role
  static const String editor = 'editor';
  static const List<Color> editorGradientColors = [
    Color(0xFF2E8B57), // Sea Green
    Color(0xFF3CB371), // Medium Sea Green
    Color(0xFF20B2AA), // Light Sea Green
  ];
  static const IconData editorIcon = Icons.edit;
  static const Color editorIconColor = Colors.white;
  
  // Viewer Role
  static const String viewer = 'viewer';
  static const List<Color> viewerGradientColors = [
    Color(0xFF708090), // Slate Gray
    Color(0xFF778899), // Light Slate Gray
    Color(0xFF696969), // Dim Gray
  ];
  static const IconData viewerIcon = Icons.visibility;
  static const Color viewerIconColor = Colors.white;
  
  // Member Role
  static const String member = 'member';
  static const List<Color> memberGradientColors = [
    Color(0xFF4682B4), // Steel Blue
    Color(0xFF5F9EA0), // Cadet Blue
    Color(0xFF6495ED), // Cornflower Blue
  ];
  static const IconData memberIcon = Icons.person;
  static const Color memberIconColor = Colors.white;
  
  // Guest Role
  static const String guest = 'guest';
  static const List<Color> guestGradientColors = [
    Color(0xFFD3D3D3), // Light Gray
    Color(0xFFC0C0C0), // Silver
    Color(0xFFDCDCDC), // Gainsboro
  ];
  static const IconData guestIcon = Icons.person_outline;
  static const Color guestIconColor = Color(0xFF666666);
  
  // Contributor Role
  static const String contributor = 'contributor';
  static const List<Color> contributorGradientColors = [
    Color(0xFF48D1CC), // Medium Turquoise
    Color(0xFF40E0D0), // Turquoise
    Color(0xFF00CED1), // Dark Turquoise
  ];
  static const IconData contributorIcon = Icons.edit_note;
  static const Color contributorIconColor = Colors.white;
  
  // Analyst Role
  static const String analyst = 'analyst';
  static const List<Color> analystGradientColors = [
    Color(0xFF1E90FF), // Dodger Blue
    Color(0xFF4169E1), // Royal Blue
    Color(0xFF0000CD), // Medium Blue
  ];
  static const IconData analystIcon = Icons.analytics;
  static const Color analystIconColor = Colors.white;
  
  // Support Role
  static const String support = 'support';
  static const List<Color> supportGradientColors = [
    Color(0xFFFF69B4), // Hot Pink
    Color(0xFFFF1493), // Deep Pink
    Color(0xFFC71585), // Medium Violet Red
  ];
  static const IconData supportIcon = Icons.support_agent;
  static const Color supportIconColor = Colors.white;
  
  // Supervisor Role
  static const String supervisor = 'supervisor';
  static const List<Color> supervisorGradientColors = [
    Color(0xFF8B4513), // Saddle Brown
    Color(0xFFA0522D), // Sienna
    Color(0xFFD2691E), // Chocolate
  ];
  static const IconData supervisorIcon = Icons.supervisor_account;
  static const Color supervisorIconColor = Colors.white;
  
  // Accountant Role
  static const String accountant = 'accountant';
  static const List<Color> accountantGradientColors = [
    Color(0xFF228B22), // Forest Green
    Color(0xFF32CD32), // Lime Green
    Color(0xFF00FF00), // Lime
  ];
  static const IconData accountantIcon = Icons.account_balance_wallet;
  static const Color accountantIconColor = Colors.white;
  
  // Sales Role
  static const String sales = 'sales';
  static const List<Color> salesGradientColors = [
    Color(0xFFFF8C00), // Dark Orange
    Color(0xFFFF7F50), // Coral
    Color(0xFFFF6347), // Tomato
  ];
  static const IconData salesIcon = Icons.trending_up;
  static const Color salesIconColor = Colors.white;
  
  // Marketing Role
  static const String marketing = 'marketing';
  static const List<Color> marketingGradientColors = [
    Color(0xFFFF00FF), // Magenta
    Color(0xFFDA70D6), // Orchid
    Color(0xFFBA55D3), // Medium Orchid
  ];
  static const IconData marketingIcon = Icons.campaign;
  static const Color marketingIconColor = Colors.white;
  
  // HR Role
  static const String hr = 'hr';
  static const List<Color> hrGradientColors = [
    Color(0xFFFF4500), // Orange Red
    Color(0xFFFF6347), // Tomato
    Color(0xFFFF7F50), // Coral
  ];
  static const IconData hrIcon = Icons.people_alt;
  static const Color hrIconColor = Colors.white;
  
  // Technical Role
  static const String technical = 'technical';
  static const List<Color> technicalGradientColors = [
    Color(0xFF2F4F4F), // Dark Slate Gray
    Color(0xFF708090), // Slate Gray
    Color(0xFF778899), // Light Slate Gray
  ];
  static const IconData technicalIcon = Icons.engineering;
  static const Color technicalIconColor = Colors.white;
  
  // Designer Role
  static const String designer = 'designer';
  static const List<Color> designerGradientColors = [
    Color(0xFFFF1493), // Deep Pink
    Color(0xFFFF69B4), // Hot Pink
    Color(0xFFFFB6C1), // Light Pink
  ];
  static const IconData designerIcon = Icons.palette;
  static const Color designerIconColor = Colors.white;
  
  // QA/Tester Role
  static const String qa = 'qa';
  static const List<Color> qaGradientColors = [
    Color(0xFF4B0082), // Indigo
    Color(0xFF663399), // Rebecca Purple
    Color(0xFF9370DB), // Medium Purple
  ];
  static const IconData qaIcon = Icons.bug_report;
  static const Color qaIconColor = Colors.white;
  
  // Operations Role
  static const String operations = 'operations';
  static const List<Color> operationsGradientColors = [
    Color(0xFF008B8B), // Dark Cyan
    Color(0xFF20B2AA), // Light Sea Green
    Color(0xFF48D1CC), // Medium Turquoise
  ];
  static const IconData operationsIcon = Icons.settings_applications;
  static const Color operationsIconColor = Colors.white;

  // ============ SUBSCRIPTION TIERS ============
  
  // Titanium Plan
  static const String titanium = 'titanium';
  static const List<Color> titaniumGradientColors = [
    Color(0xFF878681), // Titanium
    Color(0xFFA8A39D), // Light Titanium
    Color(0xFF6E6A65), // Dark Titanium
  ];
  static const IconData titaniumIcon = Icons.shield_outlined;
  static const Color titaniumIconColor = Colors.white;
  
  // Platinum Plan
  static const String platinum = 'platinum';
  static const List<Color> platinumGradientColors = [
    Color(0xFFE5E4E2), // Platinum
    Color(0xFFF0F0F0), // Light Platinum
    Color(0xFFCCCCCC), // Dark Platinum
  ];
  static const IconData platinumIcon = Icons.military_tech;
  static const Color platinumIconColor = Color(0xFF666666);
  
  // Diamond Plan
  static const String diamond = 'diamond';
  static const List<Color> diamondGradientColors = [
    Color(0xFFB9F2FF), // Diamond Blue
    Color(0xFFE0FFFF), // Light Diamond
    Color(0xFF87CEEB), // Sky Blue
  ];
  static const IconData diamondIcon = Icons.diamond;
  static const Color diamondIconColor = Colors.white;
  
  // Gold Plan
  static const String gold = 'gold';
  static const List<Color> goldGradientColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFFE55C), // Light Gold
    Color(0xFFFFC700), // Deep Gold
  ];
  static const IconData goldIcon = Icons.workspace_premium;
  static const Color goldIconColor = Colors.white;
  
  // Silver Plan
  static const String silver = 'silver';
  static const List<Color> silverGradientColors = [
    Color(0xFFC0C0C0), // Silver
    Color(0xFFD3D3D3), // Light Silver
    Color(0xFFA8A8A8), // Dark Silver
  ];
  static const IconData silverIcon = Icons.card_membership;
  static const Color silverIconColor = Colors.white;
  
  // Bronze Plan
  static const String bronze = 'bronze';
  static const List<Color> bronzeGradientColors = [
    Color(0xFFCD7F32), // Bronze
    Color(0xFFE39547), // Light Bronze
    Color(0xFFB87333), // Deep Bronze
  ];
  static const IconData bronzeIcon = Icons.stars;
  static const Color bronzeIconColor = Colors.white;
  
  // Pro Plan
  static const String pro = 'pro';
  static const List<Color> proGradientColors = [
    Color(0xFF6A11CB), // Purple
    Color(0xFF8E44AD), // Light Purple
    Color(0xFF5B0BA3), // Deep Purple
  ];
  static const IconData proIcon = Icons.rocket_launch;
  static const Color proIconColor = Colors.white;
  
  // Plus Plan
  static const String plus = 'plus';
  static const List<Color> plusGradientColors = [
    Color(0xFFFF6B6B), // Coral Red
    Color(0xFFFF8E8E), // Light Coral
    Color(0xFFFF4757), // Deep Red
  ];
  static const IconData plusIcon = Icons.add_circle;
  static const Color plusIconColor = Colors.white;
  
  // Enterprise Plan
  static const String enterprise = 'enterprise';
  static const List<Color> enterpriseGradientColors = [
    Color(0xFF1E3A8A), // Navy Blue
    Color(0xFF2563EB), // Blue
    Color(0xFF1E40AF), // Dark Blue
  ];
  static const IconData enterpriseIcon = Icons.business_center;
  static const Color enterpriseIconColor = Colors.white;
  
  // VIP Plan
  static const String vip = 'vip';
  static const List<Color> vipGradientColors = [
    Color(0xFFFF00FF), // Magenta
    Color(0xFFFF1493), // Deep Pink
    Color(0xFFDB7093), // Pale Violet Red
  ];
  static const IconData vipIcon = Icons.verified;
  static const Color vipIconColor = Colors.white;
  
  // Master Plan
  static const String master = 'master';
  static const List<Color> masterGradientColors = [
    Color(0xFF00CED1), // Dark Turquoise
    Color(0xFF40E0D0), // Turquoise
    Color(0xFF48D1CC), // Medium Turquoise
  ];
  static const IconData masterIcon = Icons.school;
  static const Color masterIconColor = Colors.white;
  
  // Premium Plus Plan
  static const String premiumPlus = 'premiumplus';
  static const List<Color> premiumPlusGradientColors = [
    Color(0xFFFF8C00), // Dark Orange
    Color(0xFFFFA500), // Orange
    Color(0xFFFFB347), // Light Orange
  ];
  static const IconData premiumPlusIcon = Icons.stars_rounded;
  static const Color premiumPlusIconColor = Colors.white;
  
  // Deluxe Plan
  static const String deluxe = 'deluxe';
  static const List<Color> deluxeGradientColors = [
    Color(0xFF9B59B6), // Amethyst
    Color(0xFFAB7AC4), // Light Amethyst
    Color(0xFF8E44AD), // Purple
  ];
  static const IconData deluxeIcon = Icons.emoji_events;
  static const Color deluxeIconColor = Colors.white;
  
  // Starter/Free Plan
  static const String starter = 'starter';
  static const List<Color> starterGradientColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF66BB6A), // Light Green
    Color(0xFF388E3C), // Dark Green
  ];
  static const IconData starterIcon = Icons.flash_on;
  static const Color starterIconColor = Colors.white;
  
  // Lite Plan
  static const String lite = 'lite';
  static const List<Color> liteGradientColors = [
    Color(0xFF90CAF9), // Light Blue
    Color(0xFFBBDEFB), // Pale Blue
    Color(0xFF64B5F6), // Medium Blue
  ];
  static const IconData liteIcon = Icons.flash_auto;
  static const Color liteIconColor = Colors.white;
  
  // Student Plan
  static const String student = 'student';
  static const List<Color> studentGradientColors = [
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFF176), // Light Yellow
    Color(0xFFFDD835), // Deep Yellow
  ];
  static const IconData studentIcon = Icons.school_outlined;
  static const Color studentIconColor = Colors.white;
  
  // Team Plan
  static const String team = 'team';
  static const List<Color> teamGradientColors = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFF26C6DA), // Light Cyan
    Color(0xFF00ACC1), // Dark Cyan
  ];
  static const IconData teamIcon = Icons.groups;
  static const Color teamIconColor = Colors.white;
  
  // Family Plan
  static const String family = 'family';
  static const List<Color> familyGradientColors = [
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF7043), // Light Orange Red
    Color(0xFFFF6F00), // Orange
  ];
  static const IconData familyIcon = Icons.family_restroom;
  static const Color familyIconColor = Colors.white;
  
  // Developer Plan
  static const String developer = 'developer';
  static const List<Color> developerGradientColors = [
    Color(0xFF263238), // Dark Grey Blue
    Color(0xFF37474F), // Blue Grey
    Color(0xFF455A64), // Light Blue Grey
  ];
  static const IconData developerIcon = Icons.code;
  static const Color developerIconColor = Colors.white;
  
  // Creator Plan
  static const String creator = 'creator';
  static const List<Color> creatorGradientColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFFF06292), // Light Pink
    Color(0xFFC2185B), // Dark Pink
  ];
  static const IconData creatorIcon = Icons.create;
  static const Color creatorIconColor = Colors.white;
  
  // Default Plan
  static const String defaultPlan = 'default';
  static const List<Color> defaultGradientColors = [
    Color(0xFF757575), // Gray
    Color(0xFF9E9E9E), // Light Gray
    Color(0xFF616161), // Dark Gray
  ];
  static const IconData defaultIcon = Icons.workspace_premium;
  static const Color defaultIconColor = Colors.white;

  // Helper method to get plan config by name
  static Map<String, dynamic> getPlanByName(String planName) {
    final planLower = planName.toLowerCase().replaceAll(' ', '');
    
    // Role-based plans
    if (planLower.contains('admin') && !planLower.contains('super')) {
      return {
        'gradientColors': adminGradientColors,
        'icon': adminIcon,
        'iconColor': adminIconColor,
      };
    }
    if (planLower.contains('superadmin')) {
      return {
        'gradientColors': superAdminGradientColors,
        'icon': superAdminIcon,
        'iconColor': superAdminIconColor,
      };
    }
    if (planLower.contains('manager')) {
      return {
        'gradientColors': managerGradientColors,
        'icon': managerIcon,
        'iconColor': managerIconColor,
      };
    }
    if (planLower.contains('owner')) {
      return {
        'gradientColors': ownerGradientColors,
        'icon': ownerIcon,
        'iconColor': ownerIconColor,
      };
    }
    if (planLower.contains('editor')) {
      return {
        'gradientColors': editorGradientColors,
        'icon': editorIcon,
        'iconColor': editorIconColor,
      };
    }
    if (planLower.contains('viewer')) {
      return {
        'gradientColors': viewerGradientColors,
        'icon': viewerIcon,
        'iconColor': viewerIconColor,
      };
    }
    if (planLower.contains('member')) {
      return {
        'gradientColors': memberGradientColors,
        'icon': memberIcon,
        'iconColor': memberIconColor,
      };
    }
    if (planLower.contains('guest')) {
      return {
        'gradientColors': guestGradientColors,
        'icon': guestIcon,
        'iconColor': guestIconColor,
      };
    }
    if (planLower.contains('contributor')) {
      return {
        'gradientColors': contributorGradientColors,
        'icon': contributorIcon,
        'iconColor': contributorIconColor,
      };
    }
    if (planLower.contains('analyst')) {
      return {
        'gradientColors': analystGradientColors,
        'icon': analystIcon,
        'iconColor': analystIconColor,
      };
    }
    if (planLower.contains('support')) {
      return {
        'gradientColors': supportGradientColors,
        'icon': supportIcon,
        'iconColor': supportIconColor,
      };
    }
    if (planLower.contains('supervisor')) {
      return {
        'gradientColors': supervisorGradientColors,
        'icon': supervisorIcon,
        'iconColor': supervisorIconColor,
      };
    }
    if (planLower.contains('accountant')) {
      return {
        'gradientColors': accountantGradientColors,
        'icon': accountantIcon,
        'iconColor': accountantIconColor,
      };
    }
    if (planLower.contains('sales')) {
      return {
        'gradientColors': salesGradientColors,
        'icon': salesIcon,
        'iconColor': salesIconColor,
      };
    }
    if (planLower.contains('marketing')) {
      return {
        'gradientColors': marketingGradientColors,
        'icon': marketingIcon,
        'iconColor': marketingIconColor,
      };
    }
    if (planLower.contains('hr')) {
      return {
        'gradientColors': hrGradientColors,
        'icon': hrIcon,
        'iconColor': hrIconColor,
      };
    }
    if (planLower.contains('technical') || planLower.contains('tech')) {
      return {
        'gradientColors': technicalGradientColors,
        'icon': technicalIcon,
        'iconColor': technicalIconColor,
      };
    }
    if (planLower.contains('designer')) {
      return {
        'gradientColors': designerGradientColors,
        'icon': designerIcon,
        'iconColor': designerIconColor,
      };
    }
    if (planLower.contains('qa') || planLower.contains('tester')) {
      return {
        'gradientColors': qaGradientColors,
        'icon': qaIcon,
        'iconColor': qaIconColor,
      };
    }
    if (planLower.contains('operations') || planLower.contains('ops')) {
      return {
        'gradientColors': operationsGradientColors,
        'icon': operationsIcon,
        'iconColor': operationsIconColor,
      };
    }
    
    // Subscription tiers
    if (planLower.contains('titanium')) {
      return {
        'gradientColors': titaniumGradientColors,
        'icon': titaniumIcon,
        'iconColor': titaniumIconColor,
      };
    }
    if (planLower.contains('platinum')) {
      return {
        'gradientColors': platinumGradientColors,
        'icon': platinumIcon,
        'iconColor': platinumIconColor,
      };
    }
    if (planLower.contains('diamond')) {
      return {
        'gradientColors': diamondGradientColors,
        'icon': diamondIcon,
        'iconColor': diamondIconColor,
      };
    }
    if (planLower.contains('gold')) {
      return {
        'gradientColors': goldGradientColors,
        'icon': goldIcon,
        'iconColor': goldIconColor,
      };
    }
    if (planLower.contains('silver')) {
      return {
        'gradientColors': silverGradientColors,
        'icon': silverIcon,
        'iconColor': silverIconColor,
      };
    }
    if (planLower.contains('bronze')) {
      return {
        'gradientColors': bronzeGradientColors,
        'icon': bronzeIcon,
        'iconColor': bronzeIconColor,
      };
    }
    if (planLower.contains('pro')) {
      return {
        'gradientColors': proGradientColors,
        'icon': proIcon,
        'iconColor': proIconColor,
      };
    }
    if (planLower.contains('plus')) {
      return {
        'gradientColors': plusGradientColors,
        'icon': plusIcon,
        'iconColor': plusIconColor,
      };
    }
    if (planLower.contains('enterprise')) {
      return {
        'gradientColors': enterpriseGradientColors,
        'icon': enterpriseIcon,
        'iconColor': enterpriseIconColor,
      };
    }
    if (planLower.contains('vip')) {
      return {
        'gradientColors': vipGradientColors,
        'icon': vipIcon,
        'iconColor': vipIconColor,
      };
    }
    if (planLower.contains('master')) {
      return {
        'gradientColors': masterGradientColors,
        'icon': masterIcon,
        'iconColor': masterIconColor,
      };
    }
    if (planLower.contains('premiumplus')) {
      return {
        'gradientColors': premiumPlusGradientColors,
        'icon': premiumPlusIcon,
        'iconColor': premiumPlusIconColor,
      };
    }
    if (planLower.contains('deluxe')) {
      return {
        'gradientColors': deluxeGradientColors,
        'icon': deluxeIcon,
        'iconColor': deluxeIconColor,
      };
    }
    if (planLower.contains('starter') || planLower.contains('free')) {
      return {
        'gradientColors': starterGradientColors,
        'icon': starterIcon,
        'iconColor': starterIconColor,
      };
    }
    if (planLower.contains('lite')) {
      return {
        'gradientColors': liteGradientColors,
        'icon': liteIcon,
        'iconColor': liteIconColor,
      };
    }
    if (planLower.contains('student')) {
      return {
        'gradientColors': studentGradientColors,
        'icon': studentIcon,
        'iconColor': studentIconColor,
      };
    }
    if (planLower.contains('team')) {
      return {
        'gradientColors': teamGradientColors,
        'icon': teamIcon,
        'iconColor': teamIconColor,
      };
    }
    if (planLower.contains('family')) {
      return {
        'gradientColors': familyGradientColors,
        'icon': familyIcon,
        'iconColor': familyIconColor,
      };
    }
    if (planLower.contains('developer') || planLower.contains('dev')) {
      return {
        'gradientColors': developerGradientColors,
        'icon': developerIcon,
        'iconColor': developerIconColor,
      };
    }
    if (planLower.contains('creator')) {
      return {
        'gradientColors': creatorGradientColors,
        'icon': creatorIcon,
        'iconColor': creatorIconColor,
      };
    }
    
    // Default
    return {
      'gradientColors': defaultGradientColors,
      'icon': defaultIcon,
      'iconColor': defaultIconColor,
    };
  }
}
