import 'package:flutter/material.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';

class MarksPainter extends StatelessWidget {
  final Set<GameMarker> marksOnBoard;
  final Set<GameMarker> hitboxes;
  final int boardRows;
  final int boardColumns;
  const MarksPainter(
    this.marksOnBoard, {
    this.hitboxes = const {},
    required this.boardRows,
    required this.boardColumns,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> renderedMarks = [];

    for (GameMarker square in marksOnBoard) {
      renderedMarks.add(
        FittedBox(
          fit: BoxFit.contain,
          child: Container(
            padding: const EdgeInsets.all(
              0.1,
            ),
            height: boardRows.toDouble(),
            width: boardColumns.toDouble(),
            child: CustomPaint(
              size: Size.infinite,
              painter: _TargetMarkPainter(
                square,
                switch (hitboxes.contains(square)) {
                  false => Theme.of(
                      context,
                    ).primaryColor,
                  true => Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withOpacity(0.9),
                },
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
      children: renderedMarks,
    );
  }
}

class _TargetMarkPainter extends CustomPainter {
  final GameMarker square;
  final Color markColor;
  final int rows;
  final int columns;
  const _TargetMarkPainter(
    this.square,
    this.markColor, {
    required this.rows,
    required this.columns,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // final normalizedBoardArea = (rows * columns) / 1000;

    const double paintPadding = 0.26;

    final shapeBounds = Rect.fromLTRB(
      (size.width / (columns)) * (square.xCoordinate) + paintPadding,
      (size.height / (rows)) * (square.yCoordinate) + paintPadding,
      (size.width / (columns)) * (square.xCoordinate + 1) - paintPadding,
      (size.height / (rows)) * (square.yCoordinate + 1) - paintPadding,
    );

    // final shapeBounds = Rect.fromCenter(
    //     center: Offset((size.width / (columns * 2)) * (unit.xComponent * 2 + 1),
    //         (size.height / (rows * 2)) * (unit.yComponent * 2 + 1)),
    //     height: normalizedBoardArea * 20,
    //     width: normalizedBoardArea * 20);

    final paint = Paint()..color = markColor;

    canvas.drawRect(
      shapeBounds,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    _TargetMarkPainter oldDelegate,
  ) {
    return square != oldDelegate.square;
  }
}
