import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:motion_toast/motion_toast.dart';

class ToastCustom {
  // Error toast
  static errorToast(BuildContext context, String message) {
    MotionToast.error(
      title:  Text(
        'Error',
        style: AppStyles.white_18_600,
      ),
      description: Text(
        message,
        style: AppStyles.white_14_400,
      ),
        animationType: AnimationType.slideInFromBottom,
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.bottomCenter,
      dismissable: true,
      borderRadius: 12,
      layoutOrientation: TextDirection.ltr,
    ).show(context);
  }

  // Success toast
  static successToast(BuildContext context, String message) {
    MotionToast.success(
      title: const Text(
        'Successful',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: AppStyles.black_14_400,
      ),
      animationType: AnimationType.slideInFromBottom,
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.bottomCenter,
     // position: MotionToastPosition.top,
      dismissable: true,
      borderRadius: 12,
      layoutOrientation: TextDirection.ltr,
    ).show(context);
  }

  // Info toast
  static infoToast(BuildContext context, String message) {
    MotionToast.info(
      title: const Text(
        'Info',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: AppStyles.black_14_400,
      ),
        animationType: AnimationType.slideInFromBottom,
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.bottomCenter,
      dismissable: true,
      borderRadius: 12,
      layoutOrientation: TextDirection.ltr,
    ).show(context);
  }
}
