import 'package:flutter/material.dart';

enum RGBThemes {
  red(
    Colors.red,
  ),
  green(
    Colors.green,
  ),
  blue(
    Colors.blue,
  );

  final Color seedColor;
  const RGBThemes(this.seedColor);
}
