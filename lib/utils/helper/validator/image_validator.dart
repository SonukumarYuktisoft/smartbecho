import 'dart:io';

class ImageValidator {
  static String? validateImageSize({
    required File imageFile,
    required double maxSizeInMB,
  }) {
    final bytes = imageFile.lengthSync();
    final sizeInMB = bytes / (1024 * 1024);

    if (sizeInMB > maxSizeInMB) {
      return "Your image size is ${sizeInMB.toStringAsFixed(2)}MB. "
          "Please select an image smaller than ${maxSizeInMB}MB.";
    }

    return null;
  }
}
