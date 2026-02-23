import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartbecho/services/api_error_handler.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();

  factory DownloadService() {
    return _instance;
  }

  DownloadService._internal();

  final Dio _dio = Dio();
  final downloadProgress = 0.0.obs;
  final isDownloading = false.obs;
  final downloadedFilePath = ''.obs;
  CancelToken? _cancelToken;

  // ==================== CHECK & REQUEST PERMISSIONS ====================
  Future<bool> _checkAndRequestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        log("📱 Android SDK: $sdkInt");

        // Android 13+ (API 33+) - Use MANAGE_EXTERNAL_STORAGE or scoped storage
        if (sdkInt >= 33) {
          // Android 13+ doesn't need storage permission for scoped storage
          return true;
        }
        // Android 10-12 (API 29-32)
        else if (sdkInt >= 29) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              log("❌ Storage permission denied");
              _showPermissionDialog();
              return false;
            }
          }
          return true;
        }
        // Android 6-9 (API 23-28)
        else {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              log("❌ Storage permission denied");
              _showPermissionDialog();
              return false;
            }
          }
          return true;
        }
      }
      
      // iOS doesn't need special permissions for app documents
      return true;
    } catch (e) {
      log("❌ Permission check error: $e");
      return true; // Continue anyway and let it fail gracefully
    }
  }

  // ==================== SHOW PERMISSION DIALOG ====================
  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'This app needs storage permission to download files. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ==================== DOWNLOAD FILE ====================
  /// Download file from URL and save to device download folder
  /// Automatically shows bottom sheet after successful download
  Future<String?> downloadFile({
    required String url,
    required String fileName,
    Map<String, dynamic>? queryParameters,
    required bool authToken,
    BuildContext? context,
    bool showToast = false,
    String? featureKey,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      _cancelToken = CancelToken();

      log("📡 DOWNLOAD: $url");
      log("💾 FILE: $fileName");

      // Check permissions first
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download directory path
      final downloadPath = await _getDownloadPath();
      if (downloadPath == null) {
        throw Exception('Unable to access download directory');
      }

      final filePath = '$downloadPath/$fileName';
      log("📂 Save Path: $filePath");

      // Prepare headers
      final headers = await _getHeaders(authToken);

      // Download file
      final response = await _dio.download(
        url,
        filePath,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
          validateStatus: (_) => true,
        ),
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = (received / total) * 100;
            log('Download Progress: ${downloadProgress.value.toStringAsFixed(2)}%');
            onReceiveProgress?.call(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        log("✅ File downloaded successfully: $filePath");
        downloadedFilePath.value = filePath;

        // Show success toast if requested
        if (showToast) {
          Get.snackbar(
            'Success',
            'File downloaded successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }

        // Auto-show bottom sheet after download completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context != null && context.mounted) {
            _showDownloadOptions(
              context: context,
              filePath: filePath,
              fileName: fileName,
            );
          }
        });

        return filePath;
      } else {
        final errorMsg = 'Download failed with status: ${response.statusCode}';
        log("❌ $errorMsg");
        final handledError = ApiErrorHandler.handleResponse(
          response,
          context: context,
          showToast: showToast,
        );
        throw Exception(handledError['message'] ?? errorMsg);
      }
    } on DioException catch (e) {
      log("❌ DioException: ${e.toString()}");
      if (e.type == DioExceptionType.cancel) {
        log("⚠️ Download was cancelled");
        return null;
      }
      ApiErrorHandler.handleError(
        e,
        context: context,
        showToast: showToast,
      );
      return null;
    } catch (error) {
      log("❌ Error: ${error.toString()}");
      ApiErrorHandler.handleError(
        error,
        context: context,
        showToast: showToast,
      );
      return null;
    } finally {
      isDownloading.value = false;
      _cancelToken = null;
    }
  }

  // ==================== CANCEL DOWNLOAD ====================
  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
    isDownloading.value = false;
    downloadProgress.value = 0.0;
    log("🛑 Download cancelled");
  }

  // ==================== SHOW DOWNLOAD OPTIONS (Bottom Sheet) ====================
  /// Beautiful bottom sheet with download options: Print, Share, Open
  void _showDownloadOptions({
    required BuildContext context,
    required String filePath,
    required String fileName,
  }) {
    final file = File(filePath);
    final fileSize = file.lengthSync();
    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    final fileExtension = fileName.split('.').last.toUpperCase();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================== HEADER ====================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getFileIcon(fileName),
                        color: const Color(0xFF4F46E5),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download Complete',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ==================== FILE INFO ====================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File Size',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$fileSizeMB MB',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFE5E7EB),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'File Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileExtension,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ==================== ACTION BUTTONS ====================
                Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Print Option
                _buildActionButton(
                  icon: Icons.print,
                  title: 'Print',
                  subtitle: 'Print to connected device',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Get.back();
                    _printFile(filePath, fileName);
                  },
                ),
                const SizedBox(height: 12),

                // Share Option
                _buildActionButton(
                  icon: Icons.share,
                  title: 'Share',
                  subtitle: 'Share with others',
                  color: const Color(0xFF06B6D4),
                  onTap: () {
                    Get.back();
                    _shareFile(filePath, fileName);
                  },
                ),
                const SizedBox(height: 12),

                // Open Option
                _buildActionButton(
                  icon: Icons.open_in_new,
                  title: 'Open',
                  subtitle: 'Open file with default app',
                  color: const Color(0xFF059669),
                  onTap: () {
                    Get.back();
                    _openFile(filePath, fileName);
                  },
                ),
                const SizedBox(height: 20),

                // ==================== CLOSE BUTTON ====================
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      enterBottomSheetDuration: const Duration(milliseconds: 400),
      exitBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }

  // ==================== BUILD ACTION BUTTON ====================
  /// Custom action button widget with icon, title, and subtitle
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OPEN FILE ====================
  Future<void> _openFile(String filePath, String fileName) async {
    try {
      log("📂 Opening file: $fileName");
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        Get.snackbar(
          'Error',
          'Unable to open file. Please use another app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        log("⚠️ File open failed: ${result.message}");
      } else {
        log("✅ File opened successfully");
      }
    } catch (e) {
      log("❌ Error opening file: $e");
      Get.snackbar(
        'Error',
        'Could not open file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // ==================== SHARE FILE ====================
  Future<void> _shareFile(String filePath, String fileName) async {
    try {
      log("📤 Sharing file: $fileName");
      
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found');
      }

      final xFile = XFile(filePath);
      final result = await Share.shareXFiles(
        [xFile],
        text: 'Check out this file: $fileName',
      );

      if (result.status == ShareResultStatus.success) {
        log("✅ File shared successfully");
        Get.snackbar(
          'Success',
          'File shared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else if (result.status == ShareResultStatus.unavailable) {
        log("⚠️ Share unavailable or cancelled by user");
      }
    } catch (e) {
      log("❌ Error sharing file: $e");
      Get.snackbar(
        'Error',
        'Could not share file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // ==================== PRINT FILE ====================
  /// Print file (currently supports PDF via Bluetooth thermal printer)
  Future<void> _printFile(String filePath, String fileName) async {
    try {
      log("🖨️ Starting print process for: $fileName");

      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found');
      }

      final fileExtension = fileName.split('.').last.toLowerCase();

      // Only PDF files can be printed
      if (fileExtension != 'pdf') {
        Get.snackbar(
          'Info',
          'Printing is currently supported for PDF files only',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Check if Bluetooth printer is connected
      final isConnected = await PrintBluetoothThermal.connectionStatus;

      if (!isConnected) {
        Get.snackbar(
          'Error',
          'No Bluetooth printer connected. Please connect a printer first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        log("⚠️ No Bluetooth printer connected");
        return;
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Send to printer using the correct method
      await PrintBluetoothThermal.writeBytes(bytes);

      log("✅ File sent to printer successfully");
      Get.snackbar(
        'Success',
        'File sent to printer: $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      log("❌ Error printing file: $e");
      Get.snackbar(
        'Error',
        'Could not print file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ==================== GET DOWNLOAD PATH ====================
  /// ✅ FIXED: Proper Android storage handling with fallback options
  Future<String?> _getDownloadPath() async {
    try {
      String downloadPath;
      
      if (Platform.isAndroid) {
        // Try multiple approaches for Android
        try {
          // Method 1: Try external storage directory (works on most devices)
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Navigate to public Download folder
            // Path structure: /storage/emulated/0/Android/data/package/files
            // We want: /storage/emulated/0/Download
            final pathParts = externalDir.path.split('/');
            
            // Find the index of 'Android' in the path
            final androidIndex = pathParts.indexOf('Android');
            
            if (androidIndex > 0) {
              // Construct path up to /storage/emulated/0/
              final basePath = pathParts.sublist(0, androidIndex).join('/');
              downloadPath = '$basePath/Download';
              
              log("✅ Using public Download folder: $downloadPath");
            } else {
              // Fallback to app-specific directory
              downloadPath = '${externalDir.path}/Downloads';
              log("⚠️ Using app-specific folder: $downloadPath");
            }
          } else {
            // Method 2: Fallback to application documents directory
            final appDocDir = await getApplicationDocumentsDirectory();
            downloadPath = '${appDocDir.path}/Downloads';
            log("⚠️ Using app documents folder: $downloadPath");
          }
        } catch (e) {
          log("⚠️ Error getting external storage, using fallback: $e");
          // Method 3: Last resort - use application cache directory
          final appCacheDir = await getApplicationCacheDirectory();
          downloadPath = '${appCacheDir.path}/Downloads';
          log("⚠️ Using cache folder (last resort): $downloadPath");
        }
      } else if (Platform.isIOS) {
        // iOS: Use Documents/Downloads
        final directory = await getApplicationDocumentsDirectory();
        downloadPath = '${directory.path}/Downloads';
        log("✅ iOS download path: $downloadPath");
      } else {
        // Other platforms
        final directory = await getApplicationDocumentsDirectory();
        downloadPath = '${directory.path}/Downloads';
        log("✅ Other platform download path: $downloadPath");
      }

      // Create directory if it doesn't exist
      final downloadDir = Directory(downloadPath);
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
        log("✅ Download directory created: $downloadPath");
      } else {
        log("✅ Download directory exists: $downloadPath");
      }

      // Verify we can write to this directory
      final testFile = File('$downloadPath/.test');
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        log("✅ Write permission verified");
      } catch (e) {
        log("⚠️ Cannot write to directory: $e");
        // If we can't write, try app documents as final fallback
        final appDocDir = await getApplicationDocumentsDirectory();
        downloadPath = '${appDocDir.path}/Downloads';
        final fallbackDir = Directory(downloadPath);
        if (!fallbackDir.existsSync()) {
          fallbackDir.createSync(recursive: true);
        }
        log("✅ Using final fallback: $downloadPath");
      }

      log("📂 Final download path: $downloadPath");
      return downloadPath;
    } catch (e) {
      log("❌ Error getting download path: $e");
      return null;
    }
  }

  // ==================== GET HEADERS ====================
  Future<Map<String, dynamic>> _getHeaders(bool authToken) async {
    if (authToken) {
      final jwtToken = await SharedPreferencesHelper.getJwtToken();
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      };
    }
    return {"Content-Type": "application/json"};
  }

  // ==================== GET FILE ICON ====================
  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'json':
      case 'xml':
        return Icons.data_object;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.file_present;
    }
  }
}