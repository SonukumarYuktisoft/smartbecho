import 'package:flutter/material.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';

class BuildStatsCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final IconData icon;
  final Color color;
  final void Function()? onTap;
  final double? width;
  final bool isAmount;
  final bool hasGrowth;
  final double growthValue;
  final String? featureKey;
  final String? featureTitle;

  TextStyle? valueTextStyle;
  TextStyle? labelTextStyle;

  BuildStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.width = 180,
    this.isAmount = true,
    this.hasGrowth = true,
    this.growthValue = 0.0,
    this.featureKey,
    this.featureTitle,
    this.valueTextStyle,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/shape_square.png'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border:
              onTap != null
                  ? Border.all(color: color.withValues(alpha: 0.2), width: 1)
                  : null,
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            if (hasGrowth)
              Positioned(
                top: 0,
                right: 0,
                child: _growthIndicator(growthValue),
              ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  if (value.isNotEmpty) ...[
                    // 🔥 WRAP ONLY VALUE with FeatureVisitor
                    Flexible(
                      child: Text(
                        "${isAmount ? "\₹" : ""} ${AppFormatterHelper.amountFormatter(AppFormatterHelper.parseAmount(value))}",
                        style:
                            valueTextStyle ??
                            TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style:
                          labelTextStyle ??
                          TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null) ...[
                    SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

   
  }

  Widget _growthIndicator(double growthValue) {
    if (growthValue == 0) {
      return const SizedBox();
    }

    final bool isPositive = growthValue > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${growthValue.abs().toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
