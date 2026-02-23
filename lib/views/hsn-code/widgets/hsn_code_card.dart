// import 'package:flutter/material.dart';
// import 'package:smartbecho/utils/app_colors.dart';
// import 'package:smartbecho/views/hsn-code/models/hsn_code_model.dart';

// class HsnCodeCard extends StatelessWidget {
//   final HsnCodeModel hsnCode;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//   final VoidCallback? onTap;

//   const HsnCodeCard({
//     Key? key,
//     required this.hsnCode,
//     this.onEdit,
//     this.onDelete,
//     this.onTap,
//   }) : super(key: key);

//   Color get _statusColor =>
//       hsnCode.isActive ? AppColors.primaryLight : Colors.grey;

//   List<Color> get _gradientColors =>
//       hsnCode.isActive
//           ? AppColors.primaryGradientLight
//           : [Colors.grey, Colors.grey[400]!];

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Colors.white, Colors.white],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: _statusColor.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//           border: Border.all(color: _statusColor.withOpacity(0.1)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // HSN Code Title
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'HSN Code',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         hsnCode.hsnCode,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Status Icon
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: _gradientColors),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     hsnCode.isActive ? 'Active' : 'Inactive',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Item Category
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Text(
//                 hsnCode.itemCategory.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[700],
//                   letterSpacing: 0.5,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // GST Percentage
//             Row(
//               children: [
//                 Icon(Icons.receipt_long, size: 14, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${hsnCode.gstPercentage.toStringAsFixed(1)}% GST',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: _statusColor,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             // Description
//             if (hsnCode.description != null && hsnCode.description!.isNotEmpty)
//               Flexible(
//                 child: Text(
//                   hsnCode.description!,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                     height: 1.3,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               )
//             else
//               Flexible(
//                 child: Text(
//                   'No description available',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey[400],
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 12),

//             // Action Buttons
//             Row(
//               children: [
//                 // Edit Button
//                 Expanded(
//                   child: InkWell(
//                     onTap: onEdit,
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(colors: _gradientColors),
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _statusColor.withOpacity(0.3),
//                             spreadRadius: 0,
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.edit, color: Colors.white, size: 16),
//                           SizedBox(width: 6),
//                           Text(
//                             'Edit',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // Delete Button
//                 InkWell(
//                   onTap: onDelete,
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red[200]!, width: 1),
//                     ),
//                     child: Icon(
//                       Icons.delete_outline,
//                       color: Colors.red[600],
//                       size: 18,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ListView.builder implementation
import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/models/hsncode_models/hsn_code_model.dart';

// Compact Row Card Widget for HSN Code
class HsnCodeCard extends StatelessWidget {
  final HsnCodeModel hsnCode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const HsnCodeCard({
    Key? key,
    required this.hsnCode,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  Color get _statusColor =>
      hsnCode.isActive ? AppColors.primaryLight : Colors.grey;

  List<Color> get _gradientColors =>
      hsnCode.isActive
          ? AppColors.primaryGradientLight
          : [Colors.grey, Colors.grey[400]!];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: HSN Icon with Status
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _gradientColors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Middle: HSN Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HSN Code
                      Row(
                        children: [
                          Text(
                            hsnCode.hsnCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: _gradientColors),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hsnCode.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Item Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          hsnCode.itemCategory.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // GST Percentage Row
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 13,
                            color: _statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hsnCode.gstPercentage.toStringAsFixed(1)}% GST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Description
                      if (hsnCode.description != null && 
                          hsnCode.description!.isNotEmpty)
                        Text(
                          hsnCode.description!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'No description available',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Right: Action Buttons (Vertical Stack)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Edit Button
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _gradientColors),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Delete Button
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}