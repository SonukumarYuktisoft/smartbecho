import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:smartbecho/services/whatsapp_due_message_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class WhatsAppService {
  // Main method to open WhatsApp with phone number
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Clean and format phone number
      String cleanedNumber = _formatPhoneNumber(phoneNumber);
      
      // Encode message if provided
      String encodedMessage = message != null ? Uri.encodeComponent(message) : '';
      
      // Try different approaches based on platform
      if (Platform.isAndroid) {
        return await _openOnAndroid(cleanedNumber, encodedMessage);
      } else if (Platform.isIOS) {
        return await _openOnIOS(cleanedNumber, encodedMessage);
      } else {
        // For other platforms, use web URL
        return await _openWebUrl(cleanedNumber, encodedMessage);
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  // Android-specific implementation
  static Future<bool> _openOnAndroid(String phoneNumber, String message) async {
    // Try app URL first
    String appUrl = 'whatsapp://send?phone=$phoneNumber';
    if (message.isNotEmpty) {
      appUrl += '&text=$message';
    }
    
    final Uri appUri = Uri.parse(appUrl);
    
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('App URL failed: $e');
    }
    
    // Try intent URL for Android
    String intentUrl = 'intent://send?phone=$phoneNumber';
    if (message.isNotEmpty) {
      intentUrl += '&text=$message';
    }
    intentUrl += '#Intent;scheme=whatsapp;package=com.whatsapp;end';
    
    final Uri intentUri = Uri.parse(intentUrl);
    
    try {
      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('Intent URL failed: $e');
    }
    
    // Fallback to web URL
    return await _openWebUrl(phoneNumber, message);
  }

  // iOS-specific implementation
  static Future<bool> _openOnIOS(String phoneNumber, String message) async {
    // Try app URL first
    String appUrl = 'whatsapp://send?phone=$phoneNumber';
    if (message.isNotEmpty) {
      appUrl += '&text=$message';
    }
    
    final Uri appUri = Uri.parse(appUrl);
    
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('App URL failed: $e');
    }
    
    // Fallback to web URL
    return await _openWebUrl(phoneNumber, message);
  }

  // Web URL implementation
  static Future<bool> _openWebUrl(String phoneNumber, String message) async {
    String webUrl = 'https://wa.me/$phoneNumber';
    if (message.isNotEmpty) {
      webUrl += '?text=$message';
    }
    
    final Uri webUri = Uri.parse(webUrl);
    
    try {
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('Web URL failed: $e');
    }
    
    return false;
  }

  // Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      if (Platform.isAndroid) {
        // Check using package name
        const String packageUrl = 'whatsapp://';
        final Uri uri = Uri.parse(packageUrl);
        return await canLaunchUrl(uri);
      } else if (Platform.isIOS) {
        // Check using app scheme
        const String appUrl = 'whatsapp://';
        final Uri uri = Uri.parse(appUrl);
        return await canLaunchUrl(uri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Alternative method with better error handling
  static Future<bool> openWhatsAppWithFallback({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      String cleanedNumber = _formatPhoneNumber(phoneNumber);
      String encodedMessage = message != null ? Uri.encodeComponent(message) : '';
      
      // List of URLs to try in order
      List<String> urlsToTry = [];
      
      if (Platform.isAndroid) {
        String messageParam = encodedMessage.isNotEmpty ? '&text=$encodedMessage' : '';
        urlsToTry.addAll([
          'whatsapp://send?phone=$cleanedNumber$messageParam',
          'intent://send?phone=$cleanedNumber$messageParam#Intent;scheme=whatsapp;package=com.whatsapp;end',
          'https://wa.me/$cleanedNumber${encodedMessage.isNotEmpty ? '?text=$encodedMessage' : ''}',
        ]);
      } else if (Platform.isIOS) {
        String messageParam = encodedMessage.isNotEmpty ? '&text=$encodedMessage' : '';
        urlsToTry.addAll([
          'whatsapp://send?phone=$cleanedNumber$messageParam',
          'https://wa.me/$cleanedNumber${encodedMessage.isNotEmpty ? '?text=$encodedMessage' : ''}',
        ]);
      } else {
        urlsToTry.add('https://wa.me/$cleanedNumber${encodedMessage.isNotEmpty ? '?text=$encodedMessage' : ''}');
      }
      
      // Try each URL
      for (String url in urlsToTry) {
        try {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
        } catch (e) {
          print('Failed to launch $url: $e');
          continue;
        }
      }
      
      return false;
    } catch (e) {
      print('Error in openWhatsAppWithFallback: $e');
      return false;
    }
  }

  // Private method to format phone number
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Remove + from the beginning if present for processing
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    // Add country code if not present (assuming Indian number)
    if (!cleaned.startsWith('91') && cleaned.length == 10) {
      cleaned = '91$cleaned';
    }
    
    return cleaned;
  }

  // Method to open WhatsApp Business
  static Future<bool> openWhatsAppBusiness({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      String cleanedNumber = _formatPhoneNumber(phoneNumber);
      String encodedMessage = message != null ? Uri.encodeComponent(message) : '';
      
      // Try WhatsApp Business app URL
      String businessUrl = 'whatsapp://send?phone=$cleanedNumber';
      if (encodedMessage.isNotEmpty) {
        businessUrl += '&text=$encodedMessage';
      }
      
      final Uri businessUri = Uri.parse(businessUrl);
      
      if (await canLaunchUrl(businessUri)) {
        await launchUrl(businessUri, mode: LaunchMode.externalApplication);
        return true;
      }
      
      // Fallback to regular WhatsApp
      return await openWhatsApp(phoneNumber: phoneNumber, message: message);
    } catch (e) {
      print('Error opening WhatsApp Business: $e');
      return false;
    }
  }

    static Future<bool> sendDueMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    String? customMessage,
    bool detailed = false,
  }) async {
    String phoneNumber = customerDue.customer.primaryPhone??"";
    
    String message = detailed 
        ? WhatsAppDueMessageService.generateDetailedDueMessage(
            customerDue: customerDue,
            businessName: businessName,
            customMessage: customMessage,
          )
        : WhatsAppDueMessageService.generateDueMessage(
            customerDue: customerDue,
            businessName: businessName,
            customMessage: customMessage,
          );

    bool success = await WhatsAppService.openWhatsAppWithFallback(
      phoneNumber: phoneNumber,
      message: message,
    );
    
    if (success) {
      print('Due message sent successfully to ${customerDue.customer.name}');
    } else {
      print('Failed to send due message to ${customerDue.customer.name}');
    }
    
    return success;
  }

  // Send overdue reminder
  static Future<bool> sendOverdueReminder({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    String? customMessage,
  }) async {
    String phoneNumber = customerDue.customer.primaryPhone??"";
    int daysPastDue = WhatsAppDueMessageService.daysPastDue(customerDue);
    
    String message = WhatsAppDueMessageService.generateOverdueReminderMessage(
      customerDue: customerDue,
      businessName: businessName,
      daysPastDue: daysPastDue,
      customMessage: customMessage,
    );

    bool success = await WhatsAppService.openWhatsAppWithFallback(
      phoneNumber: phoneNumber,
      message: message,
    );
    
    return success;
  }

  // Send multiple dues message (like reference image)
  static Future<bool> sendMultipleDuesMessage({
    required List<CustomerDueDetailsModel> customerDues,
    required String businessName,
    required String customerName,
    required String phoneNumber,
    String? customMessage,
  }) async {
    String message = WhatsAppDueMessageService.generateMultipleDuesMessage(
      customerDues: customerDues,
      businessName: businessName,
      customerName: customerName,
      customMessage: customMessage,
    );

    bool success = await WhatsAppService.openWhatsAppWithFallback(
      phoneNumber: phoneNumber,
      message: message,
    );
    
    return success;
  }

  // Send payment received confirmation
  static Future<bool> sendPaymentReceivedMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    required double paidAmount,
  }) async {
    String phoneNumber = customerDue.customer.primaryPhone??"";
    
    String message = WhatsAppDueMessageService.generatePaymentReceivedMessage(
      customerDue: customerDue,
      businessName: businessName,
      paidAmount: paidAmount,
    );

    bool success = await WhatsAppService.openWhatsAppWithFallback(
      phoneNumber: phoneNumber,
      message: message,
    );
    
    return success;
  }
}

// Usage example:
void _openWhatsApp(String phoneNumber) async {
  bool success = await WhatsAppService.openWhatsAppWithFallback(
    phoneNumber: phoneNumber,
    message: "hi"
  );
  
  if (success) {
    print('WhatsApp opened successfully');
  } else {
    print('Failed to open WhatsApp');
    // Show user a message that WhatsApp is not installed
    _showWhatsAppNotInstalledDialog();
  }


}

void _showWhatsAppNotInstalledDialog() {
  // Show dialog to user suggesting to install WhatsApp
  // You can implement this based on your UI framework
}