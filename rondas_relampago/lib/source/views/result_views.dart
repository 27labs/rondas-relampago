import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

// Owned
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/unit_painter.dart';
import 'package:rondas_relampago/source/models/gameplay/gameplay_features.dart';
import 'package:rondas_relampago/source/models/gameplay/marker_painter.dart';
import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/storage/storage.dart';
import 'package:rondas_relampago/source/views/game_table.dart';

class ResultsView extends ConsumerStatefulWidget {
  final GameBoardSize boardSize;
  final MatchData matchData;
  final void Function() onDone;
  final bool isPlayingSolo;
  const ResultsView(
    this.boardSize, {
    required this.isPlayingSolo,
    required this.matchData,
    required this.onDone,
    super.key,
  });

  @override
  ConsumerState<ResultsView> createState() => ResultsViewState();
}

enum PlayerBoard {
  playerOne,
  playerTwo,
}

enum ResultsText {
  p1IsWinner,
  p2IsWinner,
  playerIsWinner,
  computerIsWinner,
  coinFlipHeads,
  coinFlipTails,
  thanks
}

class ResultsViewState extends ConsumerState<ResultsView> {
  // PlayerBoard _selectedPlayerBoard = PlayerBoard.playerTwo;

  late PlayerBoard _calculatedLoserBoard;

  late ResultsText _resultsMessage;

  ResultsText get _calculateWinner {
    int playerOneScore = 0;
    int playerOneHits = 0;
    int playerTwoScore = 0;
    int playerTwoHits = 0;

    for (GameUnit unit in widget.matchData.playerOneUnits.data) {
      if (unit.hitBox
          .intersection(
            widget.matchData.playerTwoTargets,
          )
          .isNotEmpty) {
        playerTwoScore += 5 - unit.hitBox.length;
        playerTwoHits++;
      }
    }
    for (GameUnit unit in widget.matchData.playerTwoUnits.data) {
      if (unit.hitBox
          .intersection(
            widget.matchData.playerOneTargets,
          )
          .isNotEmpty) {
        playerOneScore += 5 - unit.hitBox.length;
        playerOneHits++;
      }
    }
    if (!widget.isPlayingSolo) {
      if (playerOneHits > playerTwoHits) {
        // _selectedPlayerBoard = PlayerBoard.playerTwo;
        _calculatedLoserBoard = PlayerBoard.playerTwo;
        return ResultsText.p1IsWinner;
      }
      if (playerOneHits < playerTwoHits) {
        // _selectedPlayerBoard = PlayerBoard.playerOne;
        _calculatedLoserBoard = PlayerBoard.playerOne;
        return ResultsText.p2IsWinner;
      }
      if (playerOneScore > playerTwoScore) {
        // _selectedPlayerBoard = PlayerBoard.playerTwo;
        _calculatedLoserBoard = PlayerBoard.playerTwo;
        return ResultsText.p1IsWinner;
      }
      if (playerOneScore < playerTwoScore) {
        // _selectedPlayerBoard = PlayerBoard.playerOne;
        _calculatedLoserBoard = PlayerBoard.playerOne;
        return ResultsText.p2IsWinner;
      }
    } else {
      if (playerOneHits > playerTwoHits) {
        // _selectedPlayerBoard = PlayerBoard.playerTwo;
        _calculatedLoserBoard = PlayerBoard.playerTwo;
        switch (ref.read(
          sharedPreferencesProvider,
        )) {
          case AsyncData(
              :final value,
            ):
            value.setInt(
              StoredValuesKeys.casualWins.storageKey,
              value.getInt(
                    StoredValuesKeys.casualWins.storageKey,
                  ) ??
                  0 + 1,
            );
        }
        return ResultsText.playerIsWinner;
      }
      if (playerOneHits < playerTwoHits) {
        // _selectedPlayerBoard = PlayerBoard.playerOne;
        _calculatedLoserBoard = PlayerBoard.playerOne;
        return ResultsText.computerIsWinner;
      }
      if (playerOneScore > playerTwoScore) {
        // _selectedPlayerBoard = PlayerBoard.playerTwo;
        _calculatedLoserBoard = PlayerBoard.playerTwo;
        switch (ref.read(
          sharedPreferencesProvider,
        )) {
          case AsyncData(
              :final value,
            ):
            value.setInt(
              StoredValuesKeys.casualWins.storageKey,
              value.getInt(
                    StoredValuesKeys.casualWins.storageKey,
                  ) ??
                  0 + 1,
            );
        }
        return ResultsText.playerIsWinner;
      }
      if (playerOneScore < playerTwoScore) {
        // _selectedPlayerBoard = PlayerBoard.playerOne;
        _calculatedLoserBoard = PlayerBoard.playerOne;
        return ResultsText.computerIsWinner;
      }
    }
    int totallyRandomCoinFlip = DateTime.now().millisecond % 5;
    if (totallyRandomCoinFlip < 2) {
      // _selectedPlayerBoard = PlayerBoard.playerTwo;
      _calculatedLoserBoard = PlayerBoard.playerTwo;
      return ResultsText.coinFlipHeads;
    }
    if (totallyRandomCoinFlip < 4) {
      // _selectedPlayerBoard = PlayerBoard.playerOne;
      _calculatedLoserBoard = PlayerBoard.playerOne;
      return ResultsText.coinFlipTails;
    }

    _calculatedLoserBoard = PlayerBoard.playerTwo;
    return ResultsText.thanks;
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   setState(() {
  //     _resultsMessage = _calculateWinner;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _resultsMessage = _calculateWinner;
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    _resultsMessage = _calculateWinner;
  }

  @override
  Widget build(
    context,
  ) {
    const gap = SizedBox(
      width: 50,
    );
    const boardGap = SizedBox(
      height: 2,
    );

    final resultsScrollController = ScrollController();

    const textHeight = 20;

    final resultsMessage = switch (_resultsMessage) {
      ResultsText.coinFlipHeads => AppLocalizations.of(context)!.coinFlipHeads,
      ResultsText.coinFlipTails => AppLocalizations.of(context)!.coinFlipTails,
      ResultsText.computerIsWinner =>
        AppLocalizations.of(context)!.computerIsWinner,
      ResultsText.p1IsWinner => AppLocalizations.of(context)!.p1IsWinner,
      ResultsText.p2IsWinner => AppLocalizations.of(context)!.p2IsWinner,
      ResultsText.playerIsWinner =>
        AppLocalizations.of(context)!.playerIsWinner,
      ResultsText.thanks => AppLocalizations.of(context)!.thanks,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: LayoutBuilder(builder: (
        context,
        constraints,
      ) {
        const duration = Duration(
          milliseconds: 400,
        );
        const curve = ElasticInOutCurve();
        const playerNameWidth = 77.0;

        final arrowGap = SizedBox(
          width: min(
              (constraints.maxWidth / widget.boardSize.x) *
                  widget.boardSize.y *
                  .1,
              (constraints.maxHeight - 130) * .1),
        );

        Future<void> scrollToWinner() => resultsScrollController.animateTo(
              resultsScrollController.position.minScrollExtent,
              duration: duration,
              curve: curve,
            );

        Future<void> scrollToLoser() => resultsScrollController.animateTo(
              resultsScrollController.position.maxScrollExtent,
              duration: duration,
              curve: curve,
            );

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            boardGap,
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                height: min(
                    (constraints.maxWidth / widget.boardSize.x) *
                        widget.boardSize.y,
                    constraints.maxHeight - 130),
                width: constraints.maxWidth - 20,
                child: Center(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: resultsScrollController,
                    shrinkWrap: true,
                    children: switch (_calculatedLoserBoard) {
                      PlayerBoard.playerOne => [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: min(
                                  (constraints.maxWidth / widget.boardSize.x) *
                                          widget.boardSize.y -
                                      39 -
                                      textHeight,
                                  constraints.maxHeight - 160 - textHeight,
                                ),
                                width: min(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight - 180,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    GameTable(
                                      columns: widget.boardSize.x,
                                      rows: widget.boardSize.y,
                                    ),
                                    UnitsPainter(
                                      widget.matchData.playerOneUnits,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                    MarksPainter(
                                      widget.matchData.playerTwoTargets,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                height: 40,
                                width: 280,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: playerNameWidth,
                                      child: Center(
                                        child: switch (widget.isPlayingSolo) {
                                          true => Text(
                                              '${AppLocalizations.of(
                                                context,
                                              )!.computer} 👑',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                            ),
                                          _ => Text(
                                              '${AppLocalizations.of(
                                                context,
                                              )!.playerTwo} 👑',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                            ),
                                        },
                                      ),
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: 40,
                                      child: MaterialButton(
                                        padding: const EdgeInsets.all(
                                          0,
                                        ),
                                        onPressed: () => scrollToLoser(),
                                        child: Icon(
                                          Icons.arrow_right_rounded,
                                          semanticLabel: AppLocalizations.of(
                                            context,
                                          )!
                                              .checkLoserBoard,
                                          color: Theme.of(
                                            context,
                                          ).primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: min(
                              constraints.maxWidth * 0.1,
                              30,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: min(
                                  (constraints.maxWidth / widget.boardSize.x) *
                                          widget.boardSize.y -
                                      39 -
                                      textHeight,
                                  constraints.maxHeight - 160 - textHeight,
                                ),
                                width: min(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight - 180,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    GameTable(
                                      columns: widget.boardSize.x,
                                      rows: widget.boardSize.y,
                                    ),
                                    UnitsPainter(
                                      widget.matchData.playerTwoUnits,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                    MarksPainter(
                                      widget.matchData.playerOneTargets,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                height: 40,
                                width: 280,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: MaterialButton(
                                        padding: const EdgeInsets.all(
                                          0,
                                        ),
                                        onPressed: () => scrollToWinner(),
                                        child: Icon(
                                          Icons.arrow_left_rounded,
                                          semanticLabel: AppLocalizations.of(
                                            context,
                                          )!
                                              .checkWinnerBoard,
                                          color: Theme.of(
                                            context,
                                          ).primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: playerNameWidth,
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!
                                              .playerOne,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge!.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                        ),
                                      ),
                                    ),
                                    arrowGap,
                                    const SizedBox(
                                      width: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      PlayerBoard.playerTwo => [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: min(
                                  (constraints.maxWidth / widget.boardSize.x) *
                                          widget.boardSize.y -
                                      39 -
                                      textHeight,
                                  constraints.maxHeight - 160 - textHeight,
                                ),
                                width: min(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight - 180,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    GameTable(
                                      columns: widget.boardSize.x,
                                      rows: widget.boardSize.y,
                                    ),
                                    UnitsPainter(
                                      widget.matchData.playerOneUnits,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                    MarksPainter(
                                      widget.matchData.playerTwoTargets,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                height: 40,
                                width: 280,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: playerNameWidth,
                                      child: Center(
                                        child: Text(
                                          '${AppLocalizations.of(
                                            context,
                                          )!.playerOne} 👑',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge!.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                        ),
                                      ),
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: 40,
                                      child: MaterialButton(
                                        padding: const EdgeInsets.all(
                                          0,
                                        ),
                                        onPressed: () => scrollToLoser(),
                                        child: Icon(
                                          Icons.arrow_right_rounded,
                                          semanticLabel: AppLocalizations.of(
                                            context,
                                          )!
                                              .checkLoserBoard,
                                          color: Theme.of(
                                            context,
                                          ).primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: min(
                              constraints.maxWidth * 0.1,
                              30,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: min(
                                  (constraints.maxWidth / widget.boardSize.x) *
                                          widget.boardSize.y -
                                      39 -
                                      textHeight,
                                  constraints.maxHeight - 160 - textHeight,
                                ),
                                width: min(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight - 180,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    GameTable(
                                      columns: widget.boardSize.x,
                                      rows: widget.boardSize.y,
                                    ),
                                    UnitsPainter(
                                      widget.matchData.playerTwoUnits,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                    MarksPainter(
                                      widget.matchData.playerOneTargets,
                                      boardColumns: widget.boardSize.x,
                                      boardRows: widget.boardSize.y,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                height: 40,
                                width: 280,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: MaterialButton(
                                        padding: const EdgeInsets.all(
                                          0,
                                        ),
                                        onPressed: () => scrollToWinner(),
                                        child: Icon(
                                          Icons.arrow_left_rounded,
                                          semanticLabel: AppLocalizations.of(
                                            context,
                                          )!
                                              .checkWinnerBoard,
                                          color: Theme.of(
                                            context,
                                          ).primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    arrowGap,
                                    SizedBox(
                                      width: playerNameWidth,
                                      child: Center(
                                        child: switch (widget.isPlayingSolo) {
                                          true => Text(
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .computer,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                            ),
                                          _ => Text(
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .playerTwo,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                            ),
                                        },
                                      ),
                                    ),
                                    arrowGap,
                                    const SizedBox(
                                      width: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                    },
                  ),
                ),
              ),
            ),
            boardGap,
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    5,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      resultsMessage,
                      style: Theme.of(
                        context,
                      ).textTheme.headline5?.copyWith(
                            color: Theme.of(
                              context,
                            ).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(
                            LogicalKeyboardKey.enter,
                            includeRepeats: false,
                          ): () {
                            context.pop();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.numpadEnter,
                            includeRepeats: false,
                          ): () {
                            context.pop();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.gameButtonStart,
                            includeRepeats: false,
                          ): () {
                            context.pop();
                          },
                        },
                        child: Focus(
                          autofocus: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              gap,
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                        5.0,
                                      ),
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).shadowColor,
                                  ),
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .mainMenu,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              gap,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
