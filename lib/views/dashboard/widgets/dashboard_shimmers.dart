import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/shimmer_responsive_utils.dart';
import 'package:shimmer/shimmer.dart';

// Enhanced KPI Cards Shimmer
class DashboardKPICardsShimmer extends StatelessWidget {
  const DashboardKPICardsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPIShimmerCard(context, delay: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPIShimmerCard(context, delay: 0.1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPIShimmerCard(context, delay: 0.2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPIShimmerCard(context, delay: 0.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIShimmerCard(BuildContext context, {required double delay}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: Duration(milliseconds: (1500 + delay * 200).toInt()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon shimmer
                Expanded(
                  child: Container(
                                   
                  
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const Spacer(),
                // Badge shimmer
                Expanded(
                  child: Container(
                    
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title shimmer
            Container(
              height: 16,
              width: double.infinity * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Value shimmer
            Container(
              height: 28,
              width: double.infinity * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Chart Section Shimmer
class DashboardChartShimmer extends StatelessWidget {
  final String title;
  final double height;
  
  const DashboardChartShimmer({
    Key? key,
    required this.title,
    this.height = 350,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Chart content shimmer
              Expanded(
                child: _buildChartContentShimmer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContentShimmer(BuildContext context) {
    if (title.toLowerCase().contains('revenue') || title.toLowerCase().contains('sales')) {
      return _buildLineChartShimmer(context);
    } else if (title.toLowerCase().contains('dues') || title.toLowerCase().contains('customer')) {
      return _buildPieChartShimmer(context);
    } else {
      return _buildBarChartShimmer(context);
    }
  }

  Widget _buildLineChartShimmer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: LineChartShimmerPainter(),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => 
            Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartShimmer(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartShimmer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final heights = [0.3, 0.7, 0.5, 0.9, 0.4, 0.8, 0.6];
              return Container(
                width: 20,
                height: (height - 150) * heights[index],
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) => 
            Container(
              width: 20,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for line chart shimmer
class LineChartShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.5),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Financial Overview Shimmer
class FinancialOverviewShimmer extends StatelessWidget {
  const FinancialOverviewShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200, 
            Colors.grey.shade300, 
            Colors.grey.shade400
          ],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            // Metrics shimmer
            Row(
              children: [
                Expanded(child: _buildFinancialMetricShimmer()),
                const SizedBox(width: 20),
                Expanded(child: _buildFinancialMetricShimmer()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildFinancialMetricShimmer()),
                const SizedBox(width: 20),
                Expanded(child: _buildFinancialMetricShimmer()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMetricShimmer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 16,
            width: double.infinity * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: double.infinity * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// Customer Analytics Shimmer
class CustomerAnalyticsShimmer extends StatelessWidget {
  const CustomerAnalyticsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            // Chart shimmer
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBarShimmer(0.8),
                  _buildBarShimmer(0.6),
                  _buildBarShimmer(0.4),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats shimmer
            Row(
              children: [
                Expanded(child: _buildCustomerStatShimmer()),
                const SizedBox(width: 16),
                Expanded(child: _buildCustomerStatShimmer()),
                const SizedBox(width: 16),
                Expanded(child: _buildCustomerStatShimmer()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarShimmer(double heightFactor) {
    return Container(
      width: 60,
      height: 200 * heightFactor,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCustomerStatShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 24,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Actions Grid Shimmer
class QuickActionsGridShimmer extends StatelessWidget {
  const QuickActionsGridShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 24,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Grid shimmer
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => _buildActionCardShimmer(context, index),
        ),
      ],
    );
  }

  Widget _buildActionCardShimmer(BuildContext context, int index) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1500 + (index * 100)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const Spacer(),
            Container(
              height: 16,
              width: double.infinity * 0.8,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}







Widget buildSalesSummaryShimmer(BuildContext context, DashboardController controller) {
  return Column(
    children: [
      // Two metric cards in a row (Total Sales and Transactions)
      _buildSummaryCardShimmer(
        context: context,
        controller: controller,
        child: Row(
          children: [
            Expanded(
              child: _buildShimmerMetricCard(context: context, controller: controller),
            ),
            SizedBox(width: ShimmerResponsiveUtils.getResponsiveMargin(context) * 3),
            Expanded(
              child: _buildShimmerMetricCard(context: context, controller: controller),
            ),
          ],
        ),
      ),
      SizedBox(height: ShimmerResponsiveUtils.getResponsiveMargin(context) * 3),

      // Full-width metric card (Smartphones Sold)
      _buildSummaryCardShimmer(
        context: context,
        controller: controller,
        child: _buildShimmerMetricCard(
          context: context, 
          controller: controller, 
          isFullWidth: true
        ),
      ),
      const SizedBox(height: 20),

      // Payment breakdown section
_buildSummaryCardShimmer(
  context: context,
  controller: controller,
  child: Container(
    padding: EdgeInsets.all(ShimmerResponsiveUtils.getResponsivePadding(context)),
    decoration: BoxDecoration(
      color: Colors.grey.shade50.withValues(alpha:0.7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods title shimmer
        Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: ShimmerResponsiveUtils.isSmallScreen(context) ? 16 : 18,
                height: ShimmerResponsiveUtils.isSmallScreen(context) ? 16 : 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // FIXED: Use Expanded to prevent overflow
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  // FIXED: Remove fixed width, let Expanded handle it
                  // width: ShimmerResponsiveUtils.getScreenWidth(context) * 0.3,
                  height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ShimmerResponsiveUtils.getResponsiveMargin(context) * 3),
        // Payment items shimmer
        ...List.generate(
          ShimmerResponsiveUtils.isSmallScreen(context) ? 3 : 4,
          (index) => _buildShimmerPaymentItem(context, controller),
        ),
      ],
    ),
  ),
),
    ],
  );
}

Widget _buildSummaryCardShimmer({
  required BuildContext context,
  required DashboardController controller,
  required Widget child,
}) {
  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: ShimmerResponsiveUtils.getResponsiveMargin(context),
      vertical: ShimmerResponsiveUtils.getResponsiveMargin(context) * 1.5,
    ),
    padding: EdgeInsets.all(ShimmerResponsiveUtils.getResponsivePadding(context)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.blue.shade50.withValues(alpha:0.3)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.blue.shade100.withValues(alpha:0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade100.withValues(alpha:0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha:0.8),
          blurRadius: 10,
          offset: const Offset(0, -2),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                  width: ShimmerResponsiveUtils.getScreenWidth(context) * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    ),
  );
}

Widget _buildShimmerMetricCard({
  required BuildContext context,
  required DashboardController controller,
  bool isFullWidth = false,
}) {
  return Container(
    padding: EdgeInsets.all(ShimmerResponsiveUtils.getResponsivePadding(context)),
    decoration: BoxDecoration(
      color: Colors.grey.shade50.withValues(alpha:0.7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200, width: 1),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title shimmer
                Container(
                  height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: ShimmerResponsiveUtils.getResponsiveMargin(context) * 2),
                // Value shimmer - FIXED: Remove explicit width since it's inside Expanded
                Container(
                  height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 20),
                  // Removed: width: double.infinity * 0.7,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildShimmerPaymentItem(BuildContext context, DashboardController controller) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: ShimmerResponsiveUtils.getResponsiveMargin(context)
    ),
    child: Row(
      children: [
        // Payment Method shimmer
        Expanded(
          flex: 2,
          child: Container(
            height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Amount shimmer
        Expanded(
          flex: 3,
          child: Container(
            height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    ),
  );
}

// Responsive Today's Sales Stats Shimmer
class TodaysSalesStatsShimmer extends StatelessWidget {
  final int itemCount;

  const TodaysSalesStatsShimmer({
    Key? key,
    this.itemCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = ShimmerResponsiveUtils.getScreenWidth(context);
    final isSmallScreen = ShimmerResponsiveUtils.isSmallScreen(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: ShimmerResponsiveUtils.getResponsiveMargin(context) * 3,
        childAspectRatio: _getResponsiveAspectRatio(context),
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildShimmerCard(context),
    );
  }

  double _getResponsiveAspectRatio(BuildContext context) {
    if (ShimmerResponsiveUtils.isSmallScreen(context)) return 3.5;
    if (ShimmerResponsiveUtils.isMediumScreen(context)) return 3.8;
    return 4.2;
  }

  Widget _buildShimmerCard(BuildContext context) {
    final screenWidth = ShimmerResponsiveUtils.getScreenWidth(context);
    final isSmallScreen = ShimmerResponsiveUtils.isSmallScreen(context);
    
    return Container(
      padding: EdgeInsets.all(ShimmerResponsiveUtils.getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 1500),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon shimmer
              Container(
                width: ShimmerResponsiveUtils.getResponsiveIconSize(context),
                height: ShimmerResponsiveUtils.getResponsiveIconSize(context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: ShimmerResponsiveUtils.getResponsivePadding(context) * 0.8),
              // Text content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title shimmer
                    Container(
                      height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                      constraints: BoxConstraints(
                        maxWidth: double.infinity,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: ShimmerResponsiveUtils.getResponsiveMargin(context) * 2),
                    // Value shimmer
                    Container(
                      height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 20),
                      width: double.infinity * 0.6,
                      constraints: BoxConstraints(
                        maxWidth: double.infinity,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Responsive Generic Bar Chart Shimmer
class GenericBarChartShimmer extends StatelessWidget {
  final String title;

  const GenericBarChartShimmer({
    Key? key,
    required this.title,
  }) : super(key: key);

  Color get primaryColor => AppColors.primaryLight;
  Color get primaryLight => AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ShimmerResponsiveUtils.getScreenWidth(context);
    final isSmallScreen = ShimmerResponsiveUtils.isSmallScreen(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ShimmerResponsiveUtils.getResponsiveMargin(context),
        vertical: ShimmerResponsiveUtils.getResponsiveMargin(context) * 1.5,
      ),
      padding: EdgeInsets.all(ShimmerResponsiveUtils.getResponsivePadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryLight.withValues(alpha:0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryLight.withValues(alpha:0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: ShimmerResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: _getResponsiveChartHeight(context),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barCount = _getResponsiveBarCount(context);
                  final barWidth = (availableWidth / barCount) * 0.5; // 50% of available space per bar
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      barCount,
                      (index) => Container(
                        width: barWidth.clamp(8.0, 20.0), // Clamp bar width between 8-20px
                        height: _getBarHeight(context, index),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final barCount = _getResponsiveBarCount(context);
                final labelWidth = (availableWidth / barCount) * 0.7; // 70% of available space per label
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    barCount,
                    (index) => Container(
                      width: labelWidth.clamp(20.0, 50.0), // Clamp label width between 20-50px
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _getResponsiveChartHeight(BuildContext context) {
    final screenHeight = ShimmerResponsiveUtils.getScreenHeight(context);
    if (ShimmerResponsiveUtils.isSmallScreen(context)) return screenHeight * 0.25;
    if (ShimmerResponsiveUtils.isMediumScreen(context)) return screenHeight * 0.28;
    return screenHeight * 0.3;
  }

  int _getResponsiveBarCount(BuildContext context) {
    if (ShimmerResponsiveUtils.isSmallScreen(context)) return 6;
    if (ShimmerResponsiveUtils.isMediumScreen(context)) return 7;
    return 8;
  }

  double _getResponsiveBarWidth(BuildContext context) {
    final screenWidth = ShimmerResponsiveUtils.getScreenWidth(context);
    final barCount = _getResponsiveBarCount(context);
    final availableWidth = screenWidth - (ShimmerResponsiveUtils.getResponsivePadding(context) * 4);
    return (availableWidth / barCount) * 0.6; // 60% of available space per bar
  }

  double _getResponsiveLabelWidth(BuildContext context) {
    final screenWidth = ShimmerResponsiveUtils.getScreenWidth(context);
    if (ShimmerResponsiveUtils.isSmallScreen(context)) return screenWidth * 0.08;
    if (ShimmerResponsiveUtils.isMediumScreen(context)) return screenWidth * 0.09;
    return screenWidth * 0.1;
  }

  double _getBarHeight(BuildContext context, int index) {
    final chartHeight = _getResponsiveChartHeight(context);
    final heights = [0.1, 0.15, 0.2, 0.08, 0.7, 0.85, 0.6, 0.05, 0.3, 0.4];
    return chartHeight * (heights[index % heights.length]);
  }
}