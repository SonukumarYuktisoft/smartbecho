import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class CongratulationsPage extends StatelessWidget {
  final String planName;
  final String period;
  final double amountPaid;
  final double gstAmount;
  final VoidCallback onDashboardTap;

  const CongratulationsPage({
    Key? key,
    required this.planName,
    required this.period,
    required this.amountPaid,
    required this.gstAmount,
    required this.onDashboardTap,
  }) : super(key: key);

  /// Show modal
  static void show({
    required String planName,
    required String period,
    required double amountPaid,
    required double gstAmount,
    required VoidCallback onDashboardTap,
  }) {
    Get.dialog(
      CongratulationsPage(
        planName: planName,
        period: period,
        amountPaid: amountPaid,
        gstAmount: gstAmount,
        onDashboardTap: onDashboardTap,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF4C5EEB),
        
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4C5EEB),
                Color(0xFF5A6CED),
                Color(0xFF6B7DEF),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Success Icon with Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CEEB4),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CEEB4).withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF2D3E50),
                            size: 80,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Congratulations Text
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Success Message
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Your payment of '),
                        TextSpan(
                          text: '₹${amountPaid.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF4CEEB4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '\nwas successful'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Plan Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          label: 'Plan Name',
                          value: planName,
                          isLarge: true,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          label: 'Subscription Period',
                          value: period,
                          isLarge: true,
                        ),
                        const SizedBox(height: 24),
                    // Dotted Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDottedLine(),
              ),
            ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amount Paid:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '₹${amountPaid.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CEEB4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'GST Included',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Go to Dashboard Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onDashboardTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.25),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Go to Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}