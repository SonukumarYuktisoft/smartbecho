import 'dart:convert';


class JwtHelper {
  /// Check if JWT token is expired
  static bool isTokenExpired(String token) {
    try {
      // Split the token to get the payload part
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // Invalid token format
      }

      // Decode the payload (middle part)
      final payload = parts[1];
      
      // Add padding if needed for base64 decoding
      String normalizedPayload = _addBase64Padding(payload);
      
      // Decode the JSON payload
      final payloadMap = json.decode(utf8.decode(base64.decode(normalizedPayload)));
      
      // Get expiry timestamp
      final exp = payloadMap['exp'];
      if (exp == null) {
        return true; // No expiry claim found
      }

      // Convert to DateTime and compare with current time
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final currentDate = DateTime.now();
      
      return currentDate.isAfter(expiryDate);
    } catch (e) {
      print('Error checking token expiry: $e');
      return true; // Consider expired if error occurs
    }
  }

  /// Helper method to add base64 padding
  static String _addBase64Padding(String source) {
    switch (source.length % 4) {
      case 0:
        return source;
      case 2:
        return source + "==";
      case 3:
        return source + "=";
      default:
        throw Exception("Invalid base64 string");
    }
  }
}