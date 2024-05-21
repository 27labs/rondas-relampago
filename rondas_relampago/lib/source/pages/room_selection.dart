import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

class OnlineRoomSelectionScreen extends StatelessWidget {
  OnlineRoomSelectionScreen({super.key});

  void _joinOnlineRoom(BuildContext context) {
    final roomId = _roomIdInputController.text;

    debugPrint(roomId);

    if (UuidValidation.isValidUUID(
      fromString: roomId,
      validationMode: ValidationMode.strictRFC4122,
    )) {
      context.pushReplacementNamed(
        RouteNames.onlineTwoPlayersJoin.name,
        pathParameters: {
          'roomId': roomId,
        },
      );
    }

    if (roomId.isEmpty) {
      context.pushReplacementNamed(
        RouteNames.onlineTwoPlayers.name,
        // pathParameters: {
        //   'roomId': null.toString(),
        // },
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onPrimaryContainer,
        icon: Icon(
          Icons.cancel_outlined,
          color: Theme.of(
            context,
          ).colorScheme.primary,
        ),
        content: Text(
          AppLocalizations.of(
            context,
          )!
              .invalidRoomIdAlertText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  final _roomIdInputController = TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onSecondaryContainer,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_new_sharp,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                height: 450,
                width: 350,
                child: AlertDialog(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  titleTextStyle: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(
                        color: Theme.of(
                          context,
                        ).primaryColor,
                      ),
                  contentTextStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(
                          context,
                        ).primaryColor,
                      ),
                  title: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .roomSelectionTitleText,
                  ),
                  content: TextField(
                    autofocus: true,
                    autocorrect: false,
                    controller: _roomIdInputController,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      helperMaxLines: 2,
                      helperText: AppLocalizations.of(
                        context,
                      )!
                          .mayLeaveEmptyText,
                      helperStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary,
                      ),
                    ),
                    onSubmitted: (
                      _,
                    ) =>
                        _joinOnlineRoom(
                      context,
                    ),
                  ),
                  icon: const Icon(
                    Icons.check,
                  ),
                  iconColor: Theme.of(
                    context,
                  ).primaryColor,
                  actions: [
                    FilledButton(
                      onPressed: () => _joinOnlineRoom(
                        context,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .submitRoomIdText,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium!.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
