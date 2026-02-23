// import 'package:flutter/material.dart';
// import 'package:smartbecho/services/api_error_handler.dart';

// class ErrorScreen extends StatelessWidget {
//   final dynamic error;
//   final VoidCallback? onRetry;
//   final String? customMessage;
//   final IconData? customIcon;
//   final bool showRetryButton;
//   final String? retryButtonText;

//   const ErrorScreen({
//     Key? key,
//     required this.error,
//     this.onRetry,
//     this.customMessage,
//     this.customIcon,
//     this.showRetryButton = true,
//     this.retryButtonText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final errorInfo = _getErrorInfo();

//     return Center(
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Error Icon with Animation
//             _buildErrorIcon(errorInfo),
//             const SizedBox(height: 32),

//             // Error Title
//             Text(
//               customMessage ?? errorInfo.title,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),

//             // Error Description
//             Text(
//               errorInfo.description,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey[700],
//                 height: 1.6,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),

//             // Retry Button
//             if (showRetryButton && onRetry != null)
//               _buildRetryButton(errorInfo),

//             // Additional Help Text
//             if (errorInfo.helpText != null) ...[
//               const SizedBox(height: 24),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue[100]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         errorInfo.helpText!,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.blue[900],
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== BUILD ERROR ICON ====================
//   Widget _buildErrorIcon(ErrorDisplayInfo errorInfo) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 600),
//       curve: Curves.elasticOut,
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: value,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: errorInfo.color.withOpacity(0.1),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: errorInfo.color.withOpacity(0.2),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             child: Icon(
//               customIcon ?? errorInfo.icon,
//               size: 60,
//               color: errorInfo.color,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ==================== BUILD RETRY BUTTON ====================
//   Widget _buildRetryButton(ErrorDisplayInfo errorInfo) {
//     return ElevatedButton.icon(
//       onPressed: onRetry,
//       icon: const Icon(Icons.refresh_rounded, size: 20),
//       label: Text(
//         retryButtonText ?? errorInfo.buttonText,
//         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: errorInfo.color,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//       ),
//     );
//   }

//   // ==================== GET ERROR INFO ====================
//   ErrorDisplayInfo _getErrorInfo() {
//     // If error is ErrorResponse from ApiErrorHandler
//     if (error is ErrorResponse) {
//       final errorResponse = error as ErrorResponse;

//       switch (errorResponse.errorType) {
//         case ErrorType.network:
//           return ErrorDisplayInfo(
//             title: 'No Internet Connection',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.wifi_off_rounded,
//             color: Colors.orange,
//             buttonText: 'Retry',
//             helpText: 'Check your WiFi or mobile data and try again.',
//           );

//         case ErrorType.timeout:
//           return ErrorDisplayInfo(
//             title: 'Request Timeout',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.hourglass_empty_rounded,
//             color: Colors.amber[700]!,
//             buttonText: 'Try Again',
//             helpText:
//                 'The request took too long. Please check your connection.',
//           );

//         case ErrorType.server:
//           return ErrorDisplayInfo(
//             title: 'Server Error',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.cloud_off_rounded,
//             color: Colors.red,
//             buttonText: 'Retry',
//             helpText: 'Our servers are having issues. We\'re working on it!',
//           );

//         case ErrorType.authentication:
//           return ErrorDisplayInfo(
//             title: 'Session Expired',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.lock_clock_rounded,
//             color: Colors.deepOrange,
//             buttonText: 'Login Again',
//             helpText: 'Your session has expired. Please login again.',
//           );

//         case ErrorType.permission:
//           return ErrorDisplayInfo(
//             title: 'Access Denied',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.block_rounded,
//             color: Colors.red[700]!,
//             buttonText: 'Go Back',
//             helpText: 'You don\'t have permission to access this resource.',
//           );

//         case ErrorType.notFound:
//           return ErrorDisplayInfo(
//             title: 'Not Found',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.search_off_rounded,
//             color: Colors.grey[600]!,
//             buttonText: 'Go Back',
//             helpText: 'The data you\'re looking for doesn\'t exist.',
//           );

//         case ErrorType.validation:
//           return ErrorDisplayInfo(
//             title: 'Invalid Data',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.error_outline_rounded,
//             color: Colors.orange[700]!,
//             buttonText: 'Try Again',
//             helpText: 'Please check your input and try again.',
//           );

//         case ErrorType.dataFormat:
//           return ErrorDisplayInfo(
//             title: 'Data Error',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.broken_image_outlined,
//             color: Colors.purple,
//             buttonText: 'Retry',
//             helpText: 'Received invalid data format from server.',
//           );

//         case ErrorType.cancelled:
//           return ErrorDisplayInfo(
//             title: 'Request Cancelled',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.cancel_outlined,
//             color: Colors.grey,
//             buttonText: 'Try Again',
//             helpText: null,
//           );

//         case ErrorType.unknown:
//           return ErrorDisplayInfo(
//             title: 'Something Went Wrong',
//             description: errorResponse.userFriendlyMessage,
//             icon: Icons.warning_amber_rounded,
//             color: Colors.redAccent,
//             buttonText: 'Retry',
//             helpText: 'An unexpected error occurred. Please try again.',
//           );
//       }
//     }

//     // Fallback: Parse error string
//     return _parseErrorString(error.toString());
//   }

//   // ==================== PARSE ERROR STRING ====================
//   ErrorDisplayInfo _parseErrorString(String errorString) {
//     final errorLower = errorString.toLowerCase();

//     // Network Errors
//     if (errorLower.contains('network') ||
//         errorLower.contains('connection') ||
//         errorLower.contains('failed host lookup') ||
//         errorLower.contains('socketexception') ||
//         errorLower.contains('no internet')) {
//       return ErrorDisplayInfo(
//         title: 'No Internet Connection',
//         description: 'Please check your network connection and try again.',
//         icon: Icons.wifi_off_rounded,
//         color: Colors.orange,
//         buttonText: 'Retry',
//         helpText: 'Make sure WiFi or mobile data is turned on.',
//       );
//     }

//     // Timeout Errors
//     if (errorLower.contains('timeout') || errorLower.contains('timed out')) {
//       return ErrorDisplayInfo(
//         title: 'Request Timeout',
//         description: 'The request took too long to complete. Please try again.',
//         icon: Icons.hourglass_empty_rounded,
//         color: Colors.amber[700]!,
//         buttonText: 'Try Again',
//         helpText: 'Check your internet connection speed.',
//       );
//     }

//     // Server Errors
//     if (errorLower.contains('server') ||
//         errorLower.contains('500') ||
//         errorLower.contains('502') ||
//         errorLower.contains('503') ||
//         errorLower.contains('504')) {
//       return ErrorDisplayInfo(
//         title: 'Server Error',
//         description: 'Our servers are having issues. Please try again later.',
//         icon: Icons.cloud_off_rounded,
//         color: Colors.red,
//         buttonText: 'Retry',
//         helpText: 'We\'re working to fix this issue.',
//       );
//     }

//     // Authentication Errors
//     if (errorLower.contains('401') ||
//         errorLower.contains('unauthorized') ||
//         errorLower.contains('session expired')) {
//       return ErrorDisplayInfo(
//         title: 'Session Expired',
//         description: 'Your session has expired. Please login again.',
//         icon: Icons.lock_clock_rounded,
//         color: Colors.deepOrange,
//         buttonText: 'Login Again',
//         helpText: 'For security, sessions expire after some time.',
//       );
//     }

//     // Permission Errors
//     if (errorLower.contains('403') ||
//         errorLower.contains('forbidden') ||
//         errorLower.contains('access denied')) {
//       return ErrorDisplayInfo(
//         title: 'Access Denied',
//         description: 'You don\'t have permission to access this.',
//         icon: Icons.block_rounded,
//         color: Colors.red[700]!,
//         buttonText: 'Go Back',
//         helpText: 'Contact support if you need access.',
//       );
//     }

//     // Not Found Errors
//     if (errorLower.contains('404') || errorLower.contains('not found')) {
//       return ErrorDisplayInfo(
//         title: 'Not Found',
//         description: 'The requested data could not be found.',
//         icon: Icons.search_off_rounded,
//         color: Colors.grey[600]!,
//         buttonText: 'Go Back',
//         helpText: 'The data may have been deleted or moved.',
//       );
//     }

//     // Data Format Errors
//     if (errorLower.contains('format') ||
//         errorLower.contains('parse') ||
//         errorLower.contains('json') ||
//         errorLower.contains('type')) {
//       return ErrorDisplayInfo(
//         title: 'Data Error',
//         description: 'Received invalid data format. Please try again.',
//         icon: Icons.broken_image_outlined,
//         color: Colors.purple,
//         buttonText: 'Retry',
//         helpText: 'There was an issue processing the data.',
//       );
//     }

//     // Default Error
//     return ErrorDisplayInfo(
//       title: 'Something Went Wrong',
//       description: 'An unexpected error occurred. Please try again.',
//       icon: Icons.warning_amber_rounded,
//       color: Colors.redAccent,
//       buttonText: 'Retry',
//       helpText: 'If this persists, please contact support.',
//     );
//   }
// }

// // ==================== ERROR DISPLAY INFO MODEL ====================
// class ErrorDisplayInfo {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;
//   final String buttonText;
//   final String? helpText;

//   ErrorDisplayInfo({
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//     required this.buttonText,
//     this.helpText,
//   });
// }
