import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class CasualMatch extends StatefulWidget {
  const CasualMatch({super.key});
  @override
  State<CasualMatch> createState() => CasualMatchState();
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
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
                  )>.microtask(
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
