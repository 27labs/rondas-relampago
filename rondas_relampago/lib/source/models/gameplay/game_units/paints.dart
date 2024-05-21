import 'package:flutter/material.dart';
// import '../themes.dart';

export 'package:flutter/material.dart';

class UnitPaints {
  static Paint get small =>
      Paint()..color = const Color.fromARGB(184, 255, 187, 39);
  static Paint get medium =>
      Paint()..color = const Color.fromARGB(184, 255, 187, 39);
  static Paint get large =>
      Paint()..color = const Color.fromARGB(184, 255, 187, 39);
}

class UnitPainter extends CustomPainter {
  final void Function(Canvas, Size) painter;
  UnitPainter(this.painter);

  @override
  void paint(Canvas canvas, Size size) {
    painter(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
    // throw UnimplementedError();
  }
}
