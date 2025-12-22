import 'package:flutter/material.dart';
import 'package:myresto/utils/values/colors/colors.dart';

class Themes {
  static final myTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    brightness: .light,
    useMaterial3: true,
    colorScheme: .fromSeed(seedColor: MyColors.brown200),
  );
}
