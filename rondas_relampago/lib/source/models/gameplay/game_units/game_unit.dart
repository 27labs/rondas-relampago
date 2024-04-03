import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'paints.dart';

sealed class GameUnit {
  final int _xComponent;
  final int _yComponent;
  final GameUnitSize _size;
  final GameUnitOrientation _orientation;
  // final GameUnitShape _shape;

  Set<GameMarker> get hitBox;
  GameUnitSize get size => _size;
  GameUnitOrientation get orientation => _orientation;
  String get coordinatesAsStrings => '$_xComponent-$_yComponent';
  int get xComponent => _xComponent;
  int get yComponent => _yComponent;

  CustomPaint get renderUnit;

  String parse(BuildContext context);

  static bool doTheyCollide(GameUnit unit1, GameUnit unit2) =>
      unit1.hitBox.intersection(unit2.hitBox).isNotEmpty;

  @override
  bool operator ==(other) {
    if (other is GameUnit) {
      return doTheyCollide(this, other);
    }
    return false;
  }

  @override
  int get hashCode => '$_xComponent - $_yComponent - ${hitBox.length}'.hashCode;

  const GameUnit(
      this._xComponent, this._yComponent, this._orientation, this._size);

  factory GameUnit.fromSize(GameUnitSize size, GameUnitOrientation orientation,
      {required int x, required int y}) {
    if (x < 0 || y < 0) {
      throw ErrorWidget(
          const FormatException("The coordinates went negative.'"));
    }
    switch (size) {
      case GameUnitSize.small:
        {
          return GameUnitSmall.fromOrientation(orientation, x: x, y: y);
        }
      case GameUnitSize.medium:
        {
          return GameUnitMedium.fromOrientation(orientation, x: x, y: y);
        }
      case GameUnitSize.large:
        {
          return GameUnitLarge.fromOrientation(orientation, x: x, y: y);
        }
    }
  }
}

class GameUnitSmall extends GameUnit {
  final void Function(Canvas, Size) _painter;
  GameUnitSmall(int xComponent, int yComponent, GameUnitOrientation orientation,
      this._painter)
      : super(xComponent, yComponent, orientation, GameUnitSize.small);

  factory GameUnitSmall.fromOrientation(
    GameUnitOrientation orientation, {
    required int x,
    required int y,
  }) {
    switch (orientation) {
      case GameUnitOrientation.horizontal:
        return GameUnitSmall(
          x,
          y,
          orientation,
          _horizontalPainter,
        );
      case GameUnitOrientation.vertical:
        return GameUnitSmall(
          x,
          y,
          orientation,
          _verticalPainter,
        );
    }
  }

  @override
  String parse(BuildContext context) {
    return '${AppLocalizations.of(context)!.smallUnitParse} (x: $xComponent, y: $yComponent).';
  }

  @override
  Set<GameMarker> get hitBox {
    Set<GameMarker> hitBox = {};
    switch (_orientation) {
      case GameUnitOrientation.horizontal:
        {
          for (int i = 0; i < 2; i++,) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent + i,
                yCoordinate: _yComponent,
              ),
            );
          }
          break;
        }
      case GameUnitOrientation.vertical:
        {
          for (int i = 0; i < 2; i++,) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent,
                yCoordinate: _yComponent + i,
              ),
            );
          }
          break;
        }
    }
    return hitBox;
  }

  @override
  CustomPaint get renderUnit {
    return CustomPaint(size: Size.infinite, painter: UnitPainter(_painter));
  }

  static CustomPaint get renderHorizontalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_horizontalPainter));
  }

  static CustomPaint get renderVerticalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_verticalPainter));
  }

  static void _horizontalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width, height: size.width / 2),
          UnitPaints.small);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height, height: size.height / 2),
          UnitPaints.small);
    }
  }

  static void _verticalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width / 2, height: size.width),
          UnitPaints.small);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height / 2, height: size.height),
          UnitPaints.small);
    }
  }
}

class GameUnitMedium extends GameUnit {
  final void Function(Canvas, Size) _painter;
  GameUnitMedium(int xComponent, int yComponent,
      GameUnitOrientation orientation, this._painter)
      : super(xComponent, yComponent, orientation, GameUnitSize.medium);

  factory GameUnitMedium.fromOrientation(GameUnitOrientation orientation,
      {required int x, required int y}) {
    switch (orientation) {
      case GameUnitOrientation.horizontal:
        return GameUnitMedium(x, y, orientation, _horizontalPainter);
      case GameUnitOrientation.vertical:
        return GameUnitMedium(x, y, orientation, _verticalPainter);
    }
  }

  @override
  String parse(BuildContext context) {
    return '${AppLocalizations.of(context)!.mediumUnitParse} (x: $xComponent, y: $yComponent).';
  }

  @override
  Set<GameMarker> get hitBox {
    Set<GameMarker> hitBox = {};
    switch (_orientation) {
      case GameUnitOrientation.horizontal:
        {
          for (int i = 0; i < 3; i++) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent + i,
                yCoordinate: _yComponent,
              ),
            );
          }
          break;
        }
      case GameUnitOrientation.vertical:
        {
          for (int i = 0; i < 3; i++) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent,
                yCoordinate: _yComponent + i,
              ),
            );
          }
          break;
        }
    }
    return hitBox;
  }

  @override
  CustomPaint get renderUnit {
    return CustomPaint(size: Size.infinite, painter: UnitPainter(_painter));
  }

  static CustomPaint get renderHorizontalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_horizontalPainter));
  }

  static CustomPaint get renderVerticalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_verticalPainter));
  }

  static void _horizontalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width, height: size.width / 3),
          UnitPaints.medium);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height, height: size.height / 3),
          UnitPaints.medium);
    }
  }

  static void _verticalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width / 3, height: size.width),
          UnitPaints.medium);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height / 3, height: size.height),
          UnitPaints.medium);
    }
  }
}

class GameUnitLarge extends GameUnit {
  final void Function(Canvas, Size) _painter;
  GameUnitLarge(int xComponent, int yComponent, GameUnitOrientation orientation,
      this._painter)
      : super(xComponent, yComponent, orientation, GameUnitSize.large);

  factory GameUnitLarge.fromOrientation(GameUnitOrientation orientation,
      {required int x, required int y}) {
    switch (orientation) {
      case GameUnitOrientation.horizontal:
        return GameUnitLarge(x, y, orientation, _horizontalPainter);
      case GameUnitOrientation.vertical:
        return GameUnitLarge(x, y, orientation, _verticalPainter);
    }
  }

  @override
  String parse(BuildContext context) {
    return '${AppLocalizations.of(context)!.largeUnitParse} (x: $xComponent, y: $yComponent).';
  }

  @override
  Set<GameMarker> get hitBox {
    Set<GameMarker> hitBox = {};
    switch (_orientation) {
      case GameUnitOrientation.horizontal:
        {
          for (int i = 0; i < 4; i++) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent + i,
                yCoordinate: _yComponent,
              ),
            );
          }
          break;
        }
      case GameUnitOrientation.vertical:
        {
          for (int i = 0; i < 4; i++) {
            hitBox.add(
              GameMarker(
                xCoordinate: _xComponent,
                yCoordinate: _yComponent + i,
              ),
            );
          }
          break;
        }
    }
    return hitBox;
  }

  @override
  CustomPaint get renderUnit {
    return CustomPaint(size: Size.infinite, painter: UnitPainter(_painter));
  }

  static CustomPaint get renderHorizontalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_horizontalPainter));
  }

  static CustomPaint get renderVerticalUnit {
    return CustomPaint(
        size: Size.infinite, painter: UnitPainter(_verticalPainter));
  }

  static void _horizontalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width, height: size.width / 4),
          UnitPaints.large);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height, height: size.height / 4),
          UnitPaints.large);
    }
  }

  static void _verticalPainter(Canvas canvas, Size size) {
    if (size.width < size.height) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.width / 4, height: size.width),
          UnitPaints.large);
    } else {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size.height / 4, height: size.height),
          UnitPaints.large);
    }
  }
}

class GameMarker {
  final int xCoordinate;
  final int yCoordinate;

  const GameMarker({
    required this.xCoordinate,
    required this.yCoordinate,
  });

  @override
  String toString() => '(x: $xCoordinate, y: $yCoordinate)';

  @override
  bool operator ==(
    Object other,
  ) =>
      switch (other) {
        GameMarker() =>
          other.xCoordinate == xCoordinate && other.yCoordinate == yCoordinate,
        _ => false,
      };

  @override
  int get hashCode => '$xCoordinate - $yCoordinate'.hashCode;

  factory GameMarker.fromString(String markerCoordinates) {
    List<String> coordinates = markerCoordinates.split('-');
    return GameMarker(
        xCoordinate: int.parse(coordinates[0]),
        yCoordinate: int.parse(coordinates[1]));
  }
}

// TODO: Implement different unit shapes. Make it a class like the other ones if it's needed.
// enum GameUnitShape {line,square,letterL}

enum GameUnitSize {
  large('Large'),
  medium('Medium'),
  small('Small');

  final String _size;
  @override
  String toString() => _size;
  const GameUnitSize(this._size);
}

enum GameUnitOrientation {
  horizontal('Horizontal'),
  vertical('Vertical');

  final String _orientation;
  @override
  String toString() => _orientation;
  const GameUnitOrientation(this._orientation);
}
