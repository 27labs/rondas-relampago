import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';

final class RenderedGameUnit<T extends GameUnit> implements GameUnit {
  final T _gameUnit;
  // final void Function(Canvas, Size) _painter;
  const RenderedGameUnit({
    required T unit,
    // required void Function(Canvas, Size) painter,
  }) :
        // _painter = painter,
        _gameUnit = unit;

  @override
  T get gameUnit => _gameUnit;
  @override
  get hitBox => _gameUnit.hitBox;
  @override
  get size => _gameUnit.size;
  @override
  get orientation => _gameUnit.orientation;
  @override
  get coordinatesAsStrings => _gameUnit.coordinatesAsStrings;
  @override
  get xComponent => _gameUnit.xComponent;
  @override
  get yComponent => _gameUnit.yComponent;
  @override
  toJson() => _gameUnit.toJson();

  // String parse(
  //   BuildContext context,
  // ) {
  //   return '${switch (_gameUnit.size) {
  //     GameUnitSize.small => AppLocalizations.of(
  //         context,
  //       )!
  //           .smallUnitParse,
  //     GameUnitSize.medium => AppLocalizations.of(
  //         context,
  //       )!
  //           .mediumUnitParse,
  //     GameUnitSize.large => AppLocalizations.of(
  //         context,
  //       )!
  //           .largeUnitParse,
  //   }} (x: $xComponent, y: $yComponent).';
  // }

  CustomPaint get renderUnit {
    return switch (_gameUnit.orientation) {
      GameUnitOrientation.vertical => renderVerticalUnit(
          _gameUnit.size,
        ),
      GameUnitOrientation.horizontal => renderHorizontalUnit(
          _gameUnit.size,
        ),
    };
    // return CustomPaint(size: Size.infinite, painter: UnitPainter(_painter));
  }

  static CustomPaint renderHorizontalUnit(
    GameUnitSize size,
  ) {
    return switch (size) {
      GameUnitSize.small => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width,
                    height: size.width / 2,
                  ),
                  UnitPaints.small,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height,
                    height: size.height / 2,
                  ),
                  UnitPaints.small,
                );
              }
            },
          ),
        ),
      GameUnitSize.medium => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width,
                    height: size.width / 3,
                  ),
                  UnitPaints.medium,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height,
                    height: size.height / 3,
                  ),
                  UnitPaints.medium,
                );
              }
            },
          ),
        ),
      GameUnitSize.large => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width,
                    height: size.width / 4,
                  ),
                  UnitPaints.large,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height,
                    height: size.height / 4,
                  ),
                  UnitPaints.large,
                );
              }
            },
          ),
        ),
    };
  }

  static CustomPaint renderVerticalUnit(
    GameUnitSize size,
  ) {
    return switch (size) {
      GameUnitSize.small => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width / 2,
                    height: size.width,
                  ),
                  UnitPaints.small,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height / 2,
                    height: size.height,
                  ),
                  UnitPaints.small,
                );
              }
            },
          ),
        ),
      GameUnitSize.medium => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width / 3,
                    height: size.width,
                  ),
                  UnitPaints.medium,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height / 3,
                    height: size.height,
                  ),
                  UnitPaints.medium,
                );
              }
            },
          ),
        ),
      GameUnitSize.large => CustomPaint(
          size: Size.infinite,
          painter: UnitPainter(
            (
              Canvas canvas,
              Size size,
            ) {
              if (size.width < size.height) {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width / 4,
                    height: size.width,
                  ),
                  UnitPaints.large,
                );
              } else {
                canvas.drawRect(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.height / 4,
                    height: size.height,
                  ),
                  UnitPaints.large,
                );
              }
            },
          ),
        ),
    };
  }
}
