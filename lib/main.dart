import 'package:flutter/material.dart';
import 'package:myresto/home/presentations/pages/home_page.dart';
import 'package:myresto/utils/values/strings/strings.dart';
import 'package:myresto/utils/values/themes/themes.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.appName,
      theme: Themes.myTheme,
      home: HomePage(),
    ),
  );
}
