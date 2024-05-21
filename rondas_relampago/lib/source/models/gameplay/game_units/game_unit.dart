// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class GameUnit {
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

  // CustomPaint get renderUnit;

  GameUnit get gameUnit;

  // String parse(BuildContext context);

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
      throw const FormatException("The coordinates went negative.'");
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

  Map<String, dynamic> toJson() => {
        'x': _xComponent.toString(),
        'y': _yComponent.toString(),
        'orientation': _orientation._orientation,
        'size': _size._size,
      };

  static GameUnit? fromJson(
    Map<String, dynamic>? json,
  ) =>
      switch (json) {
        Map json => GameUnit.fromSize(
            switch (json['size']) {
              'Large' => GameUnitSize.large,
              'Medium' => GameUnitSize.medium,
              _ => GameUnitSize.small,
            },
            switch (json['orientation']) {
              'Horizontal' => GameUnitOrientation.horizontal,
              _ => GameUnitOrientation.vertical,
            },
            x: int.parse(
              json['x'],
            ),
            y: int.parse(
              json['y'],
            ),
          ),
        _ => null,
      };
}

class GameUnitSmall extends GameUnit {
  GameUnitSmall(
    int xComponent,
    int yComponent,
    GameUnitOrientation orientation,
  ) : super(
          xComponent,
          yComponent,
          orientation,
          GameUnitSize.small,
        );

  factory GameUnitSmall.fromOrientation(
    GameUnitOrientation orientation, {
    required int x,
    required int y,
  }) =>
      GameUnitSmall(
        x,
        y,
        orientation,
      );

  // @override
  // String parse(BuildContext context) {
  //   return '${AppLocalizations.of(context)!.smallUnitParse} (x: $xComponent, y: $yComponent).';
  // }

  @override
  GameUnitSmall get gameUnit => this;

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
}

class GameUnitMedium extends GameUnit {
  GameUnitMedium(
    int xComponent,
    int yComponent,
    GameUnitOrientation orientation,
  ) : super(
          xComponent,
          yComponent,
          orientation,
          GameUnitSize.medium,
        );

  factory GameUnitMedium.fromOrientation(
    GameUnitOrientation orientation, {
    required int x,
    required int y,
  }) =>
      GameUnitMedium(
        x,
        y,
        orientation,
      );

  @override
  GameUnitMedium get gameUnit => this;

  // @override
  // String parse(BuildContext context) {
  //   return '${AppLocalizations.of(context)!.mediumUnitParse} (x: $xComponent, y: $yComponent).';
  // }

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
}

class GameUnitLarge extends GameUnit {
  GameUnitLarge(
    int xComponent,
    int yComponent,
    GameUnitOrientation orientation,
  ) : super(
          xComponent,
          yComponent,
          orientation,
          GameUnitSize.large,
        );

  factory GameUnitLarge.fromOrientation(
    GameUnitOrientation orientation, {
    required int x,
    required int y,
  }) =>
      GameUnitLarge(
        x,
        y,
        orientation,
      );

  @override
  GameUnitLarge get gameUnit => this;

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

  // factory GameMarker.fromString(String markerCoordinates) {
  //   List<String> coordinates = markerCoordinates.split('-');
  //   return GameMarker(
  //       xCoordinate: int.parse(coordinates[0]),
  //       yCoordinate: int.parse(coordinates[1]));
  // }

  GameMarker.fromJson(Map<String, dynamic> json)
      : xCoordinate = int.parse(json['xCoordinate']),
        yCoordinate = int.parse(json['yCoordinate']);

  Map<String, dynamic> toJson() => {
        'xCoordinate': xCoordinate.toString(),
        'yCoordinate': yCoordinate.toString(),
      };

  static Set<GameMarker> setFromJson(List<Map<String, dynamic>> json) {
    Set<GameMarker> markers = {};

    for (Map<String, dynamic> marker in json) {
      markers.add(
        GameMarker.fromJson(marker),
      );
    }

    return markers;
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
