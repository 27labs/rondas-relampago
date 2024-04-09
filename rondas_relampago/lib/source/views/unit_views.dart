import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Owned
import 'package:rondas_relampago/source/models/gameplay/board_sizes.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/unit_painter.dart';
import 'package:rondas_relampago/source/models/gameplay/gameplay_features.dart';
import 'package:rondas_relampago/source/views/game_table.dart';

class UnitPlacementView extends StatefulWidget {
  final GameBoardSize boardSize;
  final MatchUnits unitsState;
  final void Function<T>({
    required T unitsState,
  }) onChange;
  final void Function() onDone;
  const UnitPlacementView(
    this.boardSize, {
    required this.unitsState,
    required this.onChange,
    required this.onDone,
    super.key,
  });

  @override
  State<UnitPlacementView> createState() => UnitPlacementViewState();
}

class UnitPlacementViewState extends State<UnitPlacementView> {
  GameUnitSize _selectedSize = GameUnitSize.small;
  GameUnitOrientation _selectedOrientation = GameUnitOrientation.horizontal;

  @override
  Widget build(
    context,
  ) {
    void onTouch({
      required int x,
      required int y,
      bool dropped = false,
    }) {
      late final MatchUnits newUnitsState;
      if (widget.unitsState.hitBoxes.contains(
        GameMarker(
          xCoordinate: x,
          yCoordinate: y,
        ),
      )) {
        if (!dropped) {
          newUnitsState = MatchUnits.remove(
            widget.unitsState,
            GameMarker(
              xCoordinate: x,
              yCoordinate: y,
            ),
          );
        } else {
          newUnitsState = widget.unitsState;
        }
      } else {
        switch (_selectedOrientation) {
          case GameUnitOrientation.horizontal:
            switch (_selectedSize) {
              case GameUnitSize.small:
                if (x + 2 > widget.boardSize.x)
                  return onTouch(x: x - 1, y: y, dropped: dropped);
              case GameUnitSize.medium:
                if (x + 3 > widget.boardSize.x)
                  return onTouch(x: x - 1, y: y, dropped: dropped);
              case GameUnitSize.large:
                if (x + 4 > widget.boardSize.x)
                  return onTouch(x: x - 1, y: y, dropped: dropped);
            }
            break;
          case GameUnitOrientation.vertical:
            switch (_selectedSize) {
              case GameUnitSize.small:
                if (y + 2 > widget.boardSize.y)
                  return onTouch(x: x, y: y - 1, dropped: dropped);
              case GameUnitSize.medium:
                if (y + 3 > widget.boardSize.y)
                  return onTouch(x: x, y: y - 1, dropped: dropped);
              case GameUnitSize.large:
                if (y + 4 > widget.boardSize.y)
                  return onTouch(x: x, y: y - 1, dropped: dropped);
            }
            break;
        }

        final newUnit = GameUnit.fromSize(
          _selectedSize,
          _selectedOrientation,
          x: x,
          y: y,
        );

        if (widget.unitsState.hitBoxes
            .intersection(
              newUnit.hitBox,
            )
            .isEmpty) {
          newUnitsState = MatchUnits.add(
            widget.unitsState,
            newUnit,
          );
        } else {
          newUnitsState = widget.unitsState;
        }
      }

      setState(
        () {
          if (!newUnitsState.missingSizes.contains(
                _selectedSize,
              ) &&
              newUnitsState.missingSizes.isNotEmpty)
            _selectedSize = newUnitsState.missingSizes.first;
          widget.onChange(
            unitsState: newUnitsState,
          );
        },
      );
    }

    void onKindOfGameUnitSelection({
      GameUnitSize? size,
      GameUnitOrientation? orientation,
    }) {
      final newUnitSize = size ?? _selectedSize;
      final newUnitOrientation = orientation ?? _selectedOrientation;

      setState(() {
        _selectedSize = newUnitSize;
        _selectedOrientation = newUnitOrientation;
      });
    }

    FocusNode theFocusNode = FocusNode();

    Set<GameUnitSize> blockedSizes = {};

    for (final unitSize in widget.unitsState.sizes) {
      if (unitSize != null)
        blockedSizes.add(
          unitSize,
        );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              GameTable(
                columns: widget.boardSize.x,
                rows: widget.boardSize.y,
              ),
              UnitsPainter(
                widget.unitsState,
                boardColumns: widget.boardSize.x,
                boardRows: widget.boardSize.y,
              ),
              Focus.withExternalFocusNode(
                focusNode: theFocusNode,
                child: GameTableUnitsInput(
                  onTouch,
                  onKindOfGameUnitSelection,
                  widget.unitsState,
                  columns: widget.boardSize.x,
                  rows: widget.boardSize.y,
                ),
              ),
            ],
          ),
        ),
        widget.unitsState.isFull
            ? CallbackShortcuts(
                bindings: {
                  const SingleActivator(
                    LogicalKeyboardKey.enter,
                    includeRepeats: false,
                  ): widget.onDone,
                  const SingleActivator(
                    LogicalKeyboardKey.numpadEnter,
                    includeRepeats: false,
                  ): widget.onDone,
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonSelect,
                    includeRepeats: false,
                  ): widget.onDone,
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonStart,
                    includeRepeats: false,
                  ): () => context.pop(),
                },
                child: Focus(
                  autofocus: true,
                  focusNode: theFocusNode,
                  child: TextButton(
                    onPressed: widget.onDone,
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
                      margin: const EdgeInsets.fromLTRB(
                        10,
                        10,
                        10,
                        10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .continueText,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
                    LogicalKeyboardKey.keyA,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.small,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyS,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.medium,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyD,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.large,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyC,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.vertical,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyV,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.horizontal,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonX,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.small,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonY,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.medium,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonB,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      size: GameUnitSize.large,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonRight2,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.vertical,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonRight1,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.horizontal,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonLeft1,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.vertical,
                    );
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.gameButtonLeft2,
                    includeRepeats: false,
                  ): () {
                    onKindOfGameUnitSelection(
                      orientation: GameUnitOrientation.horizontal,
                    );
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
                  focusNode: theFocusNode,
                  child: _SelectorForKindOfGameUnit(
                    onKindOfGameUnitSelection,
                    _selectedSize,
                    _selectedOrientation,
                    blockedSizes,
                  ),
                ),
              ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class _SelectorForKindOfGameUnit extends StatelessWidget {
  final void Function({GameUnitSize? size, GameUnitOrientation? orientation})
      onSelect;
  final GameUnitSize currentSize;
  final GameUnitOrientation currentOrientation;
  final Set<GameUnitSize> blockedSizes;

  const _SelectorForKindOfGameUnit(this.onSelect, this.currentSize,
      this.currentOrientation, this.blockedSizes,
      {super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    const double draggableSize = 60;
    const double draggableOffset = 85;
    const double originFactorForPaint = 2;
    final double screenHeight = MediaQuery.of(
      context,
    ).size.height;
    final double heightScale = screenHeight * screenHeight / 530000 + 0.2;
    final double screenWidth = MediaQuery.of(
      context,
    ).size.width;
    final double widthScale = screenWidth / 380 - 0.03;
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 18,
        ),
        height: 100,
        width: 600,
        color: Theme.of(
          context,
        ).bottomAppBarTheme.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Draggable(
                data: currentOrientation == GameUnitOrientation.horizontal
                    ? AppLocalizations.of(
                        context,
                      )!
                        .thisIsASmallHorizontalPiece
                    : AppLocalizations.of(
                        context,
                      )!
                        .thisIsASmallVerticalPiece,
                dragAnchorStrategy: (
                  draggable,
                  context,
                  offset,
                ) {
                  return Offset.zero;
                },
                onDragStarted: () {
                  onSelect(
                    size: GameUnitSize.small,
                  );
                },
                feedbackOffset: screenHeight / 6 < screenWidth / 5
                    ? currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            heightScale * -draggableOffset * 1.3 / 2.5,
                            0,
                          )
                        : Offset(
                            0,
                            heightScale * -draggableOffset * 1.3 / 2.5,
                          )
                    : currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            widthScale * -draggableOffset * 1.3 / 2.5,
                            0,
                          )
                        : Offset(
                            0,
                            widthScale * -draggableOffset * 1.3 / 2.5,
                          ),
                feedback: Transform.scale(
                  origin: currentOrientation == GameUnitOrientation.horizontal
                      ? const Offset(
                          0,
                          -draggableSize * 2 / originFactorForPaint,
                        )
                      : const Offset(
                          -draggableSize * 2 / originFactorForPaint,
                          0,
                        ),
                  scale: screenHeight / 6 < screenWidth / 5
                      ? heightScale
                      : widthScale,
                  child: currentOrientation == GameUnitOrientation.horizontal
                      ? SizedBox(
                          width: draggableSize * 2,
                          height: draggableSize * 2,
                          child: GameUnitSmall.renderHorizontalUnit,
                        )
                      : SizedBox(
                          height: draggableSize * 2,
                          width: draggableSize * 2,
                          child: GameUnitSmall.renderVerticalUnit,
                        ),
                ),
                child: TextButton(
                  onPressed: () {
                    onSelect(
                      size: GameUnitSize.small,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          5.0,
                        ),
                      ),
                      color: blockedSizes.contains(
                        GameUnitSize.small,
                      )
                          ? Colors.black
                          : currentSize == GameUnitSize.small
                              ? Theme.of(
                                  context,
                                ).errorColor
                              : Theme.of(
                                  context,
                                ).cardColor,
                    ),
                    margin: const EdgeInsets.all(
                      1,
                    ),
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'S',
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .selectASmallUnit,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
            Expanded(
              child: Draggable(
                data: currentOrientation == GameUnitOrientation.horizontal
                    ? AppLocalizations.of(
                        context,
                      )!
                        .thisIsAMediumHorizontalPiece
                    : AppLocalizations.of(
                        context,
                      )!
                        .thisIsAMediumVerticalPiece,
                dragAnchorStrategy: (
                  draggable,
                  context,
                  offset,
                ) {
                  return Offset.zero;
                },
                onDragStarted: () {
                  onSelect(
                    size: GameUnitSize.medium,
                  );
                },
                feedbackOffset: screenHeight / 6 < screenWidth / 5
                    ? currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            heightScale * -draggableOffset * 2 / 2.3,
                            0,
                          )
                        : Offset(
                            0,
                            heightScale * -draggableOffset * 2 / 2.3,
                          )
                    : currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            widthScale * -draggableOffset * 2 / 2.3,
                            0,
                          )
                        : Offset(
                            0,
                            widthScale * -draggableOffset * 2 / 2.3,
                          ),
                feedback: Transform.scale(
                  origin: currentOrientation == GameUnitOrientation.horizontal
                      ? const Offset(
                          -draggableSize,
                          -draggableSize * 3 / originFactorForPaint,
                        )
                      : const Offset(
                          -draggableSize * 3 / originFactorForPaint,
                          -draggableSize,
                        ),
                  scale: screenHeight / 6 < screenWidth / 5
                      ? heightScale
                      : widthScale,
                  child: currentOrientation == GameUnitOrientation.horizontal
                      ? SizedBox(
                          width: draggableSize * 3,
                          height: draggableSize * 3,
                          child: GameUnitMedium.renderHorizontalUnit,
                        )
                      : SizedBox(
                          height: draggableSize * 3,
                          width: draggableSize * 3,
                          child: GameUnitMedium.renderVerticalUnit,
                        ),
                ),
                child: TextButton(
                  onPressed: () {
                    onSelect(
                      size: GameUnitSize.medium,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          5.0,
                        ),
                      ),
                      color: blockedSizes.contains(
                        GameUnitSize.medium,
                      )
                          ? Colors.black
                          : currentSize == GameUnitSize.medium
                              ? Theme.of(
                                  context,
                                ).errorColor
                              : Theme.of(
                                  context,
                                ).cardColor,
                    ),
                    margin: const EdgeInsets.all(
                      1,
                    ),
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'M',
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .selectAMediumUnit,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
            Expanded(
              child: Draggable(
                data: currentOrientation == GameUnitOrientation.horizontal
                    ? AppLocalizations.of(context)!.thisIsALargeHorizontalPiece
                    : AppLocalizations.of(context)!.thisIsALargeVerticalPiece,
                dragAnchorStrategy: (
                  draggable,
                  context,
                  offset,
                ) {
                  return Offset.zero;
                },
                onDragStarted: () {
                  onSelect(
                    size: GameUnitSize.large,
                  );
                },
                feedbackOffset: screenHeight / 6 < screenWidth / 5
                    ? currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            heightScale * -draggableOffset * 3 / 2.5,
                            0,
                          )
                        : Offset(
                            0,
                            heightScale * -draggableOffset * 3 / 2.5,
                          )
                    : currentOrientation == GameUnitOrientation.horizontal
                        ? Offset(
                            widthScale * -draggableOffset * 3 / 2.5,
                            0,
                          )
                        : Offset(
                            0,
                            widthScale * -draggableOffset * 3 / 2.5,
                          ),
                feedback: Transform.scale(
                  origin: currentOrientation == GameUnitOrientation.horizontal
                      ? const Offset(
                          -draggableSize,
                          -draggableSize * 4 / originFactorForPaint,
                        )
                      : const Offset(
                          -draggableSize * 4 / originFactorForPaint,
                          -draggableSize,
                        ),
                  scale: screenHeight / 6 < screenWidth / 5
                      ? heightScale
                      : widthScale + 0.015,
                  child: currentOrientation == GameUnitOrientation.horizontal
                      ? SizedBox(
                          width: draggableSize * 4,
                          height: draggableSize * 4,
                          child: GameUnitLarge.renderHorizontalUnit,
                        )
                      : SizedBox(
                          height: draggableSize * 4,
                          width: draggableSize * 4,
                          child: GameUnitLarge.renderVerticalUnit,
                        ),
                ),
                child: TextButton(
                  onPressed: () {
                    onSelect(
                      size: GameUnitSize.large,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          5.0,
                        ),
                      ),
                      color: blockedSizes.contains(
                        GameUnitSize.large,
                      )
                          ? Colors.black
                          : currentSize == GameUnitSize.large
                              ? Theme.of(
                                  context,
                                ).errorColor
                              : Theme.of(
                                  context,
                                ).cardColor,
                    ),
                    margin: const EdgeInsets.all(
                      1,
                    ),
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'L',
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .selectALargeUnit,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
            const SizedBox(
              width: 25.0,
            ),
            Expanded(
              child: Draggable(
                data: switch (currentSize) {
                  GameUnitSize.small => AppLocalizations.of(
                      context,
                    )!
                        .thisIsASmallVerticalPiece,
                  GameUnitSize.medium => AppLocalizations.of(
                      context,
                    )!
                        .thisIsAMediumVerticalPiece,
                  GameUnitSize.large => AppLocalizations.of(
                      context,
                    )!
                        .thisIsALargeVerticalPiece,
                },
                dragAnchorStrategy: (
                  draggable,
                  context,
                  offset,
                ) {
                  return Offset.zero;
                },
                onDragStarted: () {
                  onSelect(
                    orientation: GameUnitOrientation.vertical,
                  );
                },
                feedbackOffset: screenHeight / 6 < screenWidth / 5
                    ? switch (currentSize) {
                        GameUnitSize.small => Offset(
                            0,
                            heightScale * -draggableOffset * 1.3 / 2.5,
                          ),
                        GameUnitSize.medium => Offset(
                            0,
                            heightScale * -draggableOffset * 2 / 2.3,
                          ),
                        GameUnitSize.large => Offset(
                            0,
                            heightScale * -draggableOffset * 3 / 2.5,
                          ),
                      }
                    : switch (currentSize) {
                        GameUnitSize.small => Offset(
                            0,
                            widthScale * -draggableOffset * 1.3 / 2.5,
                          ),
                        GameUnitSize.medium => Offset(
                            0,
                            widthScale * -draggableOffset * 2 / 2.3,
                          ),
                        GameUnitSize.large => Offset(
                            0,
                            widthScale * -draggableOffset * 3 / 2.5,
                          ),
                      },
                feedback: Transform.scale(
                  origin: switch (currentSize) {
                    GameUnitSize.small => const Offset(
                        -draggableSize * 2 / originFactorForPaint,
                        -draggableSize,
                      ),
                    GameUnitSize.medium => const Offset(
                        -draggableSize * 3 / originFactorForPaint,
                        -draggableSize,
                      ),
                    GameUnitSize.large => const Offset(
                        -draggableSize * 4 / originFactorForPaint,
                        -draggableSize,
                      ),
                  },
                  scale: switch (currentSize) {
                    GameUnitSize.large => screenHeight / 6 < screenWidth / 5
                        ? heightScale
                        : widthScale + 0.015,
                    _ => screenHeight / 6 < screenWidth / 5
                        ? heightScale
                        : widthScale
                  },
                  child: switch (currentSize) {
                    GameUnitSize.small => SizedBox(
                        width: draggableSize * 2,
                        height: draggableSize * 2,
                        child: GameUnitSmall.renderVerticalUnit,
                      ),
                    GameUnitSize.medium => SizedBox(
                        width: draggableSize * 3,
                        height: draggableSize * 3,
                        child: GameUnitMedium.renderVerticalUnit,
                      ),
                    GameUnitSize.large => SizedBox(
                        width: draggableSize * 4,
                        height: draggableSize * 4,
                        child: GameUnitLarge.renderVerticalUnit,
                      ),
                  },
                ),
                child: TextButton(
                  onPressed: () {
                    onSelect(
                      orientation: GameUnitOrientation.vertical,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          5.0,
                        ),
                      ),
                      color: currentOrientation == GameUnitOrientation.vertical
                          ? Theme.of(context).errorColor
                          : Theme.of(context).cardColor,
                    ),
                    margin: const EdgeInsets.all(
                      1,
                    ),
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'V',
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .selectTheVerticalOrientation,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
            Expanded(
              child: Draggable(
                data: switch (currentSize) {
                  GameUnitSize.small => AppLocalizations.of(
                      context,
                    )!
                        .thisIsASmallHorizontalPiece,
                  GameUnitSize.medium => AppLocalizations.of(
                      context,
                    )!
                        .thisIsAMediumHorizontalPiece,
                  GameUnitSize.large => AppLocalizations.of(
                      context,
                    )!
                        .thisIsALargeHorizontalPiece,
                },
                dragAnchorStrategy: (
                  draggable,
                  context,
                  offset,
                ) {
                  return Offset.zero;
                },
                onDragStarted: () {
                  onSelect(
                    orientation: GameUnitOrientation.horizontal,
                  );
                },
                feedbackOffset: screenHeight / 6 < screenWidth / 5
                    ? switch (currentSize) {
                        GameUnitSize.small => Offset(
                            heightScale * -draggableOffset * 1.3 / 2.5,
                            0,
                          ),
                        GameUnitSize.medium => Offset(
                            heightScale * -draggableOffset * 2 / 2.3,
                            0,
                          ),
                        GameUnitSize.large => Offset(
                            heightScale * -draggableOffset * 3 / 2.5,
                            0,
                          ),
                      }
                    : switch (currentSize) {
                        GameUnitSize.small => Offset(
                            widthScale * -draggableOffset * 1.3 / 2.5,
                            0,
                          ),
                        GameUnitSize.medium => Offset(
                            widthScale * -draggableOffset * 2 / 2.3,
                            0,
                          ),
                        GameUnitSize.large => Offset(
                            widthScale * -draggableOffset * 3 / 2.5,
                            0,
                          ),
                      },
                feedback: Transform.scale(
                  origin: switch (currentSize) {
                    GameUnitSize.small => const Offset(
                        -draggableSize,
                        -draggableSize * 2 / originFactorForPaint,
                      ),
                    GameUnitSize.medium => const Offset(
                        -draggableSize,
                        -draggableSize * 3 / originFactorForPaint,
                      ),
                    GameUnitSize.large => const Offset(
                        -draggableSize,
                        -draggableSize * 4 / originFactorForPaint,
                      ),
                  },
                  scale: screenHeight / 6 < screenWidth / 5
                      ? heightScale
                      : widthScale + 0.015,
                  child: switch (currentSize) {
                    GameUnitSize.small => SizedBox(
                        width: draggableSize * 2,
                        height: draggableSize * 2,
                        child: GameUnitSmall.renderHorizontalUnit,
                      ),
                    GameUnitSize.medium => SizedBox(
                        width: draggableSize * 3,
                        height: draggableSize * 3,
                        child: GameUnitMedium.renderHorizontalUnit,
                      ),
                    GameUnitSize.large => SizedBox(
                        width: draggableSize * 4,
                        height: draggableSize * 4,
                        child: GameUnitLarge.renderHorizontalUnit,
                      ),
                  },
                ),
                child: TextButton(
                  onPressed: () {
                    onSelect(
                      orientation: GameUnitOrientation.horizontal,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          5.0,
                        ),
                      ),
                      color:
                          currentOrientation == GameUnitOrientation.horizontal
                              ? Theme.of(
                                  context,
                                ).errorColor
                              : Theme.of(
                                  context,
                                ).cardColor,
                    ),
                    margin: const EdgeInsets.all(
                      1,
                    ),
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'H',
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .selectTheHorizontalOrientation,
                        style: Theme.of(
                          context,
                        ).textTheme.headline6?.copyWith(
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
          ],
        ),
      ),
    );
  }
}
