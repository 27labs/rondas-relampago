import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';

import 'package:http/http.dart' as http;

// Owned
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';
import 'package:rondas_relampago/source/pages/utils/screen_title.dart';
import 'package:rondas_relampago/source/views/marker_views.dart';
import 'package:rondas_relampago/source/views/result_views.dart';
import 'package:rondas_relampago/source/views/unit_views.dart';
import 'package:game_common/game_common.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

enum CasualOnlineMatchStage {
  unitPlacement,
  markerPlacement,
  results,
}

class CasualOnlineMatch extends StatefulWidget {
  // final ({void Function(int) updateCasualScoreBy})? singleplayer;
  final String? submittedRoomId;
  final GameAudioSettings Function() onVolumeToggled;
  const CasualOnlineMatch({
    // this.singleplayer,
    this.submittedRoomId,
    required this.onVolumeToggled,
    super.key,
  });

  @override
  State<CasualOnlineMatch> createState() => CasualOnlineMatchState();
}

class CasualOnlineMatchState extends State<CasualOnlineMatch> {
  CasualOnlineMatchStage _stage = CasualOnlineMatchStage.unitPlacement;
  CasualMatchData _data = const CasualMatchData();

  GameAuth _id = GameAuth.init();
  WebSocketChannel? _serverConnection;
  MatchMessage _lastMessage = const MatchMessage(
    textMessage: "> GAME STARTING IN... <",
  );
  ServerPlayMessage? _finalPlays;

  // bool _serverReady = false;

  void _submitPlays() async {
    try {
      await _serverConnection?.ready;
    } catch (e) {
      // _serverReady = false;
      debugPrint(['Fail', e.toString()].toString());
      return;
    }

    _serverConnection?.sink.add(
      jsonEncode(
        GameCommunicationMessage.toJson(
          MatchPlayMessage(
            playerPlay: (
              markers: _data.playerOneTargets,
              units: _data.playerOneUnits,
            ),
          ),
        ),
      ),
    );

    // _serverReady = true;
    debugPrint('True');
  }

  Future<void> _pingServer() async => debugPrint(
        (
          await http.get(
            Uri.parse(
              'http://127.0.0.1:8080/',
            ),
          ),
        ).toString(),
      );

  @override
  void initState() {
    super.initState();
    final id = _id.copyWith(
      roomId: widget.submittedRoomId,
    );
    _pingServer();
    _serverConnection = WebSocketChannel.connect(
      Uri.parse(
        'ws://127.0.0.1:8080/ws',
      ),
    )..sink.add(
        jsonEncode(
          GameCommunicationMessage.toJson(
            ConnectionMessage(
              id: id,
            ),
          ),
        ),
      );
    // _setServerReadyFlag();
  }

  @override
  void dispose() {
    _serverConnection?.sink.close();
    super.dispose();
  }

  void _updateUnits<CasualMatchUnits>({
    required covariant unitsState,
  }) {
    setState(
      () {
        _data = switch (_stage) {
          CasualOnlineMatchStage.unitPlacement => CasualMatchData.copyWith(
              _data,
              playerOneUnits: unitsState,
            ),
          CasualOnlineMatchStage.results => CasualMatchData.copyWith(
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
          CasualOnlineMatchStage.markerPlacement => CasualMatchData.copyWith(
              _data,
              playerOneMarkers: markersState,
            ),
          CasualOnlineMatchStage.results => CasualMatchData.copyWith(
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
        body: StreamBuilder(
          stream: _serverConnection?.stream,
          builder: (
            _,
            snapshot,
          ) {
            if (snapshot.hasData)
              switch (GameCommunicationMessage.fromJson(
                jsonDecode(
                  snapshot.data,
                ),
              )) {
                case ConnectionMessage message:
                  _id = message.id;
                  break;
                case MatchMessage message:
                  _lastMessage = message;
                  break;
                case ServerPlayMessage message:
                  if (_finalPlays == null)
                    // setState(() {
                    _finalPlays = message;
                // });
                case _:
                  break;
              }

            return switch (_stage) {
              CasualOnlineMatchStage.unitPlacement => Column(
                  children: [
                    SizedBox(
                      height: 65,
                      child: ScreenTitleSolo(
                        AppLocalizations.of(
                          context,
                        )!
                            .playerPlacingTitle,
                        onVolumeToggled: widget.onVolumeToggled,
                      ),
                    ),
                    Expanded(
                      child: UnitPlacementView(
                        GameBoardSize.small,
                        unitsState: _data.data.playerOneUnits,
                        onChange: _updateUnits,
                        onDone: () => setState(
                          () {
                            _stage = CasualOnlineMatchStage.markerPlacement;
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          height: 90,
                          width: 480,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary.withOpacity(
                                        0.5,
                                      )),
                              onPressed: () => Clipboard.setData(ClipboardData(
                                text: _id.roomId ??
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .inNoGameRoomText,
                              )).then((_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(AppLocalizations.of(
                                  context,
                                )!
                                            .roomIdCopiedText)));
                              }),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          _id.roomId ??
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .inNoGameRoomText,
                                          softWrap: false,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    const Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.copy_sharp),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              CasualOnlineMatchStage.markerPlacement => Column(
                  children: [
                    SizedBox(
                      height: 65,
                      child: ScreenTitleSolo(
                        AppLocalizations.of(
                          context,
                        )!
                            .playerGuessingTitle,
                        onVolumeToggled: widget.onVolumeToggled,
                      ),
                    ),
                    Expanded(
                      child: MarkerPlacementView(
                        GameBoardSize.small,
                        4,
                        markersState: _data.data.playerOneMarkers,
                        onChange: _updateMarkers,
                        onDone: () => setState(
                          () {
                            _submitPlays();
                            _stage = CasualOnlineMatchStage.results;
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          height: 90,
                          width: 480,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary.withOpacity(
                                        0.5,
                                      )),
                              onPressed: () => Clipboard.setData(ClipboardData(
                                text: _id.roomId ??
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .inNoGameRoomText,
                              )).then((_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(AppLocalizations.of(
                                  context,
                                )!
                                            .roomIdCopiedText)));
                              }),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _id.roomId ??
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .inNoGameRoomText,
                                            softWrap: false,
                                          ),
                                        ),
                                      ),
                                      const Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Icon(Icons.copy_sharp),
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              CasualOnlineMatchStage.results => Column(
                  children: [
                    ScreenTitleSolo(
                      AppLocalizations.of(
                        context,
                      )!
                          .resultsTitle,
                      showingResults: true,
                      onVolumeToggled: widget.onVolumeToggled,
                    ),
                    Expanded(
                      child: ResultsView(
                        GameBoardSize.small,
                        matchData: switch (_finalPlays) {
                          null => CasualMatchData(
                              playerOneUnits: _data.playerOneUnits,
                              playerTwoUnits: null,
                              playerOneMarkers: _data.playerOneTargets,
                              playerTwoMarkers: null,
                            ),
                          ServerPlayMessage play => switch (
                                _id.id == play.player1Play.id) {
                              true => CasualMatchData(
                                  playerOneUnits: play.player1Play.units
                                      as CasualMatchUnits,
                                  playerTwoUnits: play.player2Play.units
                                      as CasualMatchUnits,
                                  playerOneMarkers: play.player1Play.markers,
                                  playerTwoMarkers: play.player2Play.markers,
                                ),
                              _ => CasualMatchData(
                                  playerOneUnits: play.player2Play.units
                                      as CasualMatchUnits,
                                  playerTwoUnits: play.player1Play.units
                                      as CasualMatchUnits,
                                  playerOneMarkers: play.player2Play.markers,
                                  playerTwoMarkers: play.player1Play.markers,
                                ),
                            }
                        },
                        onDone: () => context.pop(),
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          height: 90,
                          width: 480,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary.withOpacity(
                                        0.5,
                                      )),
                              onPressed: () => Clipboard.setData(ClipboardData(
                                text: _id.roomId ??
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .inNoGameRoomText,
                              )).then((_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(AppLocalizations.of(
                                  context,
                                )!
                                            .roomIdCopiedText)));
                              }),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _id.roomId ??
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .inNoGameRoomText,
                                            softWrap: false,
                                          ),
                                        ),
                                      ),
                                      const Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Icon(Icons.copy_sharp),
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            };
          },
        ),
      );
}

class CasualMatch extends StatefulWidget {
  final ({void Function(int) updateCasualScoreBy})? singleplayer;
  final GameAudioSettings Function() onVolumeToggled;
  const CasualMatch({
    this.singleplayer,
    required this.onVolumeToggled,
    super.key,
  });
  @override
  State<CasualMatch> createState() => switch (singleplayer) {
        null => CasualMatchMultiplayerState(),
        _ => CasualMatchState(
            updateCasualScoreBy: singleplayer!.updateCasualScoreBy,
          ),
      };
}

class CasualMatchState extends State<CasualMatch> {
  final void Function(int) updateCasualScoreBy;
  CasualMatchState({
    required this.updateCasualScoreBy,
  });
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
                SizedBox(
                  height: 80,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .playerPlacingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          CasualMatchStage.markerPlacement => Column(
              children: [
                SizedBox(
                  height: 80,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .playerGuessingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
                  Expanded(
                    child: ResultsView(
                      GameBoardSize.small,
                      isPlayingSolo: (updateCasualScoreBy: updateCasualScoreBy),
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
                  // const SizedBox(
                  //   height: 20,
                  // ),
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
                SizedBox(
                  height: 65,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .p1PlacingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                SizedBox(
                  height: 65,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .p2PlacingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                SizedBox(
                  height: 65,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .p1GuessingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                SizedBox(
                  height: 65,
                  child: ScreenTitleSolo(
                    AppLocalizations.of(
                      context,
                    )!
                        .p2GuessingTitle,
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
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
                    onVolumeToggled: widget.onVolumeToggled,
                  ),
                  Expanded(
                    child: ResultsView(
                      GameBoardSize.small,
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
