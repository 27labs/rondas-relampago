import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

// Owned
import 'package:game_common/game_common.dart';
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/unit_painter.dart';
import 'package:rondas_relampago/source/models/gameplay/marker_painter.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
// import 'package:rondas_relampago/source/storage/storage.dart';
import 'package:rondas_relampago/source/views/game_table.dart';

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

class ResultsView extends StatelessWidget {
  final GameBoardSize boardSize;
  final MatchData matchData;
  final void Function() onDone;
  final ({
    void Function(int) updateCasualScoreBy,
  })? isPlayingSolo;
  const ResultsView(
    this.boardSize, {
    this.isPlayingSolo,
    required this.matchData,
    required this.onDone,
    super.key,
  });

  @override
  Widget build(
    context,
  ) =>
      FutureBuilder(
        future: Future<
            ({
              PlayerBoard calculatedLoserBoard,
              String resultsText,
            })>.delayed(
          const Duration(
            milliseconds: 500,
          ),
          () async {
            int playerOneScore = 0;
            int playerOneHits = 0;
            int playerTwoScore = 0;
            int playerTwoHits = 0;

            for (GameUnit unit in matchData.playerOneUnits.data) {
              if (unit.hitBox
                  .intersection(
                    matchData.playerTwoTargets,
                  )
                  .isNotEmpty) {
                playerTwoScore += 5 - unit.hitBox.length;
                playerTwoHits++;
              }
            }
            for (GameUnit unit in matchData.playerTwoUnits.data) {
              if (unit.hitBox
                  .intersection(
                    matchData.playerOneTargets,
                  )
                  .isNotEmpty) {
                playerOneScore += 5 - unit.hitBox.length;
                playerOneHits++;
              }
            }
            switch (isPlayingSolo) {
              case null:
                if (playerOneHits > playerTwoHits) {
                  // _selectedPlayerBoard = PlayerBoard.playerTwo;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerTwo,
                    resultsText: AppLocalizations.of(context)!.p1IsWinner,
                  );
                }
                if (playerOneHits < playerTwoHits) {
                  // _selectedPlayerBoard = PlayerBoard.playerOne;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerOne,
                    resultsText: AppLocalizations.of(context)!.p2IsWinner,
                  );
                }
                if (playerOneScore > playerTwoScore) {
                  // _selectedPlayerBoard = PlayerBoard.playerTwo;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerTwo,
                    resultsText: AppLocalizations.of(context)!.p1IsWinner,
                  );
                }
                if (playerOneScore < playerTwoScore) {
                  // _selectedPlayerBoard = PlayerBoard.playerOne;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerOne,
                    resultsText: AppLocalizations.of(context)!.p2IsWinner,
                  );
                }
                break;
              case _:
                if (playerOneHits > playerTwoHits) {
                  // _selectedPlayerBoard = PlayerBoard.playerTwo;
                  final resultsText = AppLocalizations.of(
                    context,
                  )!
                      .playerIsWinner;

                  isPlayingSolo!.updateCasualScoreBy(1);

                  return (
                    calculatedLoserBoard: PlayerBoard.playerTwo,
                    resultsText: resultsText,
                  );
                }
                if (playerOneHits < playerTwoHits) {
                  // _selectedPlayerBoard = PlayerBoard.playerOne;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerOne,
                    resultsText: AppLocalizations.of(context)!.computerIsWinner,
                  );
                }
                if (playerOneScore > playerTwoScore) {
                  // _selectedPlayerBoard = PlayerBoard.playerTwo;
                  final resultsText = AppLocalizations.of(
                    context,
                  )!
                      .playerIsWinner;

                  isPlayingSolo!.updateCasualScoreBy(1);

                  return (
                    calculatedLoserBoard: PlayerBoard.playerTwo,
                    resultsText: resultsText,
                  );
                }
                if (playerOneScore < playerTwoScore) {
                  // _selectedPlayerBoard = PlayerBoard.playerOne;
                  return (
                    calculatedLoserBoard: PlayerBoard.playerOne,
                    resultsText: AppLocalizations.of(context)!.computerIsWinner,
                  );
                }
            }
            int totallyRandomCoinFlip = DateTime.now().millisecond % 5;
            if (totallyRandomCoinFlip < 2) {
              // _selectedPlayerBoard = PlayerBoard.playerTwo;
              return (
                calculatedLoserBoard: PlayerBoard.playerTwo,
                resultsText: AppLocalizations.of(context)!.coinFlipHeads,
              );
            }
            if (totallyRandomCoinFlip < 4) {
              // _selectedPlayerBoard = PlayerBoard.playerOne;
              return (
                calculatedLoserBoard: PlayerBoard.playerOne,
                resultsText: AppLocalizations.of(context)!.coinFlipTails,
              );
            }

            return (
              calculatedLoserBoard: PlayerBoard.playerTwo,
              resultsText: AppLocalizations.of(context)!.thanks
            );
          },
        ),
        builder: (
          _,
          snapshot,
        ) {
          const gap = SizedBox(
            width: 50,
          );
          const boardGap = SizedBox(
            height: 2,
          );

          final resultsScrollController = ScrollController();

          const textHeight = 20;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                const duration = Duration(
                  milliseconds: 900,
                );
                const curve = ElasticOutCurve();
                const playerNameWidth = 67.0;

                final arrowGap = SizedBox(
                  width: min(
                      (constraints.maxWidth / boardSize.x) * boardSize.y * .1,
                      (constraints.maxHeight - 130) * .1),
                );

                Future<void> scrollToWinner() =>
                    resultsScrollController.animateTo(
                      resultsScrollController.position.minScrollExtent,
                      duration: duration,
                      curve: curve,
                    );

                Future<void> scrollToLoser() =>
                    resultsScrollController.animateTo(
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
                            (constraints.maxWidth / boardSize.x) * boardSize.y,
                            constraints.maxHeight - 145),
                        width: constraints.maxWidth - 20,
                        child: Center(
                          child: switch (
                              matchData.playerTwoUnits.data.isNotEmpty &&
                                  snapshot.hasData) {
                            false => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            true => ListView(
                                scrollDirection: Axis.horizontal,
                                controller: resultsScrollController,
                                shrinkWrap: true,
                                children: switch (
                                    snapshot.data?.calculatedLoserBoard ??
                                        PlayerBoard.playerTwo) {
                                  PlayerBoard.playerOne => [
                                      SizedBox(
                                        width: min(
                                              constraints.maxWidth * 0.1,
                                              30,
                                            ) /
                                            2,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: min(
                                              (constraints.maxWidth /
                                                          boardSize.x) *
                                                      boardSize.y -
                                                  39 -
                                                  textHeight,
                                              constraints.maxHeight -
                                                  160 -
                                                  textHeight,
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
                                                  columns: boardSize.x,
                                                  rows: boardSize.y,
                                                ),
                                                UnitsPainter(
                                                  matchData.playerOneUnits,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                                MarksPainter(
                                                  matchData.playerTwoTargets,
                                                  hitboxes: matchData
                                                      .playerOneUnits.hitBoxes,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              height: 40,
                                              width: min(
                                                constraints.maxWidth * 0.73,
                                                constraints.maxHeight - 180,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 40,
                                                  ),
                                                  arrowGap,
                                                  SizedBox(
                                                    width: playerNameWidth,
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: switch (
                                                            isPlayingSolo) {
                                                          null => Text(
                                                              '${AppLocalizations.of(
                                                                context,
                                                              )!.playerTwo} 👑',
                                                              style: Theme.of(
                                                                context,
                                                              )
                                                                  .textTheme
                                                                  .titleLarge!
                                                                  .copyWith(
                                                                    color: Theme
                                                                        .of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                            ),
                                                          _ => Text(
                                                              '${AppLocalizations.of(
                                                                context,
                                                              )!.computer} 👑',
                                                              style: Theme.of(
                                                                context,
                                                              )
                                                                  .textTheme
                                                                  .titleLarge!
                                                                  .copyWith(
                                                                    color: Theme
                                                                        .of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                            ),
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  arrowGap,
                                                  SizedBox(
                                                    width: 40,
                                                    child: MaterialButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        0,
                                                      ),
                                                      onPressed: () =>
                                                          scrollToLoser(),
                                                      child: Icon(
                                                        Icons
                                                            .arrow_right_rounded,
                                                        semanticLabel:
                                                            AppLocalizations.of(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: min(
                                              (constraints.maxWidth /
                                                          boardSize.x) *
                                                      boardSize.y -
                                                  39 -
                                                  textHeight,
                                              constraints.maxHeight -
                                                  160 -
                                                  textHeight,
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
                                                  columns: boardSize.x,
                                                  rows: boardSize.y,
                                                ),
                                                UnitsPainter(
                                                  matchData.playerTwoUnits,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                                MarksPainter(
                                                  matchData.playerOneTargets,
                                                  hitboxes: matchData
                                                      .playerTwoUnits.hitBoxes,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              height: 40,
                                              width: min(
                                                constraints.maxWidth * 0.73,
                                                constraints.maxHeight - 180,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    child: MaterialButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        0,
                                                      ),
                                                      onPressed: () =>
                                                          scrollToWinner(),
                                                      child: Icon(
                                                        Icons
                                                            .arrow_left_rounded,
                                                        semanticLabel:
                                                            AppLocalizations.of(
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
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .playerOne,
                                                          style: Theme.of(
                                                            context,
                                                          )
                                                              .textTheme
                                                              .titleLarge!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                              ),
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: min(
                                              constraints.maxWidth * 0.1,
                                              30,
                                            ) /
                                            2,
                                      ),
                                    ],
                                  PlayerBoard.playerTwo => [
                                      SizedBox(
                                        width: min(
                                              constraints.maxWidth * 0.1,
                                              30,
                                            ) /
                                            2,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: min(
                                              (constraints.maxWidth /
                                                          boardSize.x) *
                                                      boardSize.y -
                                                  39 -
                                                  textHeight,
                                              constraints.maxHeight -
                                                  160 -
                                                  textHeight,
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
                                                  columns: boardSize.x,
                                                  rows: boardSize.y,
                                                ),
                                                UnitsPainter(
                                                  matchData.playerTwoUnits,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                                MarksPainter(
                                                  matchData.playerOneTargets,
                                                  hitboxes: matchData
                                                      .playerTwoUnits.hitBoxes,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              height: 40,
                                              width: min(
                                                constraints.maxWidth * 0.73,
                                                constraints.maxHeight - 180,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 40,
                                                  ),
                                                  arrowGap,
                                                  SizedBox(
                                                    width: playerNameWidth,
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: Text(
                                                          '${AppLocalizations.of(
                                                            context,
                                                          )!.playerOne} 👑',
                                                          style: Theme.of(
                                                            context,
                                                          )
                                                              .textTheme
                                                              .titleLarge!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  arrowGap,
                                                  SizedBox(
                                                    width: 40,
                                                    child: MaterialButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        0,
                                                      ),
                                                      onPressed: () =>
                                                          scrollToLoser(),
                                                      child: Icon(
                                                        Icons
                                                            .arrow_right_rounded,
                                                        semanticLabel:
                                                            AppLocalizations.of(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: min(
                                              (constraints.maxWidth /
                                                          boardSize.x) *
                                                      boardSize.y -
                                                  39 -
                                                  textHeight,
                                              constraints.maxHeight -
                                                  160 -
                                                  textHeight,
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
                                                  columns: boardSize.x,
                                                  rows: boardSize.y,
                                                ),
                                                UnitsPainter(
                                                  matchData.playerOneUnits,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                                MarksPainter(
                                                  matchData.playerTwoTargets,
                                                  hitboxes: matchData
                                                      .playerOneUnits.hitBoxes,
                                                  boardColumns: boardSize.x,
                                                  boardRows: boardSize.y,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              height: 40,
                                              width: min(
                                                constraints.maxWidth * 0.73,
                                                constraints.maxHeight - 180,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    child: MaterialButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        0,
                                                      ),
                                                      onPressed: () =>
                                                          scrollToWinner(),
                                                      child: Icon(
                                                        Icons
                                                            .arrow_left_rounded,
                                                        semanticLabel:
                                                            AppLocalizations.of(
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
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: switch (
                                                            isPlayingSolo) {
                                                          null => Text(
                                                              AppLocalizations
                                                                      .of(
                                                                context,
                                                              )!
                                                                  .playerTwo,
                                                              style: Theme.of(
                                                                context,
                                                              )
                                                                  .textTheme
                                                                  .titleLarge!
                                                                  .copyWith(
                                                                    color: Theme
                                                                        .of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                            ),
                                                          _ => Text(
                                                              AppLocalizations
                                                                      .of(
                                                                context,
                                                              )!
                                                                  .computer,
                                                              style: Theme.of(
                                                                context,
                                                              )
                                                                  .textTheme
                                                                  .titleLarge!
                                                                  .copyWith(
                                                                    color: Theme
                                                                        .of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                            ),
                                                        },
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: min(
                                              constraints.maxWidth * 0.1,
                                              30,
                                            ) /
                                            2,
                                      ),
                                    ],
                                },
                              ),
                          },
                        ),
                      ),
                    ),
                    boardGap,
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                switch (
                                    matchData.playerTwoUnits.data.isNotEmpty &&
                                        snapshot.hasData) {
                                  false => AppLocalizations.of(
                                      context,
                                    )!
                                        .calculating,
                                  true => snapshot.data!.resultsText,
                                },
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.contain,
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
                                  child: TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Container(
                                        // width: 200,
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .mainMenu,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
}

class CalculatedBoard extends StatelessWidget {
  final BoxConstraints constraints;
  final GameBoardSize boardSize;
  final int textHeight;
  final MatchData matchData;
  final Widget arrowGap;
  final double playerNameWidth;
  final bool? isPlayingSolo;
  final Record scrollFunctions;
  const CalculatedBoard(
    this.constraints,
    this.boardSize,
    this.textHeight,
    this.matchData,
    this.arrowGap,
    this.playerNameWidth,
    this.isPlayingSolo,
    this.scrollFunctions, {
    super.key,
  });

  @override
  Widget build(context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: min(
              (constraints.maxWidth / boardSize.x) * boardSize.y -
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
                  columns: boardSize.x,
                  rows: boardSize.y,
                ),
                UnitsPainter(
                  matchData.playerOneUnits,
                  boardColumns: boardSize.x,
                  boardRows: boardSize.y,
                ),
                MarksPainter(
                  matchData.playerTwoTargets,
                  hitboxes: matchData.playerOneUnits.hitBoxes,
                  boardColumns: boardSize.x,
                  boardRows: boardSize.y,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Flexible(
            child: SizedBox(
              height: 40,
              width: min(
                constraints.maxWidth * 0.73,
                constraints.maxHeight - 180,
              ),
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
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Center(
                        child: switch (isPlayingSolo) {
                          null => Text(
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
                          _ => Text(
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
                        },
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
                      onPressed: () => scrollFunctions,
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
          ),
        ],
      );
}
