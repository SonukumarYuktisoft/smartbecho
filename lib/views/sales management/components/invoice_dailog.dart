// // invoice_dialog.dart

// import 'package:flutter/material.dart';
// import 'package:smartbecho/controllers/sales%20hisrory%20controllers/invoice_controller.dart';
// import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
// import 'package:smartbecho/views/sales%20management/components/invoice_view_page.dart';

// class InvoiceTypeDialog extends StatelessWidget {
//   final SaleDetailResponse saleDetailResponse;

//   const InvoiceTypeDialog({
//     Key? key,
//     required this.saleDetailResponse,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 400;
    
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//       backgroundColor: Colors.transparent,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: isSmallScreen ? size.width * 0.9 : 450,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(context),
//               Padding(
//                 padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _InvoiceTypeCard(
//                       title: 'Classic',
//                       description: 'Traditional invoice with essential details',
//                       icon: Icons.receipt_long,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       onTap: () => _navigateToInvoice(context, InvoiceType.classic),
//                     ),
//                     const SizedBox(height: 12),
//                     _InvoiceTypeCard(
//                       title: 'Modern',
//                       description: 'Sleek design with enhanced visuals',
//                       icon: Icons.auto_awesome,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF10B981), Color(0xFF059669)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       onTap: () => _navigateToInvoice(context, InvoiceType.modern),
//                     ),
//                     const SizedBox(height: 12),
//                     _InvoiceTypeCard(
//                       title: 'Ultra Modern',
//                       description: 'Premium design with bold styling',
//                       icon: Icons.electric_bolt,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       onTap: () => _navigateToInvoice(context, InvoiceType.ultraModern),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.deepPurple.shade600,
//             Colors.purple.shade700,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.receipt_long_outlined,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Select Invoice Type',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close, color: Colors.white),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Choose your preferred invoice style',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToInvoice(BuildContext context, InvoiceType type) {
//     Navigator.pop(context);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InvoiceViewPage(
//           saleDetailResponse: saleDetailResponse,
//           invoiceType: type,
//         ),
//       ),
//     );
//   }
// }

// class _InvoiceTypeCard extends StatefulWidget {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Gradient gradient;
//   final VoidCallback onTap;

//   const _InvoiceTypeCard({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.gradient,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   State<_InvoiceTypeCard> createState() => _InvoiceTypeCardState();
// }

// class _InvoiceTypeCardState extends State<_InvoiceTypeCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) {
//         setState(() => _isPressed = true);
//         _controller.forward();
//       },
//       onTapUp: (_) {
//         setState(() => _isPressed = false);
//         _controller.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () {
//         setState(() => _isPressed = false);
//         _controller.reverse();
//       },
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: widget.gradient,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.gradient.colors.first.withOpacity(0.4),
//                 blurRadius: _isPressed ? 8 : 12,
//                 offset: Offset(0, _isPressed ? 3 : 6),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.25),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   widget.icon,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       widget.description,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.92),
//                         fontSize: 12,
//                         height: 1.3,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.white,
//                   size: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }