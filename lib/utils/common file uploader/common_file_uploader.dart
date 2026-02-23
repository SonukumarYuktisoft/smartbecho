
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/common%20file%20uploader/common_fileupload_controller.dart';

class CommonFileUploadWidget extends StatelessWidget {
  final FileUploadController? controller;
  final String title;
  final String subtitle;
  final List<String>? allowedExtensions;
  final FileType fileType;
  final Function(File file)? onFileSelected;
  final Function()? onFileRemoved;
  final bool isDarkTheme;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? height;
  final bool showFileSize;
  final bool showFileName;
  final Widget? customIcon;

  const CommonFileUploadWidget({
    Key? key,
    this.controller,
    this.title = 'Upload File',
    this.subtitle = 'Click to select JPG, PNG, or PDF file',
    this.allowedExtensions,
    this.fileType = FileType.custom,
    this.onFileSelected,
    this.onFileRemoved,
    this.isDarkTheme = true,
    this.primaryColor,
    this.backgroundColor,
    this.borderColor,
    this.height,
    this.showFileSize = true,
    this.showFileName = true,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FileUploadController fileController = controller ?? Get.put(FileUploadController());
    
    final Color effectivePrimaryColor = primaryColor ?? const Color(0xFF10B981);
    final Color effectiveBackgroundColor = backgroundColor ?? 
        (isDarkTheme ? const Color(0xFF2A2A2A) : Colors.grey.withValues(alpha:0.05));
    final Color effectiveBorderColor = borderColor ?? 
        (isDarkTheme ? Colors.grey.withValues(alpha:0.2) : Colors.grey.withValues(alpha:0.3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkTheme ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Obx(() => fileController.selectedFile.value == null
            ? _buildFilePickerButton(fileController, effectivePrimaryColor, effectiveBackgroundColor, effectiveBorderColor)
            : _buildSelectedFileCard(fileController, effectivePrimaryColor, effectiveBackgroundColor, effectiveBorderColor)),
      ],
    );
  }

  Widget _buildFilePickerButton(FileUploadController fileController, Color primaryColor, Color backgroundColor, Color borderColor) {
    return InkWell(
      onTap: fileController.isFileUploading.value 
          ? null 
          : () => fileController.pickFile(
              allowedExtensions: allowedExtensions,
              fileType: fileType,
              onFileSelected: onFileSelected,
            ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: height ?? 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (fileController.isFileUploading.value)
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            else
              customIcon ?? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_upload_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              fileController.isFileUploading.value ? 'Selecting file...' : title,
              style: TextStyle(
                color: isDarkTheme ? const Color(0xFF374151) : const Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fileController.isFileUploading.value ? 'Please wait' : subtitle,
              style: TextStyle(
                color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(FileUploadController fileController, Color primaryColor, Color backgroundColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileController.fileName.value),
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showFileName)
                  Text(
                    fileController.fileName.value,
                    style: TextStyle(
                      color: isDarkTheme ? const Color(0xFF374151) : const Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'File selected',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (showFileSize && fileController.fileSize.value.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${fileController.fileSize.value}',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              InkWell(
                onTap: () => fileController.pickFile(
                  allowedExtensions: allowedExtensions,
                  fileType: fileType,
                  onFileSelected: onFileSelected,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => fileController.removeFile(onFileRemoved: onFileRemoved),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.attach_file;
    }
  }
}