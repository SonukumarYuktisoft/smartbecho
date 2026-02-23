import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUploadController extends GetxController {
  var isFileUploading = false.obs;
  var selectedFile = Rx<File?>(null);
  var fileName = ''.obs;
  var fileSize = ''.obs;

  Future<void> pickFile({
    List<String>? allowedExtensions,
    FileType fileType = FileType.any,
    Function(File file)? onFileSelected,
  }) async {
    try {
      isFileUploading.value = true;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions ?? ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        fileName.value = result.files.single.name;
        fileSize.value = _formatFileSize(result.files.single.size);
        
        // Call callback if provided
        if (onFileSelected != null) {
          onFileSelected(selectedFile.value!);
        }
        
        Get.snackbar(
          'Success',
          'File selected: ${result.files.single.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Info',
          'No file selected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isFileUploading.value = false;
    }
  }

  void removeFile({Function()? onFileRemoved}) {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
    
    if (onFileRemoved != null) {
      onFileRemoved();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
