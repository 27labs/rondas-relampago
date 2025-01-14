import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';
// import 'package:provider/provider.dart';
// import 'package:rondas_relampago/source/models/ads/ads.dart';

// Owner
import 'package:rondas_relampago/source/models/themes/themes.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/pages/utils/screen_title.dart';
// import 'package:rondas_relampago/source/storage/storage.dart';

class TutorialForCasual extends StatelessWidget {
  final GameAudioSettings Function() onVolumeToggled;
  final RGBThemes activeTheme;
  final bool? multiplayer;
  const TutorialForCasual({
    required this.onVolumeToggled,
    required this.activeTheme,
    this.multiplayer,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const gap = SizedBox(
      height: 30,
    );
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.onSecondaryContainer,
      body: Column(
        children: [
          ScreenTitle(
            AppLocalizations.of(
              context,
            )!
                .tutorialTitle,
            onVolumeToggled: onVolumeToggled,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.inversePrimary,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    10.0,
                  ),
                ),
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
              margin: const EdgeInsets.all(
                10,
              ),
              padding: const EdgeInsets.all(
                20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial0,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                    gap,
                    Center(
                      child: Image.asset(
                        'assets/gifs/3U.gif',
                      ),
                    ),
                    gap,
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial1,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                    gap,
                    Center(
                      child: Image.asset(
                        'assets/gifs/vertical.gif',
                      ),
                    ),
                    gap,
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial2,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                    gap,
                    Center(
                      child: Image.asset(
                        'assets/gifs/gnd.gif',
                      ),
                    ),
                    gap,
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial3,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                    gap,
                    Center(
                      child: Image.asset(
                        AppLocalizations.of(
                          context,
                        )!
                            .markerImage,
                      ),
                    ),
                    gap,
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial4,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                    gap,
                    Center(
                      child: Image.asset(
                        AppLocalizations.of(
                          context,
                        )!
                            .scrollImage,
                      ),
                    ),
                    gap,
                    Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .tutorial5,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.enter,
                includeRepeats: false,
              ): () => context.pushReplacementNamed(
                    RouteNames.singlePlayer.name,
                  ),
              const SingleActivator(
                LogicalKeyboardKey.numpadEnter,
                includeRepeats: false,
              ): () => context.pushReplacementNamed(
                    RouteNames.singlePlayer.name,
                  ),
            },
            child: Focus(
              autofocus: true,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                onPressed: () => context.pushReplacementNamed(
                  switch (multiplayer) {
                    false => RouteNames.singlePlayer.name,
                    true => RouteNames.twoPlayers.name,
                    null => RouteNames.onlineRoomSelection.name
                  },
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        5.0,
                      ),
                    ),
                    color: activeTheme.seedColor,
                  ),
                  margin: const EdgeInsets.fromLTRB(
                    0,
                    10,
                    0,
                    35,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
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
                            ).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
