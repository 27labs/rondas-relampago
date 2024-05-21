import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_common/game_common.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit_renderer.dart';
// import 'package:rondas_relampago/source/game_units/game_unit.dart';

class GameTable extends StatelessWidget {
  final int columns;
  final int rows;
  const GameTable({
    required this.columns,
    required this.rows,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const SizedBox horizontalGap = SizedBox(
      width: 0.1,
      height: 0,
    );
    const SizedBox verticalGap = SizedBox(
      width: 0,
      height: 0.1,
    );
    // int gameTableArea = rows * columns;
    List<Widget> column = [];
    column.add(
      verticalGap,
    );
    for (int i = 0; i < rows; i++,) {
      List<Widget> row = [];
      row.add(
        horizontalGap,
      );
      for (int j = 0; j < columns; j++,) {
        row.add(
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    0.21,
                  ),
                ),
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.5),
              ),
              // margin: EdgeInsets.all((gameTableArea / 1000) * 2),
            ),
          ),
        );
        row.add(
          horizontalGap,
        );
      }
      column.add(
        Expanded(
          child: Row(
            children: row,
          ),
        ),
      );
      column.add(
        verticalGap,
      );
    }
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.all(
          0.05,
        ),
        height: rows.toDouble(),
        width: columns.toDouble(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: column,
        ),
      ),
    );
  }
}

class GameTableUnitsInput extends StatelessWidget {
  final int columns;
  final int rows;
  final void Function({
    required int x,
    required int y,
    bool dropped,
  }) onTouch;
  final void Function({
    GameUnitSize size,
    GameUnitOrientation orientation,
  }) onKindOfDraggedSelection;
  final MatchUnits unitsState;
  const GameTableUnitsInput(
    this.onTouch,
    this.onKindOfDraggedSelection,
    this.unitsState, {
    required this.columns,
    required this.rows,
    super.key,
  });

  @override
  Widget build(
    _,
  ) =>
      LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          const double draggableSize = 60;
          const double draggableOffset = 25;
          const double originFactorForPaint = 2;
          final scale = min(
            ((constraints.maxHeight - 0.0000005 * (rows - 1)) / rows) * 0.015,
            ((constraints.maxWidth - 0.0000005 * (columns - 1)) / columns) *
                0.015,
          );
          List<Widget> column = [];
          // column.add(verticalGap);
          for (int i = 0; i < rows; i++,) {
            List<Widget> row = [];
            // row.add(horizontalGap);
            for (int j = 0; j < columns; j++,) {
              row.add(
                Expanded(
                  child: DragTarget(
                    onAcceptWithDetails: (
                      data,
                    ) {
                      if (!unitsState.hitBoxes.contains(
                        GameMarker(
                          xCoordinate: j,
                          yCoordinate: i,
                        ),
                      ))
                        onTouch(
                          x: j,
                          y: i,
                          dropped: true,
                        );
                    },
                    builder: ((
                      context,
                      candidateData,
                      rejectedData,
                    ) {
                      return Draggable(
                        data: switch (unitsState.collided(
                          GameMarker(
                            xCoordinate: j,
                            yCoordinate: i,
                          ),
                        )) {
                          GameUnit(
                            :final orientation,
                          ) =>
                            orientation == GameUnitOrientation.horizontal
                                ? AppLocalizations.of(
                                    context,
                                  )!
                                    .thisIsASmallHorizontalPiece
                                : AppLocalizations.of(
                                    context,
                                  )!
                                    .thisIsASmallVerticalPiece,
                          _ => null,
                        },
                        dragAnchorStrategy: (
                          draggable,
                          context,
                          offset,
                        ) {
                          return Offset.zero;
                        },
                        onDragStarted: () {
                          final unit = unitsState.collided(
                            GameMarker(
                              xCoordinate: j,
                              yCoordinate: i,
                            ),
                          );
                          if (unit != null) {
                            onKindOfDraggedSelection(
                              size: unit.size,
                              orientation: unit.orientation,
                            );
                            onTouch(
                              x: j,
                              y: i,
                            );
                          }
                        },
                        feedbackOffset: switch (unitsState.collided(
                          GameMarker(
                            xCoordinate: j,
                            yCoordinate: i,
                          ),
                        )) {
                          GameUnit(
                            :final orientation,
                            :final hitBox,
                          ) =>
                            orientation == GameUnitOrientation.horizontal
                                ? Offset(
                                    scale * hitBox.length * -draggableOffset,
                                    0,
                                  )
                                : Offset(
                                    0,
                                    scale * hitBox.length * -draggableOffset,
                                  ),
                          _ => Offset.zero,
                        },
                        feedback: Transform.scale(
                          origin: switch (unitsState.collided(
                            GameMarker(
                              xCoordinate: j,
                              yCoordinate: i,
                            ),
                          )) {
                            GameUnit(
                              :final orientation,
                              :final hitBox,
                            ) =>
                              orientation == GameUnitOrientation.horizontal
                                  ? Offset(
                                      -draggableSize,
                                      -draggableSize *
                                          hitBox.length /
                                          originFactorForPaint,
                                    )
                                  : Offset(
                                      -draggableSize *
                                          hitBox.length /
                                          originFactorForPaint,
                                      -draggableSize,
                                    ),
                            _ => Offset.zero,
                          },
                          scale: scale,
                          child: switch (unitsState.collided(
                            GameMarker(
                              xCoordinate: j,
                              yCoordinate: i,
                            ),
                          )) {
                            GameUnit(
                              :final orientation,
                              :final size,
                              :final hitBox,
                            ) =>
                              orientation == GameUnitOrientation.horizontal
                                  ? SizedBox(
                                      width: draggableSize * hitBox.length,
                                      height: draggableSize * hitBox.length,
                                      child:
                                          RenderedGameUnit.renderHorizontalUnit(
                                        size,
                                      ),
                                    )
                                  : SizedBox(
                                      height: draggableSize * hitBox.length,
                                      width: draggableSize * hitBox.length,
                                      child:
                                          RenderedGameUnit.renderVerticalUnit(
                                        size,
                                      ),
                                    ),
                            _ => null
                          },
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                            // overlayColor: MaterialStateProperty.all(
                            //     Color.fromARGB(170, 0, 0, 0))
                          ),
                          onPressed: () {
                            debugPrint(scale.toString());
                            onTouch(
                              x: j,
                              y: i,
                              dropped: !unitsState.hitBoxes.contains(
                                GameMarker(
                                  xCoordinate: j,
                                  yCoordinate: i,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  0.000000001,
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.all(
                              0.0000005,
                            ),
                            child: Text(
                              '',
                              semanticsLabel: '${AppLocalizations.of(
                                context,
                              )!.wordCoordinate} ($j, $i)',
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
              // row.add(horizontalGap);
            }
            column.add(
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: row,
                ),
              ),
            );
            // column.add(verticalGap);
          }
          return FittedBox(
            fit: BoxFit.contain,
            child: Container(
              padding: const EdgeInsets.all(
                0.05,
              ),
              height: rows.toDouble(),
              width: columns.toDouble(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: column,
              ),
            ),
          );
        },
      );
}

class GameTableMarkersInput extends StatelessWidget {
  final int columns;
  final int rows;
  final void Function({
    required int x,
    required int y,
  }) onTouch;
  final MatchMarkers markersState;
  const GameTableMarkersInput(
    this.onTouch,
    this.markersState, {
    required this.columns,
    required this.rows,
    super.key,
  });

  @override
  Widget build(
    _,
  ) =>
      LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          const double draggableSize = 35;
          // const double draggableOffset = 25;
          // const double originFactorForPaint = 2;
          final scale = min(
            ((constraints.maxHeight - 0.0000005 * (rows - 1)) / rows) * 0.015,
            ((constraints.maxWidth - 0.0000005 * (columns - 1)) / columns) *
                0.015,
          );
          List<Widget> column = [];
          // column.add(verticalGap);
          for (int i = 0; i < rows; i++,) {
            List<Widget> row = [];
            // row.add(horizontalGap);
            for (int j = 0; j < columns; j++,) {
              row.add(
                Expanded(
                  child: DragTarget(
                    onAcceptWithDetails: (
                      data,
                    ) {
                      if (!markersState.contains(
                        GameMarker(
                          xCoordinate: j,
                          yCoordinate: i,
                        ),
                      ))
                        onTouch(
                          x: j,
                          y: i,
                        );
                    },
                    builder: ((
                      context,
                      candidateData,
                      rejectedData,
                    ) {
                      return Draggable(
                        data: switch (markersState.contains(
                          GameMarker(
                            xCoordinate: j,
                            yCoordinate: i,
                          ),
                        )) {
                          true => AppLocalizations.of(context)!.thisIsAMarker,
                          _ => AppLocalizations.of(context)!.thisIsAMarker,
                        },
                        dragAnchorStrategy: (
                          draggable,
                          context,
                          offset,
                        ) {
                          return Offset.zero;
                        },
                        onDragStarted: () {
                          debugPrint(
                            scale.toString(),
                          );
                          final unit = markersState.contains(
                            GameMarker(
                              xCoordinate: j,
                              yCoordinate: i,
                            ),
                          )
                              ? GameMarker(
                                  xCoordinate: j,
                                  yCoordinate: i,
                                )
                              : null;
                          if (unit != null) {
                            onTouch(
                              x: j,
                              y: i,
                            );
                          }
                        },
                        feedbackOffset: switch (markersState.contains(
                          GameMarker(
                            xCoordinate: j,
                            yCoordinate: i,
                          ),
                        )) {
                          // true => Offset(
                          //     scale * -draggableOffset,
                          //     scale * -draggableOffset,
                          //   ),
                          _ => Offset.zero,
                        },
                        feedback: Transform.translate(
                          offset: Offset(-draggableSize * scale / 2,
                              -draggableSize * scale / 2),
                          child: Container(
                            color: Theme.of(context).colorScheme.primary,
                            height: draggableSize * scale,
                            width: draggableSize * scale,
                          ),
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                            // overlayColor: MaterialStateProperty.all(
                            //     Color.fromARGB(170, 0, 0, 0))
                          ),
                          onPressed: () {
                            // debugPrint(scale.toString());
                            onTouch(
                              x: j,
                              y: i,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  0.000000001,
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.all(
                              0.0000005,
                            ),
                            child: Text(
                              '',
                              semanticsLabel: '${AppLocalizations.of(
                                context,
                              )!.wordCoordinate} ($j, $i)',
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
              // row.add(horizontalGap);
            }
            column.add(
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: row,
                ),
              ),
            );
            // column.add(verticalGap);
          }
          return FittedBox(
            fit: BoxFit.contain,
            child: Container(
              padding: const EdgeInsets.all(
                0.05,
              ),
              height: rows.toDouble(),
              width: columns.toDouble(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: column,
              ),
            ),
          );
        },
      );
}
