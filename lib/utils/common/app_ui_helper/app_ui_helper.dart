import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartbecho/utils/app_colors.dart';

class AppUiHelper {
  static Widget appHeaderName({
    double? fontSize,
    TextStyle? style,
    String? subtitle,
    TextStyle? subtitleStyle,
  }) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Smart',
                style:
                    style ??
                    TextStyle(
                      fontSize: fontSize ?? 32,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryLight,
                      letterSpacing: 1,
                    ),
              ),
              TextSpan(
                text: 'Becho',
                style:
                    style ??
                    TextStyle(
                      fontSize: fontSize ?? 32,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authColor2,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style:
                subtitleStyle ??
                TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryLight.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ],
    );
  }

  static Widget getPaymentModeIcon({required String paymentMode}) {
    final icons = {
      'cash': FontAwesomeIcons.moneyBillWave,
      'bank': FontAwesomeIcons.buildingColumns,
      'upi': FontAwesomeIcons.mobileScreenButton,
      'credit_card': FontAwesomeIcons.creditCard,
      'debit_card': FontAwesomeIcons.creditCard,
      'cheque': FontAwesomeIcons.moneyCheck,
      'others': FontAwesomeIcons.circleQuestion,
      'given_sale_dues': FontAwesomeIcons.handHoldingDollar,
      'emi_pending': FontAwesomeIcons.clock,
    };

    // return FaIcon(
    //   icons[paymentMode.toLowerCase()] ?? FontAwesomeIcons.circleQuestion,
    //   size: 18,
    //   color: Colors.black,
    // );
    return FaIcon(
      icons[paymentMode.toLowerCase()] ?? FontAwesomeIcons.moneyBillWave,
      color: Colors.black,
      size: 18,
    );
  }
}
