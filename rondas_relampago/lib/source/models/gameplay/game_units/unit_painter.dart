// import 'dart:html';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:game_common/game_common.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';

class UnitsPainter extends StatelessWidget {
  final MatchUnits unitsOnBoard;
  final int boardRows;
  final int boardColumns;
  const UnitsPainter(
    this.unitsOnBoard, {
    required this.boardRows,
    required this.boardColumns,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> renderedUnits = [];

    for (GameUnit unit in unitsOnBoard.data) {
      renderedUnits.add(
        FittedBox(
          fit: BoxFit.contain,
          child: Container(
            padding: const EdgeInsets.all(0.1),
            height: boardRows.toDouble(),
            width: boardColumns.toDouble(),
            child: CustomPaint(
              size: Size.infinite,
              painter: _GameUnitPainter(
                unit,
                Colors.amber,
                rows: boardRows,
                columns: boardColumns,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: renderedUnits,
    );
  }
}

class _GameUnitPainter extends CustomPainter {
  final GameUnit unit;
  final Color unitColor;
  final int rows;
  final int columns;
  const _GameUnitPainter(
    this.unit,
    this.unitColor, {
    required this.rows,
    required this.columns,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // final normalizedBoardArea = (rows * columns) / 1000;
    const double paintPadding = 0.15;

    final shapeBounds = Rect.fromLTRB(
        (size.width / (columns)) * (unit.xComponent) + paintPadding,
        (size.height / (rows)) * (unit.yComponent) + paintPadding,
        // vvvvvv Getting deprecated soon, DO NOT refactor. vvvvvv
        (size.width / (columns)) *
                (unit.xComponent +
                    (unit.orientation == GameUnitOrientation.horizontal
                        ? unit.hitBox.length
                        : 1)) -
            paintPadding,
        (size.height / (rows)) *
                (unit.yComponent +
                    (unit.orientation == GameUnitOrientation.vertical
                        ? unit.hitBox.length
                        : 1)) -
            paintPadding);

    // final shapeBounds = Rect.fromCenter(
    //     center: Offset((size.width / (columns * 2)) * (unit.xComponent * 2 + 1),
    //         (size.height / (rows * 2)) * (unit.yComponent * 2 + 1)),
    //     height: normalizedBoardArea * 20,
    //     width: normalizedBoardArea * 20);

    final paint = Paint()..color = unitColor;

    canvas.drawRect(
      shapeBounds,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    _GameUnitPainter oldDelegate,
  ) {
    return unit.hitBox != oldDelegate.unit.hitBox;
  }
}
