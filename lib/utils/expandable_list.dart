// import 'package:flutter/material.dart';

// class ExpandableList extends StatefulWidget {
//   final String title;
//   final List<String> items;
//   final int showByDefault;
//   final Color? borderColor;
//   final Color? accentColor;

//   const ExpandableList({
//     Key? key,
//     required this.title,
//     required this.items,
//     this.showByDefault = 2,
//     this.borderColor,
//     this.accentColor,
//   }) : super(key: key);

//   @override
//   State<ExpandableList> createState() => _ExpandableListState();
// }

// class _ExpandableListState extends State<ExpandableList> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = widget.accentColor ?? Colors.blue;
//     final border = widget.borderColor ?? Colors.grey[300]!;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text(
//         //   widget.title,
//         //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         // ),
//         // const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: border),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       widget.title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     // Show more / less button
//                     if (widget.items.length > widget.showByDefault)
//                       GestureDetector(
//                         onTap: () => setState(() => isExpanded = !isExpanded),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 isExpanded
//                                     ? "Show less"
//                                     : "Show ${widget.items.length - widget.showByDefault} more",
//                                 style: TextStyle(
//                                   color: primaryColor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Icon(
//                                 isExpanded
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 color: primaryColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // Show default items
//               ...List.generate(
//                 widget.showByDefault,
//                 (index) => Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Icon(Icons.check_circle, color: primaryColor),
//                       const SizedBox(width: 12),
//                       Expanded(child: Text(widget.items[index])),
//                     ],
//                   ),
//                 ),
//               ),
//               // // Show more / less button
//               // if (widget.items.length > widget.showByDefault)
//               //   GestureDetector(
//               //     onTap: () => setState(() => isExpanded = !isExpanded),
//               //     child: Padding(
//               //       padding: const EdgeInsets.all(12),
//               //       child: Row(
//               //         mainAxisAlignment: MainAxisAlignment.center,
//               //         children: [
//               //           Text(
//               //             isExpanded
//               //                 ? "Show less"
//               //                 : "Show ${widget.items.length - widget.showByDefault} more",
//               //             style: TextStyle(
//               //               color: primaryColor,
//               //               fontWeight: FontWeight.w600,
//               //             ),
//               //           ),
//               //           Icon(
//               //             isExpanded
//               //                 ? Icons.arrow_drop_up
//               //                 : Icons.arrow_drop_down,
//               //             color: primaryColor,
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // // Show remaining items when expanded
//               if (isExpanded)
//                 ...List.generate(
//                   widget.items.length - widget.showByDefault,
//                   (index) => Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle, color: primaryColor),
//                         // const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             widget.items[index + widget.showByDefault],
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             widget.items[index + widget.showByDefault],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class AccountItem {
  final IconData icon;
  final String label;
  final String amount;
  final Color backgroundColor;
  final Color? amountColor;

  AccountItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.backgroundColor, this.amountColor,
  });
}

class ExpandableList extends StatefulWidget {
  final String title;
  final List<AccountItem> items;
  final int showByDefault;

  const ExpandableList({
    Key? key,
    required this.title,
    required this.items,
    this.showByDefault = 2,
  }) : super(key: key);

  @override
  State<ExpandableList> createState() => _ExpandableListState();
}

class _ExpandableListState extends State<ExpandableList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        Column(
          children: [
            // Show default items
            ...List.generate(
              widget.showByDefault,
              (index) => _buildAccountItemTile(widget.items[index]),
            ),
            if (!isExpanded) const BounceArrowIndicator(),
            // Show more / less button
            if (widget.items.length > widget.showByDefault)
              GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      // if (!isExpanded) const BounceArrowIndicator(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded
                                ? "Show less"
                                : "Show ${widget.items.length - widget.showByDefault} more",
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Show remaining items when expanded
            if (isExpanded)
              ...List.generate(
                widget.items.length - widget.showByDefault,
                (index) => _buildAccountItemTile(
                  widget.items[index + widget.showByDefault],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountItemTile(AccountItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // Label
          Expanded(
            child: Text(
              item.label,
              style:  const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          // Amount
          
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:item.amountColor ??   Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class BounceArrowIndicator extends StatefulWidget {
  const BounceArrowIndicator({super.key});

  @override
  State<BounceArrowIndicator> createState() => _BounceArrowIndicatorState();
}

class _BounceArrowIndicatorState extends State<BounceArrowIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Faster
    )..repeat(reverse: true);

    // Bounce Animation
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Color Animation - Teal to Light Teal
    _colorAnimation = ColorTween(
      begin: Colors.teal,
      end: Colors.teal.withValues(alpha: 0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Scale Animation - Grow and Shrink
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              Icons.arrow_downward,
              size: 28,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
