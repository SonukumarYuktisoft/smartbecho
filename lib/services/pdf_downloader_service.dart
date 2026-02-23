import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartbecho/services/api_error_handler.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFDownloadService {
  static final dio.Dio _dio = dio.Dio();

  /// Downloads a PDF file from the given URL and saves it to device storage
  /// ✅ FIXED: Better error handling, URL validation, and headers
  /// Downloads a PDF file from the given URL and saves it to device storage
  /// ✅ Uses ApiErrorHandler for consistent error handling
  static Future<void> downloadPDF({
    required String url,
    required String fileName,
    String? customPath,
    bool openAfterDownload = true,
    VoidCallback? onDownloadComplete,
    BuildContext? context,
  }) async {
    try {
      // ✅ Validate URL
      if (url.isEmpty) {
        ToastHelper.error(
          message: 'Invalid URL',
          description: 'PDF URL is empty',
          context: context,
        );
        return;
      }

      print('🌐 Download URL: $url');
      print('📄 File name: $fileName');

      // Show initial loading snackbar
      Get.snackbar(
        'Download Started',
        'Downloading $fileName...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 2),
      );

      // Check and request permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ToastHelper.error(
          message: 'Permission Denied',
          description: 'Storage permission is required',
          context: context,
        );
        return;
      }

      // ✅ Get base download directory
      Directory? baseDirectory;

      if (Platform.isAndroid) {
        // Try standard Android Download paths
        baseDirectory = Directory('/storage/emulated/0/Download');
        if (!await baseDirectory.exists()) {
          baseDirectory = Directory('/storage/emulated/0/Downloads');
          if (!await baseDirectory.exists()) {
            // Fallback to external storage
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              final pathParts = externalDir.path.split('/');
              final androidIndex = pathParts.indexOf('Android');
              if (androidIndex > 0) {
                final basePath = pathParts.sublist(0, androidIndex).join('/');
                baseDirectory = Directory('$basePath/Download');
              } else {
                baseDirectory = Directory('${externalDir.path}/Downloads');
              }
            } else {
              baseDirectory = await getApplicationDocumentsDirectory();
            }
          }
        }
      } else if (Platform.isIOS) {
        baseDirectory = await getApplicationDocumentsDirectory();
      }

      if (baseDirectory == null) {
        throw Exception('Could not access storage directory');
      }

      // ✅ Create base directory if needed
      if (!await baseDirectory.exists()) {
        await baseDirectory.create(recursive: true);
        print('✅ Created base directory: ${baseDirectory.path}');
      }

      // ✅ Handle custom subdirectory
      Directory finalDirectory = baseDirectory;
      if (customPath != null && customPath.isNotEmpty) {
        finalDirectory = Directory('${baseDirectory.path}/$customPath');

        // ✅ Create subdirectory if it doesn't exist
        if (!await finalDirectory.exists()) {
          await finalDirectory.create(recursive: true);
          print('✅ Created subdirectory: ${finalDirectory.path}');
        }
      }

      // ✅ Final save path
      String savePath = '${finalDirectory.path}/$fileName';
      print('📂 Save path: $savePath');

      // ✅ Configure Dio with proper options
      _dio.options = dio.BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          'Accept': 'application/pdf,application/octet-stream,*/*',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      print('🚀 Starting download...');

      // ✅ Download the file
      dio.Response response = await _dio.download(
        url,
        savePath,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('📥 Download progress: ${progress.toStringAsFixed(1)}%');
          } else {
            print('📥 Downloaded: ${(received / 1024).toStringAsFixed(2)} KB');
          }
        },
      );

      print('📡 Response status: ${response.statusCode}');

      // ✅ Use ApiErrorHandler to handle response
      final result = ApiErrorHandler.handleResponse(
        response,
        context: context,
        showToast: false, // We'll show custom toast below
      );

      if (result['success']) {
        print('✅ File downloaded successfully: $savePath');

        // ✅ Verify file exists and has content
        final file = File(savePath);
        if (!await file.exists()) {
          throw Exception('File was not saved properly');
        }

        final fileSize = await file.length();
        print('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        if (fileSize == 0) {
          throw Exception('Downloaded file is empty');
        }

        // ✅ Trigger media scanner on Android
        if (Platform.isAndroid) {
          await _scanMediaFile(savePath);
        }

        // ✅ Success toast
        ToastHelper.success(
          message: 'Download Complete',
          description: '$fileName saved successfully',
          context: context,
        );

        // ✅ Auto-open file
        if (openAfterDownload) {
          await Future.delayed(const Duration(milliseconds: 500));
          final openResult = await OpenFile.open(savePath);

          if (openResult.type != ResultType.done) {
            print('⚠️ Could not open file: ${openResult.message}');
            ToastHelper.warning(
              message: 'File Downloaded',
              description:
                  'Could not open automatically. Find it in Downloads folder.',
              context: context,
            );
          }
        }

        // Call completion callback
        if (onDownloadComplete != null) {
          onDownloadComplete();
        }
      } else {
        // ✅ ApiErrorHandler already logged the error
        throw Exception(result['fullMessage']);
      }
    } on dio.DioException catch (e) {
      // ✅ Use ApiErrorHandler for DioException
      print('❌ DioException occurred');
      ApiErrorHandler.handleError(e, context: context, showToast: true);
    } catch (e) {
      // ✅ Use ApiErrorHandler for general exceptions
      print('❌ General error occurred');
      ApiErrorHandler.handleError(e, context: context, showToast: true);
    }
  }

  /// Downloads a PDF file from the given URL and saves it to device storage
  static Future<void> downloadPDF2({
    required String url,
    required String fileName,
    String? customPath,
    bool openAfterDownload = true,
    VoidCallback? onDownloadComplete,
  }) async {
    try {
      // Show initial loading snackbar
      Get.snackbar(
        'Download Started',
        'Downloading $fileName...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 2),
      );

      // Check and request permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Get the directory to save the file
      String savePath = await _getSavePath(fileName, customPath);

      // Configure Dio options
      _dio.options.responseType = dio.ResponseType.bytes;
      _dio.options.followRedirects = true;
      _dio.options.validateStatus = (status) => status! < 500;

      // Download the file with progress tracking
      dio.Response response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('Download progress: ${progress.toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        // Success snackbar
        Get.snackbar(
          'Download Complete',
          '$fileName saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => _openFile(savePath),
            child: const Text('Open', style: TextStyle(color: Colors.white)),
          ),
        );

        // Open file automatically if requested
        if (openAfterDownload) {
          await _openFile(savePath);
        }

        // Call completion callback
        if (onDownloadComplete != null) {
          onDownloadComplete();
        }
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      _handleDownloadError('Network error: ${e.message}');
    } catch (e) {
      _handleDownloadError('Download failed: ${e.toString()}');
    }
  }

  /// Downloads PDF and returns file path (for sharing)
  static Future<String?> downloadAndGetPath({
    required String url,
    required String fileName,
    String? customPath,
  }) async {
    try {
      // Check and request permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _handleDownloadError('Storage permission is required');
        return null;
      }

      // Get the directory to save the file
      String savePath = await _getSavePath(fileName, customPath);

      // Check if file already exists
      if (await File(savePath).exists()) {
        print('File already exists at: $savePath');
        return savePath;
      }

      // Configure Dio options
      _dio.options.responseType = dio.ResponseType.bytes;
      _dio.options.followRedirects = true;
      _dio.options.validateStatus = (status) => status! < 500;

      // Download the file
      dio.Response response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('Download progress: ${progress.toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        print('File downloaded to: $savePath');
        return savePath;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  /// Share PDF file via system share sheet
  static Future<void> sharePDF({
    required String filePath,
    String? text,
    String? subject,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _handleDownloadError('File not found');
        return;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: text ?? 'Sharing document',
        subject: subject,
      );
    } catch (e) {
      print('Error sharing file: $e');
      _handleDownloadError('Failed to share file');
    }
  }

  /// Share PDF directly to WhatsApp
  static Future<void> shareToWhatsApp({
    required String filePath,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _handleDownloadError('File not found');
        return;
      }

      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Add country code if not present (default India +91)
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+91$cleanPhone';
      }

      // Create WhatsApp URL with message
      String encodedMessage = Uri.encodeComponent(
        message ?? 'Please find the attached document',
      );
      String whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';

      // Check if WhatsApp is installed
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );

        // Wait a moment then share file
        await Future.delayed(Duration(milliseconds: 1500));

        // Share file using system share (will show in WhatsApp)
        await Share.shareXFiles([XFile(filePath)], text: message ?? 'Document');
      } else {
        // Fallback to general share if WhatsApp not installed
        Get.snackbar(
          'WhatsApp Not Found',
          'Opening general share options',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );

        await sharePDF(filePath: filePath, text: message);
      }
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      // Fallback to general share
      await sharePDF(filePath: filePath, text: message);
    }
  }

  /// Download PDF and share (combined action)
  static Future<void> downloadAndShare({
    required String url,
    required String fileName,
    String? customPath,
    String? phoneNumber,
    String? message,
    bool whatsappOnly = false,
  }) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Preparing document...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Download file
      String? filePath = await downloadAndGetPath(
        url: url,
        fileName: fileName,
        customPath: customPath,
      );

      // Close loading
      Get.back();

      if (filePath != null) {
        if (whatsappOnly && phoneNumber != null && phoneNumber.isNotEmpty) {
          // Share to WhatsApp
          await shareToWhatsApp(
            filePath: filePath,
            phoneNumber: phoneNumber,
            message: message,
          );
        } else {
          // General share
          await sharePDF(filePath: filePath, text: message);
        }

        Get.snackbar(
          'Ready to Share',
          'Document prepared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to download document');
      }
    } catch (e) {
      Get.back(); // Close loading if open
      _handleDownloadError('Failed to prepare document for sharing');
      print('Error in downloadAndShare: $e');
    }
  }

  /// Share PDF link with professional message template (No download)
  static Future<void> shareInvoiceLink({
    required String pdfUrl,
    required String invoiceNumber,
    required String customerName,
    required String shopName,
    required String amount,
    required String date,
    String? phoneNumber,
  }) async {
    try {
      // Create professional message template
      String messageTemplate = _createInvoiceMessageTemplate(
        invoiceNumber: invoiceNumber,
        customerName: customerName,
        shopName: shopName,
        amount: amount,
        date: date,
        pdfUrl: pdfUrl,
      );

      // Share message with link
      await Share.share(
        messageTemplate,
        subject: 'Invoice #$invoiceNumber - $shopName',
      );

      Get.snackbar(
        'Ready to Share',
        'Select app to send invoice link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('Error sharing invoice link: $e');
      _handleDownloadError('Failed to share invoice link');
    }
  }

  /// Share to WhatsApp directly with link
  static Future<void> shareInvoiceLinkToWhatsApp({
    required String pdfUrl,
    required String invoiceNumber,
    required String customerName,
    required String shopName,
    required String amount,
    required String date,
    required String phoneNumber,
  }) async {
    try {
      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Add country code if not present
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+91$cleanPhone';
      }

      // Create professional message
      String messageTemplate = _createInvoiceMessageTemplate(
        invoiceNumber: invoiceNumber,
        customerName: customerName,
        shopName: shopName,
        amount: amount,
        date: date,
        pdfUrl: pdfUrl,
      );

      // Encode message for URL
      String encodedMessage = Uri.encodeComponent(messageTemplate);

      // Create WhatsApp URL
      String whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';

      // Open WhatsApp
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );

        Get.snackbar(
          'WhatsApp Opened',
          'Message ready to send',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF25D366).withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          icon: Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // Fallback to general share
        await Share.share(messageTemplate, subject: 'Invoice #$invoiceNumber');
      }
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      _handleDownloadError('Failed to share invoice');
    }
  }

  /// Create professional invoice message template
  static String _createInvoiceMessageTemplate({
    required String invoiceNumber,
    required String customerName,
    required String shopName,
    required String amount,
    required String date,
    required String pdfUrl,
  }) {
    return '''
🛍️ *PURCHASE CONFIRMATION* 🛍️
Hello ${customerName},
Thank you for shopping with us! 🙏
We appreciate your business at our store.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 *DOWNLOAD YOUR INVOICE*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👉 $pdfUrl 👈

💡 Tap the link above to view and download your invoice.
Thank you for your trust! 🙏❤️
*$shopName* ✨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }

  /// Alternative: Shorter message template
  static String _createShortInvoiceMessage({
    required String invoiceNumber,
    required String customerName,
    required String amount,
    required String pdfUrl,
  }) {
    return '''
Hi $customerName,

Your invoice #$invoiceNumber (₹$amount) is ready!

Download: $pdfUrl

Thank you! 🙏
''';
  }

  /// Requests storage permission based on platform and API level
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Try to request manage external storage permission for Android 11+
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      // Fallback to legacy storage permissions
      Map<Permission, PermissionStatus> statuses =
          await [Permission.storage].request();

      return statuses[Permission.storage]?.isGranted ?? false;
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  /// Gets the appropriate save path based on platform
  static Future<String> _getSavePath(
    String fileName,
    String? customPath,
  ) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Try to get Downloads directory first
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Create custom subdirectory if specified
    if (customPath != null) {
      directory = Directory('${directory.path}/$customPath');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }

    return '${directory.path}/$fileName';
  }

  /// Opens the downloaded file
  static Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print('Could not open file: ${result.message}');
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  /// Shows error snackbar
  static void _handleDownloadError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Triggers media scanner on Android to make file visible in file manager
  static Future<void> _scanMediaFile(String filePath) async {
    if (!Platform.isAndroid) return;

    try {
      const platform = MethodChannel('com.example.mobistock/media');
      await platform.invokeMethod('scanFile', {'path': filePath});
    } catch (e) {
      print('Error scanning media file: $e');
    }
  }

  /// Extracts filename from URL
  static String getFileNameFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last;
      return path.isEmpty ? 'downloaded_file.pdf' : path;
    } catch (e) {
      return 'downloaded_file.pdf';
    }
  }

  /// Checks if file already exists
  static Future<bool> fileExists(String fileName, [String? customPath]) async {
    try {
      String filePath = await _getSavePath(fileName, customPath);
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  static Future<void> downloadAndPrint({
    required String url,
    String? fileName,
  }) async {
    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryLight),
                SizedBox(height: 16),
                Text('Preparing to print...', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Check and request permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Get temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/${fileName ?? 'print_document.pdf'}';

      // Configure Dio options
      _dio.options.responseType = dio.ResponseType.bytes;
      _dio.options.followRedirects = true;
      _dio.options.validateStatus = (status) => status! < 500;

      // Download the PDF file
      dio.Response response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('Download progress: ${progress.toStringAsFixed(1)}%');
          }
        },
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        // Read the PDF file as bytes
        File pdfFile = File(savePath);
        final bytes = await pdfFile.readAsBytes();

        // Open system print dialog
        await Printing.layoutPdf(
          onLayout: (format) async => bytes,
          name: fileName ?? 'document.pdf',
        );

        Get.snackbar(
          'Print Dialog Opened',
          'Select your printer to continue',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          icon: Icon(Icons.print, color: Colors.white),
        );

        // Optional: Delete temp file after printing
        await pdfFile.delete();
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      Get.back(); // Close loading if open
      _handleDownloadError('Network error: ${e.message}');
    } catch (e) {
      Get.back(); // Close loading if open
      _handleDownloadError('Print failed: ${e.toString()}');
      print('Error in downloadAndPrint: $e');
    }
  }

  /// Download invoice PDF to user's phone Downloads folder
  static Future<void> downloadInvoiceToPhone({
    required String url,
    String? fileName,
  }) async {
    try {
      // Show loading snackbar
      Get.snackbar(
        'Download Started',
        'Downloading invoice...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 2),
      );

      // Check and request permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Get Downloads directory path
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/Downloads');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      String savePath = '${directory.path}/${fileName ?? 'invoice.pdf'}';

      // Configure Dio options
      _dio.options.responseType = dio.ResponseType.bytes;
      _dio.options.followRedirects = true;
      _dio.options.validateStatus = (status) => status! < 500;

      // Download the PDF file
      dio.Response response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('Download progress: ${progress.toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        // Trigger media scanner on Android to make file visible
        await _scanMediaFile(savePath);

        // Success snackbar
        Get.snackbar(
          'Download Complete',
          'Invoice saved to Downloads folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => _openFile(savePath),
            child: const Text('Open', style: TextStyle(color: Colors.white)),
          ),
          icon: Icon(Icons.download_done, color: Colors.white),
        );
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      _handleDownloadError('Network error: ${e.message}');
    } catch (e) {
      _handleDownloadError('Download failed: ${e.toString()}');
      print('Error in downloadInvoiceToPhone: $e');
    }
  }
}

class AppShares {
  static Future<void> shareInvoicePdf() async {
    const pdfUrl =
        'https://shopdata2.s3.ap-south-1.amazonaws.com/FY000981381510/Sale/invoice_Invoice-04.pdf';
    final dir = await getTemporaryDirectory();
    final pathName = pdfUrl.split('/').last;
    final filePath = '${dir.path}/$pathName';
    try {
      // Download PDF karo
      await dio.Dio().download(pdfUrl, filePath);
      final params = ShareParams(
        text:
            'Thank you for your purchase. Please find your invoice attached.\n\nFor any queries, contact us.',
        files: [XFile(filePath)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        if (kDebugMode) {
          print('Invoice shared successfully!');
        }
      } else if (result.status == ShareResultStatus.dismissed) {
        if (kDebugMode) {
          print('Share dismissed');
        }
      } else if (result.status == ShareResultStatus.unavailable) {
        if (kDebugMode) {
          print('Share unavailable');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing invoice: $e');
      }
    }
  }
}
