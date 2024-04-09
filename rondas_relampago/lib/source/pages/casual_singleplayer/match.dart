import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

// Owned
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/gameplay_features.dart';
import 'package:rondas_relampago/source/pages/utils/screen_title.dart';
import 'package:rondas_relampago/source/views/marker_views.dart';
import 'package:rondas_relampago/source/views/result_views.dart';
import 'package:rondas_relampago/source/views/unit_views.dart';

enum CasualMatchStage {
  unitPlacement,
  markerPlacement,
  results,
}

enum CasualMatchTwoPlayerStage {
  p1UnitPlacement,
  p2UnitPlacement,
  p1MarkerPlacement,
  p2MarkerPlacement,
  results,
}

class CasualMatch extends StatefulWidget {
  final bool multiplayer;
  const CasualMatch({
    this.multiplayer = false,
    super.key,
  });
  @override
  State<CasualMatch> createState() => switch (multiplayer) {
        false => CasualMatchState(),
        true => CasualMatchMultiplayerState(),
      };
}

class CasualMatchState extends State<CasualMatch> {
  CasualMatchStage _stage = CasualMatchStage.unitPlacement;

  CasualMatchData _data = const CasualMatchData();

  void _updateUnits<CasualMatchUnits>({
    required covariant unitsState,
  }) {
    setState(
      () {
        _data = CasualMatchData.copyWith(
          _data,
          playerOneUnits: unitsState,
        );
      },
    );
  }

  void _updateMarkers<CasualMatchMarkers>({
    required covariant markersState,
  }) {
    setState(
      () {
        _data = CasualMatchData.copyWith(
          _data,
          playerOneMarkers: markersState,
        );
      },
    );
  }

  @override
  Widget build(
    context,
  ) =>
      Scaffold(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onPrimaryContainer,
        body: switch (_stage) {
          CasualMatchStage.unitPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .playerPlacingTitle,
                ),
                Expanded(
                  child: UnitPlacementView(
                    GameBoardSize.small,
                    unitsState: _data.data.playerOneUnits,
                    onChange: _updateUnits,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchStage.markerPlacement;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchStage.markerPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .playerGuessingTitle,
                ),
                Expanded(
                  child: MarkerPlacementView(
                    GameBoardSize.small,
                    4,
                    markersState: _data.data.playerOneMarkers,
                    onChange: _updateMarkers,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchStage.results;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchStage.results => FutureBuilder(
              future: Future<
                  (
                    CasualMatchUnits,
                    CasualMatchMarkers,
                  )>.delayed(
                const Duration(
                  milliseconds: 200,
                ),
                () {
                  const GameBoardSize boardSize = GameBoardSize.small;
                  CasualMatchUnits units = const CasualMatchUnits(
                    (
                      null,
                      null,
                      null,
                    ),
                  );
                  int randomInt = DateTime.now().millisecond % 7;
                  if (randomInt > 4) {
                    units = CasualMatchUnits.copyWith(
                      units,
                      unit: GameUnit.fromSize(
                        GameUnitSize.large,
                        GameUnitOrientation.horizontal,
                        x: ((randomInt * 3 + 1) % (boardSize.x - 3)),
                        y: ((randomInt * 5 - 1) % boardSize.y),
                      ),
                    );
                  } else {
                    units = CasualMatchUnits.copyWith(
                      units,
                      unit: GameUnit.fromSize(
                        GameUnitSize.large,
                        GameUnitOrientation.vertical,
                        x: ((randomInt * 3 + 1) % boardSize.x),
                        y: ((randomInt * 5 - 1) % (boardSize.y - 3)),
                      ),
                    );
                  }

                  GameUnit unit;

                  do {
                    randomInt = DateTime.now().millisecond % 7;
                    if (randomInt > 3) {
                      unit = GameUnit.fromSize(
                        GameUnitSize.medium,
                        GameUnitOrientation.horizontal,
                        x: ((randomInt * 3 + 1) % (boardSize.x - 2)),
                        y: ((randomInt * 5 - 1) % boardSize.y),
                      );
                    } else {
                      unit = GameUnit.fromSize(
                        GameUnitSize.medium,
                        GameUnitOrientation.vertical,
                        x: ((randomInt * 3 + 1) % boardSize.x),
                        y: ((randomInt * 5 - 1) % (boardSize.y - 2)),
                      );
                    }
                  } while (units.hitBoxes
                      .intersection(
                        unit.hitBox,
                      )
                      .isNotEmpty);
                  units = CasualMatchUnits.copyWith(
                    units,
                    unit: unit,
                  );

                  do {
                    randomInt = DateTime.now().millisecond % 7;
                    if (randomInt > 3) {
                      unit = GameUnit.fromSize(
                        GameUnitSize.small,
                        GameUnitOrientation.horizontal,
                        x: ((randomInt * 3 + 1) % (boardSize.x - 1)),
                        y: ((randomInt * 5 - 1) % boardSize.y),
                      );
                    } else {
                      unit = GameUnit.fromSize(
                        GameUnitSize.small,
                        GameUnitOrientation.vertical,
                        x: ((randomInt * 3 + 1) % boardSize.x),
                        y: ((randomInt * 5 - 1) % (boardSize.y - 1)),
                      );
                    }
                  } while (units.hitBoxes
                      .intersection(
                        unit.hitBox,
                      )
                      .isNotEmpty);
                  units = CasualMatchUnits.copyWith(
                    units,
                    unit: unit,
                  );

                  CasualMatchMarkers markers = {};

                  do {
                    int randomIntX = DateTime.now().millisecond % 5;
                    int randomIntY = DateTime.now().millisecond % 6;
                    for (GameMarker marker in markers) {
                      if (marker ==
                          GameMarker(
                            xCoordinate: randomIntX,
                            yCoordinate: randomIntY,
                          )) {
                        continue;
                      }
                    }
                    markers.add(
                      GameMarker(
                        xCoordinate: randomIntX,
                        yCoordinate: randomIntY,
                      ),
                    );
                  } while (markers.length < 4);
                  return (
                    units,
                    markers,
                  );
                },
              ),
              builder: (
                _,
                snapshot,
              ) =>
                  Column(
                children: [
                  ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .resultsTitle,
                    showingResults: true,
                  ),
                  Expanded(
                    child: ResultsView(
                      GameBoardSize.small,
                      isPlayingSolo: true,
                      matchData: switch (snapshot.data) {
                        (
                          CasualMatchUnits units,
                          CasualMatchMarkers markers,
                        ) =>
                          CasualMatchData.copyWith(
                            _data,
                            playerOneUnits: _data.data.playerOneUnits,
                            playerOneMarkers: _data.data.playerOneMarkers,
                            playerTwoUnits: units,
                            playerTwoMarkers: markers,
                          ),
                        _ => _data,
                      },
                      onDone: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
        },
      );
}

class CasualMatchMultiplayerState extends State<CasualMatch> {
  CasualMatchTwoPlayerStage _stage = CasualMatchTwoPlayerStage.p1UnitPlacement;

  CasualMatchData _data = const CasualMatchData();

  void _updateUnits<CasualMatchUnits>({
    required covariant unitsState,
  }) {
    setState(
      () {
        _data = switch (_stage) {
          CasualMatchTwoPlayerStage.p1UnitPlacement => CasualMatchData.copyWith(
              _data,
              playerOneUnits: unitsState,
            ),
          CasualMatchTwoPlayerStage.p2UnitPlacement => CasualMatchData.copyWith(
              _data,
              playerTwoUnits: unitsState,
            ),
          _ => _data,
        };
      },
    );
  }

  void _updateMarkers<CasualMatchMarkers>({
    required covariant markersState,
  }) {
    setState(
      () {
        _data = switch (_stage) {
          CasualMatchTwoPlayerStage.p1MarkerPlacement =>
            CasualMatchData.copyWith(
              _data,
              playerOneMarkers: markersState,
            ),
          CasualMatchTwoPlayerStage.p2MarkerPlacement =>
            CasualMatchData.copyWith(
              _data,
              playerTwoMarkers: markersState,
            ),
          _ => _data,
        };
      },
    );
  }

  @override
  Widget build(
    context,
  ) =>
      Scaffold(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onPrimaryContainer,
        body: switch (_stage) {
          CasualMatchTwoPlayerStage.p1UnitPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .p1PlacingTitle,
                ),
                Expanded(
                  child: UnitPlacementView(
                    GameBoardSize.small,
                    unitsState: _data.data.playerOneUnits,
                    onChange: _updateUnits,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchTwoPlayerStage.p2UnitPlacement;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchTwoPlayerStage.p2UnitPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .p2PlacingTitle,
                ),
                Expanded(
                  child: UnitPlacementView(
                    GameBoardSize.small,
                    unitsState: _data.data.playerTwoUnits,
                    onChange: _updateUnits,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchTwoPlayerStage.p1MarkerPlacement;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchTwoPlayerStage.p1MarkerPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .p1GuessingTitle,
                ),
                Expanded(
                  child: MarkerPlacementView(
                    GameBoardSize.small,
                    4,
                    markersState: _data.data.playerOneMarkers,
                    onChange: _updateMarkers,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchTwoPlayerStage.p2MarkerPlacement;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchTwoPlayerStage.p2MarkerPlacement => Column(
              children: [
                ScreenTitleSolo(
                  AppLocalizations.of(
                    context,
                  )!
                      .p2GuessingTitle,
                ),
                Expanded(
                  child: MarkerPlacementView(
                    GameBoardSize.small,
                    4,
                    markersState: _data.data.playerTwoMarkers,
                    onChange: _updateMarkers,
                    onDone: () => setState(
                      () {
                        _stage = CasualMatchTwoPlayerStage.results;
                      },
                    ),
                  ),
                ),
              ],
            ),
          CasualMatchTwoPlayerStage.results => FutureBuilder(
              future: Future<
                  (
                    CasualMatchUnits,
                    CasualMatchMarkers,
                  )?>.delayed(
                const Duration(
                  milliseconds: 200,
                ),
                () {
                  return null;
                },
              ),
              builder: (
                _,
                snapshot,
              ) =>
                  Column(
                children: [
                  ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .resultsTitle,
                    showingResults: true,
                  ),
                  Expanded(
                    child: ResultsView(
                      GameBoardSize.small,
                      isPlayingSolo: true,
                      matchData: switch (snapshot.data) {
                        _ => _data,
                      },
                      onDone: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
        },
      );
}
