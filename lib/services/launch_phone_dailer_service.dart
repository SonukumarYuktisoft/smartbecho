import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class PhoneDialerService {
  
  /// Launch phone dialer with the given phone number
  static Future<bool> launchPhoneDialer(String phoneNumber) async {
    try {
      // Clean the phone number (remove spaces, dashes, brackets, etc.)
      String cleanedNumber = _cleanPhoneNumber(phoneNumber);
      
      if (cleanedNumber.isEmpty) {
        throw 'Invalid phone number format';
      }
      
      print('Attempting to dial: $cleanedNumber');
      
      // Try different approaches based on platform
      if (Platform.isAndroid) {
        return await _launchForAndroid(cleanedNumber);
      } else if (Platform.isIOS) {
        return await _launchForIOS(cleanedNumber);
      } else {
        return await _launchGeneric(cleanedNumber);
      }
      
    } catch (e) {
      print('Error in launchPhoneDialer: $e');
      rethrow;
    }
  }
  
  /// Clean phone number by removing non-digit characters except +
  static String _cleanPhoneNumber(String phoneNumber) {
    // Remove all characters except digits and plus sign
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with + for international numbers or has at least some digits
    if (cleaned.isEmpty) {
      return '';
    }
    
    return cleaned;
  }
  
  /// Android-specific dialing logic
  static Future<bool> _launchForAndroid(String phoneNumber) async {
    // Try multiple schemes in order of preference
    final List<String> schemes = ['tel'];
    
    for (String scheme in schemes) {
      try {
        final Uri uri = Uri(scheme: scheme, path: phoneNumber);
        print('Trying scheme: $scheme with URI: $uri');
        
        if (await canLaunchUrl(uri)) {
          bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (launched) {
            print('Successfully launched with scheme: $scheme');
            return true;
          }
        }
      } catch (e) {
        print('Failed with scheme $scheme: $e');
        continue;
      }
    }
    
    throw 'Could not launch phone dialer on Android';
  }
  
  /// iOS-specific dialing logic
  static Future<bool> _launchForIOS(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Cannot launch tel: URLs on this iOS device';
      }
    } catch (e) {
      print('iOS dialing failed: $e');
      rethrow;
    }
  }
  
  /// Generic dialing logic for other platforms
  static Future<bool> _launchGeneric(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Phone dialing not supported on this platform';
      }
    } catch (e) {
      print('Generic dialing failed: $e');
      rethrow;
    }
  }
  
  /// Open dialer app without auto-dialing (safer option)
  static Future<bool> openDialer([String? phoneNumber]) async {
    try {
      String number = phoneNumber != null ? _cleanPhoneNumber(phoneNumber) : '';
      
      final Uri dialerUri = Uri(scheme: 'tel', path: number);
      
      if (await canLaunchUrl(dialerUri)) {
        return await launchUrl(
          dialerUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not open phone dialer';
      }
    } catch (e) {
      print('Error opening dialer: $e');
      rethrow;
    }
  }
  
  /// Check if phone dialing is available on this device
  static Future<bool> isPhoneDialingAvailable() async {
    try {
      final Uri testUri = Uri(scheme: 'tel', path: '');
      return await canLaunchUrl(testUri);
    } catch (e) {
      return false;
    }
  }
}