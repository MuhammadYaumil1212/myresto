import 'package:flutter/material.dart';
import 'package:myresto/utils/values/strings/strings.dart';
import 'package:myresto/utils/values/themes/themes.dart';

void main() {
  runApp(
    MaterialApp(
      title: Strings.appName,
      theme: Themes.myTheme,
      home: Container(),
    ),
  );
}
