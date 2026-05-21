import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor:
        AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Poppins',
  );
}
