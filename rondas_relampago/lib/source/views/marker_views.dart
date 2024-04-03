import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

// Owned
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/gameplay_features.dart';
import 'package:rondas_relampago/source/models/gameplay/marker_painter.dart';
import 'package:rondas_relampago/source/views/game_table.dart';

class MarkerPlacementView extends StatelessWidget {
  final GameBoardSize boardSize;
  final MatchMarkers markersState;
  final int markersMaxAmount;
  final void Function<T>({
    required T markersState,
  }) onChange;
  final void Function() onDone;
  const MarkerPlacementView(
    this.boardSize,
    this.markersMaxAmount, {
    required this.markersState,
    required this.onChange,
    required this.onDone,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    void onTouch({
      required int x,
      required int y,
    }) {
      MatchMarkers newMarkersState = {
        GameMarker(
          xCoordinate: x,
          yCoordinate: y,
        )
      };
      for (GameMarker marker in markersState) {
        if (newMarkersState.contains(
          marker,
        )) {
          newMarkersState.remove(
            marker,
          );
        } else {
          newMarkersState.add(
            marker,
          );
        }
      }

      if (newMarkersState.length > markersMaxAmount)
        return debugPrint(MarkersLimitReachedException().toString());

      onChange(
        markersState: newMarkersState,
      );
    }

    FocusNode theFocusNode = FocusNode();

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameTable(
                columns: boardSize.x,
                rows: boardSize.y,
              ),
              MarksPainter(
                markersState,
                boardColumns: boardSize.x,
                boardRows: boardSize.y,
              ),
              Focus.withExternalFocusNode(
                focusNode: theFocusNode,
                child: GameTableMarkersInput(
                  onTouch,
                  markersState,
                  columns: boardSize.x,
                  rows: boardSize.y,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(
            10,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .markersLeft,
                      style: Theme.of(
                        context,
                      ).textTheme.headline6!.copyWith(
                            color: Theme.of(
                              context,
                            ).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "${4 - markersState.length}",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(
                            color: Theme.of(
                              context,
                            ).errorColor,
                          ),
                    ),
                  ],
                ),
                markersState.length >= 4
                    ? CallbackShortcuts(
                        bindings: {
                          const SingleActivator(
                            LogicalKeyboardKey.enter,
                            includeRepeats: false,
                          ): () {
                            onDone();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.numpadEnter,
                            includeRepeats: false,
                          ): () {
                            onDone();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.gameButtonSelect,
                            includeRepeats: false,
                          ): () {
                            onDone();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.gameButtonStart,
                            includeRepeats: false,
                          ): () {
                            context.pop();
                          },
                        },
                        child: Focus(
                          focusNode: theFocusNode,
                          child: TextButton(
                            onPressed: () {
                              onDone();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    5.0,
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).errorColor,
                              ),
                              margin: const EdgeInsets.only(
                                left: 15,
                              ),
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .continueText,
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
                      )
                    : CallbackShortcuts(
                        bindings: {
                          const SingleActivator(
                            LogicalKeyboardKey.gameButtonStart,
                            includeRepeats: false,
                          ): () {
                            context.pop();
                          },
                        },
                        child: Focus(
                          focusNode: theFocusNode,
                          child: TextButton(
                            onPressed: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    5.0,
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor,
                              ),
                              margin: const EdgeInsets.only(
                                left: 15,
                              ),
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .continueText,
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
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
