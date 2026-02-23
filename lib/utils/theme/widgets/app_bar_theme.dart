import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';

class AppBarTm {
  static AppBarTheme light = const AppBarTheme(
    backgroundColor: AppColors.primaryLight,

    foregroundColor: Colors.white,

    iconTheme: IconThemeData(color: Colors.white, size: 30),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 30),
    centerTitle: true,

    elevation: 0,
    surfaceTintColor: Colors.transparent,

    actionsPadding: EdgeInsets.all(15),
  );
}
