class ValidatorHelper {
  /// Checks if the field is empty
  static String? isEmpty(String? value, {String fieldName = "This field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName cannot be empty";
    }
    return null;
  }

  /// Checks if field is required (more generic)
  static String? isRequired(String? value, {String fieldName = "This field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// Checks if email is valid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final trimmed = value.trim();

    final emailRegex = RegExp(
      r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$",
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return "Enter a valid email";
    }

    return null;
  }

  /// Checks if password is strong (with special characters, numbers, etc.)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    );
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number & special char';
    }
    return null;
  }

  /// Checks if phone number is valid (Indian format - 10 digits)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    // Remove spaces, hyphens, and country code
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check for 10 digit Indian phone number
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return "Enter a valid 10-digit phone number";
    }
    return null;
  }

  /// Checks if number is valid
  static String? validateNumber(String? value, {String fieldName = "Number"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    if (double.tryParse(value.trim()) == null) {
      return "Enter a valid number";
    }
    return null;
  }

  /// Checks if phone number is valid with country code
  static String? validatePhoneWithCountryCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Matches: +91XXXXXXXXXX or 91XXXXXXXXXX or XXXXXXXXXX
    final phoneRegex = RegExp(r'^(\+?91)?[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  /// Checks if PIN code is valid (Indian PIN code - 6 digits)
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "PIN code is required";
    }

    final pin = value.trim();

    // Length check
    if (pin.length != 6) {
      return "PIN code must be exactly 6 digits";
    }

    // Numeric check
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return "PIN code must contain only numbers";
    }

    return null; // ✅ valid
  }

  /// Checks if PIC code is valid (format: ABC12345)
  // static String? validatePicCode(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return "PIC code is required";
  //   }
  //   final picCodeRegex = RegExp(r'^[A-Z]{3}\d{5}$');
  //   if (!picCodeRegex.hasMatch(value.trim())) {
  //     return "Enter a valid PIC code (e.g., ABC12345)";
  //   }
  //   return null;
  // }

  /// Checks if address is valid
  static String? validateAddress(String? value, {int minLength = 10}) {
    if (value == null || value.trim().isEmpty) {
      return "Address is required";
    }
    if (value.trim().length < minLength) {
      return "Address must be at least $minLength characters long";
    }
    return null;
  }

  static String? validateAddressLabel(String? value, {int minLength = 10}) {
    if (value == null || value.trim().isEmpty) {
      return "Address label is required";
    }
    if (value.trim().length < minLength) {
      return "Address label must be at least $minLength characters long";
    }
    return null;
  }

  static String? validateAddressLine1(String? value, {int minLength = 5}) {
    if (value == null || value.trim().isEmpty) {
      return "Address line 1 is required";
    }
    if (value.trim().length < minLength) {
      return "Address line 1 must be at least $minLength characters long";
    }
    return null;
  }

  static String? validateAddressLine2(String? value, {int minLength = 5}) {
    if (value == null || value.trim().isEmpty) {
      return "Address line 2 is required";
    }
    if (value.trim().length < minLength) {
      return "Address line 2 must be at least $minLength characters long";
    }
    return null;
  }

  static String? validateAdhaarNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Aadhaar number';
    }

    final aadhaar = value.trim();

    if (aadhaar.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }

    if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      return 'Aadhaar number must contain only digits';
    }

    return null;
  }

  /*   static String? validateAdhaarNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Aadhaar number is required";
    }

    final aadhaar = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      return "Enter a valid 12-digit Aadhaar number";
    }

    if (aadhaar.startsWith('0') || aadhaar.startsWith('1')) {
      return "Invalid Aadhaar number";
    }

    if (!_verhoeffValidate(aadhaar)) {
      return "Invalid Aadhaar number";
    }

    return null;

  
  }
  static bool _verhoeffValidate(String num) {
    const d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
    ];

    const p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
    ];

    int c = 0;
    final digits = num.split('').map(int.parse).toList().reversed.toList();

    for (int i = 0; i < digits.length; i++) {
      c = d[c][p[i % 8][digits[i]]];
    }

    return c == 0;
  }*/

  /// Checks if GST number is valid (15 characters)
  // GST Number validation - OPTIONAL
  static String? validateGSTNumber(String? value) {
    // GST optional hai
    if (value == null || value.isEmpty) {
      return null;
    }

    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
    );

    if (!gstRegex.hasMatch(value)) {
      return 'Please enter a valid GST number (e.g., 27ABCDE1234F1Z5)';
    }

    return null;
  }

  static String? validatePan(String? value) {
    // Optional field → empty is valid
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final cleanPan = value.trim().toUpperCase();

    // PAN format: AAAAA9999A
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

    if (!panRegex.hasMatch(cleanPan)) {
      return "Enter a valid PAN number (e.g., ABCDE1234F)";
    }

    return null;
  }

  /// Checks if name is valid
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    final name = value.trim();

    if (name.length < minLength) {
      return "Name must be at least $minLength characters long";
    }

    // Allows letters, spaces, dot, apostrophe, hyphen
    final nameRegex = RegExp(r"^[a-zA-Z]+([ .'-][a-zA-Z]+)*$");

    if (!nameRegex.hasMatch(name)) {
      return "Enter a valid name";
    }

    return null;
  }

  static String? validateShopStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shop store name is required';
    }
    if (value.length < 2) {
      return 'Shop store name must be at least 2 characters';
    }
    return null;
  }

  /// Checks if username is valid
  static String? validateUsername(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required";
    }

    final username = value.trim();

    if (username.length < minLength) {
      return "Username must be at least $minLength characters long";
    }

    // Start with letter, allow letters, numbers, underscore
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(username)) {
      return "Username must start with a letter and contain only letters, numbers, or underscores";
    }

    // Avoid consecutive underscores
    if (username.contains('__')) {
      return "Username cannot contain consecutive underscores";
    }

    return null;
  }

  /// Checks if URL is valid
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "URL is required";
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return "Enter a valid URL";
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter valid amount';
    }
    return null;
  }

  /// Checks if number is within range
  static String? isInRange(
    String? value, {
    required double min,
    required double max,
    String fieldName = "Value",
  }) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return "Enter a valid number";
    }
    if (number < min || number > max) {
      return "$fieldName must be between $min and $max";
    }
    return null;
  }

  /// Checks if date is valid
  static String? validateDate(String? value, {String format = 'dd/MM/yyyy'}) {
    if (value == null || value.trim().isEmpty) {
      return "Date is required";
    }
    try {
      // Basic date validation for dd/MM/yyyy format
      final parts = value.split('/');
      if (parts.length != 3) return "Enter date in $format format";

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return "Enter a valid date";
      }
      return null;
    } catch (e) {
      return "Enter a valid date";
    }
  }

  /// Checks if age is valid (based on date of birth)
  static String? validateAge(
    String? dateOfBirth, {
    required int minAge,
    required int maxAge,
    String format = 'dd/MM/yyyy',
  }) {
    if (dateOfBirth == null || dateOfBirth.trim().isEmpty) {
      return "Date of birth is required";
    }

    try {
      final parts = dateOfBirth.split('/');
      if (parts.length != 3) return "Enter date in $format format";

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dob = DateTime(year, month, day);
      final today = DateTime.now();
      final age = today.year - dob.year;

      if (age < minAge) {
        return "Age must be at least $minAge years";
      }
      if (age > maxAge) {
        return "Age must not exceed $maxAge years";
      }
      return null;
    } catch (e) {
      return "Enter a valid date of birth";
    }
  }

  /// Confirms if two passwords match
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return "Please confirm your password";
    }
    if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return null;
  }

  /// Checks minimum length
  static String? minLength(
    String? value,
    int length, {
    String fieldName = "This field",
  }) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    if (value.trim().length < length) {
      return "$fieldName must be at least $length characters long";
    }
    return null;
  }

  /// Checks maximum length
  static String? maxLength(
    String? value,
    int length, {
    String fieldName = "This field",
  }) {
    if (value == null) return null;
    if (value.trim().length > length) {
      return "$fieldName must not exceed $length characters";
    }
    return null;
  }

  /// Checks if IFSC code is valid
  static String? validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "IFSC code is required";
    }

    final cleanIfsc = value.trim().toUpperCase();

    // IFSC format: 4 letters (bank code) + 0 + 6 characters (branch code)
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

    if (!ifscRegex.hasMatch(cleanIfsc)) {
      return "Enter a valid IFSC code (e.g., SBIN0001234)";
    }

    return null;
  }

  /// Checks if vehicle number is valid (Indian format)
  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vehicle number is required";
    }

    final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    // Format: MH12AB1234 (2 letters + 2 digits + 1-2 letters + 1-4 digits)
    final vehicleRegex = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{1,4}$');

    if (!vehicleRegex.hasMatch(cleanNumber)) {
      return "Enter a valid vehicle number (e.g., MH12AB1234)";
    }

    return null;
  }

  //add validateAddress validation

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    if (value.length < 2) {
      return 'City must be at least 2 characters';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    if (value.length < 2) {
      return 'State must be at least 2 characters';
    }
    return null;
  }

  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }
    if (value.length < 2) {
      return 'Country must be at least 2 characters';
    }
    return null;
  }

  static String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final text = value.trim();

    if (text.length < 5) {
      return 'Note must be at least 5 characters';
    }

    if (text.length > 100) {
      return 'Note can not exceed 100 characters';
    }

    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final text = value.trim();

    if (text.length < 5) {
      return 'Description must be at least 5 characters';
    }

    if (text.length > 500) {
      return 'Description can not exceed 500 characters';
    }

    return null;
  }

  static String? validateRequiredDescription(String? value) {
    
    if ((value == null || value.trim().isEmpty)) {
      return 'Description is required';
    }

    final text = value.trim();

    if (text.length < 5) {
      return 'Description must be at least 5 characters';
    }

    if (text.length > 500) {
      return 'Description can not exceed 500 characters';
    }

    return null;
  }

  // validateReturnReason validation
  static bool hasEnoughVowels(String text) {
    final vowels = RegExp(r'[aeiouAEIOU]');
    final vowelCount = vowels.allMatches(text).length;
    return vowelCount >= 2;
  }

  static bool isGibberishWord(String word) {
    if (word.length < 4) return false;

    // consonant ratio
    final consonants = RegExp(r'[bcdfghjklmnpqrstvwxyz]', caseSensitive: false);
    final matches = consonants.allMatches(word).length;

    return (matches / word.length) > 0.8;
  }

  static bool containsTooMuchGibberish(String text) {
    final words = text.split(' ');
    int gibberishCount = 0;

    for (final word in words) {
      if (isGibberishWord(word)) {
        gibberishCount++;
      }
    }

    return gibberishCount >= (words.length / 2);
  }

  static bool hasTooManyRepeats(List<String> words) {
    for (int i = 0; i < words.length - 2; i++) {
      if (words[i] == words[i + 1] && words[i] == words[i + 2]) {
        return true;
      }
    }
    return false;
  }

  static String? validateReturnReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Return reason is required';
    }

    final text = value.trim();

    if (text.length < 10) {
      return 'Please enter a meaningful reason';
    }

    final words = text.split(' ');
    if (words.length < 2) {
      return 'Please enter proper words';
    }

    if (hasTooManyRepeats(words)) {
      return 'Reason looks invalid';
    }

    if (containsTooMuchGibberish(text)) {
      return 'Please enter a valid return reason';
    }

    return null;
  }

  /// Custom validator with regex pattern
  static String? customPattern(
    String? value,
    RegExp pattern, {
    required String errorMessage,
    String fieldName = "This field",
  }) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    if (!pattern.hasMatch(value.trim())) {
      return errorMessage;
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
