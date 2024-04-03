import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
// import 'package:rondas_relampago/source/pages/casual_singleplayer/match.dart';

// New

sealed class MatchUnits {
  final Record _data;
  const MatchUnits(
    Record data,
  ) : _data = data;

  List<GameUnit> get data;

  // Record get dataRecord => _data;

  Set<GameUnitSize?> get sizes;

  bool get isFull;

  Set<GameMarker> get hitBoxes;

  GameUnit? collided(GameMarker hitBox);

  factory MatchUnits.add(
    MatchUnits state,
    GameUnit unit,
  ) =>
      switch (state) {
        CasualMatchUnits() => CasualMatchUnits.copyWith(
            state,
            unit: unit,
          ),
      };

  factory MatchUnits.remove(
    MatchUnits state,
    GameMarker hitBox,
  ) =>
      switch (state) {
        CasualMatchUnits() => CasualMatchUnits.copyWith(state, hitBox: hitBox),
      };
}

class CasualMatchUnits implements MatchUnits {
  @override
  final (
    GameUnitLarge?,
    GameUnitMedium?,
    GameUnitSmall?,
  ) _data;
  const CasualMatchUnits(
    (
      GameUnitLarge?,
      GameUnitMedium?,
      GameUnitSmall?,
    ) data,
  ) : _data = data;

  @override
  List<GameUnit> get data {
    List<GameUnit> units = [];
    if (_data.$1 != null) units.add(_data.$1!);
    if (_data.$2 != null) units.add(_data.$2!);
    if (_data.$3 != null) units.add(_data.$3!);
    return units;
  }

  // @override
  // (
  //   GameUnitLarge?,
  //   GameUnitMedium?,
  //   GameUnitSmall?,
  // ) get dataRecord => _data;

  @override
  Set<GameUnitSize?> get sizes {
    return <GameUnitSize?>{}..addAll(
        {
          _data.$1?.size,
          _data.$2?.size,
          _data.$3?.size,
        },
      );
  }

  @override
  Set<GameMarker> get hitBoxes {
    Set<GameMarker> hitBoxes = {};

    hitBoxes.addAll(_data.$1?.hitBox ?? <GameMarker>{});
    hitBoxes.addAll(_data.$2?.hitBox ?? <GameMarker>{});
    hitBoxes.addAll(_data.$3?.hitBox ?? <GameMarker>{});

    return hitBoxes;
  }

  @override
  bool get isFull =>
      !(_data.$1 == null || _data.$2 == null || _data.$3 == null);

  @override
  GameUnit? collided(GameMarker hitBox) {
    if (_data.$1?.hitBox.contains(hitBox) ?? false) return _data.$1;
    if (_data.$2?.hitBox.contains(hitBox) ?? false) return _data.$2;
    if (_data.$3?.hitBox.contains(hitBox) ?? false) return _data.$3;
    return null;
  }

  @override
  CasualMatchUnits.copyWith(
    CasualMatchUnits base, {
    GameUnit? unit,
    GameMarker? hitBox,
  }) : _data = switch (unit) {
          GameUnitSmall() => (
              base._data.$1,
              base._data.$2,
              base._data.$3 ?? unit,
            ),
          GameUnitMedium() => (
              base._data.$1,
              base._data.$2 ?? unit,
              base._data.$3,
            ),
          GameUnitLarge() => (
              base._data.$1 ?? unit,
              base._data.$2,
              base._data.$3,
            ),
          null => (
              base._data.$1 == null
                  ? null
                  : base._data.$1!.hitBox.contains(
                      hitBox,
                    )
                      ? null
                      : base._data.$1,
              base._data.$2 == null
                  ? null
                  : base._data.$2!.hitBox.contains(
                      hitBox,
                    )
                      ? null
                      : base._data.$2,
              base._data.$3 == null
                  ? null
                  : base._data.$3!.hitBox.contains(
                      hitBox,
                    )
                      ? null
                      : base._data.$3
            ),
        };
}

typedef CasualMatchMarkers = Set<GameMarker>;

sealed class MatchData {
  const MatchData();

  MatchUnits get playerOneUnits;
  MatchUnits get playerTwoUnits;
  MatchMarkers get playerOneTargets;
  MatchMarkers get playerTwoTargets;

  MatchData.copyWith();
}

class CasualMatchData implements MatchData {
  final ({
    CasualMatchUnits playerOneUnits,
    CasualMatchMarkers playerOneMarkers,
    CasualMatchUnits playerTwoUnits,
    CasualMatchMarkers playerTwoMarkers,
  }) _data;
  const CasualMatchData({
    CasualMatchUnits? playerOneUnits,
    CasualMatchMarkers? playerOneMarkers,
    CasualMatchUnits? playerTwoUnits,
    CasualMatchMarkers? playerTwoMarkers,
  }) : _data = (
          playerOneUnits: playerOneUnits ??
              const CasualMatchUnits((
                null,
                null,
                null,
              )),
          playerOneMarkers: playerOneMarkers ?? const {},
          playerTwoUnits: playerTwoUnits ??
              const CasualMatchUnits((
                null,
                null,
                null,
              )),
          playerTwoMarkers: playerTwoMarkers ?? const {},
        );

  ({
    CasualMatchUnits playerOneUnits,
    CasualMatchMarkers playerOneMarkers,
    CasualMatchUnits playerTwoUnits,
    CasualMatchMarkers playerTwoMarkers,
  }) get data => _data;

  @override
  CasualMatchUnits get playerOneUnits => _data.playerOneUnits;

  @override
  CasualMatchUnits get playerTwoUnits => _data.playerTwoUnits;

  @override
  CasualMatchMarkers get playerOneTargets => _data.playerOneMarkers;

  @override
  CasualMatchMarkers get playerTwoTargets => _data.playerTwoMarkers;

  @override
  CasualMatchData.copyWith(
    CasualMatchData base, {
    CasualMatchUnits? playerOneUnits,
    CasualMatchUnits? playerTwoUnits,
    CasualMatchMarkers? playerOneMarkers,
    CasualMatchMarkers? playerTwoMarkers,
  }) : _data = (
          playerOneUnits: playerOneUnits ?? base.data.playerOneUnits,
          playerOneMarkers: playerOneMarkers ?? base.data.playerOneMarkers,
          playerTwoUnits: playerTwoUnits ?? base.data.playerTwoUnits,
          playerTwoMarkers: playerTwoMarkers ?? base.data.playerTwoMarkers,
        );
}

typedef MatchMarkers = Set<GameMarker>;

class OutOfBoundsException implements Exception {}

class MarkersLimitReachedException implements Exception {}

// Old

// enum GameRound { first, second, last }

// enum GameStage {
//   tutorial,
//   playerOnePlacement,
//   playerTwoPlacement,
//   playerOneTargeting,
//   playerTwoTargeting,
//   results,
//   error
// }

// class CompetitiveModePlayerUnits {
//   Set<GameUnit> _roundOneUnits = {};
//   Set<GameUnit> _roundTwoUnits = {};
//   Set<GameUnit> _roundThreeUnits = {};

//   void addGameUnit(GameRound round, GameUnit unit) {
//     switch (round) {
//       case GameRound.first:
//         _roundOneUnits.add(unit);
//         break;
//       case GameRound.second:
//         _roundTwoUnits.add(unit);
//         break;
//       case GameRound.last:
//         _roundThreeUnits.add(unit);
//         break;
//     }
//   }

//   void removeGameUnit(GameRound round, GameUnit unit) {
//     switch (round) {
//       case GameRound.first:
//         _roundOneUnits.remove(unit);
//         break;
//       case GameRound.second:
//         _roundTwoUnits.remove(unit);
//         break;
//       case GameRound.last:
//         _roundThreeUnits.remove(unit);
//         break;
//     }
//   }

//   Set<GameUnit> get roundOneUnits => _roundOneUnits;
//   Set<GameUnit> get roundTwoUnits => _roundTwoUnits;
//   Set<GameUnit> get roundThreeUnits => _roundThreeUnits;

//   Set<GameUnit> fromRound(GameRound round) {
//     switch (round) {
//       case GameRound.first:
//         return _roundOneUnits;
//       case GameRound.second:
//         return _roundTwoUnits;
//       case GameRound.last:
//         return _roundThreeUnits;
//     }
//   }
// }

// class CompetitiveModePlayerTargets {
//   Set<String> _roundOneTargets = {};
//   Set<String> _roundTwoTargets = {};
//   Set<String> _roundThreeTargets = {};

//   // void addGameTarget(GameRound round, {required int x, required int y}) {
//   //   switch (round) {
//   //     case GameRound.first:
//   //       _roundOneTargets.add('$x-$y');
//   //       break;
//   //     case GameRound.second:
//   //       _roundTwoTargets.add('$x-$y');
//   //       break;
//   //     case GameRound.last:
//   //       _roundThreeTargets.add('$x-$y');
//   //       break;
//   //   }
//   // }

//   int get amountOfTargets =>
//       _roundOneTargets.length +
//       _roundTwoTargets.length +
//       _roundThreeTargets.length;

//   void addGameTarget(GameRound round, String target) {
//     switch (round) {
//       case GameRound.first:
//         _roundOneTargets.add(target);
//         break;
//       case GameRound.second:
//         _roundTwoTargets.add(target);
//         break;
//       case GameRound.last:
//         _roundThreeTargets.add(target);
//         break;
//     }
//   }

//   void removeGameTarget(GameRound round, {required int x, required int y}) {
//     switch (round) {
//       case GameRound.first:
//         _roundOneTargets.remove('$x-$y');
//         break;
//       case GameRound.second:
//         _roundTwoTargets.remove('$x-$y');
//         break;
//       case GameRound.last:
//         _roundThreeTargets.remove('$x-$y');
//         break;
//     }
//   }

//   Set<String> get roundOneTargets => _roundOneTargets;
//   Set<String> get roundTwoTargets => _roundTwoTargets;
//   Set<String> get roundThreeTargets => _roundThreeTargets;

//   Set<String> fromRound(GameRound round) {
//     switch (round) {
//       case GameRound.first:
//         return _roundOneTargets;
//       case GameRound.second:
//         return _roundTwoTargets;
//       case GameRound.last:
//         return _roundThreeTargets;
//     }
//   }
// }
