// controllers/account management controller/gst_ledger_controller.dart

import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart' show ResponseType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:smartbecho/models/account%20management%20models/gst_ledger_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/views/account%20management/components/gst%20ledger/gst_export_sheet_page.dart';

// Model for download history
class DownloadHistory {
  final String fileName;
  final String filePath;
  final DateTime downloadTime;
  final String format;
  final int fileSizeBytes;

  DownloadHistory({
    required this.fileName,
    required this.filePath,
    required this.downloadTime,
    required this.format,
    required this.fileSizeBytes,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'filePath': filePath,
    'downloadTime': downloadTime.toIso8601String(),
    'format': format,
    'fileSizeBytes': fileSizeBytes,
  };

  factory DownloadHistory.fromJson(Map<String, dynamic> json) {
    return DownloadHistory(
      fileName: json['fileName'],
      filePath: json['filePath'],
      downloadTime: DateTime.parse(json['downloadTime']),
      format: json['format'],
      fileSizeBytes: json['fileSizeBytes'],
    );
  }
}

class GstLedgerController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Form controllers

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  var startDateText = ''.obs;
  var endDateText = ''.obs;

  // Observable variables
  var isLoading = false.obs;
  var ledgerEntries = <GstLedgerEntry>[].obs;
  var filteredLedgerEntries = <GstLedgerEntry>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var hasMoreData = true.obs;

  // Download History
  var downloadHistory = <DownloadHistory>[].obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedEntityName = 'All'.obs;
  var selectedTransactionType = 'All'.obs;
  var selectedHsnCode = 'All'.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var isCustomDateRange = false.obs;

  // Available filter options
  var entityNames = <String>['All'].obs;
  var transactionTypes = <String>['All'].obs;
  var hsnCodes = <String>['All'].obs;

  // Analytics data
  var isChartLoading = false.obs;
  final RxList<MonthlyGstSummary> monthlyChartData = <MonthlyGstSummary>[].obs;

  final int pageSize = 10;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get monthDisplayText {
    return months[selectedMonth.value - 1];
  }

  @override
  void onInit() {
    super.onInit();
    loadDownloadHistory();
    loadDropdownData();
    loadLedgerEntries(refresh: true);
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // ========== DOWNLOAD HISTORY MANAGEMENT ==========

  Future<void> loadDownloadHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final historyFile = File('${appDir.path}/gst_download_history.json');

      if (await historyFile.exists()) {
        final jsonString = await historyFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        downloadHistory.value =
            jsonList
                .map(
                  (item) =>
                      DownloadHistory.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        log('Loaded ${downloadHistory.length} download history items');
      }
    } catch (e) {
      log('Error loading download history: $e');
    }
  }

  Future<void> _saveDownloadHistory(DownloadHistory item) async {
    try {
      downloadHistory.add(item);

      final appDir = await getApplicationDocumentsDirectory();
      final historyFile = File('${appDir.path}/gst_download_history.json');

      final jsonList = downloadHistory.map((h) => h.toJson()).toList();
      await historyFile.writeAsString(jsonEncode(jsonList));
      log('Download history saved: ${item.fileName}');
    } catch (e) {
      log('Error saving download history: $e');
    }
  }

  Future<void> loadDropdownData() async {
    try {
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/v1/gst-ledger/dropdowns',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final dropdowns = GstLedgerDropdowns.fromJson(response.data);
        entityNames.value = ['All', ...dropdowns.entityNames];
        transactionTypes.value = ['All', ...dropdowns.transactionTypes];
        hsnCodes.value = ['All', ...dropdowns.hsnCodes];
      }
    } catch (e) {
      log('Error loading dropdown data: $e');
    }
  }

  Future<void> loadLedgerEntries({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        ledgerEntries.clear();
        hasMoreData.value = true;
      }

      if (!hasMoreData.value) return;

      isLoading.value = true;

      final query = <String, String>{
        'page': currentPage.value.toString(),
        'size': pageSize.toString(),
        'sortBy': 'id',
        'sortDir': 'desc',
      };

      if (isCustomDateRange.value &&
          startDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty) {
        query['startDate'] = startDateController.text;
        query['endDate'] = endDateController.text;
      } else {
        query['year'] = selectedYear.value.toString();
        query['month'] = selectedMonth.value.toString();
      }

      if (selectedEntityName.value != 'All') {
        query['entityName'] = selectedEntityName.value;
      }
      if (selectedTransactionType.value != 'All') {
        query['transactionType'] = selectedTransactionType.value;
      }
      if (selectedHsnCode.value != 'All') {
        query['hsnCode'] = selectedHsnCode.value;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/v1/gst-ledger',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final ledgerResponse = GstLedgerResponse.fromJson(response.data);

        if (refresh) {
          ledgerEntries.value = ledgerResponse.content;
        } else {
          ledgerEntries.addAll(ledgerResponse.content);
        }

        totalPages.value = ledgerResponse.totalPages;
        totalElements.value = ledgerResponse.totalElements;
        hasMoreData.value = !ledgerResponse.last;

        _applyFilters();
      } else {
        log('Failed to load GST ledger entries');
      }
    } catch (e) {
      isLoading.value = false;
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered =
        ledgerEntries.where((entry) {
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            if (!entry.relatedEntityName.toLowerCase().contains(query) &&
                !entry.transactionType.toLowerCase().contains(query) &&
                !entry.hsnCode.toLowerCase().contains(query) &&
                !entry.gstRateLabel.toLowerCase().contains(query)) {
              return false;
            }
          }
          return true;
        }).toList();

    filteredLedgerEntries.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onEntityNameChanged(String entityName) {
    selectedEntityName.value = entityName;
    loadLedgerEntries(refresh: true);
  }

  void onTransactionTypeChanged(String transactionType) {
    selectedTransactionType.value = transactionType;
    loadLedgerEntries(refresh: true);
  }

  void onHsnCodeChanged(String hsnCode) {
    selectedHsnCode.value = hsnCode;
    loadLedgerEntries(refresh: true);
  }

  void onMonthChanged(int month) {
    selectedMonth.value = month;
    isCustomDateRange.value = false;
    startDateController.clear();
    endDateController.clear();
    loadLedgerEntries(refresh: true);
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    isCustomDateRange.value = false;
    startDateController.clear();
    endDateController.clear();
    loadLedgerEntries(refresh: true);
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String formatDate = DateFormat('dd/MM/yyyy').format(picked);
      startDateController.text = picked.toIso8601String().split('T')[0];
      startDateText.value = formatDate;
      isCustomDateRange.value = true;
      log(name: 'start date log', '$formatDate');
      if (startDateController.text.isNotEmpty) {
        loadLedgerEntries(refresh: true);
      }
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime initial = DateTime.now();

    if (startDateText.value.isNotEmpty) {
      initial = DateFormat('dd/MM/yyyy').parse(startDateText.value);
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String formatDate = DateFormat('dd/MM/yyyy').format(picked);
      log(name: 'end  date log', '$formatDate');

      endDateController.text = picked.toIso8601String().split('T')[0];
      log(name: 'endDateController  date log', '${endDateController.text}');

      endDateText.value = formatDate;
      isCustomDateRange.value = true;
      if (endDateController.text.isNotEmpty) {
        loadLedgerEntries(refresh: true);
      }
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedEntityName.value = 'All';
    selectedTransactionType.value = 'All';
    selectedHsnCode.value = 'All';
    isCustomDateRange.value = false;
    startDateController.clear();
    endDateController.clear();
    selectedMonth.value = DateTime.now().month;
    selectedYear.value = DateTime.now().year;
    startDateText.value = '';
    endDateText.value = '';
    _applyFilters();
    loadLedgerEntries(refresh: true);
  }

  void loadNextPage() {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      loadLedgerEntries();
    }
  }

  void refreshData() {
    loadLedgerEntries(refresh: true);
  }

  String getFilterSummary() {
    List<String> activeFilters = [];

    if (searchQuery.value.isNotEmpty) {
      activeFilters.add('Search: "${searchQuery.value}"');
    }
    if (selectedEntityName.value != 'All') {
      activeFilters.add('Entity: ${selectedEntityName.value}');
    }
    if (selectedTransactionType.value != 'All') {
      activeFilters.add('Type: ${selectedTransactionType.value}');
    }
    if (selectedHsnCode.value != 'All') {
      activeFilters.add('HSN: ${selectedHsnCode.value}');
    }
    if (isCustomDateRange.value) {
      activeFilters.add('Custom Date Range');
    }

    if (activeFilters.isEmpty) {
      return '${filteredLedgerEntries.length} entries found';
    }

    return '${activeFilters.join(' • ')} • ${filteredLedgerEntries.length} results';
  }

  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        selectedEntityName.value != 'All' ||
        selectedTransactionType.value != 'All' ||
        selectedHsnCode.value != 'All' ||
        isCustomDateRange.value ||
        selectedMonth.value != DateTime.now().month ||
        selectedYear.value != DateTime.now().year;
  }

  Color getTransactionTypeColor(String transactionType) {
    switch (transactionType.toUpperCase()) {
      case 'CREDIT':
        return const Color(0xFF10B981);
      case 'DEBIT':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getEntityColor(String entityName) {
    switch (entityName.toUpperCase()) {
      case 'SALE':
        return const Color(0xFF10B981);
      case 'PURCHASE':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double get totalTaxableAmount {
    return filteredLedgerEntries.fold(
      0.0,
      (sum, entry) => sum + entry.taxableAmount,
    );
  }

  double get totalGstAmount {
    return filteredLedgerEntries.fold(
      0.0,
      (sum, entry) =>
          sum + entry.cgstAmount + entry.sgstAmount + entry.igstAmount,
    );
  }

  Map<String, double> get entriesByTransactionType {
    final Map<String, double> result = {};
    for (var entry in filteredLedgerEntries) {
      result[entry.transactionType] =
          (result[entry.transactionType] ?? 0) + entry.taxableAmount;
    }
    return result;
  }

  Map<String, double> get entriesByEntity {
    final Map<String, double> result = {};
    for (var entry in filteredLedgerEntries) {
      result[entry.relatedEntityName] =
          (result[entry.relatedEntityName] ?? 0) + entry.taxableAmount;
    }
    return result;
  }

  Map<String, int> get entryCountByGstRate {
    final Map<String, int> result = {};
    for (var entry in filteredLedgerEntries) {
      result[entry.gstRateLabel] = (result[entry.gstRateLabel] ?? 0) + 1;
    }
    return result;
  }

  void exportData() {
    Get.snackbar(
      'Export',
      'Export functionality will be implemented soon',
      backgroundColor: const Color(0xFF6B7280),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void printReport() {
    Get.snackbar(
      'Print',
      'Print functionality will be implemented soon',
      backgroundColor: const Color(0xFF6B7280),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> loadMonthlySummary({
    String? year,
    String? startDate,
    String? endDate,
    String? entityName,
    String? transactionType,
    String? hsnCode,
  }) async {
    try {
      isChartLoading.value = true;

      final query = <String, String>{};

      if (startDate != null && endDate != null) {
        query['startDate'] = startDate;
        query['endDate'] = endDate;
      } else if (year != null) {
        query['year'] = year;
      }

      if (entityName != null && entityName != 'All') {
        query['entityName'] = entityName;
      }
      if (transactionType != null && transactionType != 'All') {
        query['transactionType'] = transactionType;
      }
      if (hsnCode != null && hsnCode != 'All') {
        query['hsnCode'] = hsnCode;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/v1/gst-ledger/monthly-summary',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> payload = response.data['payload'];
        monthlyChartData.value =
            payload.map((item) => MonthlyGstSummary.fromJson(item)).toList();
      } else {
        log('Failed to load analytics data');
        monthlyChartData.clear();
      }
    } catch (e) {
      log('Error loading monthly summary: $e');
      Get.snackbar(
        'Error',
        'Failed to load analytics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      monthlyChartData.clear();
    } finally {
      isChartLoading.value = false;
    }
  }

  double get totalCreditGst {
    return monthlyChartData.fold(0.0, (sum, item) => sum + item.credit);
  }

  double get totalDebitGst {
    return monthlyChartData.fold(0.0, (sum, item) => sum + item.debit);
  }

  double get totalGst {
    return monthlyChartData.fold(0.0, (sum, item) => sum + item.total);
  }

  // ========== EXPORT FUNCTIONS ==========

  String _getFileNameSuffix(Map<String, String> params) {
    if (params.containsKey('year') && params.containsKey('month')) {
      return '${params['year']}_${params['month']}';
    } else if (params.containsKey('startDate') &&
        params.containsKey('endDate')) {
      return '${params['startDate']}_to_${params['endDate']}';
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Android 13+ (API 33+) - Use media permissions
        if (androidInfo.version.sdkInt >= 33) {
          // For Android 13+, we need to request specific media permissions
          final statusImages = await Permission.photos.request();
          final statusVideos = await Permission.videos.request();

          // Check if at least one is granted
          if (statusImages.isGranted || statusVideos.isGranted) {
            return true;
          }

          // If denied, show settings dialog
          if (statusImages.isPermanentlyDenied ||
              statusVideos.isPermanentlyDenied) {
            await openAppSettings();
          }
          return false;
        }
        // Android 11-12 (API 30-32) - Use manage external storage
        else if (androidInfo.version.sdkInt >= 30) {
          final status = await Permission.manageExternalStorage.request();

          if (status.isGranted) {
            return true;
          }

          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return false;
        }
        // Android 10 and below - Use regular storage permission
        else {
          final status = await Permission.storage.request();

          if (status.isGranted) {
            return true;
          }

          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return false;
        }
      } catch (e) {
        log('Permission error: $e');
        return false;
      }
    }
    // iOS - no storage permission needed for app documents

    return true;
  }

  static const platform = MethodChannel('com.smartbecho/storage');

  /// Main save file function - automatically handles all Android versions
  Future<bool> _saveFile(
    dynamic data,
    String fileName,
    ResponseType responseType,
  ) async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 29) {
          // Android 10+ (API 29+) - Use MediaStore (NO PERMISSION NEEDED!)
          return await _saveFileUsingMediaStore(data, fileName, responseType);
        } else {
          // Android 9 and below - Traditional method (permission required)
          return await _saveFileTraditional(data, fileName, responseType);
        }
      } else if (Platform.isIOS) {
        // iOS - Use app documents directory
        return await _saveFileTraditional(data, fileName, responseType);
      }

      return false;
    } catch (e) {
      log('❌ Error saving file: $e');
      _showErrorSnackbar('Failed to save file: ${e.toString()}');
      return false;
    }
  }

  /// Get Android SDK version from native code
  Future<int> _getAndroidVersion() async {
    try {
      final int version = await platform.invokeMethod('getAndroidVersion');
      log('📱 Android SDK Version: $version');
      return version;
    } catch (e) {
      log('⚠️ Error getting Android version: $e');
      return 0;
    }
  }

  /// Save file using MediaStore API (Android 10+)
  /// This is the RECOMMENDED way for production apps
  Future<bool> _saveFileUsingMediaStore(
    dynamic data,
    String fileName,
    ResponseType responseType,
  ) async {
    try {
      log('📂 Using MediaStore API to save file...');

      // Prepare bytes
      final List<int> bytes = _prepareFileData(data, responseType);

      // Get MIME type
      final mimeType = _getMimeType(fileName);

      // Call native Android MediaStore
      final String? filePath = await platform.invokeMethod('saveToDownloads', {
        'fileName': fileName,
        'bytes': bytes,
        'mimeType': mimeType,
      });

      if (filePath != null && filePath.isNotEmpty) {
        log('✅ File saved via MediaStore: $filePath');

        // Save to download history
        await _saveDownloadHistory(
          DownloadHistory(
            fileName: fileName,
            filePath: filePath,
            downloadTime: DateTime.now(),
            format: fileName.split('.').last.toUpperCase(),
            fileSizeBytes: bytes.length,
          ),
        );

        // Auto-open file
        await _autoOpenFile(filePath, fileName);

        return true;
      } else {
        throw Exception('MediaStore returned null/empty path');
      }
    } catch (e) {
      log('❌ MediaStore error: $e');
      _showErrorSnackbar('Failed to save file: ${e.toString()}');
      return false;
    }
  }

  /// Traditional file save method (Android 9 and below, iOS)
  Future<bool> _saveFileTraditional(
    dynamic data,
    String fileName,
    ResponseType responseType,
  ) async {
    try {
      log('📂 Using traditional file save...');

      Directory? directory;

      if (Platform.isAndroid) {
        // Try public Downloads
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not get storage directory');
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      log('💾 Saving to: $filePath');

      // Write file
      if (responseType == ResponseType.json) {
        final jsonString = _jsonToString(data);
        await file.writeAsString(jsonString);
      } else {
        if (data is List<int>) {
          await file.writeAsBytes(data);
        } else if (data is String) {
          await file.writeAsString(data);
        } else {
          throw Exception('Unsupported data type');
        }
      }

      // Verify
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('File creation failed or file is empty');
      }

      final fileSize = await file.length();
      log('✅ File saved: $filePath (${fileSize} bytes)');

      // Save to history
      await _saveDownloadHistory(
        DownloadHistory(
          fileName: fileName,
          filePath: filePath,
          downloadTime: DateTime.now(),
          format: fileName.split('.').last.toUpperCase(),
          fileSizeBytes: fileSize,
        ),
      );

      // Auto-open
      await _autoOpenFile(filePath, fileName);

      return true;
    } catch (e) {
      log('❌ Traditional save error: $e');
      _showErrorSnackbar('Failed to save file: ${e.toString()}');
      return false;
    }
  }

  /// Prepare file data as bytes
  List<int> _prepareFileData(dynamic data, ResponseType responseType) {
    if (responseType == ResponseType.json) {
      final jsonString = _jsonToString(data);
      return utf8.encode(jsonString);
    } else {
      if (data is List<int>) {
        return data;
      } else if (data is String) {
        return utf8.encode(data);
      } else {
        throw Exception('Unsupported data type');
      }
    }
  }

  /// Convert data to JSON string
  String _jsonToString(dynamic data) {
    if (data is Map || data is List) {
      return const JsonEncoder.withIndent('  ').convert(data);
    } else if (data is String) {
      return data;
    } else {
      return data.toString();
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'json':
        return 'application/json';
      case 'csv':
        return 'text/csv';
      case 'pdf':
        return 'application/pdf';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }

  /// Auto-open file after download
  Future<void> _autoOpenFile(String filePath, String fileName) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        log('✅ File opened automatically');
      } else {
        log('⚠️ File not opened: ${result.message}');
        _showSuccessSnackbarWithOpen(fileName, filePath);
      }
    } catch (e) {
      log('⚠️ Auto-open failed: $e');
      _showSuccessSnackbarWithOpen(fileName, filePath);
    }
  }

  /// Show success snackbar with OPEN button
  void _showSuccessSnackbarWithOpen(String fileName, String filePath) {
    Get.snackbar(
      'Download Complete',
      'File saved: $fileName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => OpenFile.open(filePath),
        child: const Text(
          'OPEN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to save files. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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

  /// Export GSTR-1 and return success status
  Future<bool> exportGstLedgerGSTR1({
    required Map<String, String> params,
  }) async {
    try {
      isLoading.value = true;

      if (Platform.isAndroid) {
        if (!await _requestStoragePermission()) {
          _showPermissionError();
          return false;
        }
      }

      final url = _buildUrl('/export/gst-ledger/gstr-1', params);
      log('Exporting GSTR-1 from: $url');

      final response = await _apiService.requestGstLegerGetForApi(
        url: url,
        dictParameter: params,
        authToken: true,
        responseType: ResponseType.json,
      );

      if (response != null && response.statusCode == 200) {
        final fileName = 'GSTR1_${_getFileNameSuffix(params)}.json';
        return await _saveFile(response.data, fileName, ResponseType.json);
      } else {
        _showExportError(response?.statusCode ?? 0);
        return false;
      }
    } catch (e) {
      log('Export GSTR-1 error: $e');
      _showExportError(null, e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Export GSTR-2 and return success status
  Future<bool> exportGstLedgerGSTR2({
    required Map<String, String> params,
  }) async {
    try {
      isLoading.value = true;

      if (Platform.isAndroid) {
        if (!await _requestStoragePermission()) {
          _showPermissionError();
          return false;
        }
      }

      final url = _buildUrl('/export/gst-ledger/gstr-2', params);
      log('Exporting GSTR-2 from: $url');

      final response = await _apiService.requestGstLegerGetForApi(
        url: url,
        dictParameter: params,
        authToken: true,
        responseType: ResponseType.json,
      );

      if (response != null && response.statusCode == 200) {
        final fileName = 'GSTR2_${_getFileNameSuffix(params)}.json';
        return await _saveFile(response.data, fileName, ResponseType.json);
      } else {
        _showExportError(response?.statusCode ?? 0);
        return false;
      }
    } catch (e) {
      log('Export GSTR-2 error: $e');
      _showExportError(null, e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Export Simplified JSON and return success status

  Future<bool> exportGstLedgerSimplifiedJson({
    required Map<String, String> params,
  }) async {
    try {
      isLoading.value = true;

      if (Platform.isAndroid) {
        if (!await _requestStoragePermission()) {
          _showPermissionError();
          return false;
        }
      }

      // Get format and convert to lowercase for API
      final fileFormat = params['format'] ?? 'json';
      final apiFormat =
          fileFormat.toLowerCase(); // Convert to lowercase for API

      // UPDATE format in params with lowercase value
      params['format'] = apiFormat;

      // Build complete URL with ALL parameters in query string
      final url = _buildUrl('/export/gst-ledger', params);

      log('Exporting JSON-SIMPLIFIED from: $url with format: $apiFormat');

      // Determine response type based on file format
      ResponseType responseType;
      String fileExtension;

      switch (apiFormat) {
        case 'csv':
          responseType = ResponseType.bytes;
          fileExtension = 'csv';
          break;
        case 'excel':
          responseType = ResponseType.bytes;
          fileExtension = 'xlsx';
          break;
        case 'pdf':
          responseType = ResponseType.bytes;
          fileExtension = 'pdf';
          break;
        case 'json_simplified':
          responseType = ResponseType.json;
          fileExtension = 'json';
          break;
        default: // 'json'
          responseType = ResponseType.json;
          fileExtension = 'json';
      }

      // Make request - DON'T pass dictParameter since URL already has all params
      final response = await _apiService.requestGstLegerGetForApi(
        url: url, // URL already contains all parameters
        dictParameter: {}, // ✅ EMPTY - prevents duplication!
        authToken: true,
        responseType: responseType,
      );

      if (response != null && response.statusCode == 200) {
        final fileName =
            'gst_ledger_${_getFileNameSuffix(params)}.$fileExtension';
        return await _saveFile(response.data, fileName, responseType);
      } else {
        _showExportError(response?.statusCode ?? 0);
        return false;
      }
    } catch (e) {
      log('Export JSON error: $e');
      _showExportError(null, e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Build complete URL with query parameters
  String _buildUrl(String endpoint, Map<String, String> params) {
    String url = '${_config.baseUrl}$endpoint?';
    final queryParts = <String>[];

    params.forEach((key, value) {
      if (value.isNotEmpty) {
        queryParts.add('$key=$value');
      }
    });

    return url + queryParts.join('&');
  }

  void _showExportError(int? statusCode, [String? customMessage]) {
    String message = customMessage ?? 'Failed to export GST ledger';
    if (statusCode != null) {
      message = 'Export failed with status: $statusCode';
    }

    Get.snackbar(
      'Export Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  void _showPermissionError() {
    Get.snackbar(
      'Permission Denied',
      'Storage permission is required to save files',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Show export bottom sheet
  void showExportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => GstExportBottomSheet(),
          ),
    );
  }
}
